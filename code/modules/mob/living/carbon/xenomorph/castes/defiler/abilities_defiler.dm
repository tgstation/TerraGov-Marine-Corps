// ***************************************
// *********** Neuroclaws
// ***************************************
/datum/action/xeno_action/neuroclaws
	name = "Toggle Neuroinjectors"
	action_icon_state = "neuroclaws_off"
	mechanics_text = "Toggle on to add neurotoxin to your melee slashes."

/datum/action/xeno_action/neuroclaws/action_activate()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner

	if(!X.check_state())
		return

	if(world.time < X.last_use_neuroclaws + DEFILER_CLAWS_COOLDOWN)
		return

	X.neuro_claws = !X.neuro_claws
	X.last_use_neuroclaws = world.time
	to_chat(X, "<span class='notice'>You [X.neuro_claws ? "extend" : "retract"] your claws' neuro spines.</span>")
	button.overlays.Cut()
	if(X.neuro_claws)
		playsound(X, 'sound/weapons/slash.ogg', 15, 1)
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_on")
	else
		playsound(X, 'sound/weapons/slashmiss.ogg', 15, 1)
		button.overlays += image('icons/mob/actions.dmi', button, "neuroclaws_off")

/datum/action/xeno_action/emit_neurogas/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	if(world.time >= X.last_use_neuroclaws + DEFILER_CLAWS_COOLDOWN)
		return TRUE

// ***************************************
// *********** Sting
// ***************************************
/datum/action/xeno_action/activable/defiler_sting
	name = "Defile"
	action_icon_state = "defiler_sting"
	mechanics_text = "Channel to inject an adjacent target with larval growth serum. At the end of the channel your target will be infected."
	ability_name = "defiler sting"

/datum/action/xeno_action/activable/defiler_sting/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	X.defiler_sting(A)

/datum/action/xeno_action/activable/defiler_sting/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	if(world.time >= X.last_defiler_sting + DEFILER_STING_COOLDOWN)
		return TRUE

/mob/living/carbon/Xenomorph/Defiler/proc/defiler_sting(mob/living/carbon/C)
	if(!check_state() || !C?.can_sting())
		return

	if(world.time < last_defiler_sting + DEFILER_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='warning'>You are not ready to Defile again. It will be ready in [(last_defiler_sting + DEFILER_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='warning'>You try to sting but are too disoriented!</span>")
		return

	if(!C.can_sting())
		to_chat(src, "<span class='warning'>Your sting won't affect this target!</span>")
		return

	if(!Adjacent(C))
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='warning'>You can't reach this target!</span>")
			recent_notice = world.time //anti-notice spam
		return

	if ((C.status_flags & XENO_HOST) && istype(C.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='warning'>Ashamed, you reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_defiler_sting = world.time
	use_plasma(150)

	round_statistics.defiler_defiler_stings++

	addtimer(CALLBACK(src, .defiler_sting_cooldown), DEFILER_STING_COOLDOWN)

	larva_injection(C)
	larval_growth_sting(C)
	

/mob/living/carbon/Xenomorph/Defiler/proc/defiler_sting_cooldown()
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your toxin glands refill, another young one ready for implantation. You can use Defile again.</span>")
	update_action_button_icons()

// ***************************************
// *********** Neurogas
// ***************************************
/datum/action/xeno_action/activable/emit_neurogas
	name = "Emit Neurogas"
	action_icon_state = "emit_neurogas"
	mechanics_text = "Channel for 3 seconds to emit a cloud of noxious smoke that follows the Defiler. You must remain stationary while channeling; moving will cancel the ability but will still cost plasma."
	ability_name = "emit neurogas"

/datum/action/xeno_action/activable/emit_neurogas/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	if(world.time >= X.last_emit_neurogas + DEFILER_GAS_COOLDOWN)
		return TRUE

/datum/action/xeno_action/activable/emit_neurogas/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Defiler/X = owner
	X.emit_neurogas()

/mob/living/carbon/Xenomorph/Defiler/proc/emit_neurogas()

	if(!check_state())
		return

	if(world.time < last_emit_neurogas + DEFILER_GAS_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenodanger'>You are not ready to emit neurogas again. This ability will be ready in [(last_emit_neurogas + DEFILER_GAS_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return FALSE

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	if(!check_plasma(200))
		return

	//give them fair warning
	visible_message("<span class='danger'>Tufts of smoke begin to billow from [src]!</span>", \
	"<span class='xenodanger'>Your dorsal vents widen, preparing to emit neurogas. Keep still!</span>")

	emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	use_plasma(200)
	icon_state = "Defiler Power Up"

	if(!do_after(src, DEFILER_GAS_CHANNEL_TIME, TRUE, 5, BUSY_ICON_HOSTILE))
		smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()
		smoke_system.amount = 1
		smoke_system.set_up(1, 0, get_turf(src))
		to_chat(src, "<span class='xenodanger'>You abort emitting neurogas, your expended plasma resulting in only a feeble wisp.</span>")
		emitting_gas = FALSE
		icon_state = "Defiler Running"
		return
	emitting_gas = FALSE
	icon_state = "Defiler Running"

	addtimer(CALLBACK(src, .defiler_gas_cooldown), DEFILER_GAS_COOLDOWN)

	last_emit_neurogas = world.time

	if(stagger) //If we got staggered, return
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	round_statistics.defiler_neurogas_uses++

	visible_message("<span class='xenodanger'>[src] emits a noxious gas!</span>", \
	"<span class='xenodanger'>You emit neurogas!</span>")
	dispense_gas()

/mob/living/carbon/Xenomorph/Defiler/proc/defiler_gas_cooldown()
	playsound(loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(src, "<span class='xenodanger'>You feel your dorsal vents bristle with neurotoxic gas. You can use Emit Neurogas again.</span>")
	update_action_button_icons()

/mob/living/carbon/Xenomorph/Defiler/proc/dispense_gas(count = 3)
	set waitfor = FALSE
	while(count)
		if(stagger) //If we got staggered, return
			to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
			return
		if(stunned || knocked_down)
			to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are disabled!</span>")
			return
		playsound(loc, 'sound/effects/smoke.ogg', 25)
		var/turf/T = get_turf(src)
		smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()
		if(count > 1)
			smoke_system.amount = 2
			smoke_system.set_up(2, 0, T)
		else //last emission is larger
			smoke_system.amount = 3
			smoke_system.set_up(3, 0, T)
		smoke_system.start()
		T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")
		count = max(0,count - 1)
		sleep(DEFILER_GAS_DELAY)
