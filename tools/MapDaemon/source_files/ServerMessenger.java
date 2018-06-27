package map_daemon;

import io.github.spair.byond.message.ByondMessage;
import io.github.spair.byond.message.ServerAddress;
import io.github.spair.byond.message.client.ByondClient;
import io.github.spair.byond.message.client.exceptions.communicator.HostUnavailableException;
import io.github.spair.byond.message.client.exceptions.converter.EmptyResponseException;
import io.github.spair.byond.message.response.ByondResponse;
import io.github.spair.byond.message.response.ResponseType;

/**
 * This is a wrapper class for io.github.spair.byond stuff.
 * Pretty simple, where it just tries to handle all exceptions before returning data.
 * @author Sam
 *
 */
public class ServerMessenger {
	
	/**
	 * The address to send messages to.
	 */
	private ServerAddress server_address;
	
	private static final String ERROR_HOST_UNAVAILABLE = "ERROR: HOST WAS UNAVAILABLE";
	private static final String ERROR_EMPTY_RESPONSE = "ERROR: RECIEVED AN EMPTY RESPONSE";
	private static final String ERROR_GENERAL_ERROR = "ERROR: UNANTICIPATED PROBLEM ENCOUNTERED";
	
	/**
	 * Instatiates the object itself and the server address
	 * @param play_url The IP or URL
	 * @param port The port
	 */
	public ServerMessenger(String play_url, int port) {
		server_address = new ServerAddress(play_url, port);
	}
	
	/**
	 * Sends a command and recieves a message, returned as a ByondResponse object.
	 * @param command The command as a String, without the "?" delimiter. Ex: "ping"
	 * @param readTimeout The time, in ms, to wait before returning whatever response has been recieved. If the value is -1, then the default (1000 ms) timeout is used.
	 * @return The recieved message as a ByondResponse object.
	 */
	public ByondResponse RecieveByondResponse(String command, int readTimeout) {
		String error_msg = "";
		try{
			ByondClient client = new ByondClient();
			ByondMessage message = new ByondMessage(server_address, "?" + command);
			if(readTimeout == -1) {
				return client.sendMessage(message);
			}
			else {
				return client.sendMessage(message, readTimeout);
			}
		}
		catch(HostUnavailableException e) {
			error_msg = ERROR_HOST_UNAVAILABLE;
			error_msg += ":\n";
			error_msg += MapDaemon.returnStackTrace(e);
		}
		catch(EmptyResponseException e) {
			error_msg = ERROR_EMPTY_RESPONSE;
			error_msg += ":\n";
			error_msg += MapDaemon.returnStackTrace(e);
		}
		catch(Exception e) {
			error_msg = ERROR_GENERAL_ERROR;
			error_msg += ":\n";
			error_msg += MapDaemon.returnStackTrace(e);
		}
		//If we've gotten this far, we have a magical problem
		ByondResponse error_resp = new ByondResponse();
		error_resp.setResponseType(ResponseType.STRING);
		error_resp.setResponseData(error_msg);
		return error_resp;
	}
	
	/**
	 * Calls RecieveByondResponse(command, -1), which just uses the default (1000 ms) read timeout
	 * @param command The command to execute server-side
	 * @return The recieved message as a ByondResponse object.
	 */
	public ByondResponse RecieveByondResponse(String command) {
		return RecieveByondResponse(command, -1); //Make it use the default
	}
}
