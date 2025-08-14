
/mob/living/carbon/xenomorph/jester
	caste_base_type = /datum/xeno_caste/jester
	name = "Jester"
	desc = "" // This has always been wierd, xenos have two descriptions, Leave this null in favor of the castedatum desc
	icon = 'icons/Xeno/castes/jester.dmi'
	icon_state = "Jester Running"
	bubble_icon = "alien"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	hud_type = /datum/hud/alien/jester
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
	///An overlay of the caste thats picked for doppelganger, displayed ala stand style, from jojo
	var/atom/movable/vis_obj/xeno_wounds/doppelganger_overlay/doppelganger_overlay
	///  What type of caste this jester's doppelganger is, if it has one
	var/datum/xeno_caste/doppelganger_caste

// ***************************************
// *********** Doppelganger Overlays
// ***************************************
/atom/movable/vis_obj/xeno_wounds/doppelganger_overlay
	layer = BELOW_MOB_LAYER
	///The xeno this overlay belongs to
	var/mob/living/carbon/xenomorph/owner
	alpha = 180

/mob/living/carbon/xenomorph/jester/setDir(newdir)
	. = ..()
	if((doppelganger_caste == null))
		return
	switch(newdir)
		if(NORTH)
			doppelganger_overlay.pixel_x = 18
			doppelganger_overlay.pixel_y = 20
			doppelganger_overlay.layer = BELOW_MOB_LAYER
		if(SOUTH)
			doppelganger_overlay.pixel_x = -18
			doppelganger_overlay.pixel_y = 20
			doppelganger_overlay.layer = ABOVE_MOB_LAYER
		if(WEST)
			doppelganger_overlay.pixel_x = -10
			doppelganger_overlay.pixel_y = 20
			doppelganger_overlay.layer = BELOW_MOB_LAYER
		if(EAST)
			doppelganger_overlay.pixel_x = -6
			doppelganger_overlay.pixel_y = 20
			doppelganger_overlay.layer = ABOVE_MOB_LAYER

/mob/living/carbon/xenomorph/jester/proc/update_doppelganger_overlay()
	if(!doppelganger_overlay)
		return
	if((doppelganger_caste == null))
		doppelganger_overlay.icon_state = ""
		return
	var/mob/living/carbon/xenomorph = doppelganger_caste.caste_type_path
	doppelganger_overlay.icon_state = xenomorph.icon_state
	doppelganger_overlay.icon = xenomorph.icon
	if(stat == DEAD)
		doppelganger_overlay.icon_state = "[doppelganger_caste.caste_name] Dead"
		return
	if(lying_angle)
		if((resting || IsSleeping()) && (!IsParalyzed() && !IsUnconscious() && health > 0))
			doppelganger_overlay.icon_state = "[doppelganger_caste.caste_name] Sleeping"
			return
		doppelganger_overlay.icon_state = "[doppelganger_caste.caste_name] Knocked Down"
		return

/mob/living/carbon/xenomorph/jester/update_icons(state_change = TRUE)
	. = ..()
	update_doppelganger_overlay()

/mob/living/carbon/xenomorph/jester/Initialize(mapload, do_not_set_as_ruler)
	. = ..()
	doppelganger_overlay = new(src, src)
	vis_contents += doppelganger_overlay

// ***************************************
// *********** Chips & Related mechanics
// ***************************************
/mob/living/carbon/xenomorph/jester/onhithuman(attacker, target, damage)
	. = ..()
	var/datum/action/ability/xeno_action/chips/chipcontainer = actions_by_path[/datum/action/ability/xeno_action/chips]
	if(chipcontainer.chips < chipcontainer.maxchips)
		chipcontainer.chips += JESTER_CHIPS_RATIO * damage // ~75 Damage for 1 chip
		hud_set_chips() //Update the chips display
	if(chipcontainer.damagemult != 0)
		INVOKE_ASYNC(src, PROC_REF(handle_bonus_damage), attacker, target, damage)
	if(prob(JESTER_CRIT_CHANCE) && ishuman(target)) // 15% chance for a crit
		INVOKE_ASYNC(src, PROC_REF(crit_effect), attacker, target, damage)

///Takes the damagemult from the chips ability and applies its bonus damage, equally to all limbs
/mob/living/carbon/xenomorph/jester/proc/handle_bonus_damage(attacker, target, damage)
	var/datum/action/ability/xeno_action/chips/chipcontainer = actions_by_path[/datum/action/ability/xeno_action/chips]
	var/mob/living/carbon/human/victim = target
	victim.take_overall_damage(damage * chipcontainer.damagemult, BRUTE, sharp = TRUE)
///Whatever happens to the victim when the jester rolls a crit hit
/mob/living/carbon/xenomorph/jester/proc/crit_effect(attacker, target, damage)
	var/mob/living/carbon/human/victim = target
	var/turf/T = get_turf(victim)
	victim.apply_damage(damage * 0.5, BRUTE, sharp = TRUE) //Half of the dealt damage, ie 1.5x
	playsound(get_turf(T), 'sound/effects/jester_crit.ogg', 50, 1)
	new /obj/effect/temp_visual/heal(get_turf(T))

///Updates the jesters chips hud
/mob/living/carbon/xenomorph/jester/proc/hud_set_chips()
	if(hud_used?.jester_chips_display)
		var/datum/action/ability/xeno_action/chips/chipcontainer = actions_by_path[/datum/action/ability/xeno_action/chips]
		var/bucket = get_bucket(XENO_HUD_CHIPS_BUCKETS, chipcontainer.maxchips, chipcontainer.chips, 0, list("4", "0"), ROUND)
		hud_used.jester_chips_display.icon_state = "gamble_chips_[bucket]"

///Updates the gamble hud, and controls its progression. This proc is perennial, and ideally should never be stopped outside of the jester's (de)evolution
/mob/living/carbon/xenomorph/jester/proc/hud_set_gamble_bar(update_state = TRUE)
	var/datum/action/ability/xeno_action/chips/chipcontainer = actions_by_path[/datum/action/ability/xeno_action/chips]
	if(update_state)
		chipcontainer.gamblestate += 1
	if(chipcontainer.gamblestate != 4)
		if(hud_used)
			hud_used.jester_call_button.icon_state = "gamble_ui_call_off"
			hud_used.jester_hold_button.icon_state = "gamble_ui_hold_off"
			hud_used.jester_gamble_bar.icon_state = "gamble_bar_[chipcontainer.gamblestate]"
		if(update_state)
			addtimer(CALLBACK(src, PROC_REF(hud_set_gamble_bar)), 15 SECONDS)
	else
		playsound_local(get_turf(src),'sound/misc/gamblealert.ogg', 50, 1)
		if(hud_used)
			hud_used.jester_gamble_bar.icon_state = "gamble_bar_4"
			hud_used.jester_call_button.icon_state = "gamble_ui_call_on"
			hud_used.jester_hold_button.icon_state = "gamble_ui_hold_on"
		if(update_state)
			chipcontainer.force_gamble_timer = addtimer(CALLBACK(src, PROC_REF(force_gamble)), 30 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
			balloon_alert(src, "Must gamble in 30 seconds!")

///Forcefully cause the jester to gamble
/mob/living/carbon/xenomorph/jester/proc/force_gamble()
	var/datum/action/ability/xeno_action/chips/chipcontainer = actions_by_path[/datum/action/ability/xeno_action/chips]
	if(prob(50))
		chipcontainer.hold()
		balloon_alert(src, "Forcefully held!")
	else
		chipcontainer.allin(TRUE)
		balloon_alert(src, "Forcefully gambled!")


