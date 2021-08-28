#define DEFILER_NEUROTOXIN "Neurotoxin"
#define DEFILER_HEMODILE "Hemodile"
#define DEFILER_TRANSVITOX "Transvitox"

// ***************************************
// *********** Sting
// ***************************************
/datum/action/xeno_action/activable/larval_growth_sting/defiler
	name = "Defile"
	action_icon_state = "defiler_sting"
	mechanics_text = "Channel to inject an adjacent target with larval growth serum. At the end of the channel your target will be infected."
	ability_name = "defiler sting"
	plasma_cost = 150
	cooldown_timer = 20 SECONDS
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/larval_growth_sting/defiler/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("You feel your toxin glands refill, another young one ready for implantation. You can use Defile again."))
	return ..()

/datum/action/xeno_action/activable/larval_growth_sting/defiler/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	var/mob/living/carbon/C = A
	if(locate(/obj/item/alien_embryo) in C) // already got one, stops doubling up
		return ..()
	if(!do_after(X, DEFILER_STING_CHANNEL_TIME, TRUE, C, BUSY_ICON_HOSTILE))
		return fail_activate()
	if(!can_use_ability(A))
		return fail_activate()
	add_cooldown()
	X.face_atom(C)
	X.do_attack_animation(C)
	playsound(C, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	var/obj/item/alien_embryo/embryo = new(C)
	embryo.hivenumber = X.hivenumber
	GLOB.round_statistics.now_pregnant++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "now_pregnant")
	to_chat(X, span_xenodanger("Our stinger successfully implants a larva into the host."))
	to_chat(C, span_danger("You feel horrible pain as something large is forcefully implanted in your thorax."))
	C.apply_damage(100, STAMINA)
	C.apply_damage(10, BRUTE, "chest", updating_health = TRUE)
	C.emote("scream")
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
	to_chat(owner, span_xenodanger("We feel our dorsal vents bristle with heated gas. We can use Emit Noxious Gas again."))
	return ..()

/datum/action/xeno_action/emit_neurogas/action_activate()
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	//give them fair warning
	X.visible_message(span_danger("Tufts of smoke begin to billow from [X]!"), \
	span_xenodanger("Our dorsal vents widen, preparing to emit toxic smoke. We must keep still!"))

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	succeed_activate()
	X.icon_state = "Defiler Power Up"

	if(!do_after(X, DEFILER_GAS_CHANNEL_TIME, TRUE, null, BUSY_ICON_HOSTILE))
		if(!QDELETED(src))
			to_chat(X, span_xenodanger("We abort emitting fumes, our expended plasma resulting in nothing."))
			X.emitting_gas = FALSE
			X.icon_state = "Defiler Running"
			return fail_activate()
	X.emitting_gas = FALSE
	X.icon_state = "Defiler Running"

	add_cooldown()

	if(X.stagger) //If we got staggered, return
		to_chat(X, span_xenowarning("We try to emit toxins but are staggered!"))
		return fail_activate()

	GLOB.round_statistics.defiler_neurogas_uses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_neurogas_uses")

	X.visible_message(span_xenodanger("[X] emits a noxious gas!"), \
	span_xenodanger("We emit noxious gas!"))
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
			smoke_range = 3
		if(/datum/reagent/toxin/xeno_transvitox)
			gas = new /datum/effect_system/smoke_spread/xeno/transvitox(X)
			smoke_range = 4

	while(count)
		if(X.stagger) //If we got staggered, return
			to_chat(X, span_xenowarning("We try to emit toxins but are staggered!"))
			return
		if(X.IsStun() || X.IsParalyzed())
			to_chat(X, span_xenowarning("We try to emit toxins but are disabled!"))
			return
		var/turf/T = get_turf(X)
		playsound(T, 'sound/effects/smoke.ogg', 25)
		if(count > 1)
			gas.set_up(smoke_range, T)
		else //last emission is larger
			gas.set_up(CEILING(smoke_range*1.3,1), T)
		gas.start()
		T.visible_message(span_danger("Noxious smoke billows from the hulking xenomorph!"))
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
	to_chat(owner, span_xenodanger("We feel our stinger fill with toxins. We can inject an egg with gas again."))
	return ..()

/datum/action/xeno_action/activable/inject_egg_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	if(!istype(A, /obj/effect/alien/egg))
		return fail_activate()

	if(istype(A, /obj/effect/alien/egg/gas))
		to_chat(X, span_warning("That egg has already been filled with toxic gas.") )
		return fail_activate()

	var/obj/effect/alien/egg/alien_egg = A
	if(alien_egg.status != EGG_GROWN)
		to_chat(X, span_warning("That egg isn't strong enough to hold our gases."))
		return fail_activate()

	X.visible_message(span_danger("[X] starts injecting the egg with neurogas, killing the little one inside!"), \
		span_xenodanger("We extend our stinger into the egg, filling it with gas, killing the little one inside!"))
	if(!do_after(X, 2 SECONDS, TRUE, alien_egg, BUSY_ICON_HOSTILE))
		X.visible_message(span_danger("The stinger retracts from [X], leaving the egg and little one alive."), \
			span_xenodanger("Our stinger retracts, leaving the egg and little one alive."))
		return fail_activate()

	succeed_activate()
	add_cooldown()

	var/obj/effect/alien/egg/gas/newegg = new(A.loc)
	switch(X.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/neuro/medium
		if(/datum/reagent/toxin/xeno_hemodile)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/hemodile
			newegg.gas_size_bonus = 1
		if(/datum/reagent/toxin/xeno_transvitox)
			newegg.gas_type = /datum/effect_system/smoke_spread/xeno/transvitox
			newegg.gas_size_bonus = 2
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
	to_chat(X, span_notice("We will now use <b>[initial(A.name)]</b>."))
	update_button_icon()
	return succeed_activate()

/datum/action/xeno_action/select_reagent/alternate_keybind_action()
	INVOKE_ASYNC(src, .proc/select_reagent_radial)

/datum/action/xeno_action/select_reagent/proc/select_reagent_radial()
	//List of toxin images
	var/static/list/defiler_toxin_images_list = list(
			DEFILER_NEUROTOXIN = image('icons/mob/actions.dmi', icon_state = DEFILER_NEUROTOXIN),
			DEFILER_HEMODILE = image('icons/mob/actions.dmi', icon_state = DEFILER_HEMODILE),
			DEFILER_TRANSVITOX = image('icons/mob/actions.dmi', icon_state = DEFILER_TRANSVITOX),
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
	to_chat(X, span_notice("We will now use <b>[toxin_choice]</b>."))
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

	to_chat(X, span_xenodanger("Our spines fill with virulent toxins!")) //Let the user know
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

	to_chat(X, span_xenodanger("We are no longer benefitting from [src].")) //Let the user know
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
	X.visible_message(carbon_target, span_danger("[carbon_target] is pricked by [X]'s spines!"))

	GLOB.round_statistics.defiler_reagent_slashes++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_reagent_slashes")

	reagent_slash_count-- //Decrement the reagent slash count

	if(!reagent_slash_count) //Deactivate if we have no reagent slashes remaining
		reagent_slash_deactivate(X)


/datum/action/xeno_action/reagent_slash/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to infuse our spines with toxins again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

#undef DEFILER_NEUROTOXIN
#undef DEFILER_HEMODILE
#undef DEFILER_TRANSVITOX
