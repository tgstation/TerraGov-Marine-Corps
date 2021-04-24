obj/structure/trench
	name = "Trench"
	desc = "A wide, narrow earthwork designed to protect soldiers from any projectiles, since WWI!"
	icon = 'icons/turf/trenchicon.dmi'
	icon_state = "trench0"
	layer = TRENCH_LAYER
	generic_canpass = FALSE
	climbable = TRUE
	climb_delay = 20
	max_integrity = 220
	throwpass = TRUE
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	anchored = TRUE
	tiles_with = list(
		/obj/structure/trench,
	)
	var/slowamt = 4
	var/disassembletime = 3 SECONDS

obj/structure/trench/Initialize()
	. = ..()
	relativewall()
	relativewall_neighbours()


obj/structure/trench/Crossed(atom/movable/AM)

	var/mob/living/H = AM
	ADD_TRAIT(H, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/Uncrossed(atom/movable/AM)
	var/mob/living/H = AM
	H.next_move_slowdown += slowamt
	REMOVE_TRAIT(AM, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/CanAllowThrough(atom/movable/mover, turf/target)
	if(HAS_TRAIT(mover, TRAIT_ISINTRENCH))
		return TRUE
	else
		return FALSE

obj/structure/trench/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tool/shovel))
		if(user.a_intent == INTENT_HARM)
			var/obj/item/tool/shovel/ET = I
			if(!ET.folded)
				user.visible_message("<span class='notice'>[user] starts disassembling the [src].</span>",
				"<span class='notice'>You start disassembling the [src].</span>")
				if(do_after(user, ET.shovelspeed, TRUE, src, BUSY_ICON_BUILD))
					user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
					"<span class='notice'>You disassemble [src].</span>")
					var/deconstructed = TRUE
					for(var/obj/effect/xenomorph/acid/A in loc)
						if(A.acid_t != src)
							continue
						deconstructed = FALSE
						break
					deconstruct(deconstructed)
		if(user.a_intent == INTENT_HELP)
			if(obj_integrity == max_integrity)
				to_chat(user, "<span class='warning'>[src] isn't in need of repairs!</span>")
				return
			if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD) || obj_integrity >= max_integrity)
				return
			repair_damage(max_integrity)
			user.visible_message("<span class='notice'>[user] repairs a damaged trench</span>",
			"<span class='notice'>You repair a damaged trench</span>")


