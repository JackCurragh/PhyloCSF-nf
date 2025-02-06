

process PREPARE_FEATURES{

    input:
    val chromosome
    path full_bed
    
    output:
    tuple val(chromosome), path("*.bed")
    
    script:
    """
    bed12_to_individual_bed6.py ${full_bed} --chromosome ${chromosome}
    """
}
