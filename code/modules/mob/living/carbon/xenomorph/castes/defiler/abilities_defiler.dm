
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

/datum/action/xeno_action/activable/larval_growth_sting/defiler/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, "<span class='xenodanger'>You feel your toxin glands refill, another young one ready for implantation. You can use Defile again.</span>")
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
	to_chat(X, "<span class='xenodanger'>Our stinger successfully implants a larva into the host.</span>")
	to_chat(C, "<span class='danger'>You feel horrible pain as something large is forcefully implanted in your thorax.</span>")
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
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(owner, "<span class='xenodanger'>We feel our dorsal vents bristle with heated gas. We can use Emit Noxious Gas again.</span>")
	return ..()

/datum/action/xeno_action/activable/emit_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	//give them fair warning
	X.visible_message("<span class='danger'>Tufts of smoke begin to billow from [X]!</span>", \
	"<span class='xenodanger'>Our dorsal vents widen, preparing to emit toxic smoke. We must keep still!</span>")

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	succeed_activate()
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

	if(X.stagger) //If we got staggered, return
		to_chat(X, "<span class='xenowarning'>We try to emit toxins but are staggered!</span>")
		return fail_activate()

	GLOB.round_statistics.defiler_neurogas_uses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_neurogas_uses")

	X.visible_message("<span class='xenodanger'>[X] emits a noxious gas!</span>", \
	"<span class='xenodanger'>We emit noxious gas!</span>")
	dispense_gas()

/datum/action/xeno_action/activable/emit_neurogas/proc/dispense_gas(count = 3)
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	set waitfor = FALSE
	var/smoke_range = 2
	var/datum/effect_system/smoke_spread/xeno/neuro/N = new(X)
	N.strength = 1
	if(X.selected_reagent == /datum/reagent/toxin/xeno_hemodile)
		N.smoke_type = /obj/effect/particle_effect/smoke/xeno/hemodile
		smoke_range = 3
	else if(X.selected_reagent == /datum/reagent/toxin/xeno_transvitox)
		N.smoke_type = /obj/effect/particle_effect/smoke/xeno/transvitox
		N.strength = -0.75
		smoke_range = 4
	while(count)
		if(X.stagger) //If we got staggered, return
			to_chat(X, "<span class='xenowarning'>We try to emit toxins but are staggered!</span>")
			return
		if(X.IsStun() || X.IsParalyzed())
			to_chat(X, "<span class='xenowarning'>We try to emit toxins but are disabled!</span>")
			return
		var/turf/T = get_turf(X)
		playsound(T, 'sound/effects/smoke.ogg', 25)
		if(count > 1)
			N.set_up(smoke_range, T)
		else //last emission is larger
			N.set_up(round(smoke_range*1.3), T)
		N.start()
		T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")
		count = max(0,count - 1)
		sleep(DEFILER_GAS_DELAY)


// ***************************************
// *********** Inject Egg Neurogas
// ***************************************
/datum/action/xeno_action/activable/inject_egg_neurogas
	name = "Inject Neurogas"
	action_icon_state = "inject_egg"
	mechanics_text = "Inject an egg with neurogas, killing the egg, but filling it full with neurogas ready to explode."
	ability_name = "inject neurogas"
	plasma_cost = 100
	cooldown_timer = 5 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS

/datum/action/xeno_action/activable/inject_egg_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
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

	new /obj/effect/alien/egg/gas(A.loc)
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
/datum/action/xeno_action/activable/reagent_slash
	name = "Reagent Slash"
	action_icon_state = "reagent_slash"
	mechanics_text = "Deals damage 4 times over 3.6s and injects 3u of selected reagent per slash. Can move while slashing."
	ability_name = "reagent slash"
	cooldown_timer = 6 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_REAGENT_SLASH
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/reagent_slash/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(get_dist(owner, A) > 1)
		to_chat(owner, "<span class='warning'>We need to be next to our prey.</span>")
		return FALSE
	if(!A.can_sting())
		to_chat(owner, "<span class='warning'>Our slash won't affect this target!</span>")
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/reagent_slash/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	succeed_activate()
	slash_action(A, X.selected_reagent, DEFILER_REAGENT_SLASH_DELAY, DEFILER_REAGENT_SLASH_U_AMOUNT, DEFILER_REAGENT_SLASH_COUNT)
	add_cooldown()

/datum/action/xeno_action/activable/reagent_slash/proc/slash_action(mob/living/carbon/C, toxin = /datum/reagent/toxin/xeno_neurotoxin, channel_time = 1 SECONDS, transfer_amount = 4, count = 3)
	var/mob/living/carbon/xenomorph/X = owner
	var/datum/limb/affecting = X.zone_selected
	var/i = 1
	do
		if(get_dist(X, C) > 1)
			to_chat(X, "<span class='warning'>We need to be closer to [C].</span>")
			return
		if(X.stagger)
			return
		X.face_atom(C)
		C.reagents.add_reagent(toxin, transfer_amount)
		playsound(C, "alien_claw_flesh", 25, TRUE)
		playsound(C, 'sound/effects/spray3.ogg', 15, TRUE)
		C.attack_alien_harm(X, dam_bonus = -17, set_location = affecting, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null) //dam_bonus influences slash amount using attack damage as a base, it's low because you can slash while the effect is going on
		X.visible_message(C, "<span class='danger'>The [X] swipes at [C]!</span>")
		X.do_attack_animation(C)
	while(i++ < count && do_after(X, channel_time, TRUE, null, BUSY_ICON_HOSTILE, ignore_turf_checks = TRUE))
