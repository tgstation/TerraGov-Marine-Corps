package map_daemon;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.json.JSONObject;

import io.github.spair.byond.message.ByondMessage;
import io.github.spair.byond.message.ServerAddress;
import io.github.spair.byond.message.client.ByondClient;
import io.github.spair.byond.message.response.ByondResponse;

@SuppressWarnings("unused")
public class Tester {

	public static void main(String[] args) {
		new Tester();
	}
	
	public Tester() {
		//testConfigRetrieval();
		//testCrashLogger();
		//testTextReceive();
		//testCompilingFromShell();
		testMessaging();
		//testDisabler();
		//testGamemodeFile("LV-624");
		//testCopyRSC();
		//testGetIceColony();
	}
	
	private void testGetIceColony() {
		Config config = new Config("C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\config.json");
		System.out.println(config.getStringFromConfig("game\\maps\\" + "Ice Colony "));
	}

	private void testCMDCopyFile() {
		try {
			CMDCopyFile("C:\\Users\\Sam\\Desktop\\CM branches\\Unfucked\\ColonialMarinesALPHA.rsc", "C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\ColonialMarinesALPHA.rsc");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private void CMDCopyFile(String source, String destination) throws Exception {
		String command = "cmd.exe /C copy \"" + source + "\" \"" + destination + "\" /Y";
		System.out.println(command);
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
		
		System.out.println(data);
	}
	
	private void testCopyRSC() {
		try {
			Files.copy(Paths.get("C:/Users/Sam/Desktop/CM branches/Unfucked/ColonialMarinesALPHA.rsc"),
					Paths.get("C:/Users/Sam/Desktop/MapDaemonExecutables/ColonialMarinesALPHA.rsc"),
					StandardCopyOption.REPLACE_EXISTING);
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	private void testGamemodeFile(String map) {
		try {
			System.out.println(Files.readAllLines(Paths.get("C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\data\\mode.txt")).get(0));
			Files.write(Paths.get("C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\data\\mode.txt"), map.getBytes());
			System.out.println(Files.readAllLines(Paths.get("C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\data\\mode.txt")).get(0));
			return;
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	private void testDisabler() {
		List<String> lines = null;
		try {
			lines = Files.readAllLines(Paths.get("C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\config.json"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String all_data = "";
		for(String s : lines) {
			all_data += s;
		}
		JSONObject j = new JSONObject(all_data);
		JSONObject j2 = j.getJSONObject("prefs");
		//boolean b = j2.getBoolean("enable");
		
		Config config = new Config("C:\\Users\\Sam\\Desktop\\MapDaemonExecutables\\config.json");
		String yeet = config.getStringFromConfig("prefs\\enable");
		System.out.println(yeet);
		boolean b = config.getBooleanFromConfig("prefs\\enable");
		System.out.println(b);
		if(b) {
			System.out.println("yeet was true");
		}
		else {
			System.out.println("yeet was false");
		}
		if(yeet.equals("true")) {
			System.out.println("but it was equal to true");
		}
	}
	
	private void testCompilingFromShell() {
		String command = "\"C:\\Program Files (x86)\\BYOND\\bin\\dm.exe\" \"C:\\Users\\Sam\\Desktop\\CM branches\\Unfucked\\ColonialMarinesALPHA.dme\"";
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(command);
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			p.waitFor(5, TimeUnit.MINUTES);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
		String data = "";
		try {
			while(reader.ready()) {
				data += reader.readLine();
				data += "\n";
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		System.out.println(p.isAlive());
		System.out.println(data);
	}
	
	private void testTextReceive() {
		ByondClient client = new ByondClient();
		ByondMessage message = new ByondMessage(new ServerAddress("play.colonial-marines.com", 1400), "?status");
		ByondResponse response = client.sendMessage(message);
		System.out.println(response);
	}
	
	private void testMessaging() {
		ByondClient client = new ByondClient();
		ByondMessage message = new ByondMessage(new ServerAddress("localhost", 5001), "?ping");
		ByondResponse response = client.sendMessage(message);
		System.out.println(response);
	}
	
	private void testJSONWhitespace() {
		JSONObject j = new JSONObject("{    path:\"r u kiddin me bud\",vvvv:\n\"testying\"}");
		System.out.println(j.toString());
		System.out.println(j.getString("path"));
		System.out.println(j.getString("vvvv"));
	}
	
	private void testStringSplit() {
		String s = "aaa\\bbb\\ccc";
		//String[] a = s.split("\\");
		String[] b = s.split("\\\\");
		//System.out.println(a);
		for(String c : b) {
			System.out.println(c);
		}
	}
	
	private void testConfigRetrieval() {
		Config c = new Config("C:\\Users\\Sam\\Desktop\\WatchDogStorage\\config.json");
		String s = c.getStringFromConfig("paths\\a\\b\\c");
		System.out.println(s);
	}
	
	private void testToStringLinkedList() {
		LinkedList<String> l = new LinkedList<String>();
		l.add("a");
		l.add("b");
		l.add("c");
		l.add("d");
		System.out.println(l.toString());
	}
	
	private void testCrashLogger() {
		//CrashLogger cl = new CrashLogger("C:\\Users\\Sam\\Desktop\\WatchDogStorage\\logs");
		//cl.addLine("Important info");
		//cl.addLine("more important stuff");
		//cl.close(true);
	}
}













