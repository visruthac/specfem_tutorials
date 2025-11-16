#!/bin/bash

echo "running example: $(date)"

# ==============================================================================================
BIN_ROOT="/home/visrutha/specfem2d/bin"      # change to the bin directory 
DATA_FOLDER="/home/visrutha/specfem2d/DATA_example"        # change to the DATA directory 
# ==============================================================================================

BIN_DIR="$BIN_ROOT"
DATA_SRC="$DATA_FOLDER"

# === Create new run folder ===
RUN_DIR="RUN_$(date +%Y%m%d_%H%M)"
mkdir -p "$RUN_DIR"
cd "$RUN_DIR"
echo "Created run directory: $RUN_DIR"

mkdir -p OUTPUT_FILES

# Link executables (only if not already linked)
[ -L bin ] || ln -s "$BIN_DIR" bin

# Copy DATA folder
cp -r "$DATA_SRC" DATA

# === Detect number of processors ===
NPROC=$(grep "^NPROC" DATA/Par_file | cut -d = -f2 | cut -d '#' -f1 | tr -d ' ')
echo "Using NPROC = $NPROC"

# === Run ===
if [ "$NPROC" -eq 1 ]; then
    echo "Running serial mesher..."
    ./bin/xmeshfem2D > OUTPUT_FILES/output_meshfem2d.txt

    echo "Running serial solver..."
    ./bin/xspecfem2D > OUTPUT_FILES/output_solver.txt
else
    echo "Running MPI mesher on $NPROC processors..."
    mpirun -n "$NPROC" ./bin/xmeshfem2D > OUTPUT_FILES/output_meshfem2d.txt

    echo "Running MPI solver on $NPROC processors..."
    /usr/bin/mpirun -n "$NPROC" ./bin/xspecfem2D > OUTPUT_FILES/output_solver.txt
fi

echo
echo "Results saved in:  $RUN_DIR/OUTPUT_FILES"
echo "Finished: $(date)"
