#!/usr/bin/env python3

import sys
import glob
import os

def extract_strand_info(bed_pattern, output_file):
    """
    Extract transcript ID and strand information from BED6 files.

    Args:
        bed_pattern: Glob pattern for BED6 files
        output_file: Output TSV file with transcript_id\tstrand
    """
    strand_info = {}

    for bed_file in glob.glob(bed_pattern):
        with open(bed_file) as f:
            for line in f:
                if line.startswith('#') or not line.strip():
                    continue

                fields = line.strip().split('\t')
                if len(fields) >= 6:
                    # Extract transcript ID from the name field (remove _exonN suffix)
                    name = fields[3]
                    transcript_id = '_'.join(name.split('_')[:-1]) if '_exon' in name else name
                    strand = fields[5]

                    # Store strand info (should be consistent for all exons of same transcript)
                    strand_info[transcript_id] = strand

    # Write output
    with open(output_file, 'w') as outf:
        for transcript_id, strand in sorted(strand_info.items()):
            outf.write(f'{transcript_id}\t{strand}\n')

    print(f'Extracted strand information for {len(strand_info)} transcripts')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('Usage: extract_strand_info.py <bed_pattern> <output_file>')
        sys.exit(1)

    extract_strand_info(sys.argv[1], sys.argv[2])
