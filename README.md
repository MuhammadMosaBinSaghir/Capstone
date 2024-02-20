# Requirements
For the code to work properly, the following conditions should be respected:
- The chord lengths need to be included in the first line of the config file. The line should start with "% CHORDS: " followed by the chords from root to tip, separated by a space.
- The input folder should only contain the config file (.cfg) and the mesh files (.su2)
- The meshes need to be carefully named so that the program reads them in the correct order. To ensure proper functioning, it is recommended to add sequential numbers to the beginning of the mesh filenames. For example:
  - 1-cessna-0.su2
  - 2-cessna-25.su2
  - 3-cessna-50.su2
  - 4-cessna-75.su2
  - 5-cessna-100.su2

# Pseudocode
## File Management and running CFD
- Prompt the user to enter
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

## Calculating Lift, Drag, and overall wing CL and CD
- Extract chord lengths stored in the first line of the config file
- Extract free stream u and rho from the force-breakdown file and print them to the log file
- Extract CL and CD from each history.csv file and print them to the log
- Convert CL to L and CD to D
- Integrate L and D over the span to obtain the overall Lift and Drag of the wing L_tot and D_tot, print these to the log
- Convert L_tot to CL_tot and D_tot to CD_tot and print them to the log file
