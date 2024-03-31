SUBSYSTEM_DEF(lobbymenu)
	name = "Lobbyrefresh"
	wait = 20
	priority = 100
	flags = SS_NO_INIT
//	runlevels = RUNLEVEL_SETUP | RUNLEVEL_LOBBY | RUNLEVEL_GAME
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_LOBBY
	var/list/currentrun = list()

/datum/controller/subsystem/lobbymenu/fire(resumed = 0)
	if(!resumed)
		currentrun = GLOB.new_player_list.Copy()

	while(currentrun.len)
		var/mob/dead/new_player/player = currentrun[currentrun.len]
		currentrun.len--
		if(player.client)
			player.lobby_refresh()
		if (MC_TICK_CHECK)
			return