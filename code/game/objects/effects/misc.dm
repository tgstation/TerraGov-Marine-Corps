//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = 0






/obj/effect/mark
	var/mark = ""
	icon = 'icons/misc/mark.dmi'
	anchored = TRUE
	layer = 99
	mouse_opacity = 0

/obj/effect/beam
	name = "beam"
	var/def_zone
	flags_pass = PASSTABLE


/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = TRUE




/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = TRUE


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )




//Exhaust effect
/obj/effect/engine_exhaust
	name = "engine exhaust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "exhaust"
	anchored = TRUE

	New(var/turf/nloc, var/ndir, var/temp)
		setDir(ndir)
		..(nloc)

		spawn(20)
			loc = null



/obj/effect/rune/attunement
	luminosity = 5



/obj/effect/forcefield
	anchored = TRUE
	opacity = FALSE
	density = TRUE


/obj/effect/forcefield/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE


/obj/effect/forcefield/fog/Initialize()
	. = ..()
	dir  = pick(CARDINAL_DIRS)
	GLOB.fog_blockers += src


/obj/effect/forcefield/fog/Destroy()
	GLOB.fog_blockers -= src
	return ..()


/obj/effect/forcefield/fog/attack_hand(mob/M)
	to_chat(M, "<span class='notice'>You peer through the fog, but it's impossible to tell what's on the other side...</span>")
	return TRUE


/obj/effect/forcefield/fog/attack_alien(M)
	return attack_hand(M)


/obj/effect/forcefield/fog/attack_paw(M)
	return attack_hand(M)


/obj/effect/forcefield/fog/attack_animal(M)
	return attack_hand(M)

//used to control opacity of multitiles doors
/obj/effect/opacifier
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = UNACIDABLE | INDESTRUCTIBLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/opacifier/Initialize(mapload, initial_opacity)
	. = ..()
	set_opacity(initial_opacity)


/obj/effect/supplypod_selector
	icon_state = "supplypod_selector"
	layer = FLY_LAYER


/obj/effect/dummy/lighting_obj
	name = "lighting fx obj"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = "#FFFFFF"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/effect/dummy/lighting_obj/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	set_light(_range ? _range : light_range, _power ? _power : light_power, _color ? _color : light_color)
	if(_duration)
		QDEL_IN(src, _duration)


/obj/effect/dummy/lighting_obj/moblight
	name = "mob lighting fx"


/obj/effect/dummy/lighting_obj/moblight/Initialize(mapload, _color, _range, _power, _duration)
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL


//Makes a tile fully lit no matter what
/obj/effect/fullbright
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	blend_mode = BLEND_ADD