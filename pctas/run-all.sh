#!/bin/bash

#rm -rf /nfs/example/quad-size/absorption-ct/preproc/*
#rm -rf /nfs/example/quad-size/absorption-ct/sino/*
#rm -rf /nfs/example/quad-size/absorption-ct/recon/*
#echo time mpirun -np 1 pctas.sh
#time mpirun -np 1 pctas.sh

#rm -rf /nfs/example/quad-size/absorption-ct/preproc/*
#rm -rf /nfs/example/quad-size/absorption-ct/sino/*
#rm -rf /nfs/example/quad-size/absorption-ct/recon/*
#echo time mpirun -np 2 pctas.sh
#time mpirun -np 2 pctas.sh

#rm -rf /nfs/example/quad-size/absorption-ct/preproc/*
rm -rf /nfs/example/quad-size/absorption-ct/sino/*
#rm -rf /nfs/example/quad-size/absorption-ct/recon/*
echo time mpirun -np 4 pctas.sh
time mpirun -np 4 pctas.sh

sleep 300

#rm -rf /nfs/example/quad-size/absorption-ct/preproc/*
rm -rf /nfs/example/quad-size/absorption-ct/sino/*
#rm -rf /nfs/example/quad-size/absorption-ct/recon/*
echo time mpirun -np 8 pctas.sh
time mpirun -np 8 pctas.sh

#sleep 300

#rm -rf /nfs/example/quad-size/absorption-ct/preproc/*
#rm -rf /nfs/example/quad-size/absorption-ct/sino/*
#rm -rf /nfs/example/quad-size/absorption-ct/recon/*
#echo time mpirun -np 16  pctas.sh
#time mpirun -np 16  pctas.sh

