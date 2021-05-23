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

obj/structure/trench/Destroy()
	var/mob/living/carbon/inhabitant = locate() in src.loc
	if(inhabitant)
		REMOVE_TRAIT(inhabitant, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)
	. = ..()


obj/structure/trench/Crossed(atom/movable/AM)
	. = ..()
	var/mob/living/H = AM
	ADD_TRAIT(H, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/Uncrossed(atom/movable/AM)
	REMOVE_TRAIT(AM, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
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


/obj/structure/trench/do_climb(mob/living/user)
	if(!can_climb(user))
		return

	user.visible_message("<span class='warning'>[user] starts to climb into \the [src]!</span>")

	if(!do_after(user, climb_delay, FALSE, src, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, .proc/can_climb, user)))
		return

	for(var/m in user.buckled_mobs)
		user.unbuckle_mob(m)

	if(!(flags_atom & ON_BORDER)) //If not a border structure or we are not on its tile, assume default behavior
		user.forceMove(get_turf(src))

		if(get_turf(user) == get_turf(src))
			user.visible_message("<span class='warning'>[user] climbs into \the [src]!</span>")
	else //If border structure, assume complex behavior
		var/turf/target = get_step(get_turf(src), dir)
		if(user.loc == target)
			user.forceMove(get_turf(src))
			user.visible_message("<span class='warning'>[user] leaps over \the [src]!</span>")
		else
			if(target.density) //Turf is dense, not gonna work
				to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
				return
			for(var/atom/movable/A in target)
				if(A && A.density && !(A.flags_atom & ON_BORDER))
					if(istype(A, /obj/structure))
						var/obj/structure/S = A
						if(!S.climbable) //Transfer onto climbable surface
							to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
							return
					else
						to_chat(user, "<span class='warning'>You cannot leap this way.</span>")
						return
			user.forceMove(get_turf(target)) //One more move, we "leap" over the border structure

			if(get_turf(user) == get_turf(target))
				user.visible_message("<span class='warning'>[user] leaps over \the [src]!</span>")
