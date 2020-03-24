/mob/living/carbon/xenomorph/hivemind
	caste_base_type = /mob/living/carbon/xenomorph/hivemind
	name = "Hivemind"
	real_name = "Hivemind"
	desc = "A glorious singular entity."

	icon_state = "hivemind_marker"
	icon = 'icons/mob/cameramob.dmi'

	status_flags = GODMODE | INCORPOREAL
	density = FALSE
	throwpass = TRUE

	a_intent = INTENT_HELP

	health = 1000
	maxHealth = 1000
	plasma_stored = 5
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_ZERO

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_ABSTRACT
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	hud_type = /datum/hud/hivemind
	hud_possible = list(PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD)

	var/obj/effect/alien/hivemindcore/core

/mob/living/carbon/xenomorph/hivemind/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/xenomorph/hivemind/newmind = src
	var/obj/effect/alien/hivemindcore/newcore = new /obj/effect/alien/hivemindcore(loc)
	newcore.parent = src
	newmind.core = newcore

/mob/living/carbon/xenomorph/hivemind/Move(NewLoc, Dir = 0)
	var/obj/effect/alien/weeds/W = locate() in range("3x3", NewLoc)
	if(!W)
		var/obj/effect/alien/weeds/nearby = locate() in range("3x3", loc)
		if(!nearby)
			// If we run out of weeds just teleport to some random weeds.
			forceMove(get_turf(core))
		return FALSE

	// Don't allow them over the timed_late doors
	var/obj/machinery/door/poddoor/timed_late/door = locate() in NewLoc
	if(door?.CanPass(src, NewLoc))
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

/mob/living/carbon/xenomorph/hivemind/DblClickOn(atom/A, params)
	if(!istype(A, /obj/effect/alien/weeds))
		return

	forceMove(get_turf(A))

/mob/living/carbon/xenomorph/hivemind/CtrlClickOn(atom/A)

	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlShiftClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/ShiftClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/AltClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/a_intent_change()
	return //Unable to change intent, forced help intent

/mob/living/carbon/xenomorph/hivemind/projectile_hit()
	return FALSE

// Typing indicator cleanup
/mob/living/carbon/xenomorph/hivemind/add_typing_indicator()
	return FALSE
/mob/living/carbon/xenomorph/hivemind/remove_typing_indicator()
	return FALSE

// Should solve SSD resting
/mob/living/carbon/xenomorph/hivemind/set_resting(rest, silent)
	return

// More generic removals - Stolen from silicons
/mob/living/carbon/xenomorph/hivemind/drop_held_item()
	return

/mob/living/carbon/xenomorph/hivemind/drop_all_held_items()
	return

/mob/living/carbon/xenomorph/hivemind/get_held_item()
	return

/mob/living/carbon/xenomorph/hivemind/get_inactive_held_item()
	return

/mob/living/carbon/xenomorph/hivemind/get_active_held_item()
	return

/mob/living/carbon/xenomorph/hivemind/put_in_l_hand(obj/item/I)
	return

/mob/living/carbon/xenomorph/hivemind/put_in_r_hand(obj/item/I)
	return

/mob/living/carbon/xenomorph/hivemind/stripPanelEquip(obj/item/I, mob/M, slot)
	return

/mob/living/carbon/xenomorph/hivemind/stripPanelUnequip(obj/item/I, mob/M, slot)
	return

/mob/living/carbon/xenomorph/hivemind/med_hud_set_health()
	return

/mob/living/carbon/xenomorph/hivemind/med_hud_set_status()
	return

/mob/living/carbon/xenomorph/hivemind/contents_explosion(severity, target)
	return

/mob/living/carbon/xenomorph/hivemind/stun_effect_act(stun_amount, agony_amount, def_zone)
	return

/mob/living/carbon/xenomorph/hivemind/apply_effect(effect = 0, effecttype = STUN, blocked = 0, updating_health = FALSE)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/adjustToxLoss(amount)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/setToxLoss(amount)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/adjustCloneLoss(amount)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/setCloneLoss(amount)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/adjustBrainLoss(amount)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/setBrainLoss(amount)
	return FALSE

// =================
// hivemind core
/obj/effect/alien/hivemindcore
	name = "hivemind core"
	desc = "A very weird, pulsating node. This looks almost alive."
	max_integrity = 600
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "weed_hivemind4"
	var/mob/living/carbon/xenomorph/hivemind/parent

/obj/effect/alien/hivemindcore/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	set_light(7, 5, LIGHT_COLOR_PURPLE)

/obj/effect/alien/hivemindcore/Destroy()
	if(isnull(parent))
		return ..()
	parent.playsound_local(parent, get_sfx("alien_help"), 30, TRUE)
	to_chat(parent, "<span class='xenohighdanger'>Your core has been destroyed!</span>")
	xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... \the [parent] has been slain!</span>", 2, parent.hivenumber)
	parent.ghostize()
	QDEL_NULL(parent)
	return ..()

//hivemind cores

/obj/effect/alien/hivemindcore/attack_alien(mob/living/carbon/xenomorph/X)
	if(isxenoqueen(X))
		var/choice = alert(X, "Are you sure you want to destroy the hivemind?", "Destroy hivemind", "Yes", "Cancel")
		if(choice == "Yes")
			deconstruct(FALSE)
			return

	X.visible_message("<span class='danger'>[X] nudges its head against [src].</span>", \
	"<span class='danger'>You nudge your head against [src].</span>")

/obj/effect/alien/hivemindcore/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(isnull(parent))
		return
	if(prob(60))
		return
	var/health_percent = round((max_integrity / obj_integrity) * 100)
	switch(health_percent)
		if(-INFINITY to 25)
			to_chat(parent, "<span class='xenohighdanger'>Your core is under attack, and dangerous low on health!</span>")
		if(26 to 75)
			to_chat(parent, "<span class='xenodanger'>Your core is under attack, and low on health!</span>")
		if(76 to INFINITY)
			to_chat(parent, "<span class='xenodanger'>Your core is under attack!</span>")
