# pCTAS

- [pCTAS](#pCTAS)
  - [Configuration and invocation](#Configuration-and-invocation)
  - [Performance](#Performance)

Parallel CTAS

## Configuration and invocation

Example invocation can be seen in the "pctas/run-all.sh" script

To configure, edit the file "pctas/pctas-config.sh"

On any typical MPI cluster system, to kick off a run:
mpirun -np 4 pctas.sh

Will start the script in parallel across 4 processors.

## Performance

See performance-measurements.pdf
