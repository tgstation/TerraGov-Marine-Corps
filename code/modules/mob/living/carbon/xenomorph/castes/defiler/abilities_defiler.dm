
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
	C.apply_damage(10, BRUTE, "chest")
	UPDATEHEALTH(C)
	C.emote("scream")
	GLOB.round_statistics.defiler_defiler_stings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_defiler_stings")
	succeed_activate()
	return ..()

// ***************************************
// *********** Neurogas
// ***************************************
/datum/action/xeno_action/activable/emit_neurogas
	name = "Emit Neurogas"
	action_icon_state = "emit_neurogas"
	mechanics_text = "Channel for 3 seconds to emit a cloud of noxious smoke that follows the Defiler. You must remain stationary while channeling; moving will cancel the ability but will still cost plasma."
	ability_name = "emit neurogas"
	plasma_cost = 200
	cooldown_timer = 40 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/action/xeno_action/activable/emit_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(owner, "<span class='xenodanger'>We feel our dorsal vents bristle with neurotoxic gas. We can use Emit Neurogas again.</span>")
	return ..()

/datum/action/xeno_action/activable/emit_neurogas/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	//give them fair warning
	X.visible_message("<span class='danger'>Tufts of smoke begin to billow from [X]!</span>", \
	"<span class='xenodanger'>Our dorsal vents widen, preparing to emit neurogas. We must keep still!</span>")

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	succeed_activate()
	X.icon_state = "Defiler Power Up"

	if(!do_after(X, DEFILER_GAS_CHANNEL_TIME, TRUE, null, BUSY_ICON_HOSTILE))
		if(!QDELETED(src))
			to_chat(X, "<span class='xenodanger'>We abort emitting neurogas, our expended plasma resulting in nothing.</span>")
			X.emitting_gas = FALSE
			X.icon_state = "Defiler Running"
			return fail_activate()
	X.emitting_gas = FALSE
	X.icon_state = "Defiler Running"

	add_cooldown()

	if(X.stagger) //If we got staggered, return
		to_chat(X, "<span class='xenowarning'>We try to emit neurogas but are staggered!</span>")
		return fail_activate()

	GLOB.round_statistics.defiler_neurogas_uses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defiler_neurogas_uses")

	X.visible_message("<span class='xenodanger'>[X] emits a noxious gas!</span>", \
	"<span class='xenodanger'>We emit neurogas!</span>")
	dispense_gas()

/datum/action/xeno_action/activable/emit_neurogas/proc/dispense_gas(count = 3)
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	set waitfor = FALSE
	while(count)
		if(X.stagger) //If we got staggered, return
			to_chat(X, "<span class='xenowarning'>We try to emit neurogas but are staggered!</span>")
			return
		if(X.IsStun() || X.IsParalyzed())
			to_chat(X, "<span class='xenowarning'>We try to emit neurogas but are disabled!</span>")
			return
		var/turf/T = get_turf(X)
		playsound(T, 'sound/effects/smoke.ogg', 25)
		var/datum/effect_system/smoke_spread/xeno/neuro/N = new(X)
		if(count > 1)
			N.set_up(2, T)
		else //last emission is larger
			N.set_up(3, T)
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
