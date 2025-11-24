
process EXTRACT_REGIONS {
    publishDir "${params.outdir}/extracted_mafs", mode: 'copy'

    // errorStrategy 'ignore'

    input:
    tuple val(chrom), path(feature_specific_bed12), path(maf_file), path(bb_file)

    output:
    tuple val("${feature_specific_bed12.simpleName.replaceAll(/_exon\d+$/, '')}"), path("*.maf"), path(feature_specific_bed12), emit: extracted_regions

    script:
    """
    mafExtract $bb_file -outDir ${feature_specific_bed12.baseName} -regionList=${feature_specific_bed12}
    mv ${feature_specific_bed12.baseName}/*.maf .
    """
}
