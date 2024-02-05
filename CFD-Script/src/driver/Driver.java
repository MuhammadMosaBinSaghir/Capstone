package driver;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

public class Driver {
	
	public static void main(String[] args) {
		// Ask user to choose the input directory
		final JFileChooser inputChooser = new JFileChooser();
		JOptionPane.showMessageDialog(null, "Please select the input directory from the following window.");
		inputChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		inputChooser.setDialogTitle("SELECT THE INPUT DIRECTORY");
		inputChooser.showOpenDialog(inputChooser);
		String inputPath = inputChooser.getSelectedFile().getPath();
		
		// Ask user to choose the input directory
		final JFileChooser outputChooser = new JFileChooser(inputPath);
		JOptionPane.showMessageDialog(null, "Please select the output directory from the following window.");
		outputChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		outputChooser.setDialogTitle("SELECT THE OUTPUT DIRECTORY");
		outputChooser.showOpenDialog(outputChooser);
		String outputPath = outputChooser.getSelectedFile().getPath();
		
		// Ask the user to input the number of cores
		String cores = null;
		int availableCores = Runtime.getRuntime().availableProcessors();
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
		String workingPath = System.getProperty("user.dir");
		String solverPath = System.getenv("SU2_RUN") + "\\parallel_computation.py";
		String[] files;
		String config = null;
		String[] meshes;
		
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
		
		// The current mesh that is being run in the CFD
		int meshNumber = 0;
		
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
				int exit = solver.exitValue();
								
				// Create output directory and copy output files from the working directory to the output folder
				new File(outputPath + "\\" + meshes[meshNumber]).mkdir();
				new File(workingPath + "\\history.csv").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\history.csv"));
				new File(workingPath + "\\solution-2D.vtu").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\solution-2D.vtu"));
				new File(workingPath + "\\solution-3D.vtu").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\solution-3D.vtu"));
				new File(workingPath + "\\forces-breakdown.dat").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\forces-breakdown.dat"));
				new File(workingPath + "\\config_CFD.cfg").renameTo(new File(outputPath + "\\" + meshes[meshNumber] + "\\config_CFD.cfg"));
				
				// Write to the log file
				new File(outputPath + "\\" + meshes[meshNumber] + "\\log.txt").createNewFile();
				BufferedWriter logWrite = new BufferedWriter(new FileWriter(outputPath + "\\" + meshes[meshNumber] + "\\log.txt"));
				if(exit == 0) {
					logWrite.write("CFD SUCCEEDED - EXIT VALUE " + exit);
					logWrite.close();
				} else if(exit == 1) {
					logWrite.write("CFD FAILED - EXIT VALUE " + exit);
					logWrite.close();
				} else {
					logWrite.write("CFD FAILED - EXIT VALUE " + exit);
					logWrite.close();
				}
					
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		// Copy input files from the working directory back to the input folder
		new File(workingPath + "\\" + config).renameTo(new File(inputPath + "\\" + config));
		for(i = 0; i < meshes.length; i++) {
			new File(workingPath + "\\" + meshes[i]).renameTo(new File(inputPath + "\\" + meshes[i]));
		}
	}
}
