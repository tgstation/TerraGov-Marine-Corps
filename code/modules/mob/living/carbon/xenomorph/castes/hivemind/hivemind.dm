/mob/living/carbon/xenomorph/hivemind
	caste_base_type = /mob/living/carbon/xenomorph/hivemind
	name = "hivemind"
	real_name = "hivemind"
	desc = "A glorious singular entity."

	icon_state = "hivemind_marker"
	icon = 'icons/mob/cameramob.dmi'

	status_flags = GODMODE
	density = FALSE
	throwpass = TRUE

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
	GLOB.hivemind_list += src

	// Remove some unused xeno things
	verbs -= /mob/living/proc/lay_down

/mob/living/carbon/xeno/hivemind/Destroy()
	GLOB.hivemind_list -= src
	return ..()

/mob/living/carbon/xenomorph/hivemind/Move(NewLoc, Dir = 0)
	var/obj/effect/alien/weeds/W = locate() in range("3x3", NewLoc)
	if(!W)
		var/obj/effect/alien/weeds/nearby = locate() in range("3x3", loc)
		if(!nearby)
			forceMove(get_turf(locate(/obj/effect/alien/weeds)))
		return FALSE

	// Don't allow them over the poddoors 
	var/obj/machinery/door/poddoor/door = locate() in NewLoc
	if(door?.density)
		return FALSE

	// Hiveminds are scared of fire.
	var/obj/flamer_fire/fire_obj = locate() in range("3x3", NewLoc)
	if(istype(fire_obj))
		return FALSE

	forceMove(NewLoc)

/mob/living/carbon/xenomorph/hivemind/receive_hivemind_message(mob/living/carbon/xenomorph/X, message)
	var/track =  "<a href='?src=[REF(src)];hivemind_jump=[REF(X)]'>(F)</a>"
	show_message("[track] [X.hivemind_start()] <span class='message'>hisses, '[message]'</span>[X.hivemind_end()]", 2)

/mob/living/carbon/xenomorph/hivemind/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["hivemind_jump"])
		var/mob/living/carbon/xenomorph/xeno = locate(href_list["hivemind_jump"])
		if(!istype(xeno))
			return
		var/obj/effect/alien/weeds/nearby_weed = locate() in range("3x3", get_turf(xeno))
		if(!istype(nearby_weed))
			to_chat(src, "<span class='warning'>They are not near any weeds we can jump to.</span>")
			return
		forceMove(get_turf(nearby_weed))

/mob/living/carbon/xenomorph/hivemind/update_icons()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/update_move_intent_effects()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/UnarmedAttack(atom/A, proximity_flag)
	a_intent = INTENT_HELP //Forces help intent for all interactions.
	return ..()

/mob/living/carbon/xenomorph/hivemind/RangedAttack(atom/A, params)
	a_intent = INTENT_HELP //Forces help intent for all interactions.
	return ..()

/mob/living/carbon/xenomorph/hivemind/projectile_hit()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/add_typing_indicator()
	return FALSE
	
/mob/living/carbon/xenomorph/hivemind/remove_typing_indicator()
	return FALSE
