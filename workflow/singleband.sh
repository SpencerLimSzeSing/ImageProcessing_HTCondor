#!/bin/bash

# Debugging: Log environment and working directory
env > /mnt/shared/logs/env.txt
echo "Current working directory: $(pwd)" >> /mnt/shared/logs/env.txt

# Ensure the script starts in the correct directory
cd /mnt/shared || exit 1

# Debugging: Log file availability
echo "Listing files in /mnt/shared:" >> /mnt/shared/logs/singleband.debug
ls -l /mnt/shared >> /mnt/shared/logs/singleband.debug

# Define region and header for the mosaic
echo "Running mHdr with arguments: NGC 3372 2.0 /mnt/shared/region.hdr" >> /mnt/shared/logs/singleband.debug
/usr/bin/mHdr "NGC 3372" 2.0 /mnt/shared/region.hdr
if [ $? -ne 0 ]; then
    echo "Error: mHdr failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi
echo "mHdr completed successfully." >> /mnt/shared/logs/singleband.debug

# Set up directories
rm -rf raw projected diffs corrected
mkdir -p raw projected diffs corrected

# Generate metadata table for K-band files
echo "Running mImgtbl on /mnt/shared/input_data" >> /mnt/shared/logs/singleband.debug
/usr/bin/mImgtbl /mnt/shared/input_data /mnt/shared/rimages.tbl ".*k.*"
if [ $? -ne 0 ]; then
    echo "Error: mImgtbl failed for K-band files. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Reproject the K-band images
echo "Running mProjExec" >> /mnt/shared/logs/singleband.debug
/usr/bin/mProjExec -p /mnt/shared/input_data /mnt/shared/rimages.tbl /mnt/shared/region.hdr /mnt/shared/projected /mnt/shared/stats.tbl
if [ $? -ne 0 ]; then
    echo "Error: mProjExec failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Generate metadata table for reprojected images
echo "Running mImgtbl for projected images" >> /mnt/shared/logs/singleband.debug
/usr/bin/mImgtbl /mnt/shared/projected /mnt/shared/pimages.tbl
if [ $? -ne 0 ]; then
    echo "Error: mImgtbl failed for projected images. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# ... (continued from Part 1)
if [ $? -ne 0 ]; then
    echo "Error: mOverlaps failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Compute differences and fit backgrounds
echo "Running mDiffFitExec" >> /mnt/shared/logs/singleband.debug
/usr/bin/mDiffFitExec -p /mnt/shared/projected /mnt/shared/diffs.tbl /mnt/shared/region.hdr /mnt/shared/diffs /mnt/shared/fits.tbl
if [ $? -ne 0 ]; then
    echo "Error: mDiffFitExec failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Model background corrections
echo "Running mBgModel" >> /mnt/shared/logs/singleband.debug
/usr/bin/mBgModel /mnt/shared/pimages.tbl /mnt/shared/fits.tbl /mnt/shared/corrections.tbl
if [ $? -ne 0 ]; then
    echo "Error: mBgModel failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Apply background corrections
echo "Running mBgExec" >> /mnt/shared/logs/singleband.debug
/usr/bin/mBgExec -p /mnt/shared/projected /mnt/shared/pimages.tbl /mnt/shared/corrections.tbl /mnt/shared/corrected
if [ $? -ne 0 ]; then
    echo "Error: mBgExec failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Create the final mosaic
echo "Running mAdd" >> /mnt/shared/logs/singleband.debug
/usr/bin/mAdd -p /mnt/shared/corrected /mnt/shared/pimages.tbl /mnt/shared/region.hdr /mnt/shared/kband.fits
if [ $? -ne 0 ]; then
    echo "Error: mAdd failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

# Shrink the mosaic for easier visualization
echo "Running mShrink" >> /mnt/shared/logs/singleband.debug
/usr/bin/mShrink /mnt/shared/kband.fits /mnt/shared/ksmall.fits 5
if [ $? -ne 0 ]; then
    echo "Error: mShrink failed. Exiting." >> /mnt/shared/logs/singleband.debug
    exit 1
fi

echo "K-band mosaic created successfully: /mnt/shared/ksmall.fits" >> /mnt/shared/logs/singleband.debug