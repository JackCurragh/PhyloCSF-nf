
process MAF_TO_FASTA {
    publishDir "${params.outdir}/extracted_mafs", mode: 'copy'

    input:
    tuple val(chrom), path(extracted_regions)
    path(species_map)

    output:
    path "fasta/*.fasta", emit: merged_fastas
    path "merged_maf/*.maf", emit: merged_mafs

    script:
    """
    merge_alignments.py --input_pattern "*.maf" --output_dir . --species_map_file ${species_map}
    """
}
