/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_tile = null
	intact_tile = FALSE


/turf/open/floor/plating/almayer
	icon = 'icons/turf/almayer.dmi'

/turf/open/floor/plating/almayer/striped
	icon_state = "plating_striped"

/turf/open/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"

/turf/open/floor/plating/icefloor
	icon_state = "plating"
	name = "ice colony plating"


/turf/open/floor/plating/icefloor/New()
	. = ..()
	name = "plating"


/turf/open/floor/plating/icefloor/warnplate
	icon_state = "warnplate"


/turf/open/floor/plating/plating_catwalk
	icon = 'icons/turf/almayer.dmi'
	icon_state = "plating_catwalk"
	var/base_state = "plating" //Post mapping
	name = "catwalk"
	desc = "Cats really don't like these things."
	var/covered = TRUE


/turf/open/floor/plating/plating_catwalk/Initialize()
	. = ..()
	icon_state = base_state
	update_turf_overlay()


/turf/open/floor/plating/plating_catwalk/proc/update_turf_overlay()
	var/image/I = image(icon, src, "catwalk", CATWALK_LAYER)
	I.plane = GAME_PLANE
	if(covered)
		overlays += I
	else
		overlays -= I
		qdel(I)


/turf/open/floor/plating/plating_catwalk/attackby(obj/item/I, mob/user)
	. = ..()
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
	return ..()


/turf/open/floor/plating/plating_catwalk/prison
	icon = 'icons/turf/prison.dmi'



/turf/open/floor/plating/ironsand/New()
	. = ..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"



/turf/open/floor/plating/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."
	layer = ATMOS_PIPE_LAYER


/turf/open/floor/plating/warning
	icon_state = "warnplate"


/turf/open/floor/plating/platebot
	icon_state = "platebot"


/turf/open/floor/plating/platebotc
	icon_state = "platebotc"


/turf/open/floor/plating/asteroidwarning // used around lv's lz2
	icon_state = "asteroidwarning"


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