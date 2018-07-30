package map_daemon;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * TODO: Make getting other data types easy and in this class.
 * @author Sam
 *
 */
public class Config {
	
	private JSONObject info;
	private int status;
	
	public static final int STATUS_UNUSABLE = 1;
	public static final int STATUS_READY = 2;
	
	public static final String ERROR_UNUSABLE = "ERROR: CONFIG UNUSABLE";
	public static final String ERROR_BAD_INDEX = "ERROR: BAD INDEX PASSED";

	public Config(String directory) {
		status = STATUS_UNUSABLE;
		try {
			List<String> lines = Files.readAllLines(Paths.get(directory));
			String all_data = "";
			for(String s : lines) {
				String a = s.trim();
				if(a.startsWith("###")) continue;
				all_data += s;
			}
			info = new JSONObject(all_data);
		}
		catch(IOException e) {
			info = null;
			return;
		}
		status = STATUS_READY;
	}
	
	public int getStatus() {
		return status;
	}
	
	/**
	 * Just gets a String from the JSON file.
	 * @param path The json path, using double backslashes ("\\") between keys.
	 * @return The String
	 */
	public String getStringFromConfig(String path) {
		if(status == STATUS_UNUSABLE) return ERROR_UNUSABLE;
		
		String[] keys = path.split("\\\\"); //Translates into a single "\" because fuck strings
		JSONObject interim_a, interim_b = info;
		
		for(int i = 0; i < keys.length-1; i++) {
			interim_a = interim_b;
			interim_b = interim_a.getJSONObject(keys[i]);
		}
		String to_return = ERROR_BAD_INDEX;
		try {
			to_return = interim_b.getString(keys[keys.length-1]);
		}
		catch(JSONException e) {
			throw e;
		}
		return to_return;
	}
	
	public boolean getBooleanFromConfig(String path) {
		if(status == STATUS_UNUSABLE) return false;
		
		String[] keys = path.split("\\\\"); //Translates into a single "\" because fuck strings
		JSONObject interim_a, interim_b = info;
		
		for(int i = 0; i < keys.length-1; i++) {
			interim_a = interim_b;
			interim_b = interim_a.getJSONObject(keys[i]);
		}
		boolean to_return = false;
		try {
			to_return = interim_b.getBoolean(keys[keys.length-1]);
		}
		catch(JSONException e) {
			throw e;
		}
		return to_return;
	}
}
