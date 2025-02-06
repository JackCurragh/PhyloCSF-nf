process INDEX_MAFS {
    publishDir "${params.outdir}/MAFs", mode: 'copy'

    input:
    tuple val(chromosome), path(downloaded_maf)
    path chrom_sizes
    
    output:
    tuple val(chromosome), path(downloaded_maf), path("${chromosome}.maf.bb")
    
    script:
    """
    mafIndex ${downloaded_maf} ${chromosome}.maf.bb -chromSizes=${chrom_sizes}
    """
}