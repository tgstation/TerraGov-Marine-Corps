
/obj/structure/fluff/tram_rail
	name = "tram rail"
	desc = "Great for trams, not so great for skating."
	icon = 'icons/obj/tram/tram_rails.dmi'
	icon_state = "rail"
	layer = TRAM_RAIL_LAYER
	plane = FLOOR_PLANE
	resistance_flags =  ALL
	obj_flags = NONE

/obj/structure/fluff/tram_rail/floor
	name = "tram rail protective cover"
	icon_state = "rail_floor"

/obj/structure/fluff/tram_rail/end
	icon_state = "railend"

/obj/structure/fluff/tram_rail/electric
	desc = "Great for trams, not so great for skating. This one is a power rail."

/obj/structure/fluff/tram_rail/anchor
	name = "tram rail anchor"
	icon_state = "anchor"

/obj/structure/fluff/tram_rail/electric/anchor
	name = "tram rail anchor"
	icon_state = "anchor"

/obj/structure/fluff/tram_rail/electric/attack_hand(mob/living/user, list/modifiers)
	if(user.electrocute_act(75, src))
		do_sparks(5, TRUE, src)
