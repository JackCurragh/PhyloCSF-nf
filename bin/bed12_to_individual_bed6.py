#!/usr/bin/env python3

import sys
import os
from typing import List, Tuple
import argparse

def parse_bed12_line(line: str) -> Tuple[List[str], List[int], List[int]]:
   fields = line.strip().split('\t')
   if len(fields) != 12:
       raise ValueError(f"Input line does not have 12 fields: {line}")
   
   block_sizes = [int(x) for x in fields[10].rstrip(',').split(',')]
   block_starts = [int(x) for x in fields[11].rstrip(',').split(',')]
   
   return fields, block_sizes, block_starts

def convert_to_bed6(fields: List[str], block_size: int, block_start: int, block_num: int) -> str:
   chrom = fields[0]
   start = int(fields[1])
   name = fields[3]
   score = fields[4]
   strand = fields[5]
   
   block_abs_start = start + block_start
   block_abs_end = block_abs_start + block_size
   
   bed6_entry = [
       chrom,
       str(block_abs_start),
       str(block_abs_end),
       f"{name}_exon{block_num + 1}",
       score,
       strand
   ]
   return '\t'.join(bed6_entry)

def process_bed12_file(input_file: str, chromosome: str = None):
   with open(input_file, 'r') as f:
       for line in f:
           if line.startswith('#') or not line.strip():
               continue
               
           try:
               fields, block_sizes, block_starts = parse_bed12_line(line)
               chrom = fields[0]
               
               if chromosome and chrom != chromosome:
                   continue
                   
               transcript_id = fields[3]
               
               for i, (block_size, block_start) in enumerate(zip(block_sizes, block_starts)):
                   bed6_entry = convert_to_bed6(fields, block_size, block_start, i)
                   output_file = f"{transcript_id}_exon{i + 1}.bed"
                   
                   with open(output_file, 'w') as out_f:
                       out_f.write(f"{bed6_entry}\n")
                       
           except ValueError as e:
               print(f"Error processing line: {e}", file=sys.stderr)
               continue

def main():
   parser = argparse.ArgumentParser(
       description='Convert BED12 to individual BED6 files for each block/exon'
   )
   parser.add_argument('input_file', help='Input BED12 file')
   parser.add_argument('--chromosome', help='Process only specified chromosome')
   args = parser.parse_args()
   
   process_bed12_file(args.input_file, args.chromosome)

if __name__ == "__main__":
   main()