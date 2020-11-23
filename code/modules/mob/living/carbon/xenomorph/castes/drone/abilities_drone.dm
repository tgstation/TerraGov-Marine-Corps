/datum/action/xeno_action/activable/corrosive_acid/drone
	name = "Corrosive Acid"
	plasma_cost = 75
	acid_type = /obj/effect/xenomorph/acid/weak

/datum/action/xeno_action/activable/salvage_biomass
	name = "Salvage Biomass"
	action_icon_state = "salvage_plasma"
	ability_name = "salvage biomass"
	keybind_signal = COMSIG_XENOABILITY_SALVAGE_PLASMA
	cooldown_timer = DRONE_SALVAGE_COOLDOWN

/datum/action/xeno_action/activable/salvage_biomass/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/voice/alien_drool1.ogg', 25, 0, 1)
	to_chat(owner, "<span class='notice'>We are ready to salvage xeno biomass again.</span>")
	return ..()

/datum/action/xeno_action/activable/salvage_biomass/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/X = owner
	if(!isxeno(A))
		to_chat(X, "<span class='xenowarning'>We can only salvage the biomass of deceased xenomorphs!</span>")
		return FALSE

	var/mob/living/carbon/xenomorph/target = A

	if(target.stat != DEAD)
		to_chat(X, "<span class='xenowarning'>We can't salvage the biomass of living sisters!</span>")
		return FALSE

	var/distance = get_dist(X, target)
	if(distance > DRONE_SALVAGE_BIOMASS_RANGE)
		to_chat(X, "<span class='xenowarning'>We need to be [distance -  DRONE_SALVAGE_BIOMASS_RANGE] tiles closer to [target].</span>")
		return FALSE


/datum/action/xeno_action/activable/salvage_biomass/use_ability(atom/A)

	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/xenomorph/target = A


	X.face_atom(target) //Face the target so we don't look like an ass
	to_chat(X, "<span class='xenowarning'>We begin to salvage the biomass of [target]...</span>")
	playsound(X, pick('sound/voice/alien_drool1.ogg','sound/voice/alien_drool2.ogg'), 25)

	if(!do_after(X, DRONE_SALVAGE_BIOMASS_WINDUP, TRUE, target, BUSY_ICON_FRIENDLY)) //Wind up
		return fail_activate()


	X.face_atom(target) //Face the target so we don't look like an ass

	if(!can_use_ability(target, FALSE, XACT_IGNORE_PLASMA)) //Check to make sure the target hasn't gone anywhere/been exploded/etc
		return fail_activate()

	succeed_activate()

	var/upgrade_amount = target.upgrade_stored * DRONE_SALVAGE_BIOMASS_SALVAGE_RATIO //We only recover a small portion of the target's upgrade and evo points.
	var/evo_amount = target.evolution_stored * DRONE_SALVAGE_BIOMASS_SALVAGE_RATIO

	//Take all the plas-mar
	X.gain_plasma(target.plasma_stored)

	//Distribute the upgrade and evo points the target had to the hive:
	var/list/list_of_upgrade_xenos = list()
	var/list/list_of_evolve_xenos = list()

	for(var/mob/living/carbon/xenomorph/filter in X.hive.get_all_xenos())
		if(!(filter.upgrade in DRONE_SALVAGE_UPGRADE_FILTER_LIST)) //Only Xenos who can use the salvage get it; filter them
			list_of_upgrade_xenos += filter
		if(!(filter.tier in DRONE_SALVAGE_EVOLUTION_FILTER_LIST) && (filter.evolution_stored < filter.xeno_caste.evolution_threshold))
			list_of_evolve_xenos += filter

	if(length(list_of_upgrade_xenos))
		upgrade_amount /= length(list_of_upgrade_xenos) //get the amount distributed to each xeno; protect against dividing by 0
		for(var/mob/living/carbon/xenomorph/beneficiary in list_of_upgrade_xenos) //Distribute the upgrade salvage to those who can use it
			beneficiary.upgrade_stored += upgrade_amount

	if(length(list_of_evolve_xenos))
		evo_amount /= length(list_of_evolve_xenos)
		for(var/mob/living/carbon/xenomorph/beneficiary in list_of_evolve_xenos) //Distribute the evolve salvage to those who can use it
			beneficiary.evolution_stored = min(beneficiary.xeno_caste.evolution_threshold, beneficiary.evolution_stored + evo_amount) //Prevents janky overflow

	playsound(target, 'sound/effects/alien_egg_burst.ogg', 25)
	X.hive.xeno_message("[target]'s remains were salvaged by [X], recovering [upgrade_amount] upgrade points for [length(list_of_upgrade_xenos)] sisters and [evo_amount] evolution points for [length(list_of_evolve_xenos) ] sisters.") //Notify hive and give credit to the good boy drone
	X.visible_message("<span class='xenowarning'>\ [X] gruesomely absorbs and devours the remains of [target]!</span>", \
	"<span class='xenowarning'>We messily devour the remains of [target], absorbing [target.plasma_stored] plasma and distributing our deceased sister's essence throughout the hive. We now have [X.plasma_stored]/[X.xeno_caste.plasma_max] plasma stored.</span>") //Narrative description.

	target.gib() //Destroy the corpse

	GLOB.round_statistics.drone_salvage_biomass++ //Statistic incrementation
	SSblackbox.record_feedback("tally", "round_statistics", 1, "drone_salvage_biomass")


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

/datum/action/xeno_action/activable/psychic_cure/acidic_salve/use_ability(atom/target)
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
