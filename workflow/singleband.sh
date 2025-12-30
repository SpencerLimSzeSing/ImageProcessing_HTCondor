#!/bin/sh

mHdr "NGC 3372" 2.0 region.hdr

mArchiveList 2mass j "NGC 3372" 2.8 2.8 archive.tbl


# Perform the same processing as in the single-band example
# script (singleband.sh) for all three 2MASS wavelengths.

rm -rf raw projected diffs corrected
mkdir  raw projected diffs corrected
mCoverageCheck archive.tbl remote.tbl -header region.hdr
mArchiveExec -p raw remote.tbl
mImgtbl raw rimages.tbl
mProjExec -q -p raw rimages.tbl region.hdr projected stats.tbl
mImgtbl projected pimages.tbl
mOverlaps pimages.tbl diffs.tbl
mDiffFitExec -p projected diffs.tbl region.hdr diffs fits.tbl
mBgModel pimages.tbl fits.tbl corrections.tbl
mBgExec -p projected pimages.tbl corrections.tbl corrected
mImgtbl corrected cimages.tbl
mAdd -p corrected cimages.tbl region.hdr jband.fits

rm -rf raw projected diffs corrected
mkdir  raw projected diffs corrected
mArchiveList 2mass h "NGC 3372" 2.8 2.8 archive.tbl
mCoverageCheck archive.tbl remote.tbl -header region.hdr
mArchiveExec -p raw remote.tbl
mImgtbl raw rimages.tbl
mProjExec -q -p raw rimages.tbl region.hdr projected stats.tbl
mImgtbl projected pimages.tbl
mOverlaps pimages.tbl diffs.tbl
mDiffFitExec -p projected diffs.tbl region.hdr diffs fits.tbl
mBgModel pimages.tbl fits.tbl corrections.tbl
mBgExec -p projected pimages.tbl corrections.tbl corrected
mImgtbl corrected cimages.tbl
mAdd -p corrected cimages.tbl region.hdr hband.fits

rm -rf raw projected diffs corrected
mkdir  raw projected diffs corrected
mArchiveList 2mass k "NGC 3372" 2.8 2.8 archive.tbl
mCoverageCheck archive.tbl remote.tbl -header region.hdr
mArchiveExec -p raw remote.tbl
mImgtbl raw rimages.tbl
mProjExec -q -p raw rimages.tbl region.hdr projected stats.tbl
mImgtbl projected pimages.tbl
mOverlaps pimages.tbl diffs.tbl
mDiffFitExec -p projected diffs.tbl region.hdr diffs fits.tbl
mBgModel pimages.tbl fits.tbl corrections.tbl
mBgExec -p projected pimages.tbl corrections.tbl corrected
mImgtbl corrected cimages.tbl
mAdd -p corrected cimages.tbl region.hdr kband.fits


# And make a color PNG image of the result.

mShrink kband.fits ksmall.fits 5
mShrink hband.fits hsmall.fits 5
mShrink jband.fits jsmall.fits 5

mViewer -t 2 \
        -red   ksmall.fits 0s max gaussian-log \
        -green hsmall.fits 0s max gaussian-log \
        -blue  jsmall.fits 0s max gaussian-log \
        -out   color_mosaic.png

