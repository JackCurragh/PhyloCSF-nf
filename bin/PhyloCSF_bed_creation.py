#!/usr/bin/env python3
import sys
import pandas as pd
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description='Convert PhyloCSF scores and BED12 to BED6 format')
    parser.add_argument('-p', '--phylocsf', 
                        required=True,
                        help='Input file containing PhyloCSF scores')
    parser.add_argument('-b', '--bed12',
                        required=True, 
                        help='Input BED12 file')
    parser.add_argument('-o', '--output',
                        required=True,
                        help='Output BED6 file')
    return parser.parse_args()

def convert_to_bed6(phylocsf_file, bed12_file, output_file):
    # Read PhyloCSF scores into a dictionary
    scores = {}
    with open(phylocsf_file) as f:
        for line in f:
            parts = line.strip().split()
            transcript = parts[0]

            # Check if this is an exception line
            if len(parts) > 2 and parts[1] == "exception":
                continue  # Skip exception entries
                
            # Check if this is a normal score line
            if len(parts) >= 3 and parts[1] == "score(decibans)":
                try:
                    score = float(parts[2])
                except ValueError:
                    continue  # Skip if score conversion fails
            else:
                continue  # Skip malformed lines
            # Remove .fasta extension if present
            transcript = transcript.replace('.fasta', '')
            scores[transcript] = float(score)
    
    # Read BED12 file
    bed_columns = ['chrom', 'start', 'end', 'name', 'score', 'strand', 
                  'thickStart', 'thickEnd', 'itemRgb', 'blockCount', 
                  'blockSizes', 'blockStarts']
    
    bed_df = pd.read_csv(bed12_file, sep='\t', names=bed_columns)
    
    # Create BED6 output
    with open(output_file, 'w') as out:
        for _, row in bed_df.iterrows():
            transcript_id = row['name']
            if transcript_id in scores:
                bed6_line = f"{row['chrom']}\t{row['start']}\t{row['end']}\t"
                bed6_line += f"{transcript_id}\t{scores[transcript_id]}\t{row['strand']}\n"
                out.write(bed6_line)

def main():
    args = parse_args()
    convert_to_bed6(args.phylocsf, args.bed12, args.output)

if __name__ == "__main__":
    main()