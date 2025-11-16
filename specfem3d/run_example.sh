#!/bin/bash

echo "running example: $(date)"

# ==============================================================================================
specfem3d_ROOT="/home/visrutha/specfem3d"      # change to the specfem3d directory 
# ==============================================================================================

BIN_DIR="$specfem3d_ROOT/bin"


# === Create new run folder ===
RUN_DIR="RUN_$(date +%Y%m%d_%H%M)"
mkdir -p "$RUN_DIR"
cd "$RUN_DIR"
echo "Created run directory: $RUN_DIR"

# Link executables (only if not already linked)
[ -L bin ] || ln -s "$BIN_DIR" bin

mkdir -p OUTPUT_FILES
mkdir -p OUTPUT_FILES/DATABASES_MPI

cp -r "$specfem3d_ROOT/EXAMPLES/applications/homogeneous_halfspace/DATA" .
cp -r "$specfem3d_ROOT/EXAMPLES/applications/homogeneous_halfspace/meshfem3D_files" DATA/.

# get the number of processors, ignoring comments in the Par_file
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2 | cut -d \# -f 1`
echo "The simulation will run on NPROC = " $NPROC " MPI tasks"

echo
echo " running mesher generation on $NPROC processors..."
echo
mpirun -n $NPROC ./bin/xmeshfem3D

# runs database generation
echo
echo "  running database generation on $NPROC processors..."
echo
mpirun -n $NPROC ./bin/xgenerate_databases

# runs simulation
echo
echo "  running solver on $NPROC processors..."
echo
mpirun -n $NPROC ./bin/xspecfem3D

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
echo `date`


