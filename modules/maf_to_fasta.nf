
process MAF_TO_FASTA {
    publishDir "${params.outdir}/extracted_mafs", mode: 'copy'

    input:
    tuple val(chrom), path(extracted_regions)
    path(species_map)
    path(bed_files)

    output:
    path "fasta/*.fasta", emit: merged_fastas
    path "merged_maf/*.maf", emit: merged_mafs

    script:
    """
    # Extract strand information from BED files
    extract_strand_info.py "*.bed" strand_info.tsv

    # Run merge_alignments with strand information
    merge_alignments.py --input_pattern "*.maf" --output_dir . --species_map_file ${species_map} --strand_info_file strand_info.tsv
    """
}
