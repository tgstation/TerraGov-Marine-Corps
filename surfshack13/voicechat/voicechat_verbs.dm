
/mob/verb/join_vc()
	set name = "Join"
	set category = "ProxChat"
	if(!SSvoicechat || !SSvoicechat.actually_initialized)
		to_chat(src, span_ooc("voicechat disabled"))
		return
	SSvoicechat.join_vc(client)

/mob/verb/join_with_url()
	set name = "Join with URL"
	set category = "ProxChat"
	if(!SSvoicechat || !SSvoicechat.actually_initialized)
		to_chat(src, span_ooc("voicechat disabled"))
		return

	if(SSvoicechat)
		SSvoicechat.join_vc(client, external=TRUE)

/mob/verb/help_voicechat()
	set name = "Help"
	set category = "ProxChat"
	src << browse({"
	<html>
		<h2>Experimental Proximity Chat</h2>
		<p>
			Try <b>join</b> to load with default browser.
			If the browser fails to open, try <b>"Join with URL"</b> instead.<br>
			Once the external browser is loaded:<br>
				1. When prompted, allow mic perms,.<br>
				2. Verify this is working, by looking for a voice indicator over your mob when speaking.<br>
				3. Drag voicechat to its own window so its only the <b>active tab</b><br>
			If you open a different tab it stops detecting microphone input.
			So make sure voicechat is in its to its own browser window.
		</p>
		<h4>Verbs</h4>
		<p>
			Join - uses default web browser<br>
			Join with URL - gives you link and QR code to use<br>
			Leave - disconnects you from voicechat, note the website doesnt close<br>
			Mute - mutes yourself<br>
			Deafen - deafens yourself<br>
			Note: for security, <b>mute and deafen are one way, use the web browser to unmute</b>
		</p>
		<h4>Trouble shooting tips</h4>
		<p>
			* Ensure browser extensions are off and the page is whitelisted.<br>
			* VPNS occasionally break voicechat.<br>
			* For best results, look up if your browser supports webRTC well.
		</p>
		<h4>Issues</h4>
		<p>
			Note: You cant reuse the same link, from a browser. <b>Every time you reconnect you need to get a new link through
			the Join verbs</b>
		</p>
		<p>
			If your are still having issues, its most likely with microphone setup or rtc connections.
			To verify the microphone is connected on the website, open the settings tabs and click test mic. If you can hear your
			mic playback then its working fine.
			To check if its an RTC connection issue, open your browser debugger console and check for connection failed errors.
			If you confirmed its a connection failure, try messing with your firewall to open the correct ports (usually
			3000).
		</p>
		<h4>Source</h4>
		<p>
			A small demo is availible at <a href="https://github.com/forgman6/voice_chat_byond">github.com/forgman6/voice_chat_byond</a><br>
		</p>
	</html>
	"}, "window=voicechat_help")

/mob/verb/mute_self()
	set name = "Mute"
	set category = "ProxChat"
	if(!SSvoicechat)
		return
	SSvoicechat.mute_mic(client)


/mob/verb/deafen()
	set name = "Deafen"
	set category = "ProxChat"
	if(!SSvoicechat)
		return
	SSvoicechat.mute_mic(client, deafen=TRUE)

/mob/verb/leave()
	set name = "Leave"
	set category = "ProxChat"
	if(!SSvoicechat)
		return
	var/userCode = SSvoicechat.client_userCode_map[client]
	if(!userCode)
		to_chat(src, span_ooc("No connection found, make sure to close the tab"))
		return
	SSvoicechat.disconnect(userCode, from_byond=TRUE)
	to_chat(src, span_ooc("Disconnected"))

ADMIN_VERB(restart_voicechat, R_ADMIN, "Restart Voicechat", "Disconnects voicechat clients and restarts voicechat", "ProxChat.Admin")
	if(!SSvoicechat)
		return

	var/confirm = alert(usr, "Restarting will disconnect everyone from voicechat.", "Restart Voicechat?", "yes", "no", "TWAT's option")

	if(confirm == "yes")
		SSvoicechat.restart()

ADMIN_VERB(stop_voicechat, R_ADMIN, "Stop Voicechat", "disconnects voicechat clients and stops voicechat", "ProxChat.Admin")
	if(SSvoicechat)
		SSvoicechat.Shutdown()
