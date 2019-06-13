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
	l_color = "#ff0000"
	luminosity = 5


/obj/effect/rune/attunement/Destroy()
	SetLuminosity(0)
	return ..()


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
	SetOpacity(initial_opacity)


/obj/effect/supplypod_selector
	icon_state = "supplypod_selector"
	layer = FLY_LAYER