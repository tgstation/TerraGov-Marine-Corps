package map_daemon;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.file.CopyOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.json.JSONException;
import org.json.JSONObject;

import io.github.spair.byond.message.response.ByondResponse;
import io.github.spair.byond.message.response.ResponseType;

public class MapDaemon {
	
	private static String default_config_dir = "C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\config.json";
	private static String default_log_dir = "C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\logs";
	private String byond_base;
	private String project_base;
	private String dest_base;
	private String project_name;
	private String z1_map_preprocess_line;
	private String[] maps;
	private String[] binary_files = new String[] {".dmb", ".rsc", ".int"};
	private String default_map;
	
	private boolean compile_needed;
	
	private long UID; //Time in millis since UNIX epoch on creation, so unique enough without using the Random() library.
	
	private Config config;
	private CrashLogger logger;
	private ServerMessenger server_msgr;
	private boolean running;
	private boolean verbose = false;
	private String next_map;
	
	private float tick_delay;
	private float startup_delay;
	private float read_timeout_increment;
	private int MAX_COMMAND_RETRIES = 5;
	
	private static final int PROCESS_COMMAND_SUCCESS = 1;
	private static final int PROCESS_COMMAND_RETRY = 2;
	private static final int PROCESS_COMMAND_TERMINATE = 3;
	
	private static final int ROUND_STATUS_OVER = 1;
	private static final int KILL_MAPDAEMON = 2; //Do_it.gif
	
	/**
	 * 
	 * @param args The first is a String of the config.json file and the second is a boolean for whetehr or not to enable verbose logging
	 */
	public static void main(String[] args) {
		String config_dir = args[0];
		if(config_dir.equals("")) config_dir = default_config_dir;
		boolean verbose = false;
		try {
			verbose = Boolean.parseBoolean(args[1]);
		}
		catch (Exception e) {
			verbose = true;
		}
		try {
			new MapDaemon(config_dir, verbose);
		} catch (Exception e) {
			e.printStackTrace();
		}
		try {
			Thread.sleep(10000);
		} catch (Exception e) {
			
		}
	}
	
	/**
	 * Instantiates a ton of stuff and gets info from config
	 * @param config_dir The path of config.json
	 * @param verbose Whether or not to enable verbose logging
	 */
	public MapDaemon(String config_dir, boolean verbose) {
		UID = System.currentTimeMillis();
		
		config = new Config(config_dir);
		
		if(!config.getBooleanFromConfig("prefs\\enable")) return; //Terminate if we are set to
		
		this.verbose = verbose;
		String log_dir = config.getStringFromConfig("paths\\crash_logs");
		if(log_dir.indexOf("ERROR") >= 0) log_dir = default_log_dir;
		logger = new CrashLogger(log_dir, verbose);
		String play_url = config.getStringFromConfig("server\\url");
		int port = Integer.parseInt(config.getStringFromConfig("server\\port"));
		server_msgr = new ServerMessenger(play_url, port);
		running = true;
		
		default_map = config.getStringFromConfig("game\\maps\\default_map");
		
		byond_base = config.getStringFromConfig("paths\\byond_base");
		project_base = config.getStringFromConfig("paths\\project_base");
		dest_base = config.getStringFromConfig("paths\\dest_base");
		project_name = config.getStringFromConfig("paths\\project_name");
		z1_map_preprocess_line = config.getStringFromConfig("game\\maps\\map_preprocess_line");
		
		tick_delay = Float.parseFloat(config.getStringFromConfig("prefs\\tick_delay")) * 1000;
		startup_delay = Float.parseFloat(config.getStringFromConfig("prefs\\startup_delay")) * 1000;
		MAX_COMMAND_RETRIES = Integer.parseInt(config.getStringFromConfig("prefs\\MAX_COMMAND_RETRIES"));
		read_timeout_increment = Float.parseFloat(config.getStringFromConfig("prefs\\read_timeout_increment"));
		
		String map_cdl = config.getStringFromConfig("game\\maps\\map_cdl");
		maps = map_cdl.split(",");

		compile_needed = true;
		
		try {
			logger.addLine("Waiting " + startup_delay/1000 + " seconds...");
			Thread.sleep((long) startup_delay);
		}
		catch(Exception e) {
			return;
		}
		logger.addLine("Finished waiting, beginning round-end checks.");
		try{
			while(running) {
				Thread.sleep((long) tick_delay);
				if(!verifyRoundEnded(0)) continue;
				logger.addLine("Round has ended, waiting 30 seconds to collect votes.");
				if(!delayRound(0)) return;
				Thread.sleep(50000);
				if(!getNextMap(0)) return;
				if(!Compile()) return;
				if(!resumeRound(0)) return;
				//resumeRound() ends the bot, so this will just rest for the tick delay before restarting so the user can look at logs in the console or wherever.
			}
		}
		catch(Exception e) {
			logger.addLine(returnStackTrace(e));
			crashedEndProcess("Something in the main loop threw an exception, ending process.");
		}
	}
	
	//Thanks https://stackoverflow.com/questions/1149703/how-can-i-convert-a-stack-trace-to-a-string
	/**
	 * Takes an exception and returns it's stack trace
	 * @param e The exception
	 * @return The stack trace
	 */
	public static String returnStackTrace(Exception e) {
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		e.printStackTrace(pw);
		String s = sw.toString();
		return s;
	}
	
	/**
	 * Called when the bot has decided to crash for any number of reasons. This will write logs no matter what.
	 * @param info A crash message to write before closing the logger and writing it.
	 */
	private void crashedEndProcess(String info) {
		logger.addLine(info);
		logger.addLine("Closing program on next tick");
		if(!logger.close(true)) {
			System.out.println("Failed to write logs! Crash report will be lost!");
			//System.out.println("Dumping logs to console:");
			//List<String> data = logger.getData();
		}
		else System.out.println("Successfully wrote logs! Check relevant directory for crash logs!");
		running = false;
		try {
			Thread.sleep(10000);
		} catch (InterruptedException e) {
			
		}
	}
	
	/**
	 * Called when the bot decides to close but only because it thinks the round restarted properly.
	 * If verbose was set true, it will write the logs anyways.
	 */
	private void goodExitEndProcess() {
		logger.addLine("Bot successfully terminated!");
		if(verbose) {
			logger.addLine("Logs set to verbose, writing logs anyways");
			logger.close(true); //"Crashed, but not really
		}
		running = false;
	}
	
	private void goodExitEndProcess(String message) {
		logger.addLine(message);
		goodExitEndProcess();
	}
	
	
	/**
	 * This takes a BYOND response and processes its info. It is used only to judge success versus failure.
	 * It will return one of  the three response codes, telling the calling method what to do.
	 * This is pretty messy but doesn't really need to be fixed since it works right.
	 * TODO: Make this better and neater.
	 * TODO: Think of a better name for this.
	 * @param obj The ByondResponse object returned by the server messenger.
	 * @param fails How many times the method has failed in a row
	 * @param info_text What the calling method was doing, used for logging purposes.
	 * @return One of the static response code found in this class.
	 */
	private int processCommandStringAttempt(ByondResponse obj, int fails, String info_text) {

		if(!obj.getResponseType().equals(ResponseType.STRING)) {
			if(fails < MAX_COMMAND_RETRIES) {
				logger.addLine("Recieved unexpected response type, retrying.");
				return PROCESS_COMMAND_RETRY;
			}
			else {
				crashedEndProcess("Recieved unexpected response type with too many failures. Writing logs and ending process.");
				return PROCESS_COMMAND_TERMINATE;
			}
		}
		
		String resp = (String) obj.getResponseData();
		if(!(resp.indexOf("ERROR") >= 0)) {
			logger.addLine("Command successfully recieved and processed");
			return PROCESS_COMMAND_SUCCESS;
		}
		else if(fails < MAX_COMMAND_RETRIES) {
			logger.addLine(resp);
			logger.addLine("Failed to "+info_text+", attempting again");
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				crashedEndProcess("Failed to sleep for 1 second. No longer attempting to "+info_text+". Writing logs and ending process.");
				logger.addLine(returnStackTrace(e));
				return PROCESS_COMMAND_TERMINATE;
			}
			return PROCESS_COMMAND_RETRY;
		}
		else {
			crashedEndProcess("Failed to "+info_text+" too many times. Writing logs.");
			return PROCESS_COMMAND_TERMINATE;
		}
	}
	
	/**
	 * Tells the server to resume the round.
	 * @param fails The number of consecutive failures.
	 */
	private boolean resumeRound(int fails) {
		logger.addLine("Telling server to restart the round");
		ByondResponse obj = server_msgr.RecieveByondResponse("mapdaemon_restart_round&" + UID, (int) Math.pow(read_timeout_increment, fails)*1000);
		
		String s = (String) obj.getResponseData();
		
		if((s == null || s.contains("ERROR")) && fails < MAX_COMMAND_RETRIES) {
			return resumeRound(++fails);
		}
		else if(s != null && s.contains("WILL DO")) {
			logger.addLine("Server says it will restart, terminating program.");
			goodExitEndProcess();
		}
		else if(fails >= MAX_COMMAND_RETRIES) {
			crashedEndProcess("Tried to restart the server but failed too many times");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Gets voting JSON info from the server. This does it's own reply processing since it's actually trying to recieve info.
	 * TODO: Make this neater when I make processCommandStringAttempt()
	 * @param fails The number of consecutive failures.
	 */
	private boolean getNextMap(int fails) {
		logger.addLine("Getting next map from server");
		ByondResponse obj = server_msgr.RecieveByondResponse("mapdaemon_receive_votes&" + UID, (int) Math.pow(read_timeout_increment, fails)*1000);
		
		int flag = processCommandStringAttempt(obj, fails, "get next map");

		if(flag == PROCESS_COMMAND_SUCCESS) {
			logger.addLine("Successfully received votes");
			logger.addLine("Processing recieved data");
			next_map = (String) obj.getResponseData();
			next_map = next_map.substring(0,  next_map.length()-1); //Discarding \u0000 that is appended to the response body for some reason
			
			logger.addLine("Successfully processed and saved the next map: " + next_map);
		}
		else if(flag == PROCESS_COMMAND_RETRY) {
			fails++;
			return getNextMap(fails);
		}
		else if(flag != PROCESS_COMMAND_TERMINATE) {
			crashedEndProcess("Received unknown response code, terminating process");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Takes the JSON vote info as text and makes sure the formatting is correct. It does not actually find the winner.
	 * @param text The JSON text as a String
	 * @return Whether or not the formatting is correct.
	 */
	@SuppressWarnings("unused")
	private boolean testVoteJSON(String text) {
		JSONObject interim = null;
		try {
			interim = new JSONObject(text);
		}
		catch(JSONException e) {
			return false;
		}
		
		for(String s : maps) {
			try {
				Integer I = interim.getInt(s);
				if(I.intValue() >= 0) continue;
				else return false;
			}
			catch(JSONException e) {
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Tells the server to delay the round. This does not toggle the round delay, but actually confirms that it will delay.
	 * @param fails The number of consecutive failures.
	 */
	private boolean delayRound(int fails) {
		logger.addLine("Telling server to delay the round");
		ByondResponse obj = server_msgr.RecieveByondResponse("mapdaemon_delay_round&" + UID, (int) Math.pow(read_timeout_increment, fails)*1000);
		
		int flag = processCommandStringAttempt(obj, fails, "delay round");
		
		//Switches are nasty
		if(flag == PROCESS_COMMAND_SUCCESS) {
			logger.addLine("Successfully delayed round");
		}
		else if(flag == PROCESS_COMMAND_RETRY) {
			fails++;
			return delayRound(fails);
		}
		else if(flag != PROCESS_COMMAND_TERMINATE) {
			crashedEndProcess("Recieved unknown response code, terminating process");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Checks to see if the round has ended.
	 * @return Whether or not the round as ended.
	 */
	private boolean verifyRoundEnded(int fails) {
		
		boolean important = false;
		
		String query_string = "mapdaemon_get_round_status&" + UID;
		
		ByondResponse obj = server_msgr.RecieveByondResponse(query_string, (int) Math.pow(read_timeout_increment, fails)*1000);
		
		if(!obj.getResponseType().equals(ResponseType.FLOAT_NUMBER)) {
			important = true;
			
			fails++;
			
			if(fails >= MAX_COMMAND_RETRIES) {

				logger.addLine("Received incorrect response type.");
				if(obj.getResponseType().equals(ResponseType.STRING)) {
					String s = (String) obj.getResponseData();
					if(s.indexOf("ERROR") >= 0) logger.addLine(s);
				}
				crashedEndProcess("Failed round end checks, writing logs and terminating script.");
				return false;
			}
			else {
				logger.addLine("Failed to recieve the proper response " + fails + " times consecutively.");
				return verifyRoundEnded(fails);
			}
		}
		
		logger.addLine("Checking for round end.", important);
		
		int round_status = ((Float) obj.getResponseData()).intValue();
		
		if(round_status == ROUND_STATUS_OVER) return true;
		else if(round_status == KILL_MAPDAEMON) {
			goodExitEndProcess("Received kill code from server. Terminating...");
		}
		
		return false;
	}
	
	/*
	/**
	 * Just pings the server, getting the number of online players +1. Called to see if the server is online.
	 * @return The number of online players +1
	 */
	/*
	private int pingServer() {
		ByondResponse resp = server_msgr.RecieveByondResponse("ping");
		if(resp.getResponseType().equals(ResponseType.FLOAT_NUMBER)) {
			Float F = (Float) resp.getResponseData();
			return F.intValue();
		}
		return 0;
	}
	*/
	
	/**
	 * Calls a bunch of methods in order to compile the server. Called once the round is over, once a round.
	 */
	private boolean Compile() {
		logger.addLine("Compiling:");
		
		if(!compile_needed) {
			logger.addLine("No compile needed, skipping compile stage.");
			return true;
		}
		String map_filename = "";
		try {
			map_filename = z1_map_preprocess_line + config.getStringFromConfig("game\\maps\\" + next_map) + ".dmm";
		} catch(Exception e) {
			logger.addLine("Something went wrong while getting the next map, reverting to default map");
			logger.addLine(returnStackTrace(e));
			map_filename = default_map;
		}
		logger.addLine("Next compile will be using file: ----->  " + map_filename);
		String dme_path = project_base + "\\" + project_name + ".dme";
		
		boolean modify_success = modifyDME(dme_path, map_filename);
		if(!modify_success) {
			crashedEndProcess("Failed to modify the DME.");
			return false;
		}
		
		String compile_info = compileDME(dme_path);
		boolean compile_success = verifyCompileSuccess(compile_info);
		if(!compile_success) {
			crashedEndProcess("Failed to verify compile success.");
			return false;
		}
		
		boolean copy_success = copyBinaries(project_base, dest_base);
		if(!copy_success) {
			crashedEndProcess("Failed to copy binary files.");
			return false;
		}
		/*
		boolean gm_success = modifyGamemodeFile(next_map);
		if(!gm_success) {
			crashedEndProcess("Failed to modify the gamemode file.");
			return false;
		}*/

		compile_needed = false;
		
		return true;
	}
	/*
	private boolean modifyGamemodeFile(String map) {
		try {
			System.out.println(dest_base + "\\data\\mode.txt");
			Files.write(Paths.get(dest_base + "\\data\\mode.txt"), map.getBytes());
			return true;
		}
		catch(Exception e) {
			logger.addLine(returnStackTrace(e));
			return false;
		}
	}
	*/
	/*
	/**
	 * Process the saved JSON vote info to find the next map to play on.
	 * @return The filename (e.g. Z.01.LV624.dmm) of the map.
	 */
	/*
	private String processVotes() {
		logger.addLine("Finding next map to play on:");
		
		int largest_count = 0;
		String map_name = "";
		for(String s : maps) {
			int votes = next_map.getInt(s);
			if(votes > largest_count) {
				largest_count = votes;
				map_name = s;
			}
		}
		if(map_name.equals("")) map_name = config.getStringFromConfig("game\\maps\\default_map");
		if(!map_name.equals(last_map)) compile_needed = true;
		logger.addLine("Next round will be on: " + map_name);
		return map_name;
	}
	*/
	
	/**
	 * Changes the .dme to include the proper map file.
	 * @param targ_dme The DME to edit.
	 * @param map_filename The new map to use, actually the filename gotten from processVotes()
	 * @return Whether or not it succeeded.
	 */
	private boolean modifyDME(String targ_dme, String map_filename) {
		logger.addLine("Modifying project DME file:");
		
		List<String> lines = null;
		try {
			lines = Files.readAllLines(Paths.get(targ_dme));
		} catch (IOException e) {
			crashedEndProcess("Failed to read project DME, writing logs and terminating script.");
			logger.addLine(returnStackTrace(e));
			return false;
		}
		
		String new_line = "#include \"maps\\" + map_filename + "\"";
		
		for(int i = 0; i < lines.size(); i ++) {
			String s = lines.get(i);
			if(s.indexOf(z1_map_preprocess_line) >= 0) {
				lines.set(i, new_line);
				break;
			}
		}
		
		try {
			Files.write(Paths.get(targ_dme), lines);
		} catch (IOException e) {
			crashedEndProcess("Failed to write the modified DME, writing logs and terminating script");
			logger.addLine(returnStackTrace(e));
			return false;
		}
		
		logger.addLine("Successfully modified " + targ_dme + ".");
		
		return true;
	}
	
	/**
	 * Actually compiles the project.
	 * @param dme_path The path of the .dme
	 * @return The output from dm.exe (the compiler) or "ERROR" if it fucked up. Newline characters included and necessary.
	 */
	private String compileDME(String dme_path) {
		logger.addLine("Executing dm.exe:");
		
		String dm_exe = byond_base + "\\bin\\dm.exe";
		String command = "\"" + dm_exe + "\" \"" + dme_path + "\"";
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(command);
		} catch (IOException e) {
			crashedEndProcess("Failed to execute dm.exe, writing logs and terminating script");
			logger.addLine(returnStackTrace(e));
			return "ERROR";
		}
		
		try {
			p.waitFor(5, TimeUnit.MINUTES);
		} catch (InterruptedException e) {
			crashedEndProcess("Process was interrupted while waiting for compile to complete");
			logger.addLine(returnStackTrace(e));
			return "ERROR";
		}
		
		//All on different lines so if there's a runtime it's easier to identify
		String data = "";
		BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
		try {
			while(reader.ready()) {
				data += reader.readLine();
				data += "\n";
			}
		} catch (IOException e) {
			crashedEndProcess("Runtimed while reading from compiler output. Writing logs and terminating script.");
			logger.addLine(returnStackTrace(e));
			return "ERROR";
		}
		
		return data;
	}
	
	/**
	 * Whether or not the compile succeeded. The bot will end up crashing if it doesn't.
	 * @param data The output from dm.exe (the compiler).
	 * @return true for success, false for failure.
	 */
	private boolean verifyCompileSuccess(String data) {
		logger.addLine("Verifying compile success:");
		
		if(data.equals("")) {
			
		}
		
		if(data.equals("ERROR")) return false;
		
		if(data.equals("")) return true; //Debug stuff
		
		String[] lines = data.split("\n");
		String last_line = lines[lines.length-1];
		
		int error_index = last_line.indexOf("error");
		int warning_index = last_line.indexOf("warning");
		
		int errors = Integer.parseInt(last_line.substring(error_index-2, error_index-1));
		int warnings = Integer.parseInt(last_line.substring(warning_index-2, warning_index-1));
		
		logger.addLine("Compiler output processed. Compile completed with " + errors + " errors and " + warnings + " warnings.");
		
		if(errors > 0 || warnings > 0) {
			logger.addLine(data);
			crashedEndProcess("Compile judged as a failure, writing logs and terminating script");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Moves the output binary files (.rsc, .int, and .dmb) to the directory that DreamDaemon should be running out of so the restart will use the new files.
	 * @param base_path The path of the actually DM code that is compiled.
	 * @param targ_path The destination of the binaries, where DreamDaemon is running off of. Can be an empty folder plus the config directory (admins.txt etc)
	 * @return Success or failure, true or false respectively.
	 */
	private boolean copyBinaries(String base_path, String targ_path) {
		logger.addLine("Copying binary files:");
		
		for(int i = 0; i < binary_files.length; i++) {
			String base_file = base_path + "\\" + project_name + binary_files[i];
			String targ_file = targ_path + "\\" + project_name + binary_files[i];
			
			try {
				CMDCopyFile(base_file, targ_file);
				logger.addLine("Successfully copied " + base_file + " to " + targ_file);
			} catch (Exception e) {
				crashedEndProcess("Failed to copy " + base_file + " to " + targ_file);
				logger.addLine(returnStackTrace(e));
				return false;
			}
		}
		
		logger.addLine("All binary files copied over, ready for next round.");
		
		return true;
	}
	
	/**
	 * Uses CMD to copy a file. Using this instead of Files.copy() so we can force it, like in the case of the .rsc still being in use.
	 * @param source The source file directory as a String. Absolute path encouraged.
	 * @param destination The destination file directory as a String. Absolute path encouraged.
	 * @throws Exception Any recieved exceptions from copying or failure to copy in general.
	 */
	private void CMDCopyFile(String source, String destination) throws Exception {
		String command = "cmd.exe /C copy \"" + source + "\" \"" + destination + "\" /Y";
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(command);
		} catch (Exception e) {
			throw e;
		}
		
		try {
			p.waitFor(15, TimeUnit.SECONDS);
		} catch (Exception e) {
			throw e;
		}
		
		String data = "";
		BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
		try {
			while(reader.ready()) {
				data += reader.readLine();
				data += "\n";
			}
		} catch (Exception e) {
			throw e;
		}
		
		int index = data.indexOf(" file(s) copied");
		if(!data.substring(index-1, index).equals("1")) {
			throw new Exception("Could not copy " + source + "using data:\n\n" + data);
		}
	}
}










