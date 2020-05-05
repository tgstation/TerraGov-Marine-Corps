/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid"
	plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/salvage_plasma
	name = "Salvage Plasma"
	action_icon_state = "salvage_plasma"
	ability_name = "salvage plasma"
	var/plasma_salvage_amount = PLASMA_SALVAGE_AMOUNT
	var/salvage_delay = 5 SECONDS
	var/max_range = 1
	keybind_signal = COMSIG_XENOABILITY_SALVAGE_PLASMA

/datum/action/xeno_action/activable/salvage_plasma/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(owner.action_busy)
		return
	X.xeno_salvage_plasma(A, plasma_salvage_amount, salvage_delay, max_range)

/datum/action/xeno_action/activable/transfer_plasma/drone
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

/datum/action/xeno_action/activable/psychic_cure/drone
	name = "Acidic Salve"
	action_icon_state = "heal_xeno"
	mechanics_text = "Slowly heal an ally with goop. Apply repeatedly for best results."
	cooldown_timer = 5 SECONDS
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE


/datum/action/xeno_action/activable/psychic_cure/drone/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	switch(dist)
		if(-1)
			if(!silent && target == owner)
				to_chat(owner, "<span class='warning'>We cannot cure ourselves.</span>")
			return FALSE
		if(2 to INFINITY) //Only adjacent.
			if(!silent)
				to_chat(owner, "<span class='warning'>Our sister needs to be next to us.</span>")
			return FALSE
	return TRUE


/datum/action/xeno_action/activable/psychic_cure/drone/use_ability(atom/target)
	if(owner.action_busy)
		return FALSE

	if(!do_mob(owner, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE

	owner.visible_message("<span class='xenowarning'>\the [owner] vomits acid over [target]!</span>", \
	"<span class='xenowarning'>We cover [target] with our rejuvinating goo!</span>")
	target.visible_message("<span class='xenowarning'>[target]'s wounds are mended by the acid.</span>", \
	"<span class='xenowarning'>We feel a sudden soothing chill.</span>")

	playsound(target, "alien_drool", 25)

	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	patient.salve_healing()

	owner.changeNext_move(CLICK_CD_RANGE)

	log_combat(owner, patient, "acid salved")	//Not sure how important this log is but leaving it in

	succeed_activate()
	add_cooldown()

/mob/living/carbon/xenomorph/proc/salve_healing() //Slight modification of the heal_wounds proc
	var/amount = 40	//Smaller than psychic cure, less useful on xenos with large health pools
	if(recovery_aura)	//Leaving in the recovery aura bonus, not sure if it is too high the way it is
		amount += recovery_aura * maxHealth * 0.008 // +0.8% max health per recovery level, up to +4%
	adjustBruteLoss(-amount)
	adjustFireLoss(-amount, updating_health = TRUE)
	adjust_sunder(-amount/20)
