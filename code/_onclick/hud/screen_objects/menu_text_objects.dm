
/*!
 * Screen Lobby objects
 * Uses maptext to display the objects
 * Automatically will align in the order that they are defined
 * Stuff happens on Click(), although hrefs are also valid to get stuff done
 * hrefs will make the text blue though :/
 */

///Unclickable Lobby UI objects
/obj/screen/text/lobby
	screen_loc = "CENTER"
	maptext_height = 480
	maptext_width = 480
	maptext = "If you see this yell at coders"


/obj/screen/text/lobby/title
	maptext = "<span class=menutext>Welcome to TGMC</span>"

/obj/screen/text/lobby/title/Initialize()
	. = ..()
	maptext = "<span class=menutext>Welcome to TGMC[SSmapping?.configs ? " - [SSmapping.configs[SHIP_MAP].map_name]" : ""]</span>"


/obj/screen/text/lobby/year
	maptext = "<span class=menutext>Current Year: ERROR</span>"

/obj/screen/text/lobby/year/Initialize()
	. = ..()
	maptext = "<span class=menutext>Current Year: [GAME_YEAR]</span>"


/obj/screen/text/lobby/owners_char
	screen_loc = "CENTER-7,CENTER-7"
	maptext = "<span class=menutext>Loading...</span>"

/obj/screen/text/lobby/owners_char/Initialize(mapload)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/update_appeared_name)//used to dodge some a race condition when sending back to lobby
		return
	update_appeared_name()

/obj/screen/text/lobby/owners_char/proc/update_appeared_name()
	SIGNAL_HANDLER
	maptext = "<span class=menutext>Current character: [hud.mymob.client ? hud.mymob.client.prefs.real_name : "Unknown User"]</span>"

///Clickable UI lobby objects which do stuff on Click() when pressed
/obj/screen/text/lobby/clickable
	maptext = "if you see this a coder was stinky"
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/obj/screen/text/lobby/clickable/Click()
	var/mob/new_player/player = usr
	player.playsound_local(player, "bloop", 50)

/obj/screen/text/lobby/clickable/MouseEntered(location, control, params)
	. = ..()
	color = COLOR_RED
	var/matrix/M = matrix()
	M.Scale(1.1, 1.1)
	animate(src, transform = M, time = 1, easing = CUBIC_EASING)
	var/mob/new_player/player = usr
	player.playsound_local(player, 'sound/effects/menu_click.ogg', 50)

/obj/screen/text/lobby/clickable/MouseExited(location, control, params)
	. = ..()
	animate(src, transform = null, time = 1, easing = CUBIC_EASING)
	color = initial(color)


/obj/screen/text/lobby/clickable/setup_character
	maptext = "<span class=menutext>Setup Character</span>"

/obj/screen/text/lobby/clickable/setup_character/Click()
	. = ..()
	hud.mymob.client?.prefs.ShowChoices(hud.mymob)


/obj/screen/text/lobby/clickable/join_game
	maptext = "<span class=menutext>Join Game</span>"

/obj/screen/text/lobby/clickable/join_game/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.attempt_late_join()


/obj/screen/text/lobby/clickable/observe
	screen_loc = "CENTER"
	maptext = "<span class=menutext>Observe</span>"

/obj/screen/text/lobby/clickable/observe/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.try_to_observe()


/obj/screen/text/lobby/clickable/ready
	maptext = "<span class=menutext>Not ready</span>"

/obj/screen/text/lobby/clickable/ready/Initialize(mapload)
	. = ..()
	var/mob/new_player/player = hud.mymob
	maptext = "<span class=menutext>[player.ready ? "" : "Not "]Ready</span>"

/obj/screen/text/lobby/clickable/ready/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.toggle_ready()
	maptext = "<span class=menutext>[player.ready ? "" : "Not "]Ready</span>"


/obj/screen/text/lobby/clickable/changelog
	maptext = "<span class=menutext>Changelog</span>"

/obj/screen/text/lobby/clickable/changelog/Click()
	. = ..()
	hud.mymob.client?.changes()


/obj/screen/text/lobby/clickable/background
	maptext = "<span class=menutext>Background</span>"

/obj/screen/text/lobby/clickable/background/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_lore()


/obj/screen/text/lobby/clickable/polls
	maptext = "<span class=menutext>Polls</span>"

/obj/screen/text/lobby/clickable/polls/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, .proc/fetch_polls)

///This proc is invoked async to avoid sleeping in Initialize and fetches polls from the DB
/obj/screen/text/lobby/clickable/polls/proc/fetch_polls()
	var/mob/new_player/player = hud.mymob
	var/pollstring = player.playerpolls()
	if(!pollstring)
		pollstring = "No Database connection!"
	maptext = "<span class=menutext>" + pollstring + "</span>"
//no Click() needed because hrefs in playerpolls()


/obj/screen/text/lobby/clickable/manifest
	maptext = "<span class=menutext>View Manifest</span>"

/obj/screen/text/lobby/clickable/manifest/Click()
	var/mob/new_player/player = hud.mymob
	player.view_manifest()
