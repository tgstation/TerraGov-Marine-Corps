// ***************************************
// *********** Defile
// ***************************************
/datum/action/xeno_action/activable/defile
	name = "Defile"
	action_icon_state = "defiler_sting"
	mechanics_text = "Channel to inject an adjacent target with an accelerant that violently reacts with xeno toxins, releasing gas and dealing heavy tox damage in proportion to the amount in their system."
	ability_name = "defiler sting"
	plasma_cost = 100
	cooldown_timer = 20 SECONDS
	target_flags = XABB_MOB_TARGET
	keybind_signal = COMSIG_XENOABILITY_DEFILE

/datum/action/xeno_action/activable/defile/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	owner.balloon_alert(owner, "You feel your toxin accelerant glands refill. You can use Defile again.")
	to_chat(owner, span_xenodanger("You feel your toxin accelerant glands refill. You can use Defile again."))
	return ..()

/datum/action/xeno_action/activable/defile/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!A.can_sting())
		if(!silent)
			owner.balloon_alert(owner, "Our sting won't affect this target")
		return FALSE

	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent)
			X.balloon_alert(X, "We need to be adjacent")
		return FALSE


/datum/action/xeno_action/activable/defile/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/living_target = A
	X.face_atom(living_target)
	if(!do_after(X, DEFILER_DEFILE_CHANNEL_TIME, TRUE, living_target, BUSY_ICON_HOSTILE))
		add_cooldown(DEFILER_DEFILE_FAIL_COOLDOWN)
		return fail_activate()
	if(!can_use_ability(A))
		return fail_activate()
	add_cooldown()
	X.face_atom(living_target)
	X.do_attack_animation(living_target)
	playsound(living_target, 'sound/effects/spray3.ogg', 15, TRUE)
	playsound(living_target, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	X.balloon_alert(X, "Our stinger successfully discharges accelerant into our victim")
	living_target.balloon_alert(living_target, "You feel horrible pain as something sharp forcibly pierces your thorax")
	living_target.apply_damage(50, STAMINA)
	living_target.apply_damage(5, BRUTE, "chest", updating_health = TRUE)
	living_target.emote("scream")

	var/defile_strength_multiplier = 0.5
	var/defile_reagent_amount
	var/defile_power
	var/neuro_applied

	for(var/datum/reagent/current_reagent AS in living_target.reagents.reagent_list) //Cycle through all chems
		defile_reagent_amount += living_target.reagents.get_reagent_amount(current_reagent.type)
		living_target.reagents.remove_reagent(current_reagent.type,defile_reagent_amount) //Purge current chem
		if(is_type_in_typecache(current_reagent, GLOB.defile_purge_list)) //For each xeno toxin reagent, double the strength multiplier
			if(istype(current_reagent, /datum/reagent/toxin/xeno_neurotoxin)) //Make sure neurotoxin isn't double counted
				if(neuro_applied)
					continue
				else
					neuro_applied = TRUE
			defile_strength_multiplier *= 2


	defile_power = defile_reagent_amount * defile_strength_multiplier //Total amount of toxin damage we deal

	living_target.setToxLoss(min(200, living_target.getToxLoss() + defile_power)) //Apply the toxin damage; cap toxin damage at lower of 200 or defile power + current tox loss

	var/datum/effect_system/smoke_spread/xeno/sanguinal/blood_smoke = new(living_target) //Set up Sanguinal smoke
	blood_smoke.strength = CEILING(clamp(defile_power*DEFILER_SANGUINAL_SMOKE_MULTIPLIER,1,2),1)
	blood_smoke.set_up(CEILING(clamp(defile_power*DEFILER_SANGUINAL_SMOKE_MULTIPLIER,1,4),1), get_turf(living_target))
	blood_smoke.start()

	switch(defile_power) //Description varies in severity and probability with the multiplier
		if(1 to 49)
			living_target.balloon_alert(living_target, "Your body aches")
		if(50 to 99)
			living_target.balloon_alert(living_target, "Your insides are in agony")
		if(100 to INFINITY)
			living_target.balloon_alert(living_target, "YOUR INSIDES FEEL LIKE THEY'RE ON FIRE")

	GLOB.round_statistics.defiler_defiler_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_defiler_stings")
	succeed_activate()
	return ..()

// ***************************************
// *********** Neurogas
// ***************************************
/datum/action/xeno_action/emit_neurogas
	name = "Emit Noxious Gas"
	action_icon_state = "emit_neurogas"
	mechanics_text = "Channel for 3 seconds to emit a cloud of noxious smoke, based on selected reagent, that follows the Defiler. You must remain stationary while channeling; moving will cancel the ability but will still cost plasma."
	ability_name = "emit neurogas"
	plasma_cost = 200
	cooldown_timer = 40 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY|XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/action/xeno_action/emit_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	owner.balloon_alert(owner, "We can use Emit Noxious Gas again")
	return ..()

/datum/action/xeno_action/emit_neurogas/action_activate()
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	//give them fair warning
	X.balloon_alert_to_viewers("Tufts of smoke begin to billow from [X]", ignored_mobs = X)
	X.balloon_alert(X, "Our dorsal vents widen, preparing to emit toxic smoke")

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	succeed_activate()
	X.icon_state = "Defiler Power Up"

	if(!do_after(X, DEFILER_GAS_CHANNEL_TIME, TRUE, null, BUSY_ICON_HOSTILE))
		if(!QDELETED(src))
			X.balloon_alert(X, "We abort emitting fumes")
			X.emitting_gas = FALSE
			X.icon_state = "Defiler Running"
			return fail_activate()
	X.emitting_gas = FALSE
	X.icon_state = "Defiler Running"

	add_cooldown()

	if(X.stagger) //If we got staggered, return
		X.balloon_alert(X, "We try to emit toxins but are staggered")
		return fail_activate()

	GLOB.round_statistics.defiler_neurogas_uses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_neurogas_uses")

	X.balloon_alert_to_viewers("[X] emits a noxious gas", ignored_mobs = X)
	X.balloon_alert(X, "We emit noxious gas!")
	dispense_gas()

/datum/action/xeno_action/emit_neurogas/proc/dispense_gas(count = 3)
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	set waitfor = FALSE
	var/smoke_range = 2
	var/datum/effect_system/smoke_spread/xeno/gas

	switch(X.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			gas = new /datum/effect_system/smoke_spread/xeno/neuro/medium(X)
		if(/datum/reagent/toxin/xeno_hemodile)
			gas = new /datum/effect_system/smoke_spread/xeno/hemodile(X)
		if(/datum/reagent/toxin/xeno_transvitox)
			gas = new /datum/effect_system/smoke_spread/xeno/transvitox(X)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			gas = new /datum/effect_system/smoke_spread/xeno/ozelomelyn(X)

	while(count)
		if(X.stagger) //If we got staggered, return
			X.balloon_alert(X, "We try to emit toxins but are staggered")
			return
		if(X.IsStun() || X.IsParalyzed())
			X.balloon_alert(X, "We try to emit toxins but are disabled")
			return
		var/turf/T = get_turf(X)
		playsound(T, 'sound/effects/smoke.ogg', 25)
		if(count > 1)
			gas.set_up(smoke_range, T)
		else //last emission is larger
			gas.set_up(CEILING(smoke_range*1.3,1), T)
		gas.start()
		X.balloon_alert_to_viewers("Noxious smoke billows from the hulking xenomorph", ignored_mobs = X)
		count = max(0,count - 1)
		sleep(DEFILER_GAS_DELAY)


// ***************************************
// *********** Inject Egg Neurogas
// ***************************************
/datum/action/xeno_action/activable/inject_egg_neurogas
	name = "Inject Gas"
	action_icon_state = "inject_egg"
	mechanics_text = "Inject an egg with toxins, killing the larva, but filling it full with gas ready to explode."
	ability_name = "inject neurogas"
	plasma_cost = 100
	cooldown_timer = 5 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS

/datum/action/xeno_action/activable/inject_egg_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	owner.balloon_alert(owner, "We can inject an egg with gas again.)
	return ..()

/datum/action/xeno_action/activable/inject_egg_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	if(istype(A, /obj/effect/alien/egg/gas))
		X.balloon_alert(X, "That egg has already been filled with toxic gas")
		return fail_activate()

	if(!istype(A, /obj/effect/alien/egg/hugger))
		return fail_activate()

	var/obj/effect/alien/egg/alien_egg = A
	if(alien_egg.maturity_stage != alien_egg.stage_ready_to_burst)
		X.balloon_alert(X, "That egg isn't strong enough to hold our gases")
		return fail_activate()

	X.balloon_alert_to_viewers("[X] starts injecting the egg with neurogas", ignored_mobs = X)
	X.balloon_alert(X, "[X] starts injecting the egg with neurogas")
	if(!do_after(X, 2 SECONDS, TRUE, alien_egg, BUSY_ICON_HOSTILE))
		X.balloon_alert_to_viewers("The stinger retracts from [X]", ignored_mobs = X)
		X.balloon_alert(X, "Our stinger retracts")
		return fail_activate()

	succeed_activate()
	add_cooldown()

	var/obj/effect/alien/egg/gas/newegg = new(A.loc, X.hivenumber)
	switch(X.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/neuro/medium
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/ozelomelyn
		if(/datum/reagent/toxin/xeno_hemodile)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/hemodile
		if(/datum/reagent/toxin/xeno_transvitox)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/transvitox
	qdel(alien_egg)

	GLOB.round_statistics.defiler_inject_egg_neurogas++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_inject_egg_neurogas")

// ***************************************
// *********** Reagent selection
// ***************************************
/datum/action/xeno_action/select_reagent
	name = "Select Reagent"
	action_icon_state = "select_reagent0"
	mechanics_text = "Selects which reagent to use for reagent slash and noxious gas. Hemodile slows by 25%, increased to 50% with neurotoxin present, and deals 20% of damage received as stamina damage. Transvitox converts brute/burn damage to toxin based on 40% of damage received up to 45 toxin on target, upon reaching which causes a stun. Neurotoxin deals increasing stamina damage the longer it remains in the victim's system and prevents stamina regeneration."
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING
	keybind_signal = COMSIG_XENOABILITY_SELECT_REAGENT
	alternate_keybind_signal = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT

/datum/action/xeno_action/select_reagent/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	X.selected_reagent = GLOB.defiler_toxin_type_list[1] //Set our default
	update_button_icon() //Update immediately to get our default

/datum/action/xeno_action/select_reagent/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_reagent
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/select_reagent/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = GLOB.defiler_toxin_type_list.Find(X.selected_reagent)
	if(length(GLOB.defiler_toxin_type_list) == i)
		X.selected_reagent = GLOB.defiler_toxin_type_list[1]
	else
		X.selected_reagent = GLOB.defiler_toxin_type_list[i+1]

	var/atom/A = X.selected_reagent
	X.balloon_alert(X, "We will now use <b>[initial(A.name)]</b>")
	update_button_icon()
	return succeed_activate()

/datum/action/xeno_action/select_reagent/alternate_action_activate()
	INVOKE_ASYNC(src, .proc/select_reagent_radial)
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/select_reagent/proc/select_reagent_radial()
	//List of toxin images
	var/static/list/defiler_toxin_images_list = list(
			DEFILER_NEUROTOXIN = image('icons/mob/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
			DEFILER_HEMODILE = image('icons/mob/actions.dmi', icon_state = DEFILER_HEMODILE),
			DEFILER_TRANSVITOX = image('icons/mob/actions.dmi', icon_state = DEFILER_TRANSVITOX),
			DEFILER_OZELOMELYN = image('icons/mob/actions.dmi', icon_state = DEFILER_OZELOMELYN),
			)
	var/toxin_choice = show_radial_menu(owner, owner, defiler_toxin_images_list, radius = 48)
	if(!toxin_choice)
		return
	var/mob/living/carbon/xenomorph/X = owner
	for(var/toxin in GLOB.defiler_toxin_type_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[toxin]
		if(R.name == toxin_choice)
			X.selected_reagent = R.type
			break
	X.balloon_alert(X, "We will now use <b>[toxin_choice]</b>")
	update_button_icon()
	return succeed_activate()


// ***************************************
// *********** Reagent slash
// ***************************************
/datum/action/xeno_action/reagent_slash
	name = "Reagent Slash"
	action_icon_state = "reagent_slash"
	mechanics_text = "For a short duration the next 3 slashes made will inject a small amount of selected toxin."
	ability_name = "reagent slash"
	cooldown_timer = 6 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_REAGENT_SLASH
	target_flags = XABB_MOB_TARGET
	///How many remaining reagent slashes the Defiler has
	var/reagent_slash_count = 0
	///Timer ID for the Reagent Slashes timer; we reference this to delete the timer if the effect lapses before the timer does
	var/reagent_slash_duration_timer_id
	///Defines the reagent being used for reagent slashes; locks it to the selected reagent on activation
	var/reagent_slash_reagent

/datum/action/xeno_action/reagent_slash/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner

	RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/reagent_slash)

	reagent_slash_count = DEFILER_REAGENT_SLASH_COUNT //Set the number of slashes
	reagent_slash_duration_timer_id = addtimer(CALLBACK(src, .proc/reagent_slash_deactivate, X), DEFILER_REAGENT_SLASH_DURATION, TIMER_STOPPABLE) //Initiate the timer and set the timer ID for reference
	reagent_slash_reagent = X.selected_reagent

	X.balloon_alert(X, "Our spines fill with virulent toxins")
	X.playsound_local(X, 'sound/voice/alien_drool2.ogg', 25)

	succeed_activate()
	add_cooldown()

///Called when the duration of reagent slash lapses
/datum/action/xeno_action/reagent_slash/proc/reagent_slash_deactivate(mob/living/carbon/xenomorph/X)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING) //unregister the signals; party's over

	reagent_slash_count = 0 //Zero out vars
	deltimer(reagent_slash_duration_timer_id) //delete the timer so we don't have mismatch issues, and so we don't potentially try to deactivate the ability twice
	reagent_slash_duration_timer_id = null
	reagent_slash_reagent = null

	X.balloon_alert(X, "We are no longer benefitting from [src]")
	X.playsound_local(X, 'sound/voice/hiss5.ogg', 25)


///Called when we slash while reagent slash is active
/datum/action/xeno_action/reagent_slash/proc/reagent_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER

	if(!target?.can_sting()) //We only care about targets that we can actually sting
		return

	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/carbon_target = target

	carbon_target.reagents.add_reagent(reagent_slash_reagent, DEFILER_REAGENT_SLASH_INJECT_AMOUNT)
	playsound(carbon_target, 'sound/effects/spray3.ogg', 15, TRUE)
	X.balloon_alert_to_viewers("[carbon_target] is pricked by [X]'s spines", ignored_mobs = X)

	GLOB.round_statistics.defiler_reagent_slashes++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_reagent_slashes")

	reagent_slash_count-- //Decrement the reagent slash count

	if(!reagent_slash_count) //Deactivate if we have no reagent slashes remaining
		reagent_slash_deactivate(X)


/datum/action/xeno_action/reagent_slash/on_cooldown_finish()
	owner.balloon_alert(owner, "We are able to infuse our spines with toxins again")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/tentacle
	name = "Tentacle"
	action_icon_state = "tail_attack"
	mechanics_text = "Throw one of your tentacles forward to grab a tallhost or item."
	ability_name = "Tentacle"
	cooldown_timer = 20 SECONDS
	plasma_cost = 200
	keybind_signal = COMSIG_XENOABILITY_TENTACLE
	///reference to beam tentacle
	var/datum/beam/tentacle

/datum/action/xeno_action/activable/tentacle/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isitem(A) && !ishuman(A))
		if(!silent)
			owner.balloon_alert(owner, "We cant use that on [A]")
		return FALSE
	if(isliving(A))
		var/mob/living/livingtarget = A
		if(livingtarget.stat == DEAD)
			if(!silent)
				owner.balloon_alert(owner, "We cant use that on [livingtarget]")
			return FALSE
	var/atom/movable/target = A
	if(target.anchored)
		if(!silent)
			owner.balloon_alert(owner, "[target] is anchored and cannot be moved!")
		return FALSE

	var/turf/current = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	if(current == target_turf)
		return TRUE
	if(get_dist(current, target_turf) > TENTACLE_ABILITY_RANGE)
		return FALSE
	current = get_step_towards(current, target_turf)
	while((current != target_turf))
		if(current.density)
			if(!silent)
				owner.balloon_alert(owner, "We can't reach [target]")
			return FALSE
		current = get_step_towards(current, target_turf)


/datum/action/xeno_action/activable/tentacle/use_ability(atom/movable/target)
	var/atom/movable/tentacle_end/tentacle_end = new (get_turf(owner))
	tentacle = owner.beam(tentacle_end,"curse0",'icons/effects/beam.dmi')
	RegisterSignal(tentacle_end, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT), .proc/finish_grab)
	tentacle_end.throw_at(target, TENTACLE_ABILITY_RANGE * 1.5, 3, owner, FALSE) //Too hard to hit if just TENTACLE_ABILITY_RANGE
	succeed_activate()
	add_cooldown()

///Signal handler to grab the target when we thentacle head hit something
/datum/action/xeno_action/activable/tentacle/proc/finish_grab(datum/source, atom/movable/target)
	SIGNAL_HANDLER
	QDEL_NULL(tentacle)
	qdel(source)
	if(!can_use_ability(target, TRUE, XACT_IGNORE_COOLDOWN|XACT_IGNORE_PLASMA))
		owner.balloon_alert(owner, "We failed to grab anything")
		return
	tentacle = owner.beam(target, "curse0",'icons/effects/beam.dmi')
	playsound(target, 'sound/effects/blobattack.ogg', 40, 1)
	owner.balloon_alert(owner, "We grab [target] with a tentacle")
	target.balloon_alert_to_viewers("Grabbed")
	RegisterSignal(target, COMSIG_MOVABLE_POST_THROW, .proc/delete_beam)
	target.throw_at(owner, TENTACLE_ABILITY_RANGE, 1, owner, FALSE)
	if(isliving(target))
		var/mob/living/loser = target
		loser.apply_effects(stun = 1, weaken = 0.1)

///signal handler to delete tetacle after we are done draggging owner along
/datum/action/xeno_action/activable/tentacle/proc/delete_beam(datum/source, atom/impacted)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	QDEL_NULL(tentacle)

/atom/movable/tentacle_end
	name = "You can't see this"
	invisibility = INVISIBILITY_ABSTRACT

#undef DEFILER_NEUROTOXIN
#undef DEFILER_HEMODILE
#undef DEFILER_TRANSVITOX
#undef DEFILER_OZELOMELYN
