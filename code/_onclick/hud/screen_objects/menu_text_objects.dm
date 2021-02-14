
/*!
 * Screen Lobby objects
 * Uses maptext to display the objects
 * Automatically will align in the order that they are defined
 * Stuff happens on Click(), although hrefs are also valid to get stuff done
 * hrefs will make the text blue though  so dont do it :/
 */

///Unclickable Lobby UI objects
/obj/screen/text/lobby
	screen_loc = "CENTER"
	maptext_height = 480
	maptext_width = 480
	maptext_x = 3
	maptext_y = 5
	maptext = "If you see this yell at coders"

/**
 * What the hell is this proc? you might be asking
 * Well this is the answer to a wierd ass bug where the hud datum passes null to Initialize instead of a reference to itself
 * Why does this happen? I'd love to know but noone else has so far
 * Please fix it so you dont have to manually set the owner and this junk to make it work
 *
 * This proc sets the maptext of the screen obj when it's updated
 */
/obj/screen/text/lobby/proc/set_text()
	return

/obj/screen/text/lobby/title
	maptext = "<span class=menutext>Welcome to TGMC</span>"

/obj/screen/text/lobby/title/Initialize()
	. = ..()
	maptext = "<span class=menutext>Welcome to TGMC[SSmapping?.configs ? " - [SSmapping.configs[SHIP_MAP].map_name]" : ""]</span>"
	var/matrix/M = matrix()
	M.Scale(1.1, 1.1)//make text bigger for title page
	transform = M


/obj/screen/text/lobby/year
	maptext = "<span class=menutext>Current Year: Loading...</span>"

/obj/screen/text/lobby/year/Initialize()
	. = ..()
	maptext = "<span class=menutext>Current Year: [GAME_YEAR]</span>"


/obj/screen/text/lobby/owners_char
	screen_loc = "CENTER-7,CENTER-7"
	maptext = "<span class=menutext>Loading...</span>"

/obj/screen/text/lobby/owners_char/Initialize(mapload)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/set_text)//stupid fucking initialize bug fuck you
		return
	set_text()

/obj/screen/text/lobby/owners_char/set_text()
	maptext = "<span class=menutext>Current character: [hud.mymob.client ? hud.mymob.client.prefs.real_name : "Unknown User"]</span>"

///Clickable UI lobby objects which do stuff on Click() when pressed
/obj/screen/text/lobby/clickable
	maptext = "if you see this a coder was stinky"
	icon = 'icons/UI_Icons/lobby_button.dmi' //hitbox prop
	mouse_opacity = MOUSE_OPACITY_ICON

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

/obj/screen/text/lobby/clickable/Click()
	var/mob/new_player/player = usr
	player.playsound_local(player, 'sound/effects/menu_select.ogg', 50)


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
	maptext = "<span class=menutext>You are: Not Ready</span>"

/obj/screen/text/lobby/clickable/ready/Initialize(mapload)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/set_text)//stupid fucking initialize bug fuck you
		return
	set_text()

/obj/screen/text/lobby/clickable/ready/set_text()
	var/mob/new_player/player = hud.mymob
	maptext = "<span class=menutext>You are: [player.ready ? "" : "Not "]Ready</span>"

/obj/screen/text/lobby/clickable/ready/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.toggle_ready()
	set_text()

/obj/screen/text/lobby/clickable/manifest
	maptext = "<span class=menutext>View Manifest</span>"

/obj/screen/text/lobby/clickable/manifest/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_manifest()

/obj/screen/text/lobby/clickable/background
	maptext = "<span class=menutext>Background</span>"

/obj/screen/text/lobby/clickable/background/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.view_lore()


/obj/screen/text/lobby/clickable/changelog
	maptext = "<span class=menutext>Changelog</span>"

/obj/screen/text/lobby/clickable/changelog/Click()
	. = ..()
	hud.mymob.client?.changes()


/obj/screen/text/lobby/clickable/polls
	maptext = "<span class=menutext>Polls</span>"

/obj/screen/text/lobby/clickable/polls/Initialize(mapload, atom/one, atom/two)
	. = ..()
	if(!mapload)
		INVOKE_NEXT_TICK(src, .proc/fetch_polls)//stupid fucking initialize bug fuck you
		return
	INVOKE_ASYNC(src, .proc/fetch_polls)

///This proc is invoked async to avoid sleeping in Initialize and fetches polls from the DB
/obj/screen/text/lobby/clickable/polls/proc/fetch_polls()
	var/mob/new_player/player = hud.mymob
	var/hasnewpolls = player.check_playerpolls()
	if(isnull(hasnewpolls))
		maptext = "<span class=menutext>No Database!</span>"
		return
	maptext = "<span class=menutext>Show Polls[hasnewpolls ? " (NEW!)" : ""]</span>"

/obj/screen/text/lobby/clickable/polls/Click()
	. = ..()
	var/mob/new_player/player = hud.mymob
	player.handle_playeR_DBRANKSing()
	fetch_polls()

