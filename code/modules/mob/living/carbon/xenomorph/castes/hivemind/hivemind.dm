/mob/living/carbon/xenomorph/hivemind
	caste_base_type = /mob/living/carbon/xenomorph/hivemind
	name = "hivemind"
	real_name = "hivemind"
	desc = "A glorious singular entity."

	icon_state = "hivemind_marker"
	icon = 'icons/mob/cameramob.dmi'

	status_flags = GODMODE

	health = 1000
	maxHealth = 1000
	plasma_stored = 5
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_ZERO

	mouse_opacity = MOUSE_OPACITY_OPAQUE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	hud_type = /datum/hud/hivemind
	hud_possible = list(PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD)

	var/mob/living/carbon/xenomorph/observed_xeno

/mob/living/carbon/xenomorph/hivemind/Initialize(mapload, ...)
	. = ..()
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, NONE, TRUE, 0)
	GLOB.hivemind_list += src

	// Remove some unused xeno things
	verbs -= /mob/living/proc/lay_down


/mob/living/carbon/xenomorph/hivemind/Move(NewLoc, Dir = 0)
	var/obj/effect/alien/weeds/W = locate() in range("3x3", NewLoc)
	if(!W)
		var/obj/effect/alien/weeds/nearby = locate() in range("3x3", loc)
		if(!nearby)
			forceMove(get_turf(locate(/obj/effect/alien/weeds)))
		return FALSE
	forceMove(NewLoc)


/mob/living/carbon/xenomorph/hivemind/update_icons()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/update_move_intent_effects()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/UnarmedAttack(atom/A, proximity_flag)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/RangedAttack(atom/A, params)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/add_typing_indicator()
	return FALSE
	
/mob/living/carbon/xenomorph/hivemind/remove_typing_indicator()
	return FALSE
