#!/bin/bash

#
# pCTAS: parallel CTAS
# www.ctas.sourceforge.net
#

###
### system dependencies
###
### lcms
###


###
### Input / Output directories
###
BASE_PATH="/nfs/example/quad-size/absorption-ct"
RAW_DATA_DIR="$BASE_PATH/original"
PREPROC_RAW_DATA_DIR="$BASE_PATH/preproc"
SINOGRAM_OUTPUT_DIR="$BASE_PATH/sino"
RECON_OUTPUT_DIR="$BASE_PATH/recon"

###
### Conversion options
###
CONVERT_SINO_TO=""
CONVERT_RECON_TO=""

###
### Foreground / Background list
###
FG_BG_LIST="${RAW_DATA_DIR}/list.txt"

###
### Need to know the projection width 
###
PROJ_WIDTH=$(tiffinfo $(ls $RAW_DATA_DIR/*.tif | head -n 1) | grep 'Image Width' | awk '{print $3}')
PROJ_LENGTH=$(tiffinfo $(ls $RAW_DATA_DIR/*.tif | head -n 1) | grep 'Image Width' | awk '{print $6}')

###
### N Total Projections
###
TOTAL_PROJ=900

#echo $TOTAL_PROJ, $PROJ_WIDTH, $PROJ_LENGTH

