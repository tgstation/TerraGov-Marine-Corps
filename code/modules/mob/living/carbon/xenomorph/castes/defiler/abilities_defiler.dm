// ***************************************
// *********** Neuroclaws
// ***************************************
/datum/action/xeno_action/neuroclaws
	name = "Toggle Neuroinjectors"
	action_icon_state = "neuroclaws_off"
	mechanics_text = "Toggle on to add neurotoxin to your melee slashes."
	cooldown_timer = DEFILER_CLAWS_COOLDOWN

/datum/action/xeno_action/neuroclaws/action_activate()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner

	add_cooldown()
	X.neuro_claws = !X.neuro_claws
	to_chat(X, "<span class='notice'>You [X.neuro_claws ? "extend" : "retract"] your claws' neuro spines.</span>")

	if(X.neuro_claws)
		playsound(X, 'sound/weapons/slash.ogg', 15, 1)
	else
		playsound(X, 'sound/weapons/slashmiss.ogg', 15, 1)
	update_button_icon()

/datum/action/xeno_action/neuroclaws/update_button_icon()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	button.overlays.Cut()
	if(X.neuro_claws)
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_on")
	else
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_off")
	return ..()

// ***************************************
// *********** Sting
// ***************************************
/datum/action/xeno_action/activable/larval_growth_sting/defiler
	name = "Defile"
	action_icon_state = "defiler_sting"
	mechanics_text = "Channel to inject an adjacent target with larval growth serum. At the end of the channel your target will be infected."
	ability_name = "defiler sting"
	plasma_cost = 150
	cooldown_timer = DEFILER_STING_COOLDOWN

/datum/action/xeno_action/activable/larval_growth_sting/defiler/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, "<span class='xenodanger'>You feel your toxin glands refill, another young one ready for implantation. You can use Defile again.</span>")
	return ..()

/datum/action/xeno_action/activable/larval_growth_sting/defiler/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	var/mob/living/carbon/C = A
	if(locate(/obj/item/alien_embryo) in C) // already got one, stops doubling up
		return ..()
	if(!do_after(X, DEFILER_STING_CHANNEL_TIME, TRUE, 5, BUSY_ICON_HOSTILE))
		return fail_activate()
	if(!can_use_ability(A))
		return fail_activate()
	add_cooldown()
	X.face_atom(C)
	X.animation_attack_on(C)
	playsound(C, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	var/obj/item/alien_embryo/embryo = new(C)
	embryo.hivenumber = X.hivenumber
	round_statistics.now_pregnant++
	to_chat(X, "<span class='xenodanger'>Your stinger successfully implants a larva into the host.</span>")
	to_chat(C, "<span class='danger'>You feel horrible pain as something large is forcefully implanted in your thorax.</span>")
	C.apply_damage(100, HALLOSS)
	C.apply_damage(10, BRUTE, "chest")
	C.emote("scream")
	round_statistics.defiler_defiler_stings++
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
	cooldown_timer = DEFILER_GAS_COOLDOWN

/datum/action/xeno_action/activable/emit_neurogas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(owner, "<span class='xenodanger'>You feel your dorsal vents bristle with neurotoxic gas. You can use Emit Neurogas again.</span>")
	return ..()

/datum/action/xeno_action/activable/emit_neurogas/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner

	//give them fair warning
	X.visible_message("<span class='danger'>Tufts of smoke begin to billow from [X]!</span>", \
	"<span class='xenodanger'>Your dorsal vents widen, preparing to emit neurogas. Keep still!</span>")

	X.emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	succeed_activate()
	X.icon_state = "Defiler Power Up"

	if(!do_after(X, DEFILER_GAS_CHANNEL_TIME, TRUE, 5, BUSY_ICON_HOSTILE))
		X.smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro()
		X.smoke_system.set_up(1, get_turf(src))
		to_chat(X, "<span class='xenodanger'>You abort emitting neurogas, your expended plasma resulting in only a feeble wisp.</span>")
		X.emitting_gas = FALSE
		X.icon_state = "Defiler Running"
		return fail_activate()
	X.emitting_gas = FALSE
	X.icon_state = "Defiler Running"

	add_cooldown()

	if(X.stagger) //If we got staggered, return
		to_chat(X, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return fail_activate()

	round_statistics.defiler_neurogas_uses++

	X.visible_message("<span class='xenodanger'>[X] emits a noxious gas!</span>", \
	"<span class='xenodanger'>You emit neurogas!</span>")
	dispense_gas()

/datum/action/xeno_action/activable/emit_neurogas/proc/dispense_gas(count = 3)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	set waitfor = FALSE
	while(count)
		if(X.stagger) //If we got staggered, return
			to_chat(X, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
			return
		if(X.stunned || X.knocked_down)
			to_chat(X, "<span class='xenowarning'>You try to emit neurogas but are disabled!</span>")
			return
		var/turf/T = get_turf(X)
		playsound(T, 'sound/effects/smoke.ogg', 25)
		X.smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro()
		if(count > 1)
			X.smoke_system.set_up(2, T)
		else //last emission is larger
			X.smoke_system.set_up(3, T)
		X.smoke_system.start()
		T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")
		count = max(0,count - 1)
		sleep(DEFILER_GAS_DELAY)
