
include { PHYLOCSF } from '../../modules/phylocsf.nf'

workflow RUN_PHYLOCSF {
    take:
    bed12_file

    main:
    phylocsf_results = PHYLOCSF(bed12_file)

    emit:
    maf_files = phylocsf_results
}