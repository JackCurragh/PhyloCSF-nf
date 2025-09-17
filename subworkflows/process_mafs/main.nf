

include { EXTRACT_REGIONS } from '../../modules/extract_regions.nf'
include { MAF_TO_FASTA } from '../../modules/maf_to_fasta.nf'

workflow PROCESS_MAFS {
    take:
    matched_beds_and_mafs

    main:

    extracted_regions = EXTRACT_REGIONS(matched_beds_and_mafs).groupTuple()

    merged_alignments = MAF_TO_FASTA(extracted_regions, params.species_map)

    emit:
    merged_alignments.merged_fastas 
}
