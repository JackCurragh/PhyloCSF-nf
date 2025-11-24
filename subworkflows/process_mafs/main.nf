

include { EXTRACT_REGIONS } from '../../modules/extract_regions.nf'
include { MAF_TO_FASTA } from '../../modules/maf_to_fasta.nf'

workflow PROCESS_MAFS {
    take:
    matched_beds_and_mafs

    main:

    extracted_regions = EXTRACT_REGIONS(matched_beds_and_mafs)

    // Group both MAF files and BED files by transcript ID
    grouped_data = extracted_regions.map { transcript_id, maf, bed ->
        [transcript_id, maf, bed]
    }.groupTuple()

    // Separate grouped MAFs and BEDs for the process
    grouped_with_beds = grouped_data.map { transcript_id, mafs, beds ->
        [transcript_id, mafs, beds]
    }

    merged_alignments = MAF_TO_FASTA(grouped_with_beds, params.species_map)

    emit:
    merged_alignments.merged_fastas
}
