GLOBAL_LIST_INIT(defiler_toxins, typecacheof(list(
		/datum/reagent/toxin/xeno_neurotoxin,
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox
	)))



// ***************************************
// *********** Defile
// ***************************************
/datum/action/xeno_action/activable/defile
	name = "Defile"
	action_icon_state = "defiler_sting"
	mechanics_text = "Injects an adjacent target with larval accelerant and a larva after a short wind up. All Defiler rapidly increase larval growth while the target has larval accelerant."
	ability_name = "defiler sting"
	plasma_cost = 150
	cooldown_timer = 60 SECONDS
	keybind_signal = COMSIG_XENOABILITY_DEFILE

/datum/action/xeno_action/activable/defile/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	to_chat(owner, "<span class='xenodanger'>You feel your toxin glands refill and another young one ready for implantation. You can use Defile again.</span>")
	return ..()

/datum/action/xeno_action/activable/defile/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!iscarbon(A))
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>Our sting won't affect this target!</span>")
		return FALSE

	var/mob/living/carbon/victim = A

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>Our sting won't affect this target!</span>")
		return FALSE

	if(CHECK_BITFIELD(victim.status_flags, XENO_HOST)) // already got one, stops doubling up
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>This target already has a young one!</span>")
		return FALSE

	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent)
			to_chat(X, "<span class='warning'>We can't reach this target!</span>")
		return FALSE


/datum/action/xeno_action/activable/defile/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	var/mob/living/carbon/C = A
	X.face_atom(C)
	X.do_attack_animation(C)
	if(!do_after(X, DEFILER_STING_CHANNEL_TIME, TRUE, C, BUSY_ICON_HOSTILE))
		return fail_activate()
	if(!can_use_ability(A))
		return fail_activate()
	add_cooldown()
	playsound(C, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	playsound(C, 'sound/effects/spray3.ogg', 15, TRUE)
	var/obj/item/alien_embryo/embryo = new(C)
	embryo.hivenumber = X.hivenumber
	GLOB.round_statistics.now_pregnant++
	C.reagents.add_reagent(/datum/reagent/toxin/xeno_growthtoxin, REAGENTS_OVERDOSE, no_overdose = TRUE) //Inject the maximum possible larval growth without ODing
	SSblackbox.record_feedback("tally", "round_statistics", 1, "now_pregnant")
	to_chat(X, "<span class='xenodanger'>Our stinger successfully implants a larva into the host.</span>")
	to_chat(C, "<span class='danger'>You feel horrible pain as something large is forcefully implanted in your thorax.</span>")
	C.adjust_stagger(3)
	C.add_slowdown(3)
	C.adjust_blurriness(3) //Cosmetic eye blur SFX
	C.reagents.add_reagent(X.selected_reagent, DEFILER_DEFILE_INJECT_AMOUNT, no_overdose = TRUE) //Inject selected chem with OD protection
	C.apply_damage(50, STAMINA) //Mainly to remove the ability to sprint
	C.apply_damage(5, BRUTE, "chest", updating_health = TRUE) //Cosmetic
	C.emote("scream")
	GLOB.round_statistics.defiler_defiler_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_defiler_stings")
	succeed_activate()

// ***************************************
// *********** Neurogas
// ***************************************
/datum/action/xeno_action/activable/emit_neurogas
	name = "Emit Noxious Gas"
	action_icon_state = "emit_neurogas"
	mechanics_text = "Channel for 3 seconds to emit a cloud of noxious smoke, based on selected reagent, that follows the Defiler. You must remain stationary while channeling; moving will cancel the ability but will still cost plasma."
	ability_name = "emit neurogas"
	plasma_cost = 200
	cooldown_timer = 40 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY|XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/action/xeno_action/activable/emit_neurogas/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	to_chat(owner, "<span class='xenodanger'>We feel our dorsal vents bristle with heated gas. We can use Emit Noxious Gas again.</span>")
	return ..()

/datum/action/xeno_action/activable/emit_neurogas/fail_activate()
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	X.use_plasma(plasma_cost)
	return ..()

/datum/action/xeno_action/activable/emit_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	//give them fair warning
	X.visible_message("<span class='danger'>Tufts of smoke begin to billow from [X]!</span>", \
	"<span class='xenodanger'>Our dorsal vents widen, preparing to emit toxic smoke. We must keep still!</span>")

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	X.icon_state = "Defiler Power Up"

	if(!do_after(X, DEFILER_GAS_CHANNEL_TIME, TRUE, null, BUSY_ICON_HOSTILE))
		if(!QDELETED(src))
			to_chat(X, "<span class='xenodanger'>We abort emitting fumes, our expended plasma resulting in nothing.</span>")
			X.emitting_gas = FALSE
			X.icon_state = "Defiler Running"
			return fail_activate()
	X.emitting_gas = FALSE
	X.icon_state = "Defiler Running"

	add_cooldown()
	succeed_activate()

	GLOB.round_statistics.defiler_neurogas_uses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_neurogas_uses")

	X.visible_message("<span class='xenodanger'>[X] emits a noxious gas!</span>", \
	"<span class='xenodanger'>We emit noxious gas!</span>")
	dispense_gas()

/datum/action/xeno_action/activable/emit_neurogas/proc/dispense_gas(count = 3)
	if(!count) //If no repetitions left, cancel out
		return

	var/mob/living/carbon/xenomorph/Defiler/X = owner

	if(X.stagger) //If we got staggered, return
		to_chat(X, "<span class='xenowarning'>We try to emit toxins but are staggered!</span>")
		return
	if(X.IsStun() || X.IsParalyzed())
		to_chat(X, "<span class='xenowarning'>We try to emit toxins but are disabled!</span>")
		return

	var/smoke_range = 2
	var/datum/effect_system/smoke_spread/xeno/neuro/medium/N = new(X)
	N.strength = 1
	if(X.selected_reagent == /datum/reagent/toxin/xeno_hemodile)
		N.smoke_type = /obj/effect/particle_effect/smoke/xeno/hemodile
		smoke_range = 4
	else if(X.selected_reagent == /datum/reagent/toxin/xeno_transvitox)
		N.smoke_type = /obj/effect/particle_effect/smoke/xeno/transvitox
		smoke_range = 4

	var/turf/T = get_turf(X)
	playsound(T, 'sound/effects/smoke.ogg', 25)
	if(count > 1)
		N.set_up(smoke_range, T)
	else //last emission is larger
		N.set_up(CEILING(smoke_range*1.3, 1), T)
	N.start()
	T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")
	count = max(0,count - 1)

	addtimer(CALLBACK(src, .proc/dispense_gas, count), DEFILER_GAS_DELAY) //Cycle; replaces use of sleep


// ***************************************
// *********** Inject Egg Neurogas
// ***************************************
/datum/action/xeno_action/activable/inject_egg_neurogas
	name = "Inject Gas"
	action_icon_state = "inject_egg"
	mechanics_text = "Inject an egg with gas of the selected toxin type, killing the facehugger inside, but filling it with gas ready to explode."
	ability_name = "inject neurogas"
	plasma_cost = 100
	cooldown_timer = 5 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS

/datum/action/xeno_action/activable/inject_egg_neurogas/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	to_chat(owner, "<span class='xenodanger'>We feel our dorsal vents bristle with neurotoxic gas. We can use Emit Neurogas again.</span>")
	return ..()

/datum/action/xeno_action/activable/inject_egg_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	if(!istype(A, /obj/effect/alien/egg))
		return fail_activate()

	var/obj/effect/alien/egg/alien_egg = A
	if(alien_egg.status != EGG_GROWN)
		to_chat(X, "<span class='warning'>That egg isn't strong enough to hold our gases.</span>")
		return fail_activate()

	X.visible_message("<span class='danger'>[X] starts injecting the egg with neurogas, killing the little one inside!</span>", \
		"<span class='xenodanger'>We extend our stinger into the egg, filling it with gas, killing the little one inside!</span>")
	if(!do_after(X, 2 SECONDS, TRUE, alien_egg, BUSY_ICON_HOSTILE))
		X.visible_message("<span class='danger'>The stinger retracts from [X], leaving the egg and little one alive.</span>", \
			"<span class='xenodanger'>Our stinger retracts, leaving the egg and little one alive.</span>")
		return fail_activate()

	succeed_activate()
	add_cooldown()

	var/obj/effect/alien/egg/gas/trapped_egg = new(A.loc)
	qdel(alien_egg)

	if(X.selected_reagent == /datum/reagent/toxin/xeno_hemodile)
		trapped_egg.selected_reagent = /obj/effect/particle_effect/smoke/xeno/hemodile
		trapped_egg.aoe_increment = 1
	else if(X.selected_reagent == /datum/reagent/toxin/xeno_transvitox)
		trapped_egg.selected_reagent = /obj/effect/particle_effect/smoke/xeno/transvitox
		trapped_egg.aoe_increment = 1
	else
		trapped_egg.selected_reagent = /obj/effect/particle_effect/smoke/xeno/neuro //apply the gassssss

	GLOB.round_statistics.defiler_inject_egg_neurogas++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_inject_egg_neurogas")

// ***************************************
// *********** Reagent selection
// ***************************************
/datum/action/xeno_action/select_reagent
	name = "Select Reagent"
	action_icon_state = "select_reagent0"
	mechanics_text = "Selects which reagent to use for reagent slash and noxious gas. Hemodile slows by 25%, doubled for each other Defiler chem in the target's blood, and deals 20% of damage received as stamina damage. Transvitox converts brute/burn damage to toxin based on 40% of damage received up to 45 toxin on target, upon reaching which causes a stun. Neurotoxin deals increasing stamina damage the longer it remains in the victim's system and prevents stamina regeneration."
	use_state_flags = XACT_USE_BUSY
	keybind_signal = COMSIG_XENOABILITY_SELECT_REAGENT
	var/list_position

/datum/action/xeno_action/select_reagent/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_reagent
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/select_reagent/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/available_reagents = X.xeno_caste.available_reagents_define
	if(list_position < length(available_reagents))
		list_position++
	else
		list_position = 1
	X.selected_reagent = available_reagents[list_position]
	var/atom/A = X.selected_reagent
	to_chat(X, "<span class='notice'>We will now slash with <b>[initial(A.name)]</b>.</span>")
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


/datum/action/xeno_action/reagent_slash/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner

	RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/reagent_slash)

	reagent_slash_count = DEFILER_REAGENT_SLASH_COUNT //Set the number of slashes
	reagent_slash_duration_timer_id = addtimer(CALLBACK(src, .proc/reagent_slash_deactivate, X), DEFILER_REAGENT_SLASH_DURATION, TIMER_STOPPABLE) //Initiate the timer and set the timer ID for reference

	to_chat(X, "<span class='xenodanger'>Our spines fill with virulent toxins!</span>") //Let the user know
	X.playsound_local(X, 'sound/voice/alien_drool2.ogg', 25)

	succeed_activate()
	add_cooldown()

///Called when the duration of reagent slash lapses
/datum/action/xeno_action/reagent_slash/proc/reagent_slash_deactivate(mob/living/carbon/xenomorph/X)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING) //unregister the signals; party's over

	reagent_slash_count = 0 //Zero out vars
	deltimer(reagent_slash_duration_timer_id) //delete the timer so we don't have mismatch issues, and so we don't potentially try to deactivate the ability twice
	reagent_slash_duration_timer_id = null

	to_chat(X, "<span class='xenodanger'>We are no longer benefitting from [src].</span>") //Let the user know
	X.playsound_local(X, 'sound/voice/hiss5.ogg', 25)


///Called when we slash while reagent slash is active
/datum/action/xeno_action/reagent_slash/proc/reagent_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER

	if(!target?.can_sting()) //We only care about targets that we can actually sting
		return

	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/carbon_target = target

	carbon_target.reagents.add_reagent(X.selected_reagent, DEFILER_REAGENT_SLASH_INJECT_AMOUNT)
	carbon_target.reagents.add_reagent(/datum/reagent/toxin/xeno_growthtoxin, DEFILER_REAGENT_SLASH_INJECT_AMOUNT, no_overdose = TRUE) //Inject larval growth without ODing
	playsound(carbon_target, 'sound/effects/spray3.ogg', 15, TRUE)
	X.visible_message(carbon_target, "<span class='danger'>[carbon_target] is pricked by [X]'s spines!</span>")

	GLOB.round_statistics.defiler_reagent_slashes++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_reagent_slashes")

	reagent_slash_count-- //Decrement the reagent slash count

	if(!reagent_slash_count) //Deactivate if we have no reagent slashes remaining
		reagent_slash_deactivate(X)


/datum/action/xeno_action/reagent_slash/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We are able to infuse our spines with toxins again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()
