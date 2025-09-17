#!/usr/bin/env python3


import glob
import os
import argparse
import subprocess
from collections import defaultdict
from Bio.Seq import Seq
from Bio import SeqIO, AlignIO

def merge_maf_files(input_pattern, output_dir):
    """
    Merge MAF files for the same transcript.
    
    Args:
        input_pattern: Glob pattern to match MAF files
        output_dir: Directory to save merged MAF files
    """
    transcript_files = defaultdict(list)
    
    # Group files by transcript ID
    for path in glob.glob(input_pattern):
        # Assuming filename format is transcript_id_exon.maf
        # Modify this split logic based on your actual filename format
        transcript_id = '_'.join(path.split('/')[-1].split('.maf')[0].split('_')[:-1])
        transcript_files[transcript_id].append(path)
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Merge files for each transcript
    for transcript_id, files in transcript_files.items():
        # Sort files by exon number if present in filename
        sorted_files = sorted(files, key=lambda x: int(x.split('/')[-1].split('.maf')[0].split('_exon')[-1]))
        output_path = os.path.join(output_dir, f'{transcript_id}.maf')
        
        # Concatenate files
        cmd = f'cat {" ".join(sorted_files)} > {output_path}'
        subprocess.call(cmd, shell=True)
        print(f'Merged {len(files)} files for transcript {transcript_id}')

def stitch_blocks(input_maf_path, output_fasta_path, strand='+'):
    """
    Convert MAF to FASTA by stitching alignment blocks.
    
    Args:
        input_maf_path: Path to input MAF file
        output_fasta_path: Path to output FASTA file
        strand: Strand orientation ('+' or '-')
    """
    blocks = {}
    all_species = set()
    
    # Parse MAF file
    for i, alignment in enumerate(AlignIO.parse(input_maf_path, "maf")):
        blocks[i] = {}
        for seqrec in alignment:
            blocks[i][seqrec.id] = str(seqrec.seq)
            all_species.add(seqrec.id)
    
    # Initialize empty sequences for all species
    stitched_seqs = defaultdict(str)
    
    # Stitch blocks
    for block_idx in range(len(blocks)):
        block = blocks[block_idx]
        block_length = len(next(iter(block.values())))
        
        for species in all_species:
            if species in block:
                stitched_seqs[species] += block[species]
            else:
                stitched_seqs[species] += '-' * block_length
    
    # Process sequences based on strand
    if strand == '-':
        for species in stitched_seqs:
            stitched_seqs[species] = str(Seq(stitched_seqs[species]).reverse_complement())
    
    # Write FASTA output
    os.makedirs(os.path.dirname(output_fasta_path), exist_ok=True)
    with open(output_fasta_path, 'w') as outf:
        for species, seq in stitched_seqs.items():
            # Clean up species name if needed
            clean_species = ''.join(filter(str.isalpha, species.split('.')[0]))
            outf.write(f'>{clean_species}\n{seq}\n')

def convert_species_names(input_fasta, output_fasta, species_map):
    """
    Convert species identifiers to readable names in FASTA file.
    
    Args:
        input_fasta: Path to input FASTA file
        output_fasta: Path to output FASTA file
        species_map: Dictionary mapping species IDs to readable names
    """
    with open(output_fasta, 'w') as outf:
        for record in SeqIO.parse(input_fasta, "fasta"):
            species_id = record.id
            # Clean up species ID (remove non-alphabetic characters)
            clean_species = ''.join(filter(str.isalpha, species_id.split('.')[0]))
            # Get readable name or keep original if not in mapping
            readable_name = species_map.get(clean_species, clean_species)
            outf.write(f'>{readable_name}\n{str(record.seq)}\n')

def main():
    parser = argparse.ArgumentParser(description='Process MAF files to FASTA alignments')
    parser.add_argument('--input_pattern', required=True, help='Glob pattern for input MAF files (e.g., "path/to/files/*.maf")')
    parser.add_argument('--output_dir', required=True, help='Output directory')
    parser.add_argument('--strand_info_file', help='Optional: TSV file with transcript_id\\tstrand information')
    parser.add_argument('--species_map_file', help='Optional: TSV file with species_id\\treadable_name mapping')
    args = parser.parse_args()
    
    # Create output directories
    merged_dir = os.path.join(args.output_dir, 'merged_maf')
    fasta_dir = os.path.join(args.output_dir, 'fasta')
    os.makedirs(merged_dir, exist_ok=True)
    os.makedirs(fasta_dir, exist_ok=True)
    
    # Load strand information if provided
    strand_info = {}
    if args.strand_info_file:
        with open(args.strand_info_file) as f:
            for line in f:
                transcript_id, strand = line.strip().split('\t')
                strand_info[transcript_id] = strand
    
    # Step 1: Merge MAF files
    print("Merging MAF files...")
    merge_maf_files(args.input_pattern, merged_dir)
    
    # Load species mapping if provided
    species_map = {}
    if args.species_map_file:
        with open(args.species_map_file) as f:
            for line in f:
                species_id, readable_name = line.strip().split('\t')
                species_map[species_id] = readable_name

    # Step 2: Convert to FASTA
    print("Converting to FASTA...")
    fasta_intermediate = os.path.join(args.output_dir, 'fasta_intermediate')
    os.makedirs(fasta_intermediate, exist_ok=True)
    
    for maf_file in glob.glob(os.path.join(merged_dir, '*.maf')):
        transcript_id = os.path.basename(maf_file).replace('.maf', '')
        temp_fasta = os.path.join(fasta_intermediate, f'{transcript_id}.fasta')
        final_fasta = os.path.join(fasta_dir, f'{transcript_id}.fasta')
        
        # Get strand information (default to '+' if not provided)
        strand = strand_info.get(transcript_id, '+')
        
        # Convert MAF to FASTA
        stitch_blocks(maf_file, temp_fasta, strand)
        
        # Convert species names if mapping provided
        if species_map:
            convert_species_names(temp_fasta, final_fasta, species_map)
        else:
            # If no mapping provided, just copy the file
            subprocess.run(['cp', temp_fasta, final_fasta])
            
        print(f'Processed {transcript_id}')

if __name__ == '__main__':
    main()