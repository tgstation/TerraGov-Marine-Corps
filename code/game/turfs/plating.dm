/turf/open/floor/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"
	floor_tile = null
	intact_tile = FALSE
	shoefootstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD
	mediumxenofootstep = FOOTSTEP_PLATING

/turf/open/floor/plating/broken_states()
	return pick("platingdmg1", "platingdmg2", "platingdmg3")

/turf/open/floor/plating/burnt_states()
	return "panelscorched"

/turf/open/floor/plating/make_plating()
	return //we don't dig past plating

/turf/open/floor/plating/fire_act(burn_level)
	if(hull_floor)
		return
	if(!burnt && prob(5))
		burn_tile()

/turf/open/floor/plating/welder_act(mob/living/user, obj/item/I)
	var/obj/item/tool/weldingtool/welder = I

	if(!broken && !burnt)
		return
	if(!(welder.use(1)))
		to_chat(user, span_warning("You need more welding fuel to complete this task."))
		return

	to_chat(user, span_warning("You fix some dents on the broken plating."))
	playsound(src, 'sound/items/welder.ogg', 25, 1)
	burnt = FALSE
	broken = FALSE
	update_icon()

/turf/open/floor/plating/mainship
	icon = 'icons/turf/mainship.dmi'

/turf/open/floor/plating/mainship/striped
	icon_state = "plating_striped"

/turf/open/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"

/turf/open/floor/plating/fake_space //todo: kill mappers that use dodgy fake tiles that are basically just varedits
	icon = 'icons/turf/space.dmi'
	name = "\proper shielded space"
	icon_state = "0"
	plane = PLANE_SPACE
	hull_floor = TRUE

/turf/open/floor/plating/icefloor
	icon_state = "plating"
	name = "ice colony plating"


/turf/open/floor/plating/icefloor/Initialize(mapload)
	. = ..()
	name = "plating"


/turf/open/floor/plating/icefloor/warnplate
	icon_state = "warnplate"

/turf/open/floor/plating/icefloor/warnplate/corner
	icon_state = "warnplatecorner"

/turf/open/floor/plating/plating_catwalk
	icon = 'icons/turf/mainship.dmi'
	icon_state = "plating_catwalk"
	var/base_state = "plating" //Post mapping
	name = "catwalk"
	desc = "Cats really don't like these things."
	var/covered = TRUE
	shoefootstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	mediumxenofootstep = FOOTSTEP_CATWALK


/turf/open/floor/plating/plating_catwalk/Initialize(mapload)
	. = ..()
	icon_state = base_state
	update_turf_overlay()


/turf/open/floor/plating/plating_catwalk/proc/update_turf_overlay()
	var/image/I = image(icon, src, "catwalk", CATWALK_LAYER)
	SET_PLANE_EXPLICIT(I, FLOOR_PLANE, src)
	if(covered)
		overlays += I
	else
		overlays -= I
		qdel(I)


/turf/open/floor/plating/plating_catwalk/attackby(obj/item/I, mob/user)
	. = ..()
	if(.)
		return
	if(iscrowbar(I))
		if(covered)
			var/obj/item/stack/catwalk/R = new(user.loc)
			R.add_to_stacks(user)
			covered = FALSE
			update_turf_overlay()
			return
	if(istype(I, /obj/item/stack/catwalk))
		if(!covered)
			var/obj/item/stack/catwalk/E = I
			E.use(1)
			covered = TRUE
			update_turf_overlay()
			return

/turf/open/floor/plating/plating_catwalk/prison
	icon = 'icons/turf/prison.dmi'

/turf/open/floor/plating/ironsand
	name = "Iron Sand"
/turf/open/floor/plating/plating_catwalk/prison/alt
	icon_state = "plating_catwalk_alt"

/turf/open/floor/plating/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/open/floor/plating/warning
	icon_state = "warnplate"

/turf/open/floor/plating/warning/grime
	icon_state = "floorgrimecaution"

/turf/open/floor/plating/platebot
	icon_state = "platebot"


/turf/open/floor/plating/platebotc
	icon_state = "platebotc"


/turf/open/floor/plating/asteroidwarning // used around lv's lz2
	icon_state = "asteroidwarning"

/turf/open/floor/plating/asteroidwarning/down
	dir = SOUTH

/turf/open/floor/plating/asteroidfloor
	icon_state = "asteroidfloor"


/turf/open/floor/plating/asteroidplating
	icon_state = "asteroidplating"


/turf/open/floor/plating/dmg1
	icon_state = "platingdmg1"

/turf/open/floor/plating/dmg2
	icon_state = "platingdmg2"

/turf/open/floor/plating/dmg3
	icon_state = "platingdmg3"

/turf/open/floor/plating/scorched
	icon_state = "panelscorched"
