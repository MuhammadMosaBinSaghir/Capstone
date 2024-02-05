# The CFD "Terminal" Script pseudocode
## File Management and running CFD
- Prommpt the user to enter
  - The input directory (containing the config and mesh files)
  - The output directory (where the CFD results will be stored)
  - The number of cores
- Move the input files from the input directory to the working directory
  - Note: the working directory is the one in which the CFD script is running, not SU2's "bin" folder
- For every mesh input file:
  - Verify that the config file has the current mesh file name under the "MESH_FILENAME" variable
    - If not, correct the config file
  - Run SU2's CFD Solver on the current mesh file and save the exit code
  - Create a folder in the output directory to store this mesh's output files
  - Move the following output files to the new folder in the output directory:
    - history.csv
    - solution-2D.vtu
    - solution-3D.vtu
    - forces-breakdown.dat
    - config_CFS.cfg
  - Create a log file in the new folder in the output directory that contains the exit code
- Once all meshes have been run, move the input files from the working directory back into the input directory

## To be done next: Calculating Lift, Drag, and other fun things
