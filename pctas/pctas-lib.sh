#!/bin/bash

#
# pCTAS: parallel CTAS
# www.ctas.sourceforge.net
#

[[ -z $DEBUG ]] && DEBUG=0
[[ -z $VERBOSE1 ]] && VERBOSE1=1
[[ -z $VERBOSE2 ]] && VERBOSE2=1
[[ -z $VERBOSE3 ]] && VERBOSE3=1

[[ $DEBUG == 1 ]] && set -x

# set up for the ctas relocatable distribution
export PATH=/opt/ctas/ctas-relocatable-x64/bin:$PATH
export LD_LIBRARY_PATH=/opt/ctas/ctas-relocatable-x64/lib:/opt/ctas/ctas-relocatable-x64/lib/ctas:/usr/local/lib:/usr/local/lib64:/usr/lib64:/usr/lib:/lib64:/lib

###
### Setup the input / output hierarchy as required
###
[[ ! -d $SINOGRAM_OUTPUT_DIR ]] && mkdir -p $SINOGRAM_OUTPUT_DIR
[[ ! -d $RECON_OUTPUT_DIR ]] && mkdir -p $RECON_OUTPUT_DIR
[[ ! -d $PREPROC_RAW_DATA_DIR ]] && mkdir -p $PREPROC_RAW_DATA_DIR


###
### Get the MPI info we need in order to work out how to split the processing
###
if [ -z $OMPI_COMM_WORLD_RANK ] ; then
  # if OMPI_COMM_WORLD_RANK is not set - then assume
  #  we should just run serially
  PROC_RANK=0
  PROC_TOTAL=1
else

  PROC_RANK=$OMPI_COMM_WORLD_RANK
  PROC_TOTAL=$OMPI_COMM_WORLD_SIZE
fi

### 
### Number of images / MPI process
###
N_PROJ_PER_PROCESS=$(( TOTAL_PROJ / PROC_TOTAL ))

### Start / end Images for this process
START_PROJ=$(( PROC_RANK * N_PROJ_PER_PROCESS + 1 ))
END_PROJ=$(( (PROC_RANK + 1) * N_PROJ_PER_PROCESS + 1 ))

# we need to be sure we process all projections
#  to do this, the last process just has to go to the end
if [ $(( PROC_RANK + 1 )) == $PROC_TOTAL ] ; then
  END_PROJ=$(( (TOTAL_PROJ - END_PROJ) + END_PROJ + 1 ))
fi

### 
### Number of sinograms / MPI process
### 
N_SINO_PER_PROCESS=$(( PROJ_LENGTH / PROC_TOTAL ))
  
### Start / end Sinograms for this process
START_SINO=$(( PROC_RANK * N_SINO_PER_PROCESS ))
END_SINO=$(( (PROC_RANK + 1) * N_SINO_PER_PROCESS ))

# we need to be sure we create all sinograms
#  to do this, the last process just has to go to the end
if [ $(( PROC_RANK + 1 )) == $PROC_TOTAL ] ; then
  END_SINO=$(( (PROJ_LENGTH - END_SINO) + END_SINO ))
fi

    
timestamp() {

  local MSG=${1}
  echo "$(date +%s) ::: $MSG"

}

v1() {
  local MSG=${1}

  if [ $VERBOSE1 == 1 ] ; then
    echo "V1 ::: $(date +%s) ::: $MSG "
  fi
}

v2() {
  export VERBOSE1=1
  local MSG=${1}

  if [ $VERBOSE2 == 1 ] ; then
    echo "V2 ::: $(date +%s) ::: $MSG "
  fi
}

v3() {
  export VERBOSE1=1
  export VERBOSE2=1
  local MSG=${1}

  if [ $VERBOSE3 == 1 ] ; then
    echo "V3 ::: $(date +%s) ::: $MSG "
  fi
}


info() {

  [[ $DEBUG == 1 ]] && echo -e "\n *** ${1} ***"
}

###
### Find the correct background for the given projection
###
##### ***
##### *** Time required to find background for a specific projection is negligible
##### ***  quick and dirty test: find background for each of 900 projections - total time < 1 sec
##### ***
getBackgroundForProjection() {

  if [ $# != 1 ] ; then
    echo "requires an image name (don't include path information)"
    return 0
  fi

  local IMAGE=${1}

  local BGMARK='#BACKGROUND# '
  local BG=""

  cat "$FG_BG_LIST" |
  while read line ; do
    if echo $line | grep -q "^${BGMARK}" ; then
      BG="${line#${BGMARK}}"
    else
      if [ "$line" = "${IMAGE}" ] ; then
        echo $BG
        return 0
      fi
    fi
  done
}

###
### De-Noise the images
###
denoiseImages() {
  v2 "Start noise removal"
  [[ ! -d $BASE_PATH/postoriginal ]] && mkdir -p "$BASE_PATH/postoriginal"
  for file in $RAW_DATA_DIR/*.tif ; do 
    convert -noise 1 $file $BASE_PATH/postoriginal/$(basename $file)
  done
  v2 "End noise removal"
}

###
### Subtract the background from the images
###
removeBackgrounds() {
  v2 "Process: $PROC_RANK started :::: $N_PROJ_PER_PROCESS to process :::: start $START_PROJ, end $(( $END_PROJ-1 ))"
  for (( i=$START_PROJ ; i<$END_PROJ ; i++ )) ; do
    if (( $i < 10 )) ; then
      ctas bg --idealworld $RAW_DATA_DIR/00$i.tif $RAW_DATA_DIR/$(getBackgroundForProjection 00$i.tif) $PREPROC_RAW_DATA_DIR/00$i.tif
    elif (( $i < 100 )) ; then
      ctas bg --idealworld $RAW_DATA_DIR/0$i.tif $RAW_DATA_DIR/$(getBackgroundForProjection 0$i.tif) $PREPROC_RAW_DATA_DIR/0$i.tif
    else
      ctas bg --idealworld $RAW_DATA_DIR/$i.tif $RAW_DATA_DIR/$(getBackgroundForProjection $i.tif) $PREPROC_RAW_DATA_DIR/$i.tif
    fi
  done
  v2 "Process: $PROC_RANK ended"
}

### 
### Sinogram creation
###
createSinograms() {
  v2 "Process: $PROC_RANK started :::: $N_SINO_PER_PROCESS to process :::: start $START_SINO, end $(( $END_SINO-1 ))"
  for (( i=$START_SINO ; i<$END_SINO ; i++ )) ; do
    #v1 "Processing Sinogram: $i on process: $PROC_RANK"
    if (( $i < 10 )) ; then
      ctas sino --slice $i "$SINOGRAM_OUTPUT_DIR/00$i.sino.tif" "$PREPROC_RAW_DATA_DIR/*.tif"
      #[[ ! -z "$CONVERT_SINO_TO" ]] && ctas sino --slice $i --int "$SINOGRAM_OUTPUT_DIR/000$i.sino.$CONVERT_SINO_TO" "$PREPROC_RAW_DATA_DIR/*.tif"
    elif (( $i < 100 )) ; then
      ctas sino --slice $i "$SINOGRAM_OUTPUT_DIR/0$i.sino.tif" "$PREPROC_RAW_DATA_DIR/*.tif"
      #[[ ! -z "$CONVERT_SINO_TO" ]] && ctas sino --slice $i --int "$SINOGRAM_OUTPUT_DIR/00$i.sino.$CONVERT_SINO_TO" "$PREPROC_RAW_DATA_DIR/*.tif"
    else
      ctas sino --slice $i "$SINOGRAM_OUTPUT_DIR/$i.sino.tif" "$PREPROC_RAW_DATA_DIR/*.tif"
      #[[ ! -z "$CONVERT_SINO_TO" ]] && ctas sino --slice $i --int "$SINOGRAM_OUTPUT_DIR/$i.sino.$CONVERT_SINO_TO" "$PREPROC_RAW_DATA_DIR/*.tif"
    fi
  done
  v2 "Process: $PROC_RANK ended"
}

###
### Sinogram reconstruction
### 
reconstructSinograms() {
  v2 "Process: $PROC_RANK started :::: $N_SINO_PER_PROCESS to process :::: start $START_SINO, end $(( $END_SINO-1 ))"
  for (( i=$START_SINO ; i<$END_SINO ; i++ )) ; do
    if (( $i < 10 )) ; then
      ctas ct -t 1 "$SINOGRAM_OUTPUT_DIR/00$i.sino.tif" "$RECON_OUTPUT_DIR/00$i.recon.tif"
    elif (( $i < 100 )) ; then
      ctas ct -t 1 "$SINOGRAM_OUTPUT_DIR/0$i.sino.tif" "$RECON_OUTPUT_DIR/0$i.recon.tif"
    else
      ctas ct -t 1 "$SINOGRAM_OUTPUT_DIR/$i.sino.tif" "$RECON_OUTPUT_DIR/$i.recon.tif"
    fi
  done
  v2 "Process: $PROC_RANK ended"
}
