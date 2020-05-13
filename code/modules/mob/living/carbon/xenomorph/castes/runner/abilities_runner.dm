// ***************************************
// *********** Savage
// ***************************************
/datum/action/xeno_action/toggle_savage
	name = "Toggle Savage"
	action_icon_state = "savage_on"
	mechanics_text = "Toggle on to add a vicious attack to your pounce."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_SAVAGE

/datum/action/xeno_action/toggle_savage/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	if(!X.check_state())
		return

	if(X.savage)
		X.savage = FALSE
		to_chat(X, "<span class='xenowarning'>We untense our muscles, and relax. We will no longer savage when pouncing.</span>")
	else
		X.savage = TRUE
		to_chat(X, "We ready ourselves for a killing stroke. We will savage when pouncing.[X.savage_used ? " However, we're not quite yet able to savage again." : ""]")
	update_button_icon()

/datum/action/xeno_action/toggle_savage/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	button.overlays.Cut()
	if(X.savage)
		button.overlays += image('icons/mob/actions.dmi', button, "savage_off")
	else
		button.overlays += image('icons/mob/actions.dmi', button, "savage_on")
	return ..()

/mob/living/carbon/xenomorph/proc/Savage(mob/living/carbon/M)

	if(!check_state())
		return

	if(savage_used)
		to_chat(src, "<span class='xenowarning'>We're too tired to savage right now.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>We can't savage with that thing on our leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenodanger'>We're too disoriented from the shock to savage!</span>")
		return

	var/alien_roar = "alien_roar[rand(1,6)]"
	playsound(src, alien_roar, 50)
	use_plasma(10) //Base cost of the Savage
	src.visible_message("<span class='danger'>\ [src] savages [M]!</span>", \
	"<span class='xenodanger'>We savage [M]!</span>", null, 5)
	var/extra_dam = min(15, plasma_stored * 0.2)
	GLOB.round_statistics.runner_savage_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_savage_attacks")
	M.attack_alien(src,  extra_dam, FALSE, TRUE, TRUE, TRUE) //Inflict a free attack on pounce that deals +1 extra damage per 4 plasma stored, up to 35 or twice the max damage of an Ancient Runner attack.
	use_plasma(extra_dam * 5) //Expend plasma equal to 4 times the extra damage.
	savage_used = TRUE
	addtimer(CALLBACK(src, .proc/savage_cooldown), xeno_caste.savage_cooldown)

	return TRUE

/mob/living/carbon/xenomorph/proc/savage_cooldown()
	if(!savage_used)//sanity check/safeguard
		return
	savage_used = FALSE
	to_chat(src, "<span class='xenowarning'><b>We can now savage our victims again.</b></span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()

// ***************************************
// *********** Pouncey
// ***************************************
/datum/action/xeno_action/activable/pounce
	name = "Pounce"
	action_icon_state = "pounce"
	mechanics_text = "Leap at your target, tackling and disarming them."
	ability_name = "pounce"
	plasma_cost = 10
	keybind_signal = COMSIG_XENOABILITY_POUNCE
	///How far can we pounce.
	var/range = 6
	///For how long will we stun the victim
	var/victim_paralyze_time = 2 SECONDS
	///For how long will we freeze upon hitting our target
	var/freeze_on_hit_time = 0.5 SECONDS

// TODO: merge defender/ravager pounces into this typepath since they are essentially the same thing
/datum/action/xeno_action/activable/pounce/proc/pounce_complete()
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_NONE_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/pounce/proc/obj_hit(datum/source, obj/target, speed)
	var/mob/living/carbon/xenomorph/X = owner
	if(!istype(target, /obj/structure/table) && !istype(target, /obj/structure/rack))
		target.hitby(X, speed) //This resets throwing.
	pounce_complete()

/datum/action/xeno_action/activable/pounce/proc/mob_hit(datum/source, mob/living/M)
	if(M.stat || isxeno(M))
		return
	var/mob/living/carbon/xenomorph/X = owner
	if(ishuman(M) && (M.dir in reverse_nearby_direction(X.dir)))
		var/mob/living/carbon/human/H = M
		if(!H.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			X.Paralyze(6 SECONDS)
			X.set_throwing(FALSE) //Reset throwing manually.
			return COMPONENT_KEEP_THROWING

	X.visible_message("<span class='danger'>[X] pounces on [M]!</span>",
					"<span class='xenodanger'>We pounce on [M]!</span>", null, 5)

	if(victim_paralyze_time)
		M.Paralyze(victim_paralyze_time)

	step_to(X, M)
	if(freeze_on_hit_time)
		X.Immobilize(freeze_on_hit_time)
	if(X.savage) //If Runner Savage is toggled on, attempt to use it.
		if(!X.savage_used)
			if(X.plasma_stored >= 10)
				X.Savage(M)
			else
				to_chat(X, "<span class='xenodanger'>We attempt to savage our victim, but we need [10-X.plasma_stored] more plasma.</span>")
		else
			to_chat(X, "<span class='xenodanger'>We attempt to savage our victim, but we aren't yet ready.</span>")

	playsound(X.loc, prob(95) ? 'sound/voice/alien_pounce.ogg' : 'sound/voice/alien_pounce2.ogg', 25, TRUE)

	pounce_complete()

/datum/action/xeno_action/activable/pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/pounce/proc/prepare_to_pounce()
	if(owner.layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		owner.layer = MOB_LAYER

/datum/action/xeno_action/activable/pounce/get_cooldown()
	var/mob/living/carbon/xenomorph/X = owner
	return X.xeno_caste.pounce_delay

/datum/action/xeno_action/activable/pounce/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We're ready to pounce again.</span>")
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	var/mob/living/carbon/xenomorph/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/pounce/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	
	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(X, COMSIG_XENO_NONE_THROW_HIT, .proc/pounce_complete)

	prepare_to_pounce()

	X.visible_message("<span class='xenowarning'>\The [X] pounces at [A]!</span>", \
	"<span class='xenowarning'>We pounce at [A]!</span>")

	SEND_SIGNAL(X, COMSIG_XENOMORPH_POUNCE)

	succeed_activate()
	add_cooldown()
	X.usedPounce = TRUE // this is needed for throwing code
	X.flags_pass = PASSTABLE
	X.throw_at(A, range, 2, X) //Victim, distance, speed

	addtimer(CALLBACK(X, /mob/living/carbon/xenomorph/.proc/reset_flags_pass), 6)

	return TRUE

/mob/living/carbon/xenomorph/proc/reset_flags_pass()
	if(!xeno_caste.hardcore)
		flags_pass = initial(flags_pass) //Reset the passtable.
	else
		flags_pass = NONE //Reset the passtable.

	//AI stuff
/datum/action/xeno_action/activable/pounce/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/pounce/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 6)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE
