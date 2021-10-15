/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid"
	plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/transfer_plasma/drone
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 2

// ***************************************
// *********** Acidic salve
// ***************************************
/datum/action/xeno_action/activable/psychic_cure/acidic_salve
	name = "Acidic Salve"
	action_icon_state = "heal_xeno"
	mechanics_text = "Slowly heal an ally with goop. Apply repeatedly for best results."
	cooldown_timer = 5 SECONDS
	plasma_cost = 150
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE
	heal_range = DRONE_HEAL_RANGE
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/psychic_cure/acidic_salve/use_ability(atom/target)
	if(owner.do_actions)
		return FALSE

	if(!do_mob(owner, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE

	owner.visible_message(span_xenowarning("\the [owner] vomits acid over [target]!"), \
	span_xenowarning("We cover [target] with our rejuvinating goo!"))
	target.visible_message(span_xenowarning("[target]'s wounds are mended by the acid."), \
	span_xenowarning("We feel a sudden soothing chill."))

	playsound(target, "alien_drool", 25)

	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	patient.salve_healing()

	owner.changeNext_move(CLICK_CD_RANGE)

	log_combat(owner, patient, "acid salved")	//Not sure how important this log is but leaving it in

	succeed_activate()
	add_cooldown()

/mob/living/carbon/xenomorph/proc/salve_healing() //Slight modification of the heal_wounds proc
	var/amount = 50	//Smaller than psychic cure, less useful on xenos with large health pools
	if(recovery_aura)	//Leaving in the recovery aura bonus, not sure if it is too high the way it is
		amount += recovery_aura * maxHealth * 0.01 // +1% max health per recovery level, up to +5%
	var/remainder = max(0, amount - getBruteLoss()) //Heal brute first, apply whatever's left to burns
	adjustBruteLoss(-amount)
	adjustFireLoss(-remainder, updating_health = TRUE)
	adjust_sunder(-amount/20)

// ***************************************
// *********** Drone Jelly
// ***************************************
/datum/action/xeno_action/create_jelly/slow
	cooldown_timer = 45 SECONDS
