/mob/living/carbon/xenomorph/hivemind
	name = "hivemind"
	real_name = "hivemind"
	desc = "A glorious singular entity."

	mouse_opacity = MOUSE_OPACITY_OPAQUE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	hud_type = /datum/hud/hivemind
	hud_possible = list()

/mob/living/carbon/xenomorph/hivemind/Initialize(mapload, ...)
	. = ..()
	new /obj/effect/alien/weeds/node/strong(loc)
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, NONE, TRUE, 0)


/mob/living/carbon/xenomorph/hivemind/Move(NewLoc, Dir = 0)
	var/obj/effect/alien/weeds/W = locate() in range("3x3", NewLoc)
	if(!W)
		return FALSE
	forceMove(NewLoc)

/mob/living/carbon/xenomorph/hivemind/update_move_intent_effects()
	return


/mob/living/carbon/xenomorph/hivemind/UnarmedAttack(atom/A, proximity_flag)
	. = ..()
	to_chat(world, "melee attack on [A]")

/mob/living/carbon/xenomorph/hivemind/RangedAttack(atom/A, params)
	. = ..()
	to_chat(world, "ranged attack on [A]")