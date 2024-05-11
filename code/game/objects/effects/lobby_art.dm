GLOBAL_LIST_EMPTY(lobby_art_files)

/obj/effect/lobby_art
	name = "Lobby"
	icon = 'icons/lobby art/tgmc_flag.dmi'	//Default icon
	layer = FLY_LAYER
	pixel_x = -64

/obj/effect/lobby_art/New(loc, previous_art_icon)
	..()
	pick_art(previous_art_icon)

/obj/effect/lobby_art/Initialize(mapload)
	. = ..()
	if(!mapload)	//Only fade in art that is loaded after the first
		fade_in()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/lobby_art/LateInitialize()
	. = ..()
	if(length(GLOB.lobby_art_files) > 1)	//Don't bother changing the art if there's only one
		addtimer(CALLBACK(src, PROC_REF(transition_art)), CONFIG_GET(number/lobby_art_duration) SECONDS)

///Create a new lobby art object and delete this one
/obj/effect/lobby_art/proc/transition_art()
	new /obj/effect/lobby_art(loc, icon_state)
	layer -= 0.1	//I could use initial() but I don't see an instance to where anything should be changing the layer of it (minus this)
	QDEL_IN(src, CONFIG_GET(number/lobby_art_fade_duration) SECONDS)

///Fade in the lobby art
/obj/effect/lobby_art/proc/fade_in()
	alpha = 0
	animate(src, CONFIG_GET(number/lobby_art_fade_duration) SECONDS, alpha = 255)

///Choose a random icon from the lobby_art_files global list
/obj/effect/lobby_art/proc/pick_art(previous_art_icon)
	if(!length(GLOB.lobby_art_files))
		return

	//From what I have read in the BYOND forums and what I have seen while testing, it is important to use fcopy_rsc and NOT file()
	//Using file() will load the local file and not the cached one, so I assume it will try to make everyone download all the files again
	icon = fcopy_rsc(CONFIG_GET(string/lobby_art_directory) + pick(GLOB.lobby_art_files))
	if(!previous_art_icon || icon != previous_art_icon)
		return

	pick_art(previous_art_icon)	//Recursion until it picks a different icon
