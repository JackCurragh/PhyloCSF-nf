include { DOWNLOAD_MAFS } from '../../modules/download_mafs.nf'
include { INDEX_MAFS } from '../../modules/index_mafs.nf'


workflow DOWNLOAD_MAFS_AND_INDEX {
    take:
    chromosomes
    chrom_sizes

    main:
    // Add your MAF download logic here
    // This is a placeholder process
    downloaded_mafs = DOWNLOAD_MAFS(chromosomes)
    indexed_mafs = INDEX_MAFS(downloaded_mafs, chrom_sizes)

    emit:
    maf_files = indexed_mafs
}

