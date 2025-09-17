#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { DOWNLOAD_MAFS_AND_INDEX } from './subworkflows/download_mafs'
include { PROCESS_MAFS } from './subworkflows/process_mafs'
include { RUN_PHYLOCSF } from './subworkflows/run_phylocsf'
include { PREPARE_FEATURES } from './modules/prepare_features'
include { FORMAT_RESULTS } from './modules/format_results'

nextflow.enable.dsl = 2

workflow {
    chromosomes = Channel
                    .fromPath(params.chrom_sizes)
                    .splitCsv(sep: '\t', header: ['chrom', 'size'])
                    .map { row -> row.chrom }

    if (params.maf_dir) {
        // Use existing MAF files
        maf_ch = chromosomes
            .map { chrom -> 
                def bb = file("${params.maf_dir}/${chrom}${params.bb_pattern}")
                def maf = file("${params.maf_dir}/${chrom}${params.maf_pattern}")
                if (!maf || !bb) {
                    error "Missing MAF or index file for chromosome ${chrom}"
                }
                tuple(chrom, maf, bb)
            }
        
    } else {
        if (!params.chrom_sizes) {
           error "Chromosome sizes file must be provided using --chrom_sizes parameter"
        }
        // Download and index MAF files

        maf_ch = DOWNLOAD_MAFS_AND_INDEX(chromosomes, params.chrom_sizes)
    }

    // Use maf_ch in your subsequent processes
    feature_specific_bed12 = PREPARE_FEATURES(chromosomes, params.feature_bed12)

    // Subworkflow to process MAFs (extract regions and merge)
    // Create a channel from maf_ch with chromosome as the key
    maf_ch_keyed = maf_ch.map { chrom, maf, bb -> 
        [chrom, [maf, bb]]
    }

    // Create a channel from feature_specific_bed12_ch with chromosome as the key
    bed_ch_keyed = feature_specific_bed12.flatMap { chrom, beds -> 
        beds.collect { bed -> 
            [chrom, bed]
        }
    }
    // Join the two channels based on the chromosome key
    joined_ch = maf_ch_keyed.cross(bed_ch_keyed)

    result_ch = joined_ch.map { item ->
        def chrom = item[0][0]
        def maf = item[0][1][0]
        def bb = item[0][1][1]
        def bed = item[1][1]
        [chrom, bed, maf, bb]
    }

    PROCESS_MAFS(result_ch)

    // Run PhyloCSF
    RUN_PHYLOCSF(PROCESS_MAFS.out)
    
    FORMAT_RESULTS(RUN_PHYLOCSF.out.collect(), params.feature_bed12)
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