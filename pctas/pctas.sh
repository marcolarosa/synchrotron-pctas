#!/bin/bash

#
# pCTAS: parallel CTAS
# www.ctas.sourceforge.net
#

###
### source the configuration file
###
. ./pctas-config.sh

###
### source the library file
###
. ./pctas-lib.sh

###
###***********************************************************************************
###

#if [ "$PROC_RANK" == "0" ] ; then
  # place holder for things to do on the root process only
  # ie serial stuff: setup the job, prepare the filesystem, etc etc
#
#fi

###
### De-Noise the images
###
denoiseImages

###
### Subtract the background from the images
###
removeBackgrounds

### 
### Sinogram creation
###
createSinograms

###
### Reconstruction of the Sinograms
### 
reconstructSinograms

#if [ "$PROC_RANK" == "0" ] ; then
  # place holder for things to do on the root process only
  # ie serial stuff: cleanup the job, post-processing, etc etc
#
#fi

exit 0
