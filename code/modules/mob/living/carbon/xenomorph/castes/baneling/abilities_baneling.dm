// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/ability/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	action_icon = 'icons/Xeno/actions/baneling.dmi'
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
	RegisterSignal(L, COMSIG_MOB_PRE_DEATH, PROC_REF(handle_smoke))

/datum/action/ability/xeno_action/baneling_explode/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_MOB_PRE_DEATH)

/datum/action/ability/xeno_action/baneling_explode/action_activate()
	. = ..()
	handle_smoke(ability = TRUE)
	xeno_owner.record_tactical_unalive()
	xeno_owner.death(FALSE)

/// This proc defines, and sets up and then lastly starts the smoke, if ability is false we divide range by 4.
/datum/action/ability/xeno_action/baneling_explode/proc/handle_smoke(datum/source, ability = FALSE)
	SIGNAL_HANDLER
	if(xeno_owner.plasma_stored <= 60)
		return
	var/turf/owner_T = get_turf(xeno_owner)
	var/smoke_choice = baneling_smoke_list[xeno_owner.selected_reagent]
	var/datum/effect_system/smoke_spread/smoke = new smoke_choice(owner_T)
	xeno_owner.use_plasma(xeno_owner.plasma_stored)
	var/smoke_range = BANELING_SMOKE_RANGE
	/// If this proc is triggered by signal(so death), we want to divide range by 2
	if(!ability)
		smoke_range = smoke_range / 2
	smoke.set_up(smoke_range, owner_T, BANELING_SMOKE_DURATION)
	playsound(owner_T, 'sound/effects/blobattack.ogg', 25)
	smoke.start()

	xeno_owner.record_war_crime()

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
	xeno_owner.set_selected_reagent(GLOB.baneling_chem_type_list[rand(1,length(GLOB.baneling_chem_type_list))])
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
	xeno_owner.set_selected_reagent(GLOB.baneling_chem_type_list[1])
	update_button_icon() //Update immediately to get our default

/datum/action/ability/xeno_action/select_reagent/baneling/action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_reagent_radial))
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/select_reagent/baneling/select_reagent_radial()
	// This is cursed, don't copy this code its the WRONG way to do this.
	// TODO: generate this from GLOB.baneling_chem_type_list
	action_icon = 'icons/Xeno/actions/baneling.dmi'
	var/static/list/reagent_images_list = list(
		DEFILER_NEUROTOXIN = image('icons/Xeno/actions/baneling.dmi', icon_state = DEFILER_NEUROTOXIN),
		BANELING_ACID = image('icons/Xeno/actions/baneling.dmi', icon_state = BANELING_ACID),
		)
	var/toxin_choice = show_radial_menu(owner, owner, reagent_images_list, radius = 48)
	if(!toxin_choice)
		return
	for(var/toxin in GLOB.baneling_chem_type_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[toxin]
		if(R.name == toxin_choice)
			xeno_owner.set_selected_reagent(R.type)
			break
	xeno_owner.balloon_alert(xeno_owner, "[toxin_choice]")
	update_button_icon()
	return succeed_activate()
