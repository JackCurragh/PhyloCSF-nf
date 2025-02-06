workflow PROCESS_MAFS {
    take:
    maf_files
    feature_specific_bed12

    main:

    // add logic to get the relevant maf for each feature from the maf_files channel. 
    // channel will need to be collected first 
    // read the feature specific bed to get the chr from first column first row. Make sure no header. 
    // Add warning about chr mismatch between maf and bed12 file.
    extracted_regions = EXTRACT_REGIONS(maf_files, feature_specific_bed12)
    // merged_maf = MERGE_MAFS(extracted_regions.collect())

    emit:
    extracted_regions
}

process EXTRACT_REGIONS {

    input:
    path maf_file
    path feature_specific_bed12

    output:
    path "extracted_*.maf"

    script:
    """
    mafExtractor --maf ${maf_file} --bed ${feature_specific_bed12} > ${feature_specific_bed12.basename}.extracted.maf
    """
}

// process MAF_TO_FASTA {

// }