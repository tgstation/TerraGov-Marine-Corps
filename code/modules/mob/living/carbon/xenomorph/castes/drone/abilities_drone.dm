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

// ***************************************
// *********** Sow
// ***************************************
/datum/action/xeno_action/sow
	name = "Sow"
	action_icon_state = "place_trap"
	mechanics_text = "Sow the seeds of an alien plant."
	plasma_cost = 50
	cooldown_timer = 2 SECONDS
	use_state_flags = XACT_USE_LYING
	keybind_signal = null //TODO
	alternate_keybind_signal = null //TODO

/datum/action/xeno_action/activable/sow/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, span_warning("Only weeds are fertile enough for our plants!"))
		return FALSE

	if(!(locate(/obj/structure/xeno/plant) in T))
		if(!silent)
			to_chat(owner, span_warning("There is already a plant growing here!"))
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

/datum/action/xeno_action/activable/sow/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!X.selected_plant)
		return FALSE
	var/obj/structure/xeno/plant/P = X.selected_plant
	if(P.plasma_cost_override)
		if((X.plasma_stored < P.plasma_cost_override))
			to_chat(owner, span_warning("This plant requires [P.plasma_cost_override] to grow properly!"))
			return fail_activate()
		else
			new X.selected_plant
			return succeed_activate(P.plasma_cost_override)

	playsound(src, "alien_resin_build", 25)
	new X.selected_plant
	return succeed_activate()

/datum/action/xeno_action/activable/sow/use_ability(atom/A)
	. = ..()
	return action_activate()

/datum/action/xeno_action/activable/sow/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_resin
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/activable/sow/proc/choose_plant()
	var/obj/structure/xeno/plant_choice = show_radial_menu(owner, owner, GLOB.plant_images_list, radius = 48)
	var/mob/living/carbon/xenomorph/X = owner
	if(!plant_choice)
		return
	for(var/obj/structure/xeno/plant AS in GLOB.plant_type_list)
		if(plant.name == plant_choice)
			X.selected_plant = plant_choice
			break
	to_chat(X, span_notice("We will now sow <b>[plant_choice.name]</b>."))
	update_button_icon()

/datum/action/xeno_action/activable/sow/alternate_action_activate()
	INVOKE_ASYNC(src, .proc/choose_plant)
	return COMSIG_KB_ACTIVATED
