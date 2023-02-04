
/*!
 * Screen Lobby objects
 * Uses maptext to display the objects
 * Automatically will align in the order that they are defined
 * Stuff happens on Click(), although hrefs are also valid to get stuff done
 * hrefs will make the text blue though  so dont do it :/
 */

///Unclickable Lobby UI objects
/atom/movable/screen/text/lobby
	screen_loc = "CENTER"
	maptext_height = 480
	maptext_width = 480
	maptext_x = 24
	maptext_y = 9

/**
 * What the hell is this proc? you might be asking
 * Well this is the answer to a wierd ass bug where the hud datum passes null to Initialize instead of a reference to itself
 * Why does this happen? I'd love to know but noone else has so far
 * Please fix it so you dont have to manually set the owner and this junk to make it work
 *
 * This proc sets the maptext of the screen obj when it's updated
 */
/atom/movable/screen/text/lobby/proc/set_text()
	SIGNAL_HANDLER
	return

/atom/movable/screen/text/lobby/title
	icon = 'icons/UI_Icons/lobbytext.dmi'
	icon_state = "tgmc"

///Clickable UI lobby objects which do stuff on Click() when pressed
/atom/movable/screen/text/lobby/clickable
	maptext = "if you see this a coder was stinky"
	icon = 'icons/UI_Icons/lobby_button.dmi' //hitbox prop
	mouse_opacity = MOUSE_OPACITY_ICON

/atom/movable/screen/text/lobby/clickable/MouseEntered(location, control, params)
	. = ..()
	color = COLOR_ORANGE
	var/mob/new_player/player = usr
	player.playsound_local(player, 'sound/effects/menu_click.ogg', 50)

/atom/movable/screen/text/lobby/clickable/MouseExited(location, control, params)
	. = ..()
	color = initial(color)

/atom/movable/screen/text/lobby/clickable/Click()
	var/mob/new_player/player = usr
	player.playsound_local(player, 'sound/effects/menu_select.ogg', 50)


/atom/movable/screen/text/lobby/clickable/setup_character
	maptext = "<span class='maptext' style=font-size:6px>CHARACTER: ...</span>"
	icon_state = "setup"
	///Bool, whether we registered to listen for charachter updates already
	var/registered = FALSE
	maptext_y = 11

/atom/movable/screen/text/lobby/clickable/setup_character/Initialize(mapload)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/set_text)//stupid fucking initialize bug fuck you
		return
	set_text()

/atom/movable/screen/text/lobby/clickable/setup_character/Click()
	. = ..()
	hud.mymob.client?.prefs.ShowChoices(hud.mymob)

/atom/movable/screen/text/lobby/clickable/setup_character/set_text()
	maptext = "<span class='maptext' style=font-size:6px>CHARACTER: [hud.mymob.client ? hud.mymob.client.prefs.real_name : "Unknown User"]</span>"
	if(!registered)
		RegisterSignal(hud.mymob.client, COMSIG_CLIENT_PREFERENCES_UIACTED, .proc/set_text)
		registered = TRUE

/atom/movable/screen/text/lobby/clickable/join_game
	maptext = "<span class='maptext' style=font-size:8px>JOIN GAME</span>"
	icon_state = "join"

/atom/movable/screen/text/lobby/clickable/join_game/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.attempt_late_join()


/atom/movable/screen/text/lobby/clickable/observe
	maptext = "<span class='maptext' style=font-size:8px>OBSERVE</span>"
	icon_state = "observe"

/atom/movable/screen/text/lobby/clickable/observe/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.try_to_observe()

/atom/movable/screen/text/lobby/clickable/ready
	maptext = "<span class='maptext' style=font-size:8px>YOU ARE: NOT READY</span>"
	icon_state = "unready"

/atom/movable/screen/text/lobby/clickable/ready/Initialize(mapload)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/set_text)//stupid fucking initialize bug fuck you
		return
	set_text()

/atom/movable/screen/text/lobby/clickable/ready/set_text()
	var/mob/new_player/player = hud.mymob
	maptext = "<span class='maptext' style=font-size:8px>YOU ARE: [player.ready ? "" : "NOT "]READY</span>"

/atom/movable/screen/text/lobby/clickable/ready/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.toggle_ready()
	icon_state = player.ready ? "ready" : "unready"
	set_text()

/atom/movable/screen/text/lobby/clickable/manifest
	maptext = "<span class='maptext' style=font-size:8px>VIEW MANIFEST</span>"
	icon_state = "manifest"

/atom/movable/screen/text/lobby/clickable/manifest/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_manifest()

/atom/movable/screen/text/lobby/clickable/background
	maptext = "<span class='maptext' style=font-size:8px>BACKGROUND</span>"
	icon_state = "background"

/atom/movable/screen/text/lobby/clickable/background/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_lore()


/atom/movable/screen/text/lobby/clickable/changelog
	maptext = "<span class='maptext' style=font-size:8px>CHANGELOG</span>"
	icon_state = "changelog"

/atom/movable/screen/text/lobby/clickable/changelog/Click()
	. = ..()
	hud.mymob.client?.changes()


/atom/movable/screen/text/lobby/clickable/polls
	maptext = "<span class='maptext' style=font-size:8px>POLLS</span>"
	icon_state = "poll"

/atom/movable/screen/text/lobby/clickable/polls/Initialize(mapload, atom/one, atom/two)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/fetch_polls)//stupid fucking initialize bug fuck you
		return
	INVOKE_ASYNC(src, .proc/fetch_polls)

///This proc is invoked async to avoid sleeping in Initialize and fetches polls from the DB
/atom/movable/screen/text/lobby/clickable/polls/proc/fetch_polls()
	var/mob/new_player/player = hud.mymob
	var/hasnewpolls = player.check_playerpolls()
	if(isnull(hasnewpolls))
		maptext = "<span class='maptext' style=font-size:8px>NO DATABASE!</span>"
		return
	maptext = "<span class='maptext' style=font-size:8px>SHOW POLLS[hasnewpolls ? " (NEW!)" : ""]</span>"

/atom/movable/screen/text/lobby/clickable/polls/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.handle_playeR_DBRANKSing()
	fetch_polls()

