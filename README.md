# PhyloCSF-nf

A Nextflow pipeline for running PhyloCSF on spliced genomic features.

## Overview

PhyloCSF-nf processes BED12 format files containing multi-exon features and computes PhyloCSF scores using multiple alignment files (MAF). The pipeline handles exon extraction, sequence stitching, and strand orientation automatically.

## Requirements

- Nextflow (≥21.10.3)
- Docker/Singularity
- PhyloCSF
- MAF alignment files

## Usage

```bash
nextflow run main.nf \
  --feature_bed12 features.bed12 \
  --chrom_sizes genome.sizes \
  --maf_dir /path/to/maf/files \
  --outdir results
```

## Parameters

- `feature_bed12`: BED12 file with candidate regions
- `chrom_sizes`: Chromosome sizes file
- `maf_dir`: Directory containing MAF files (optional, will download if not provided)
- `maf_url_base`: Base URL for downloading MAF files (default: 120 mammals alignment)
- `outdir`: Output directory (default: results)
- `species_map`: Species name mapping file

## MAF Files

The pipeline can either use existing MAF files or download them automatically:

### Using existing MAF files
```bash
nextflow run main.nf \
  --feature_bed12 features.bed12 \
  --maf_dir /path/to/maf/files \
  --chrom_sizes genome.sizes
```

### Auto-download MAF files
```bash
nextflow run main.nf \
  --feature_bed12 features.bed12 \
  --chrom_sizes genome.sizes \
  --maf_url_base https://bds.mpi-cbg.de/hillerlab/120MammalAlignment/Human120way/data/maf/
```

## Output

- `results/phylocsf/`: PhyloCSF scores for each feature
- `results/*.bed6`: Final results in BED6 format with PhyloCSF scores
