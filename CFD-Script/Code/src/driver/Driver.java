package driver;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

public class Driver {
	
	public static void main(String[] args) {
		
			/*** SETTING UP VARIABLES AND MOVING FILES ***/
		
		// Variable definition
		String inputPath;
		String outputPath;
		String cores;
		int availableCores;
		String workingPath;
		String solverPath;
		String[] files;
		String config = null;
		String[] meshes;
		int meshNumber;
		int exit[];
		BufferedWriter logWrite = null;
		
		// Ask user to choose the input directory
		final JFileChooser inputChooser = new JFileChooser();
		JOptionPane.showMessageDialog(null, "                                                                                        IMPORTANT - PLEASE READ\n"
				+ "- The input directory must only contain the config file (.cfg) and the mesh files (.su2).\n"
				+ "- The chord lengths must be included in the first line of the config file.\n    The line should start with \"% CHORDS: \" followed by the chords from root to tip, separated by a space.\n"
				+ "- The meshes must be carefully named so that the program reads them in the correct order.\n    To ensure proper functioning, it is recommended to add sequential numbers to the beginning of the mesh filenames. For example:\n"
				+ "        1-cessna-0.su2\n"
				+ "        2-cessna-25.su2\n"
				+ "        3-cessna-50.su2\n"
				+ "        4-cessna-75.su2\n"
				+ "        5-cessna-100.su2\n\n"
				+ "                                                           Please select the INPUT directory from the following window.");
		inputChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		inputChooser.setDialogTitle("SELECT THE INPUT DIRECTORY");
		inputChooser.showOpenDialog(inputChooser);
		inputPath = inputChooser.getSelectedFile().getPath();
		
		// Ask user to choose the output directory
		final JFileChooser outputChooser = new JFileChooser(inputPath);
		JOptionPane.showMessageDialog(null, "Please select the OUTPUT directory from the following window.");
		outputChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		outputChooser.setDialogTitle("SELECT THE OUTPUT DIRECTORY");
		outputChooser.showOpenDialog(outputChooser);
		outputPath = outputChooser.getSelectedFile().getPath();
		
		// Create the log file and open its BufferedWriter
		try {
			new File(outputPath + "\\log.txt").createNewFile();
			logWrite = new BufferedWriter(new FileWriter(outputPath + "\\log.txt"));
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// Ask the user to input the number of cores
		cores = null;
		availableCores = Runtime.getRuntime().availableProcessors();
		while(true) {
			cores = (String)JOptionPane.showInputDialog(
					null,
					"Please specify the number of cores.\nThe selected number of cores cannot be less than 2 or greater than the maximum number of cores.\nNote: this computer has a total of " + availableCores + " available cores.",
					"Number of Cores Selection",
					JOptionPane.PLAIN_MESSAGE,
					null, null, null);
			if( (Integer.parseInt(cores) <= availableCores) && (Integer.parseInt(cores) > 1) )
				break;
		}
		
		// Other inputs and files
		workingPath = System.getProperty("user.dir");
		solverPath = System.getenv("SU2_RUN") + "\\parallel_computation.py";
		
		// Read input folder and load all file names into "files" array
		files = new File(inputPath).list();
		
		// Place the config file's name into "config"
		int i;
		for(i = 0; i < files.length; i++) {
			if(files[i].contains(".cfg")) {
				config = files[i];
				break;
			}
		}
		if(i == files.length) {
			System.out.println("Error: Congifuration (.cfg) file not found.");
			System.exit(-1);
		}
		
		// Initialize the array containing the exit codes
		exit = new int[files.length - 1];
		
		// Place the mesh files into the "meshes" array
		meshes = new String[files.length - 1];
		int j = 0;
		for(i = 0; i < files.length; i++) {
			if(files[i].contains(".cfg")) {
				j = 1;
				continue;
			}
			meshes[i - j] = files[i];
		}
		
		// Copy input files to the working directory
		new File(inputPath + "\\" + config).renameTo(new File(workingPath + "\\" + config));
		for(i = 0; i < meshes.length; i++) {
			new File(inputPath + "\\" + meshes[i]).renameTo(new File(workingPath + "\\" + meshes[i]));
		}
		
		
		
			/*** RUNNING THE CFD ***/
		
		// The current mesh that is being run in the CFD
		meshNumber = 0;
		
		for(meshNumber = 0; meshNumber < meshes.length; meshNumber++) {
			try {
				// Search the config file to make sure "MESH_FILENAME" matches the current mesh
				BufferedReader configFileRead = new BufferedReader(new FileReader(workingPath + "\\" + config));
				String line;
				StringBuilder configContents = new StringBuilder();
				while((line = configFileRead.readLine()) != null) {
					if(line.contains("MESH_FILENAME")) {
						String newLine = "MESH_FILENAME= " + meshes[meshNumber];
						configContents.append(newLine);
						configContents.append("\n");
					} else {
						configContents.append(line);
						configContents.append("\n");
						
					}
				}
				configFileRead.close();
				BufferedWriter configFileWrite = new BufferedWriter(new FileWriter(workingPath + "\\" + config));
				configFileWrite.write(configContents.toString());
				configFileWrite.close();
				
				// RUNNING THE CFD SOLVER
				ProcessBuilder solverBuilder = new ProcessBuilder("python", solverPath, "-f", config, "-n", cores);
				Process solver = solverBuilder.start();
				// Read the output
				BufferedReader solverOutput = new BufferedReader(new InputStreamReader(solver.getInputStream()));
				String lines = null;
				while((lines = solverOutput.readLine()) != null) {
					System.out.println(lines);
				}
				// Read the error (if applicable)
				BufferedReader error = new BufferedReader(new InputStreamReader(solver.getErrorStream()));
				lines = null;
				while((lines = error.readLine()) != null) {
					System.out.println(lines);
				}
				exit[meshNumber] = solver.exitValue();
								
				// Create output directory and copy output files from the working directory to the output folder
				new File(outputPath + "\\" + meshes[meshNumber]).mkdir();
				new File(workingPath + "\\history.csv").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\history.csv"));
				new File(workingPath + "\\solution-2D.vtu").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\solution-2D.vtu"));
				new File(workingPath + "\\solution-3D.vtu").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\solution-3D.vtu"));
				new File(workingPath + "\\forces-breakdown.dat").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\forces-breakdown.dat"));
				new File(workingPath + "\\config_CFD.cfg").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\config_CFD.cfg"));
				
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		try {
			// Write to the log file
			logWrite.write("\t--- SU2_CFD EXIT CODES ---");
			
			for(i = 0; i < meshes.length; i++) {
				if(exit[i] == 0) {
					logWrite.write(meshes[i] + ": CFD SUCCEEDED - EXIT VALUE " + exit[i] + "\n");
				} else {
					logWrite.write(meshes[i] + ": CFD FAILED - EXIT VALUE " + exit[i] + "\n");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		// Copy input files from the working directory back to the input folder
		new File(workingPath + "\\" + config).renameTo(new File(inputPath + "\\" + config));
		for(i = 0; i < meshes.length; i++) {
			new File(workingPath + "\\" + meshes[i]).renameTo(new File(inputPath + "\\" + meshes[i]));
		}
		
		
		
			/*** ANALYSIS ***/
		
		// Create arrays for CL, L, CD, D, and spanwise chords
		double CL[] = new double[meshes.length];
		double CD[] = new double[meshes.length];
		double L[] = new double[meshes.length];
		double D[] = new double[meshes.length];
		double chord[] = new double[meshes.length];
		
		// Create variables for span & S_REF, u & rho, D_TOT and L_TOT
		double SPAN = 9.69;		// Fixed value
		double S_REF = 27.419;	// Fixed value
		double u = 0.0;
		double rho = 0.0;
		double L_tot = 0.0;
		double D_tot = 0.0;
		double CL_tot = 0.0;
		double CD_tot = 0.0;
		double deltaB = SPAN / (double)(meshes.length - 1);	// The span distance between two slices/meshes/airfoils
		
		// Extract chords from the config file
		try {
			BufferedReader configFileRead = new BufferedReader(new FileReader(inputPath + "\\" + config));
			String line = configFileRead.readLine();
			configFileRead.close();
			StringTokenizer st = new StringTokenizer(line);
			st.nextToken();
			st.nextToken();
			for(i = 0; i < meshes.length; i++) {
				chord[i] = Double.valueOf(st.nextToken());
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// Extract u and rho from force breakdown and write them to the log
		try {
			BufferedReader forceBreakdown = new BufferedReader(new FileReader(outputPath + "\\" + meshes[0] + "\\forces-breakdown.dat"));
			String line;
			while((line = forceBreakdown.readLine()) != null) {
				if(line.contains("Free-stream density:")) {
					StringTokenizer st = new StringTokenizer(line);
					st.nextToken();
					st.nextToken();
					rho = Double.valueOf(st.nextToken());
				} else if(line.contains("Free-stream velocity:")) {
					StringTokenizer st = new StringTokenizer(line);
					st.nextToken();
					st.nextToken();
					st.nextToken();
					st.nextToken();
					st.nextToken();
					st.nextToken();
					u = Double.valueOf(st.nextToken());
				}
				
				if( (rho != 0.0) && (u != 0.0) )
					break;
			}
			forceBreakdown.close();
			
			// Write to the log file
			logWrite.write("\n\t--- FREE STREAM PARAMETERS ---\n");
			logWrite.write("Free-stream density: " + rho + "\n");
			logWrite.write("Free-stream velocity: " + u + "\n");
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// Extract CD (D) and CL (E) from each history file and save them in array
		try {
			for(i = 0; i < meshes.length; i++) {
				BufferedReader history = new BufferedReader(new FileReader(outputPath + "\\" + meshes[i] + "\\history.csv"));
				String line;
				String lastLine = null;
				while((line = history.readLine()) != null) {
					lastLine = line;
				}
				StringTokenizer st = new StringTokenizer(lastLine);
				st.nextToken();
				st.nextToken();
				st.nextToken();
				CD[i] = Double.valueOf( st.nextToken().replace(",", "") );
				CL[i] = Double.valueOf( st.nextToken().replace(",", "") );
				history.close();
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// Convert CL to L and CD to D
		for(i = 0; i < meshes.length; i++) {
			L[i] = CL[i] * 0.5 * Math.pow(u,  2) * rho * chord[i];
			D[i] = CD[i] * 0.5 * Math.pow(u,  2) * rho * chord[i];
		}
		
		// Write CL, CD, L and D values to the log file
		try {
			logWrite.write("\n\t--- CL & CD VALUES ---\n");
			
			for(i = 0; i < meshes.length; i++) {
				logWrite.write(meshes[i] + ":\n");
				logWrite.write("\tCL: " + CL[i] + "\n");
				logWrite.write("\tCD: " + CD[i] + "\n");
				logWrite.write("\tLift: " + L[i] + "\n");
				logWrite.write("\tDrag: " + D[i] + "\n");
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// Integrate L and D to get L_TOT and D_TOT and write to log
		for(i = 0; i < (meshes.length - 1); i++) {
			L_tot = L_tot + ( deltaB * 0.5 * (L[i] + L[i+1]) );
			D_tot = D_tot + ( deltaB * 0.5 * (D[i] + D[i+1]) );
		}
		try {
			// Write to the log file
			logWrite.write("\n\t--- TOTAL LIFT AND DRAG VALUES ---\n");
			logWrite.write("TOTAL LIFT: " + L_tot + "\n");
			logWrite.write("TOTAL DRAG: " + D_tot + "\n");
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		// Convert L_TOT and D_TOT to CL_TOT and CL_TOT and write to the log
		CL_tot = L_tot / ( 0.5 * Math.pow(u,  2) * rho * S_REF );
		CD_tot = D_tot / ( 0.5 * Math.pow(u,  2) * rho * S_REF );
		try {
			// Write to the log file
			logWrite.write("\n\t--- WING CL AND CD VALUES ---\n");
			logWrite.write("WING CL: " + CL_tot + "\n");
			logWrite.write("WING CD: " + CD_tot + "\n");
			logWrite.close();
		} catch(Exception e) {
			
		}
	}
}
