process FORMAT_RESULTS {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path phylocsf_results
    path feature_bed12

    output:
    path "*.bed6"

    script:
    """
    cat *.txt > combined_results.txt 

    PhyloCSF_bed_creation.py -p combined_results.txt -b ${feature_bed12} -o ${feature_bed12.baseName}.bed6
    """
}