
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
	///Mutation vars
	/// The percentage increase or reduction to chips gain
	var/chip_multipler = 1
	/// The Percentage chance to double slash, hitting a additional, random limb, when slashing
	var/double_slash_chance = 0
	/// The percentage chance to apply a random debuff, when slashing
	var/debuff_slash_chance = 0
	/// The amount of Riposte charms this xeno has, for mutations
	var/riposte_charms = 0
	/// The multipler on damage healed by a succesfull riposte
	var/riposte_multipler = 1
	/// The max amount of riposte charms this mob can have
	var/riposte_charms_max = 0
	/// The multipler on damage recieved whenever a attack crits against this mob. Note that this added in addition to the attacks damage, so a mult of 1 would double damage
	var/recieved_crit_damage_mult = 0
	// /An overlay of the riposte charms,
	var/atom/movable/vis_obj/xeno_wounds/riposte_charms_overlay/riposte_charms_overlay

// ***************************************
// *********** Mutations
// ***************************************
/mob/living/carbon/xenomorph/jester/proc/handle_riposte(target, damage)
	SIGNAL_HANDLER
	if(riposte_charms > 0)
		if(prob(35))
			playsound(get_turf(src), 'sound/effects/riposte.ogg', 60, 1)
			HEAL_XENO_DAMAGE(src, damage, FALSE) //Heal the initial damage, so the net is 0
			var/healamount = (damage * riposte_multipler)
			HEAL_XENO_DAMAGE(src, healamount, FALSE) // Then heal at the actual ratio
			riposte_charms -= 1
			addtimer(CALLBACK(src, PROC_REF(recharge_riposte)), 1 MINUTES)
			return
	if(prob(10))
		adjustBrainLoss(damage * recieved_crit_damage_mult)
		playsound(get_turf(src), 'sound/effects/jester_crit.ogg', 60, 1)
		new /obj/effect/temp_visual/heal(get_turf(src))

/mob/living/carbon/xenomorph/jester/proc/recharge_riposte()
	if(riposte_charms <  riposte_charms_max)
		riposte_charms += 1
	handle_riposte_overlay()

/mob/living/carbon/xenomorph/jester/proc/handle_riposte_overlay()
	if(!riposte_charms_overlay)
		return
	if(stat == DEAD)
		riposte_charms_overlay.icon_state = ""
		return
	switch(riposte_charms)
		if(0)
			riposte_charms_overlay.icon_state = ""
		if(1)
			riposte_charms_overlay.icon_state = "riposte_charms_1"
		if(2)
			riposte_charms_overlay.icon_state = "riposte_charms_2"
		else
			riposte_charms_overlay.icon_state = "riposte_charms_3"

/atom/movable/vis_obj/xeno_wounds/riposte_charms_overlay
	layer = BELOW_MOB_LAYER
	alpha = 180
	icon_state = ""
	icon = 'icons/effects/64x64.dmi'
	///The xeno this overlay belongs to
	var/mob/living/carbon/xenomorph/owner
	pixel_y = -8

/atom/movable/vis_obj/xeno_wounds/riposte_charms_overlay/Initialize(mapload, ...)
	. = ..()
	SpinAnimation(30)

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
	if(stat == DEAD)
		riposte_charms_overlay.icon_state = ""

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
		chipcontainer.chips += JESTER_CHIPS_RATIO * (damage * chip_multipler) // ~75 Damage for 1 chip
		hud_set_chips() //Update the chips display
	if(chipcontainer.damagemult != 0)
		INVOKE_ASYNC(src, PROC_REF(handle_bonus_damage), attacker, target, damage)
	if(prob(JESTER_CRIT_CHANCE) && ishuman(target)) // 15% chance for a crit
		INVOKE_ASYNC(src, PROC_REF(crit_effect), attacker, target, damage)
	if(prob(debuff_slash_chance) && ishuman(target))
		var/datum/action/ability/activable/xeno/deck_of_disaster/dod =  actions_by_path[/datum/action/ability/activable/xeno/deck_of_disaster]
		var/mob/living/carbon/human/victim = target
		switch(pick(dod.debuffs))

			if(STATUS_EFFECT_STAGGER)
				victim.Stagger(1 SECONDS) // Stagger for 1 second

			if(STATUS_EFFECT_CONFUSED)
				victim.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 50)
				victim.apply_status_effect(STATUS_EFFECT_CONFUSED, 20) // Half of what king applies

			if(STATUS_EFFECT_INTOXICATED)
				if(victim.has_status_effect(STATUS_EFFECT_INTOXICATED))
					var/datum/status_effect/stacking/intoxicated/debuff = victim.has_status_effect(STATUS_EFFECT_INTOXICATED)
					debuff.add_stacks(2)
				victim.apply_status_effect(STATUS_EFFECT_INTOXICATED, 2) // Same as sentinel spit

		victim.updatehealth() // So the other xenos can see the effect applied instead of waiting for next tick (could expire before then lole)
	if(prob(double_slash_chance) && ishuman(target))
		var/mob/living/carbon/human/victim = target
		victim.attack_alien_harm(src, random_location = TRUE)

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


