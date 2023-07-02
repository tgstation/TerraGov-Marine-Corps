// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	desc = "Explode and spread dangerous toxins to kill your foes"
	ability_name = "baneling explode"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)

/datum/action/xeno_action/baneling_explode/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	RegisterSignal(X, COMSIG_MOB_DEATH, PROC_REF(handle_smoke))

/datum/action/xeno_action/baneling_explode/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	handle_smoke(ability = TRUE)
	X.death(FALSE)

/datum/action/xeno_action/baneling_explode/proc/handle_smoke(mob/M, ability = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	var/turf/owner_T = get_turf(X)
	var/datum/effect_system/smoke_spread/smoke
	switch(X.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			smoke = new /datum/effect_system/smoke_spread/xeno/neuro/medium(owner_T)
		if(/datum/reagent/toxin/xeno_hemodile)
			smoke = new /datum/effect_system/smoke_spread/xeno/hemodile(owner_T)
		if(/datum/reagent/toxin/xeno_transvitox)
			smoke = new /datum/effect_system/smoke_spread/xeno/transvitox(owner_T)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			smoke = new /datum/effect_system/smoke_spread/xeno/ozelomelyn(owner_T)
		if(/datum/reagent/toxin/acid)
			smoke = new /datum/effect_system/smoke_spread/xeno/acid(owner_T)
	/// Our smoke size is directly dependant on the amount of plasma we have stored
	var/smoke_range = X.plasma_stored/60
	/// Use up all plasma so that we dont smoke twice because we die.
	X.use_plasma(X.plasma_stored)
	/// If this proc is triggered by signal, we want to divide range by 4
	if(!ability)
		smoke_range = smoke_range*0.25
	var/smoke_duration = X.baneling_smoke_duration
	smoke.set_up(smoke_range, owner_T, smoke_duration)
	playsound(owner_T, 'sound/effects/blobattack.ogg', 25)
	smoke.start()

// ***************************************
// *********** Reagent Selection
// ***************************************
/datum/action/xeno_action/select_reagent/baneling
	name = "Choose Explosion Reagent"
	action_icon_state = "select_reagent0"
	desc = "Select which reagent will be released when you explode"
	plasma_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SELECT_REAGENT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT,
	)

/datum/action/xeno_action/select_reagent/baneling/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/caster = L
	caster.selected_reagent = GLOB.baneling_chem_type_list[1]
	update_button_icon() //Update immediately to get our default

/datum/action/xeno_action/select_reagent/baneling/action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_reagent_radial))
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/select_reagent/baneling/select_reagent_radial()
		//List of toxin images
	var/static/list/reagent_images_list = list(
		DEFILER_NEUROTOXIN = image('icons/mob/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
		DEFILER_HEMODILE = image('icons/mob/actions.dmi', icon_state = DEFILER_HEMODILE),
		DEFILER_TRANSVITOX = image('icons/mob/actions.dmi', icon_state = DEFILER_TRANSVITOX),
		DEFILER_OZELOMELYN = image('icons/mob/actions.dmi', icon_state = DEFILER_OZELOMELYN),
		BANELING_ACID = image('icons/mob/actions.dmi', icon_state = BANELING_ACID),
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

// ***************************************
// *********** Spawn Pod
// ***************************************
/datum/action/xeno_action/spawn_pod
	name = "Spawn pod"
	action_icon_state = "spawn_pod"
	desc = "Spawn a pod that we will respawn inside of upon death. If the pod is destroyed and we die it's over.."
	ability_name = "spawn pod"
	plasma_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_SPAWN_POD,
	)

/datum/action/xeno_action/spawn_pod/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(isnull(X.pod_ref))
		X.pod_ref = new /obj/structure/xeno/baneling_pod(get_turf(X.loc), owner)
		succeed_activate()
		return
	var/obj/structure/xeno/baneling_pod/pod = X.pod_ref
	pod.loc = get_turf(X.loc)
	succeed_activate()
