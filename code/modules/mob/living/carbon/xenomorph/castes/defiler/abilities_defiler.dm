/particles/xeno_slash
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "rectangle"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 9
	fade = 12
	grow = 0.04
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 15, 15, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.15), list(0, 0.15))
	gravity = list(0, 0.8)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(0.9,0.9), NORMAL_RAND)
	rotation = 0
	spin = generator(GEN_NUM, 10, 20)

/particles/xeno_slash/neurotoxin
	color = "#BF8F42"

/particles/xeno_slash/hemodile
	color = "#239FB2"

/particles/xeno_slash/transvitox
	color = "#87BF5F"

/particles/xeno_slash/ozelomelyn
	color = "#CCB7C5"

/particles/xeno_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 100
	height = 100
	count = 1000
	spawning = 6
	lifespan = 8
	fade = 12
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 15, 17, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(0.9,0.9), NORMAL_RAND)
	rotation = 0
	spin = generator(GEN_NUM, -20, 20)

/particles/xeno_smoke/neurotoxin
	color = "#BF8F42"

/particles/xeno_smoke/hemodile
	color = "#006C7F"

/particles/xeno_smoke/transvitox
	color = "#87BF5F"

/particles/xeno_smoke/ozelomelyn
	color = "#CCB7C5"

// ***************************************
// *********** Defile
// ***************************************
/datum/action/ability/activable/xeno/defile
	name = "Defile"
	action_icon_state = "defiler_sting"
	desc = "Channel to inject an adjacent target with an accelerant that violently reacts with xeno toxins, releasing gas and dealing heavy tox damage in proportion to the amount in their system."
	ability_cost = 100
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DEFILE,
	)

/datum/action/ability/activable/xeno/defile/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("You feel your toxin accelerant glands refill. You can use Defile again."))
	return ..()

/datum/action/ability/activable/xeno/defile/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!A.can_sting())
		if(!silent)
			A.balloon_alert(owner, "Cannot effect")
		return FALSE

	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent)
			A.balloon_alert(X, "Cannot reach")
		return FALSE


/datum/action/ability/activable/xeno/defile/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/living_target = A
	if(living_target.status_flags & GODMODE)
		owner.balloon_alert(owner, "Cannot defile")
		return fail_activate()
	X.face_atom(living_target)
	if(!do_after(X, DEFILER_DEFILE_CHANNEL_TIME, NONE, living_target, BUSY_ICON_HOSTILE))
		add_cooldown(DEFILER_DEFILE_FAIL_COOLDOWN)
		return fail_activate()
	if(!can_use_ability(A))
		return fail_activate()
	add_cooldown()
	X.face_atom(living_target)
	X.do_attack_animation(living_target)
	playsound(living_target, 'sound/effects/spray3.ogg', 15, TRUE)
	playsound(living_target, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	to_chat(X, span_xenodanger("Our stinger successfully discharges accelerant into our victim."))
	to_chat(living_target, span_danger("You feel horrible pain as something sharp forcibly pierces your thorax."))
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
		if(is_type_in_typecache(current_reagent, GLOB.defiler_toxins_typecache_list)) //For each xeno toxin reagent, double the strength multiplier
			if(istype(current_reagent, /datum/reagent/toxin/xeno_neurotoxin)) //Make sure neurotoxin isn't double counted
				if(neuro_applied)
					continue
				else
					neuro_applied = TRUE
			defile_strength_multiplier *= 2
	if(living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = living_target.has_status_effect(STATUS_EFFECT_INTOXICATED)
		defile_reagent_amount += debuff.stacks
		debuff.stacks -= round(debuff.stacks * 0.5)

	defile_power = defile_reagent_amount * defile_strength_multiplier //Total amount of toxin damage we deal

	living_target.setToxLoss(min(200, living_target.getToxLoss() + defile_power)) //Apply the toxin damage; cap toxin damage at lower of 200 or defile power + current tox loss

	var/datum/effect_system/smoke_spread/xeno/sanguinal/blood_smoke = new(living_target) //Set up Sanguinal smoke
	blood_smoke.strength = CEILING(clamp(defile_power*DEFILER_SANGUINAL_SMOKE_MULTIPLIER,1,2),1)
	blood_smoke.set_up(CEILING(clamp(defile_power*DEFILER_SANGUINAL_SMOKE_MULTIPLIER,1,4),1), get_turf(living_target))
	blood_smoke.start()

	switch(defile_power) //Description varies in severity and probability with the multiplier
		if(1 to 49)
			to_chat(living_target, span_warning("Your body aches."))
		if(50 to 99)
			to_chat(living_target, span_danger("Your insides are in agony!"))
		if(100 to INFINITY)
			to_chat(living_target, span_highdanger("YOUR INSIDES FEEL LIKE THEY'RE ON FIRE!!"))

	GLOB.round_statistics.defiler_defiler_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_defiler_stings")
	succeed_activate()
	return ..()

// ***************************************
// *********** Neurogas
// ***************************************
/datum/action/ability/xeno_action/emit_neurogas
	name = "Emit Noxious Gas"
	action_icon_state = "emit_neurogas"
	desc = "Channel for 3 seconds to emit a cloud of noxious smoke, based on selected reagent, that follows the Defiler. You must remain stationary while channeling; moving will cancel the ability but will still cost plasma."
	ability_cost = 200
	cooldown_duration = 40 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EMIT_NEUROGAS,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/xeno_action/emit_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(owner, span_xenodanger("We feel our dorsal vents bristle with heated gas. We can emit Noxious Gas again."))
	return ..()

/datum/action/ability/xeno_action/emit_neurogas/action_activate()
	var/mob/living/carbon/xenomorph/defiler/X = owner
	toggle_particles(TRUE)

	//give them fair warning
	X.visible_message(span_danger("Tufts of smoke begin to billow from [X]!"), \
	span_xenodanger("Our dorsal vents widen, preparing to emit toxic smoke. We must keep still!"))
	X.balloon_alert(X, "Keep still...")

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.

	X.icon_state = "[X.xeno_caste.caste_name][X.is_a_rouny ? " rouny" : ""] Power Up"

	if(!do_after(X, DEFILER_GAS_CHANNEL_TIME, NONE, null, BUSY_ICON_HOSTILE))
		if(!QDELETED(src))
			to_chat(X, span_xenodanger("We abort emitting fumes, our expended plasma resulting in nothing."))
			X.emitting_gas = FALSE
			X.icon_state = "[X.xeno_caste.caste_name][X.is_a_rouny ? " rouny" : ""] Running"
			return fail_activate()
	X.emitting_gas = FALSE
	X.icon_state = "[X.xeno_caste.caste_name][X.is_a_rouny ? " rouny" : ""] Running"

	add_cooldown()
	succeed_activate()

	if(X.IsStaggered()) //If we got staggered, return
		to_chat(X, span_xenowarning("We try to emit toxins but are staggered!"))
		return fail_activate()

	owner.record_war_crime()
	GLOB.round_statistics.defiler_neurogas_uses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_neurogas_uses")

	X.visible_message(span_xenodanger("[X] emits a noxious gas!"), \
	span_xenodanger("We emit noxious gas!"))
	dispense_gas()

/datum/action/ability/xeno_action/emit_neurogas/fail_activate()
	toggle_particles(FALSE)
	return ..()

/datum/action/ability/xeno_action/emit_neurogas/proc/dispense_gas(time_left = 3, datum/effect_system/smoke_spread/emitted_gas)
	if(time_left <= 0)
		return
	var/mob/living/carbon/xenomorph/defiler/defiler_owner = owner
	var/smoke_range = 2

	if(!emitted_gas)
		switch(defiler_owner.selected_reagent)
			if(/datum/reagent/toxin/xeno_neurotoxin)
				emitted_gas = new /datum/effect_system/smoke_spread/xeno/neuro/medium(defiler_owner)
			if(/datum/reagent/toxin/xeno_hemodile)
				emitted_gas = new /datum/effect_system/smoke_spread/xeno/hemodile(defiler_owner)
			if(/datum/reagent/toxin/xeno_transvitox)
				emitted_gas = new /datum/effect_system/smoke_spread/xeno/transvitox(defiler_owner)
			if(/datum/reagent/toxin/xeno_ozelomelyn)
				emitted_gas = new /datum/effect_system/smoke_spread/xeno/ozelomelyn(defiler_owner)

	if(defiler_owner.IsStaggered()) //If we got staggered, return
		to_chat(defiler_owner, span_xenowarning("We try to emit toxins but are staggered!"))
		toggle_particles(FALSE)
		return
	if(defiler_owner.IsStun() || defiler_owner.IsParalyzed())
		to_chat(defiler_owner, span_xenowarning("We try to emit toxins but are disabled!"))
		toggle_particles(FALSE)
		return
	var/turf/T = get_turf(defiler_owner)
	playsound(T, 'sound/effects/smoke.ogg', 25)
	if(time_left > 1)
		emitted_gas.set_up(smoke_range, T)
	else //last emission is larger
		emitted_gas.set_up(CEILING(smoke_range*1.3,1), T)
	emitted_gas.start()
	T.visible_message(span_danger("Noxious smoke billows from the hulking xenomorph!"))
	toggle_particles(FALSE)
	addtimer(CALLBACK(src, PROC_REF(dispense_gas), time_left - 1, emitted_gas), DEFILER_GAS_DELAY)

// Toggles particles on or off, depending on the defined var.
/datum/action/ability/xeno_action/emit_neurogas/proc/toggle_particles(activate)
	var/mob/living/carbon/xenomorph/X = owner

	if(!activate)
		QDEL_NULL(particle_holder)
		return

	switch(X.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			particle_holder = new(owner, /particles/xeno_smoke/neurotoxin)
		if(/datum/reagent/toxin/xeno_hemodile)
			particle_holder = new(owner, /particles/xeno_smoke/hemodile)
		if(/datum/reagent/toxin/xeno_transvitox)
			particle_holder = new(owner, /particles/xeno_smoke/transvitox)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			particle_holder = new(owner, /particles/xeno_smoke/ozelomelyn)
	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 16

// ***************************************
// *********** Inject Egg Neurogas
// ***************************************
/datum/action/ability/activable/xeno/inject_egg_neurogas
	name = "Inject Gas"
	action_icon_state = "inject_egg"
	desc = "Inject an egg with toxins, killing the larva, but filling it full with gas ready to explode."
	ability_cost = 100
	cooldown_duration = 5 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS,
	)

/datum/action/ability/activable/xeno/inject_egg_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(owner, span_xenodanger("We feel our stinger fill with toxins. We can inject an egg with gas again."))
	return ..()

/datum/action/ability/activable/xeno/inject_egg_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/defiler/X = owner

	if(!owner.Adjacent(A))
		A.balloon_alert(X, "Out of reach")
		return fail_activate()

	if(istype(A, /obj/alien/egg/gas))
		A.balloon_alert(X, "Egg already injected")
		return fail_activate()

	if(!istype(A, /obj/alien/egg/hugger))
		return fail_activate()

	var/obj/alien/egg/alien_egg = A
	if(alien_egg.maturity_stage != alien_egg.stage_ready_to_burst)
		alien_egg.balloon_alert(X, "Egg not mature")
		return fail_activate()

	alien_egg.balloon_alert_to_viewers("Injecting...")
	X.visible_message(span_danger("[X] starts injecting the egg with neurogas, killing the little one inside!"), \
		span_xenodanger("We extend our stinger into the egg, filling it with gas, killing the little one inside!"))
	if(!do_after(X, 2 SECONDS, NONE, alien_egg, BUSY_ICON_HOSTILE))
		alien_egg.balloon_alert_to_viewers("Canceled injection")
		X.visible_message(span_danger("The stinger retracts from [X], leaving the egg and little one alive."), \
			span_xenodanger("Our stinger retracts, leaving the egg and little one alive."))
		return fail_activate()

	succeed_activate()
	add_cooldown()

	var/obj/alien/egg/gas/newegg = new(A.loc, X.hivenumber)
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

	owner.record_war_crime()
	GLOB.round_statistics.defiler_inject_egg_neurogas++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_inject_egg_neurogas")

// ***************************************
// *********** Reagent selection
// ***************************************
/datum/action/ability/xeno_action/select_reagent
	name = "Select Reagent"
	action_icon_state = "select_reagent0"
	desc = "Selects which reagent to use for reagent slash and noxious gas. Neuro causes increasing pain and stamina damage. Hemodile slows targets down, multiplied by each other xeno-based toxin. Transvitox converts burns to toxin, and causes additional toxin damage when they take brute damage, both effects multiplied by other xeno-based toxins. Ozelomelyn purges all medicines from their system rapidly and causes minor toxin damage."
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SELECT_REAGENT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT,
	)

/datum/action/ability/xeno_action/select_reagent/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	X.selected_reagent = GLOB.defiler_toxin_type_list[1] //Set our default
	update_button_icon() //Update immediately to get our default

/datum/action/ability/xeno_action/select_reagent/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_reagent
	action_icon_state = initial(A.name)
	return ..()

/datum/action/ability/xeno_action/select_reagent/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = GLOB.defiler_toxin_type_list.Find(X.selected_reagent)
	if(length(GLOB.defiler_toxin_type_list) == i)
		X.selected_reagent = GLOB.defiler_toxin_type_list[1]
	else
		X.selected_reagent = GLOB.defiler_toxin_type_list[i+1]

	var/atom/A = X.selected_reagent
	X.balloon_alert(X, "[initial(A.name)]")
	update_button_icon()
	return succeed_activate()

/datum/action/ability/xeno_action/select_reagent/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_reagent_radial))
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/select_reagent/proc/select_reagent_radial()
	//List of toxin images
	// This is cursed, don't copy this code its the WRONG way to do this.
	// TODO: generate this from GLOB.defiler_toxin_type_list
	var/static/list/defiler_toxin_images_list = list(
			DEFILER_NEUROTOXIN = image('icons/Xeno/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
			DEFILER_HEMODILE = image('icons/Xeno/actions.dmi', icon_state = DEFILER_HEMODILE),
			DEFILER_TRANSVITOX = image('icons/Xeno/actions.dmi', icon_state = DEFILER_TRANSVITOX),
			DEFILER_OZELOMELYN = image('icons/Xeno/actions.dmi', icon_state = DEFILER_OZELOMELYN),
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
	X.balloon_alert(X, "[toxin_choice]")
	update_button_icon()
	return succeed_activate()

// ***************************************
// *********** Reagent slash
// ***************************************
/datum/action/ability/xeno_action/reagent_slash
	name = "Reagent Slash"
	action_icon_state = "reagent_slash"
	desc = "For a short duration the next 3 slashes made will inject a small amount of selected toxin."
	cooldown_duration = 6 SECONDS
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REAGENT_SLASH,
	)
	target_flags = ABILITY_MOB_TARGET
	///How many remaining reagent slashes the Defiler has
	var/reagent_slash_count = 0
	///Timer ID for the Reagent Slashes timer; we reference this to delete the timer if the effect lapses before the timer does
	var/reagent_slash_duration_timer_id
	///Defines the reagent being used for reagent slashes; locks it to the selected reagent on activation
	var/reagent_slash_reagent
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/xeno_action/reagent_slash/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner

	RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(reagent_slash))

	reagent_slash_count = DEFILER_REAGENT_SLASH_COUNT //Set the number of slashes
	reagent_slash_duration_timer_id = addtimer(CALLBACK(src, PROC_REF(reagent_slash_deactivate), X), DEFILER_REAGENT_SLASH_DURATION, TIMER_STOPPABLE) //Initiate the timer and set the timer ID for reference
	reagent_slash_reagent = X.selected_reagent

	X.balloon_alert(X, "Reagent slash active") //Let the user know
	X.playsound_local(X, 'sound/voice/alien_drool2.ogg', 25)

	toggle_particles(TRUE)
	succeed_activate()
	add_cooldown()

///Called when the duration of reagent slash lapses
/datum/action/ability/xeno_action/reagent_slash/proc/reagent_slash_deactivate(mob/living/carbon/xenomorph/X)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING) //unregister the signals; party's over

	reagent_slash_count = 0 //Zero out vars
	deltimer(reagent_slash_duration_timer_id) //delete the timer so we don't have mismatch issues, and so we don't potentially try to deactivate the ability twice
	reagent_slash_duration_timer_id = null
	reagent_slash_reagent = null
	toggle_particles(FALSE)

	X.balloon_alert(X, "Reagent slash over") //Let the user know
	X.playsound_local(X, 'sound/voice/hiss5.ogg', 25)


///Called when we slash while reagent slash is active
/datum/action/ability/xeno_action/reagent_slash/proc/reagent_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER

	if(!target?.can_sting()) //We only care about targets that we can actually sting
		return

	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/carbon_target = target

	carbon_target.reagents.add_reagent(reagent_slash_reagent, DEFILER_REAGENT_SLASH_INJECT_AMOUNT)
	playsound(carbon_target, 'sound/effects/spray3.ogg', 15, TRUE)
	X.visible_message(carbon_target, span_danger("[carbon_target] is pricked by [X]'s spines!"))

	GLOB.round_statistics.defiler_reagent_slashes++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_reagent_slashes")

	reagent_slash_count-- //Decrement the reagent slash count

	if(!reagent_slash_count) //Deactivate if we have no reagent slashes remaining
		reagent_slash_deactivate(X)


/datum/action/ability/xeno_action/reagent_slash/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to infuse our spines with toxins again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// Toggles particles on or off, depending on the defined var.
/datum/action/ability/xeno_action/reagent_slash/proc/toggle_particles(activate)
	var/mob/living/carbon/xenomorph/X = owner

	if(!activate)
		QDEL_NULL(particle_holder)
		return

	switch(X.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			particle_holder = new(owner, /particles/xeno_slash/neurotoxin)
		if(/datum/reagent/toxin/xeno_hemodile)
			particle_holder = new(owner, /particles/xeno_slash/hemodile)
		if(/datum/reagent/toxin/xeno_transvitox)
			particle_holder = new(owner, /particles/xeno_slash/transvitox)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			particle_holder = new(owner, /particles/xeno_slash/ozelomelyn)
	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 12

// ***************************************
// *********** Tentacle
// ***************************************
/datum/action/ability/activable/xeno/tentacle
	name = "Tentacle"
	action_icon_state = "tail_attack"
	desc = "Throw one of your tentacles forward to grab a tallhost or item."
	cooldown_duration = 20 SECONDS
	ability_cost = 175
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TENTACLE,
	)
	///reference to beam tentacle
	var/datum/beam/tentacle

/datum/action/ability/activable/xeno/tentacle/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isitem(A) && !ishuman(A))
		if(!silent)
			A.balloon_alert(owner, "Cannot grab")
		return FALSE
	if(isliving(A))
		var/mob/living/livingtarget = A
		if(livingtarget.stat == DEAD)
			if(!silent)
				livingtarget.balloon_alert(owner, "Cannot grab, dead")
			return FALSE
	var/atom/movable/target = A
	if(target.anchored)
		if(!silent)
			target.balloon_alert(owner, "Cannot grab, anchored")
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
				target.balloon_alert(owner, "Cannot reach")
			return FALSE
		current = get_step_towards(current, target_turf)


/datum/action/ability/activable/xeno/tentacle/use_ability(atom/movable/target)
	var/atom/movable/tentacle_end/tentacle_end = new (get_turf(owner))
	tentacle = owner.beam(tentacle_end,"curse0",'icons/effects/beam.dmi')
	RegisterSignals(tentacle_end, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT), PROC_REF(finish_grab))
	tentacle_end.throw_at(target, TENTACLE_ABILITY_RANGE * 1.5, 3, owner, FALSE) //Too hard to hit if just TENTACLE_ABILITY_RANGE
	succeed_activate()
	add_cooldown()

///Signal handler to grab the target when we thentacle head hit something
/datum/action/ability/activable/xeno/tentacle/proc/finish_grab(datum/source, atom/movable/target)
	SIGNAL_HANDLER
	QDEL_NULL(tentacle)
	qdel(source)
	if(!can_use_ability(target, TRUE, ABILITY_IGNORE_COOLDOWN|ABILITY_IGNORE_PLASMA))
		owner.balloon_alert(owner, "Grab failed")
		clear_cooldown()
		return
	tentacle = owner.beam(target, "curse0",'icons/effects/beam.dmi')
	playsound(target, 'sound/effects/blobattack.ogg', 40, 1)
	to_chat(owner, span_warning("We grab [target] with a tentacle!"))
	target.balloon_alert_to_viewers("Grabbed!")
	RegisterSignal(target, COMSIG_MOVABLE_POST_THROW, PROC_REF(delete_beam))
	target.throw_at(owner, TENTACLE_ABILITY_RANGE, 1, owner, FALSE)
	if(isliving(target))
		var/mob/living/loser = target
		loser.apply_effect(0.2 SECONDS, WEAKEN)
		loser.adjust_stagger(5 SECONDS)

///signal handler to delete tetacle after we are done draggging owner along
/datum/action/ability/activable/xeno/tentacle/proc/delete_beam(datum/source, atom/impacted)
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
