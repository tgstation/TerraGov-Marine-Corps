
/*!
 * Screen Lobby objects
 * Uses maptext to display the objects
 * Automatically will align in the order that they are defined
 * Stuff happens on Click(), although hrefs are also valid to get stuff done
 * hrefs will make the text blue though  so dont do it :/
 */

#define COLOR_HOVER_MOUSE COLOR_ORANGE
#define MAX_CHAR_NAME_DISPLAYED 22

//its a new player yo they join instantly
INITIALIZE_IMMEDIATE(/atom/movable/screen/text/lobby)

///Unclickable Lobby UI objects
/atom/movable/screen/text/lobby
	plane = SPLASHSCREEN_PLANE
	layer = LOBBY_MENU_LAYER
	screen_loc = "CENTER"
	maptext_height = 480
	maptext_width = 480
	maptext_x = 28
	maptext_y = 6
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// if this text has a different color that we want to display when it's not being mosued over
	var/unhighlighted_color

/atom/movable/screen/text/lobby/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	add_atom_colour(unhighlighted_color, FIXED_COLOR_PRIORITY)
	update_text()

///This proc updates the maptext of the buttons.
/atom/movable/screen/text/lobby/proc/update_text()
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
	if(!(atom_flags & INITIALIZED)) //yes this can happen, fuck me
		return
	add_atom_colour(COLOR_HOVER_MOUSE, TEMPORARY_COLOR_PRIORITY)
	var/mob/new_player/player = usr
	player.playsound_local(player, 'sound/effects/menu_click.ogg', 50)

/atom/movable/screen/text/lobby/clickable/MouseExited(location, control, params)
	. = ..()
	remove_atom_colour(TEMPORARY_COLOR_PRIORITY, COLOR_HOVER_MOUSE)

/atom/movable/screen/text/lobby/clickable/Click()
	if(!(atom_flags & INITIALIZED)) //yes this can happen, fuck me
		to_chat(usr, span_warning("The game is still setting up, please try again later."))
		return
	var/mob/new_player/player = usr
	player.playsound_local(player, 'sound/effects/menu_select.ogg', 50)

/atom/movable/screen/text/lobby/clickable/setup_character
	maptext = "<span class='lobbytext'>CHARACTER LOADING</span>"
	icon_state = "setup"
	maptext_x = 23
	///Bool, whether we registered to listen for charachter updates already
	var/registered = FALSE

/atom/movable/screen/text/lobby/clickable/setup_character/Click()
	. = ..()
	hud.mymob.client?.prefs.ShowChoices(hud.mymob)

/atom/movable/screen/text/lobby/clickable/setup_character/update_text()
	var/nametouse = hud?.mymob.client ? hud.mymob.client.prefs.real_name : "Unknown Character"
	if(length(nametouse) > MAX_CHAR_NAME_DISPLAYED)
		nametouse = trim(nametouse, MAX_CHAR_NAME_DISPLAYED) + "..."
	maptext = "<span class='lobbytext'>[nametouse]</span>"
	if(registered)
		return
	RegisterSignal(hud.mymob.client, COMSIG_CLIENT_PREFERENCES_UIACTED, PROC_REF(update_text))
	registered = TRUE

/atom/movable/screen/text/lobby/clickable/join_game
	maptext = "<span class='lobbytext'>JOIN GAME</span>"
	icon_state = "join"

/atom/movable/screen/text/lobby/clickable/join_game/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_GAMEMODE_LOADED, TYPE_PROC_REF(/atom/movable/screen/text/lobby, update_text))

/atom/movable/screen/text/lobby/clickable/join_game/update_text()
	var/mob/new_player/player = hud.mymob
	if(SSticker?.current_state > GAME_STATE_PREGAME)
		maptext = "<span class='lobbytext'>JOIN GAME</span>"
		icon_state = "join"
		remove_atom_colour(FIXED_COLOR_PRIORITY, unhighlighted_color)
		return
	remove_atom_colour(FIXED_COLOR_PRIORITY, unhighlighted_color)
	unhighlighted_color = player.ready ? COLOR_GREEN : COLOR_RED
	add_atom_colour(unhighlighted_color, FIXED_COLOR_PRIORITY)
	maptext = "<span class='lobbytext'>YOU ARE: [player.ready ? "" : "NOT "]READY</span>"
	icon_state = player.ready ? "ready" : "unready"

/atom/movable/screen/text/lobby/clickable/join_game/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	if(SSticker?.current_state > GAME_STATE_PREGAME)
		player.attempt_late_join()
		return
	player.toggle_ready()
	update_text()


/atom/movable/screen/text/lobby/clickable/observe
	maptext = "<span class='lobbytext'>OBSERVE</span>"
	icon_state = "observe"

/atom/movable/screen/text/lobby/clickable/observe/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.try_to_observe()

/atom/movable/screen/text/lobby/clickable/manifest
	maptext = "<span class='lobbytext'>VIEW MANIFEST</span>"
	icon_state = "manifest"

/atom/movable/screen/text/lobby/clickable/manifest/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_manifest()

/atom/movable/screen/text/lobby/clickable/xenomanifest
	maptext = "<span class='lobbytext'>VIEW HIVE LEADERS</span>"
	icon_state = "manifest"

/atom/movable/screen/text/lobby/clickable/xenomanifest/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_xeno_manifest()

/atom/movable/screen/text/lobby/clickable/background
	maptext = "<span class='lobbytext'>BACKGROUND</span>"
	icon_state = "background"

/atom/movable/screen/text/lobby/clickable/background/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_lore()


/atom/movable/screen/text/lobby/clickable/changelog
	maptext = "<span class='lobbytext'>CHANGELOG</span>"
	icon_state = "changelog"

/atom/movable/screen/text/lobby/clickable/changelog/Click()
	. = ..()
	hud.mymob.client?.changes()


/atom/movable/screen/text/lobby/clickable/polls
	maptext = "<span class='lobbytext'>POLLS</span>"
	icon_state = "poll"

/atom/movable/screen/text/lobby/clickable/polls/update_text()
	INVOKE_ASYNC(src, PROC_REF(fetch_polls)) //this sleeps and it shouldn't because update_text uses a signal sometimes

///Proc that fetches the polls, exists so we can async it in update_text
/atom/movable/screen/text/lobby/clickable/polls/proc/fetch_polls()
	var/mob/new_player/player = hud.mymob
	var/hasnewpolls = player.check_playerpolls()
	if(isnull(hasnewpolls))
		maptext = "<span class='lobbytext'>NO DATABASE!</span>"
		return
	maptext = "<span class='lobbytext'>SHOW POLLS[hasnewpolls ? " (NEW!)" : ""]</span>"

/atom/movable/screen/text/lobby/clickable/polls/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.handle_playeR_POLLSing()
	fetch_polls()

#undef COLOR_HOVER_MOUSE
#undef MAX_CHAR_NAME_DISPLAYED
