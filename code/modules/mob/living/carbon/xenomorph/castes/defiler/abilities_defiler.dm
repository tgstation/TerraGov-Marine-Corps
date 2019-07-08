// ***************************************
// *********** Neuroclaws
// ***************************************
/datum/action/xeno_action/neuroclaws
	name = "Toggle Neuroinjectors"
	action_icon_state = "neuroclaws_off"
	mechanics_text = "Toggle on to add neurotoxin to your melee slashes."
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_NEUROCLAWS
	var/active = FALSE

/datum/action/xeno_action/neuroclaws/action_activate()
	var/mob/living/carbon/xenomorph/Defiler/X = owner

	add_cooldown()
	active = !active
	to_chat(X, "<span class='notice'>You [active ? "extend" : "retract"] your claws' neuro spines.</span>")

	if(active)
		playsound(X, 'sound/weapons/slash.ogg', 15, 1)
		RegisterSignal(src, list(
			COMSIG_XENOMORPH_DISARM_HUMAN,
			COMSIG_XENOMORPH_ATTACK_HUMAN),
			.proc/slash)
	else
		playsound(X, 'sound/weapons/slashmiss.ogg', 15, 1)
		UnregisterSignal(src, list(
			COMSIG_XENOMORPH_DISARM_HUMAN,
			COMSIG_XENOMORPH_ATTACK_HUMAN))

	update_button_icon()

/datum/action/xeno_action/neuroclaws/update_button_icon()
	button.overlays.Cut()
	if(active)
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_on")
	else
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_off")
	return ..()

/datum/action/xeno_action/neuroclaws/proc/slash(datum/source, mob/living/carbon/human/H, damage, list/damage_mod)
	if(!active)
		CRASH("neuroclaws slash callback invoked without neuroclaws active")
	if(!H)
		CRASH("neuroclaws slash callback invoked with a null human reference")
	var/mob/living/carbon/xenomorph/Defiler/X = owner
	if(!X.check_plasma(50))
		return
	X.use_plasma(50)
	H.reagents.add_reagent("xeno_toxin", X.xeno_caste.neuro_claws_amount)
	to_chat(X, "<span class='xenowarning'>Your claw spines inject your victim with neurotoxin!</span>")

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
	to_chat(X, "<span class='xenodanger'>Our stinger successfully implants a larva into the host.</span>")
	to_chat(C, "<span class='danger'>You feel horrible pain as something large is forcefully implanted in your thorax.</span>")
	C.apply_damage(100, HALLOSS)
	C.apply_damage(10, BRUTE, "chest")
	C.emote("scream")
	GLOB.round_statistics.defiler_defiler_stings++
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
			var/datum/effect_system/smoke_spread/xeno/neuro/NS = new(X)
			NS.set_up(1, get_turf(src))
			NS.start()
			to_chat(X, "<span class='xenodanger'>We abort emitting neurogas, our expended plasma resulting in only a feeble wisp.</span>")
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
		if(X.stunned || X.knocked_down)
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
