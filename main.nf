#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { DOWNLOAD_MAFS_AND_INDEX } from './subworkflows/download_mafs'
include { PROCESS_MAFS } from './subworkflows/process_mafs'
include { RUN_PHYLOCSF } from './subworkflows/run_phylocsf'
include { PREPARE_FEATURES } from './modules/prepare_features'


nextflow.enable.dsl = 2

// Define a process to download and index MAF files if not provided


// Define a process to use existing MAF and index files
process USE_EXISTING_MAF {
    input:
    tuple val(chromosome), path(maf), path(bb)
    
    output:
    tuple val(chromosome), path(maf), path(bb)
    
    script:
    """
    echo "Using existing MAF file for ${chromosome}: ${maf}"
    echo "Using existing MAF index for ${chromosome}: ${bb}"
    """
}

workflow {
    chromosomes = Channel
                    .fromPath(params.chrom_sizes)
                    .splitCsv(sep: '\t', header: ['chrom', 'size'])
                    .map { row -> row.chrom }
    if (params.maf_dir) {
        // Use existing MAF files
        Channel
            .fromFilePairs("${params.maf_dir}/${params.maf_pattern}", size: -1)
            .map { chr, files -> 
                def maf = files.find { it.name.endsWith('.maf') }
                def bb = files.find { it.name.endsWith('.maf.bb') }
                if (!maf || !bb) {
                    error "Missing MAF or index file for chromosome ${chr}"
                }
                tuple(chr, maf, bb)
            }
            .set { maf_files_ch }
        
        USE_EXISTING_MAF(maf_files_ch)
        maf_ch = USE_EXISTING_MAF.out
    } else {
        if (!params.chrom_sizes) {
           error "Chromosome sizes file must be provided using --chrom_sizes parameter"
        }
        // Download and index MAF files

        maf_ch = DOWNLOAD_MAFS_AND_INDEX(chromosomes, params.chrom_sizes)
    }

    // Use maf_ch in your subsequent processes
    maf_ch.view { chromosome, maf, bb -> 
        "Chromosome: $chromosome, MAF: ${maf.name}, Index: ${bb.name}"
    }

    feature_specific_bed12 = PREPARE_FEATURES(chromosomes, params.feature_bed12)
    feature_specific_bed12.view { it }

    // Subworkflow to process MAFs (extract regions and merge)
    PROCESS_MAFS(maf_ch, feature_specific_bed12)

    // Run PhyloCSF
    RUN_PHYLOCSF(PROCESS_MAFS.out)
}

// Output configuration
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}

// Function to validate the input MAF and index files
def validateMafFiles(chr, maf, bb) {
    if (!maf.exists()) {
        error "MAF file for chromosome ${chr} does not exist: ${maf}"
    }
    if (!bb.exists()) {
        error "MAF index file for chromosome ${chr} does not exist: ${bb}"
    }
    if (!maf.name.endsWith('.maf')) {
        error "Invalid MAF file extension for chromosome ${chr}: ${maf}"
    }
    if (!bb.name.endsWith('.maf.bb')) {
        error "Invalid MAF index file extension for chromosome ${chr}: ${bb}"
    }
}