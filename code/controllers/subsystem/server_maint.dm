#define PING_BUFFER_TIME 25

SUBSYSTEM_DEF(server_maint)
	name = "Server Tasks"
	wait = 6
	flags = SS_POST_FIRE_TIMING
	priority = FIRE_PRIORITY_SERVER_MAINT
	init_order = INIT_ORDER_SERVER_MAINT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/list/currentrun
	var/cleanup_ticker = 0


/datum/controller/subsystem/server_maint/PreInit()
	world.hub_password = ""


/datum/controller/subsystem/server_maint/Initialize(timeofday)
	if(CONFIG_GET(flag/hub))
		world.update_hub_visibility(TRUE)
	return ..()


/datum/controller/subsystem/server_maint/fire(resumed = FALSE)
	if(!resumed)
		if(listclearnulls(GLOB.clients))
			log_world("Found a null in clients list!")
		src.currentrun = GLOB.clients.Copy()

		switch(cleanup_ticker) //do only one of these at a time, once per 5 fires
			if(0)
				if(listclearnulls(GLOB.player_list))
					log_world("Found a null in player_list!")
				cleanup_ticker++
			if(5)
				if(listclearnulls(GLOB.mob_list))
					log_world("Found a null in mob_list!")
				cleanup_ticker++
			if(10)
				if(listclearnulls(GLOB.alive_living_list))
					log_world("Found a null in alive_living_list!")
				cleanup_ticker++
			if(15)
				if(listclearnulls(GLOB.human_mob_list))
					log_world("Found a null in human_mob_list!")
				cleanup_ticker++
			if(20)
				cleanup_ticker = 0
			else
				cleanup_ticker++


	var/list/currentrun = src.currentrun
	var/round_started = SSticker.HasRoundStarted()

	var/kick_inactive = CONFIG_GET(flag/kick_inactive)
	var/afk_period
	if(kick_inactive)
		afk_period = CONFIG_GET(number/afk_period)
	for(var/I in currentrun)
		var/client/C = I
		//handle kicking inactive players
		if(round_started && kick_inactive && !check_other_rights(C, R_ADMIN, FALSE) && C.is_afk(afk_period))
			var/cmob = C.mob
			if(!isnewplayer(cmob))
				log_access("AFK: [key_name(C)]")
				to_chat(C, "<span class='userdanger'>You have been inactive for more than [DisplayTimeText(afk_period)] and have been disconnected.</span><br><span class='danger'You may reconnect via the button in the file menu or by <b><u><a href='byond://winset?command=.reconnect'>clicking here to reconnect</a></b></u></span>")
				QDEL_IN(C, 1) //to ensure they get our message before getting disconnected
				continue

		if(C && world.time - C.connection_time >= PING_BUFFER_TIME && C.inactivity < (wait - 1))
			winset(C, null, "command=.update_ping+[world.time + world.tick_lag * TICK_USAGE_REAL / 100]")

		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/server_maint/Shutdown()
	var/server = CONFIG_GET(string/server)
	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/client/C = thing
		var/datum/chatOutput/CO = C.chatOutput
		if(SSticker.graceful && CO)
			CO.ehjax_send(data = "shutdown")
			continue
		if(CO)
			CO.ehjax_send(data = "roundrestart")
		if(server)
			C << link("byond://[server]")


#undef PING_BUFFER_TIME
