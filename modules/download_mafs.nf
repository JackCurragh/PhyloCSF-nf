process DOWNLOAD_MAFS {
    publishDir "${params.outdir}/MAFs", mode: 'copy'

    input:
    val(chromosome)
    
    output:
    tuple val(chromosome), path("${chromosome}.maf")
    
    script:
    """
    wget -O ${chromosome}.maf.gz ${params.maf_url_base}/${chromosome}.maf.gz --quiet
    gzip -d ${chromosome}.maf.gz
    """
}