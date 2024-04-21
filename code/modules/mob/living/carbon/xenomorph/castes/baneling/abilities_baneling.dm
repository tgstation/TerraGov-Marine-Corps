// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/ability/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	desc = "Explode and spread dangerous toxins to hinder or kill your foes. You die."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)
	/// List of available reagants for baneling
	var/static/list/baneling_smoke_list = list(
		/datum/reagent/toxin/xeno_neurotoxin = /datum/effect_system/smoke_spread/xeno/neuro/medium,
		/datum/reagent/toxin/acid = /datum/effect_system/smoke_spread/xeno/acid,
	)

/datum/action/ability/xeno_action/baneling_explode/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	RegisterSignal(X, COMSIG_MOB_PRE_DEATH, PROC_REF(handle_smoke))

/datum/action/ability/xeno_action/baneling_explode/remove_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	UnregisterSignal(X, COMSIG_MOB_PRE_DEATH)

/datum/action/ability/xeno_action/baneling_explode/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	handle_smoke(ability = TRUE)
	X.record_tactical_unalive()
	X.death(FALSE)

/// This proc defines, and sets up and then lastly starts the smoke, if ability is false we divide range by 4.
/datum/action/ability/xeno_action/baneling_explode/proc/handle_smoke(datum/source, ability = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored <= 60)
		return
	var/turf/owner_T = get_turf(X)
	var/smoke_choice = baneling_smoke_list[X.selected_reagent]
	var/datum/effect_system/smoke_spread/smoke = new smoke_choice(owner_T)
	X.use_plasma(X.plasma_stored)
	var/smoke_range = BANELING_SMOKE_RANGE
	/// If this proc is triggered by signal(so death), we want to divide range by 2
	if(!ability)
		smoke_range = smoke_range / 2
	smoke.set_up(smoke_range, owner_T, BANELING_SMOKE_DURATION)
	playsound(owner_T, 'sound/effects/blobattack.ogg', 25)
	smoke.start()

	X.record_war_crime()

/datum/action/ability/xeno_action/baneling_explode/ai_should_start_consider()
	return TRUE

/datum/action/ability/xeno_action/baneling_explode/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!line_of_sight(owner, target))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	X.selected_reagent = GLOB.baneling_chem_type_list[rand(1,length(GLOB.baneling_chem_type_list))]
	return TRUE

// ***************************************
// *********** Reagent Selection
// ***************************************
/datum/action/ability/xeno_action/select_reagent/baneling
	name = "Choose Explosion Reagent"
	action_icon_state = "select_reagent0"
	desc = "Select which reagent will be released when you explode."
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_CHOOSE_REAGENT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT,
	)

/datum/action/ability/xeno_action/select_reagent/baneling/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/caster = L
	caster.selected_reagent = GLOB.baneling_chem_type_list[1]
	update_button_icon() //Update immediately to get our default

/datum/action/ability/xeno_action/select_reagent/baneling/action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_reagent_radial))
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/select_reagent/baneling/select_reagent_radial()
	// This is cursed, don't copy this code its the WRONG way to do this.
	// TODO: generate this from GLOB.baneling_chem_type_list
	var/static/list/reagent_images_list = list(
		DEFILER_NEUROTOXIN = image('icons/Xeno/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
		BANELING_ACID = image('icons/Xeno/actions.dmi', icon_state = BANELING_ACID_ICON),
		)
	var/toxin_choice = show_radial_menu(owner, owner, reagent_images_list, radius = 48)
	if(!toxin_choice)
		return
	var/mob/living/carbon/xenomorph/X = owner
	for(var/toxin in GLOB.baneling_chem_type_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[toxin]
		if(R.name == toxin_choice)
			X.selected_reagent = R.type
			break
	X.balloon_alert(X, "[toxin_choice]")
	update_button_icon()
	return succeed_activate()
