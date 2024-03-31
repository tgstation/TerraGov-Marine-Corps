
/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	///Contains admin info. Null if client is not an admin.
	var/datum/admins/holder = null
 	///Needs to implement InterceptClickOn(user,params,atom) proc
	var/datum/click_intercept = null
	///Used for admin AI interaction
	var/AI_Interact = FALSE

 	///Used to cache this client's bans to save on DB queries
	var/ban_cache = null
 	///Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message = ""
	///contins a number of how many times a message identical to last_message was sent.
	var/last_message_count = 0
	///How many messages sent in the last 10 seconds
	var/total_message_count = 0
	///Next tick to reset the total message counter
	var/total_count_reset = 0
	///Internal counter for clients sending irc relay messages via ahelp to prevent spamming. Set to a number every time an admin reply is sent, decremented for every client send.
	var/ircreplyamount = 0

		/////////
		//OTHER//
		/////////
	///Player preferences datum for the client
	var/datum/preferences/prefs = null
	///last turn of the controlled mob, I think this is only used by mechs?
	var/last_turn = 0
	///Move delay of controlled mob, related to input handling
	var/move_delay = 0
	///Current area of the controlled mob
	var/area = null

		///////////////
		//SOUND STUFF//
		///////////////
	///Currently playing ambience sound
	var/ambience_playing = null
	///Whether an ambience sound has been played and one shouldn't be played again, unset by a callback
	var/list/played = list()
	var/list/nextspooky = 0

	var/patreonlevel = -1

		////////////
		//SECURITY//
		////////////
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	///Used to determine how old the account is - in days.
	var/player_age = -1
 	///Date that this account was first seen in the server
	var/player_join_date = null
	///So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_ip = "Requires database"
	///So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/related_accounts_cid = "Requires database"
	///Date of byond account creation in ISO 8601 format
	var/account_join_date = null
	///Age of byond account in days
	var/account_age = -1

	preload_rsc = PRELOAD_RSC

	var/obj/screen/click_catcher/void

	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_up_icon = null
	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_down_icon = null

	///Used for ip intel checking to identify evaders, disabled because of issues with traffic
	var/ip_intel = "Disabled"

	///datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	///Last ping of the client
	var/lastping = 0
	///Average ping of the client
	var/avgping = 0
 	///world.time they connected
	var/connection_time
 	///world.realtime they connected
	var/connection_realtime
 	///world.timeofday they connected
	var/connection_timeofday

	///If the client is currently in player preferences
	var/inprefs = FALSE
	///Used for limiting the rate of topic sends by the client to avoid abuse
	var/list/topiclimiter
	///Used for limiting the rate of clicks sends by the client to avoid abuse
	var/list/clicklimiter

	///goonchat chatoutput of the client
	var/datum/chatOutput/chatOutput

 	///lazy list of all credit object bound to this client
	var/list/credits = list()

 	///these persist between logins/logouts during the same round.
	var/datum/player_details/player_details

	///Should only be a key-value list of north/south/east/west = obj/screen.
	var/list/char_render_holders

	///Amount of keydowns in the last keysend checking interval
	var/client_keysend_amount = 0
	///World tick time where client_keysend_amount will reset
	var/next_keysend_reset = 0
	///World tick time where keysend_tripped will reset back to false
	var/next_keysend_trip_reset = 0
	///When set to true, user will be autokicked if they trip the keysends in a second limit again
	var/keysend_tripped = FALSE

	var/obj/screen/movable/mouseover/mouseovertext
	var/obj/screen/movable/mouseover/mouseoverbox
	///custom movement keys for this client
	var/list/movement_keys = list()

	/// Messages currently seen by this client
	var/list/seen_messages

	var/list/current_weathers = list()
	var/last_lighting_update = 0

	var/list/open_popups = list()

	var/discord_registration
	var/discord_name

	var/loop_sound = FALSE
	var/rain_sound = FALSE
	var/last_droning_sound
	var/sound/droning_sound

/client/proc/update_weather(force)
	if(!mob)
		return
	if(!isobserver(mob) && !isliving(mob))
		return
	if(!force)
		if(last_lighting_update)
			if(length(last_lighting_update & list(mob.x, mob.y, mob.z)) == 3)
				return
	last_lighting_update = list(mob.x, mob.y, mob.z)
	var/area/A = get_area(mob)
	var/obj/PMW = locate(/obj/screen/plane_master/weather) in screen
	if(PMW && A)
		if(A.outdoors)
			PMW.filters = list()
		else
			if(!PMW.filters || !islist(PMW.filters) || !PMW.filters.len)
				PMW.filters = filter(type="alpha", render_source = "*rainzone", flags = MASK_INVERSE)

	for(var/W in current_weathers)
		var/found = FALSE
		for(var/datum/weather/WE in SSweather.curweathers)
			if(WE.type == W)
				if(WE.stage == MAIN_STAGE)
					for(var/image/I in current_weathers[W])
						if(!(I in images))
							images += I
					for(var/obj/O in current_weathers[W])
						if(!(O in screen))
							screen += O
					found = TRUE
		if(!found)
			for(var/I in current_weathers[W])
				current_weathers[W] -= I
				fade_weather(I)

	for(var/datum/weather/WE in SSweather.curweathers)
		if(WE.stage != MAIN_STAGE)
			continue
		if(!current_weathers[WE.type])
			current_weathers[WE.type] = list()
		for(var/image/P in current_weathers[WE.type]) //need to update position of particles
			current_weathers[WE.type] -= P
			fade_weather(P)
		for(var/P in WE.particles)
			if(ispath(P,/obj/emitters/weather))
				var/obj/emitters/PE = new P
				var/image/I = image(null,mob.loc)
				I.plane = WEATHER_PLANE
				I.vis_contents += PE
				images += I
				current_weathers[WE.type] += I
			else
				var/found = FALSE
				for(var/obj/screen/WO in current_weathers[WE.type])
					if(istype(WO,P))
						found = TRUE
						break
				if(found)
					continue
				var/obj/screen/PE = new P()
				screen += PE
				current_weathers[WE.type] += PE

/client/proc/fade_weather(var/W)
	if(!W)
		return
	var/image/P = W
	if(istype(P))
		animate(P,alpha = 0, time=20)
		addtimer(CALLBACK(src,.proc/kill_weather,P),20)
	else //screen obj
		var/obj/screen/O = W
		animate(O,alpha = 0, time=10)
		addtimer(CALLBACK(src,.proc/kill_weather,O),10)


/client/proc/kill_weather(var/P)
	if(!P)
		return
	var/image/I = P
	if(istype(I))
		images -= I
		for(var/obj/O in I.vis_contents)
			I.vis_contents -= O
			qdel(O)
		qdel(I)
	else
		screen -= P
		qdel(P)