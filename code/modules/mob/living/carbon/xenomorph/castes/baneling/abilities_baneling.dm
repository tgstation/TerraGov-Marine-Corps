// ***************************************
// *********** Baneling Explode
// ***************************************
/datum/action/xeno_action/baneling_explode
	name = "Baneling Explode"
	action_icon_state = "baneling_explode"
	desc = "Explode and spread dangerous toxins to hinder or kill your foes. You will respawn in your pod after you detonate, should your pod be planted."
	ability_name = "baneling explode"
	var/static/list/baneling_smoke_list = list(
		/datum/reagent/toxin/xeno_neurotoxin = /datum/effect_system/smoke_spread/xeno/neuro/medium,
		/datum/reagent/toxin/xeno_hemodile = /datum/effect_system/smoke_spread/xeno/hemodile,
		/datum/reagent/toxin/xeno_transvitox = /datum/effect_system/smoke_spread/xeno/transvitox,
		/datum/reagent/toxin/xeno_ozelomelyn = /datum/effect_system/smoke_spread/xeno/ozelomelyn,
		/datum/reagent/toxin/acid = /datum/effect_system/smoke_spread/xeno/acid,
	)
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)

/datum/action/xeno_action/baneling_explode/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = L
	RegisterSignal(X, COMSIG_MOB_PRE_DEATH, PROC_REF(handle_smoke))

/datum/action/xeno_action/baneling_explode/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	handle_smoke(ability = TRUE)
	X.record_tactical_unalive()
	X.death(FALSE)

/// This proc defines, and sets up and then lastly starts the smoke, if ability is false we divide range by 4.
/datum/action/xeno_action/baneling_explode/proc/handle_smoke(datum/source, ability = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored <= 60)
		return
	var/turf/owner_T = get_turf(X)
	var/smoke_choice = baneling_smoke_list[X.selected_reagent]
	var/datum/effect_system/smoke_spread/smoke = new smoke_choice(owner_T)
	var/smoke_range = X.plasma_stored/60
	/// Use up all plasma so that we dont smoke twice because we die.
	X.use_plasma(X.plasma_stored)
	/// If this proc is triggered by signal, we want to divide range by 4
	if(!ability)
		smoke_range = smoke_range*0.25
	smoke.set_up(smoke_range, owner_T, BANELING_SMOKE_DURATION)
	playsound(owner_T, 'sound/effects/blobattack.ogg', 25)
	smoke.start()

	X.record_war_crime()

// ***************************************
// *********** Reagent Selection
// ***************************************
/datum/action/xeno_action/select_reagent/baneling
	name = "Choose Explosion Reagent"
	action_icon_state = "select_reagent0"
	desc = "Select which reagent will be released when you explode."
	plasma_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_CHOOSE_REAGENT,
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
	// This is cursed, don't copy this code its the WRONG way to do this.
	// TODO: generate this from GLOB.baneling_chem_type_list
	var/static/list/reagent_images_list = list(
		DEFILER_NEUROTOXIN = image('icons/Xeno/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
		DEFILER_HEMODILE = image('icons/Xeno/actions.dmi', icon_state = DEFILER_HEMODILE),
		DEFILER_TRANSVITOX = image('icons/Xeno/actions.dmi', icon_state = DEFILER_TRANSVITOX),
		DEFILER_OZELOMELYN = image('icons/Xeno/actions.dmi', icon_state = DEFILER_OZELOMELYN),
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

// ***************************************
// *********** Spawn Pod
// ***************************************
/datum/action/xeno_action/spawn_pod
	name = "Spawn pod"
	action_icon_state = "spawn_pod"
	desc = "Spawn a pod that you will respawn inside of upon death. You will NOT respawn if the pod is destroyed!"
	ability_name = "spawn pod"
	plasma_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_SPAWN_POD,
	)

/datum/action/xeno_action/spawn_pod/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	RegisterSignal(new /obj/structure/xeno/baneling_pod(get_turf(X.loc), X.hivenumber, X, src), COMSIG_QDELETING, PROC_REF(notify_owner))
	succeed_activate()

/// Proc to notify the owner of the pod that it has been destroyed
/datum/action/xeno_action/spawn_pod/proc/notify_owner()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	X.balloon_alert(X, "YOUR POD IS DESTROYED")
	to_chat(X, span_xenohighdanger("Our POD IS DESTROYED! Rebuild it if we can!"))

// ***************************************
// *********** Dash explosion
// ***************************************
/datum/action/xeno_action/activable/dash_explosion
	name = "Dash Explosion"
	action_icon_state = "dash_explosion"
	desc = "Wind up and charge in a direction, detonating yourself on impact."
	ability_name = "dash explosion"
	plasma_cost = 0
	///How far can we charge
	var/range = 6
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_DASH_EXPLOSION,
	)

/datum/action/xeno_action/activable/dash_explosion/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(X, 1 SECONDS, FALSE, X, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), A, FALSE, XACT_USE_BUSY)))
		return fail_activate()
	RegisterSignals(X, list(COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_OBJ_THROW_HIT), PROC_REF(charge_complete))
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	X.throw_at(A, range, 70, X)

/// Whenever we hit something living, if its a human we knock them down for 2 seconds and keep throwing ourselves. If we hit xeno, we get blocked and explode on them
/datum/action/xeno_action/activable/dash_explosion/proc/mob_hit(datum/source, mob/M)
	SIGNAL_HANDLER
	if(ishuman(M))
		var/mob/living/carbon/human/victim = M
		victim.Knockdown(2 SECONDS)
	return COMPONENT_KEEP_THROWING

/// In here we finish the charge and unregister signals, then we emit smoke and then we kill ourselves
/datum/action/xeno_action/activable/dash_explosion/proc/charge_complete()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	UnregisterSignal(X, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT, COMSIG_MOVABLE_POST_THROW))
	var/datum/action/xeno_action/baneling_explode/explode_action = X.actions_by_path[/datum/action/xeno_action/baneling_explode]
	explode_action.handle_smoke(ability = TRUE)
	X.record_tactical_unalive()
	X.death(FALSE)

/datum/action/xeno_action/watch_xeno/baneling
	use_state_flags = XACT_USE_LYING|XACT_USE_NOTTURF|XACT_USE_INCAP
