package map_daemon;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

public class CrashLogger {

	private String directory;
	private LinkedList<String> data;
	private SimpleDateFormat line_date_format;
	private SimpleDateFormat file_name_format;
	private boolean closed;
	private boolean verbose;

	public CrashLogger(String directory, boolean verbose) {
		this.directory = directory;
		this.verbose = verbose;
		data = new LinkedList<String>();
		line_date_format = new SimpleDateFormat("HH-mm-ss");
		file_name_format = new SimpleDateFormat("yyyy-MM-dd HH-mm-ss");
		closed = false;
	}

	public void addLine(String s, boolean important) {
		if(closed || !important) return;
		if(verbose) System.out.println(s);
		Date date = new Date();
		data.add("[" + line_date_format.format(date) + "]: " + s);
	}

	public void addLine(String s) {
		addLine(s, true);
	}

	private boolean writeInfo() {
		cleanUpLogs();
		
		Date date = new Date();
		directory += "\\" + file_name_format.format(date) + ".log";
		try {
			Files.write(Paths.get(directory), data, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
		}
		catch(IOException e) {
			addLine(MapDaemon.returnStackTrace(e));
			return false;
		}
		return true;
	}

	private void cleanUpLogs() {
		for(int i = 0; i < data.size() - 1; i++) {
			if(data.get(i).equals(data.get(i+1))) {
				data.remove(i);
				i--;
			}
		}
	}

	public boolean getClosed() {
		return closed;
	}

	public List<String> getData() {
		return data;
	}

	/**
	 * Doesn't allow more logs to be written.
	 * @param crashed true if it should actually write the logs to the file.
	 * @return If it succeeded in writng the logs.
	 */
	public boolean close(boolean crashed) {
		if(closed) return true;
		if(crashed) {
			return writeInfo();
		}
		closed = true;
		return true;
	}
}
