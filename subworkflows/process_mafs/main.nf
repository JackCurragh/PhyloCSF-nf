

include { EXTRACT_REGIONS } from '../../modules/extract_regions.nf'
include { MAF_TO_FASTA } from '../../modules/maf_to_fasta.nf'

workflow PROCESS_MAFS {
    take:
    matched_beds_and_mafs

    main:

    extracted_regions = EXTRACT_REGIONS(matched_beds_and_mafs)

    // Group MAF files by transcript ID
    grouped_mafs = extracted_regions.map { transcript_id, maf, bed ->
        [transcript_id, maf]
    }.groupTuple()

    // Collect all BED files for strand extraction
    bed_files = extracted_regions.map { transcript_id, maf, bed ->
        bed
    }.collect()

    merged_alignments = MAF_TO_FASTA(grouped_mafs, params.species_map, bed_files)

    emit:
    merged_alignments.merged_fastas
}
