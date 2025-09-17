

process PHYLOCSF {
    publishDir "${params.outdir}/phylocsf", mode: 'copy'

    input:
    path merged_fasta

    output:
    path "*phylocsf_results.txt"

    script:
    """
    PhyloCSF 120mammals --removeRefGaps $merged_fasta > ${merged_fasta.simpleName}_phylocsf_results.txt

    """
}