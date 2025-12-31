#!/bin/bash
# Corrected Script
env > /mnt/shared/logs/env.txt
echo "Current working directory: $(pwd)" >> /mnt/shared/logs/env.txt

# Set the directory and output file
raw_images_dir=$1
output_file=$2

# Generate a metadata table for all files in the directory
mImgtbl $raw_images_dir $output_file
if [ $? -eq 0 ]; then
    echo "mImgtbl completed successfully for directory $raw_images_dir"
else
    echo "mImgtbl failed for $raw_images_dir" >&2
    exit 1
fi

# Corrected Script
# Generate a metadata table for all files in the directory
#mImgtbl $raw_images_dir $output_file
#if [ $? -eq 0 ]; then
#    echo "mImgtbl completed successfully for directory $raw_images_dir"
#else
#    echo "mImgtbl failed for $raw_images_dir" >&2
#    exit 1
#fi

# Debugging: Print parameters and working directory
echo "raw_images_dir: $raw_images_dir" >> /mnt/shared/logs/imgtbl.debug
echo "output_file: $output_file" >> /mnt/shared/logs/imgtbl.debug
echo "Listing input directory:" >> /mnt/shared/logs/imgtbl.debug
ls -l $raw_images_dir >> /mnt/shared/logs/imgtbl.debug