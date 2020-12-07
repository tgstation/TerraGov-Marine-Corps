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
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_NONE_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/pounce/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	if(!istype(target, /obj/structure/table) && !istype(target, /obj/structure/rack))
		target.hitby(X, speed) //This resets throwing.
	pounce_complete()

/datum/action/xeno_action/activable/pounce/proc/mob_hit(datum/source, mob/living/M)
	SIGNAL_HANDLER
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
				INVOKE_ASYNC(X, /mob/living/carbon/xenomorph/.proc/Savage, M)
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

// ***************************************
// *********** Evasion
// ***************************************
/datum/action/xeno_action/evasion
	name = "Evasion"
	action_icon_state = "evasion"
	mechanics_text = "Take evasive action, forcing non-friendly projectiles that would hit you to miss so long as you keep moving."
	plasma_cost = 20
	cooldown_timer = 30 SECONDS
	keybind_signal = COMSIG_XENOABILITY_EVASION


/datum/action/xeno_action/evasion/action_activate()
	var/mob/living/carbon/xenomorph/runner/R = owner

	R.do_jitter_animation(1000)
	R.visible_message("<span class='warning'>[R.name] begins to move erratically!</span>", \
	"<span class='xenodanger'>We move erratically, making us impossible to hit with projectiles; the next [RUNNER_EVASION_STACKS] projectile damage that would hit us will now miss.</span>")

	addtimer(CALLBACK(src, .proc/evasion_warning), RUNNER_EVASION_DURATION * RUNNER_EVASION_DURATION_WARNING) //Warn the runner when the duration is about to expire.
	addtimer(CALLBACK(src, .proc/evasion_deactivate), RUNNER_EVASION_DURATION)

	R.evasion_stacks = RUNNER_EVASION_STACKS

	succeed_activate()

	GLOB.round_statistics.runner_evasions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_evasions") //Statistics
	add_cooldown()


/datum/action/xeno_action/evasion/proc/evasion_deactivate()

	var/mob/living/carbon/xenomorph/runner/R = owner
	if(R.evasion_stacks) //If our evasion stacks are already depleted, don't tell us again.
		R.evasion_stacks = 0
		R.visible_message("<span class='warning'>[R.name] stops moving erratically.</span>", \
		"<span class='highdanger'>We stop moving erratically; projectiles will hit us normally again!</span>")

	R.playsound_local(R, 'sound/voice/hiss5.ogg', 50)


/datum/action/xeno_action/evasion/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We are able to take evasive action again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/evasion/proc/evasion_warning()
	var/mob/living/carbon/xenomorph/runner/R = owner

	if(!R.evasion_stacks) //Check to see if we actually have any evasion stacks remaining.
		return

	to_chat(owner,"<span class='highdanger'>We begin to slow down as we tire. We can only keep this up for [RUNNER_EVASION_DURATION * (1-RUNNER_EVASION_DURATION_WARNING) * 0.1] more seconds!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)


///This is where the dodgy magic happens
/mob/living/carbon/xenomorph/runner/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)

	if(!evasion_stacks || (last_move_time  < (world.time - RUNNER_EVASION_RUN_DELAY) ) ) //Gotta keep moving to benefit from evasion!
		return ..()

	if(issamexenohive(proj.firer)) //We automatically dodge allied projectiles at no cost
		return FALSE

	evasion_stacks = max(0, evasion_stacks - proj.damage)

	visible_message("<span class='warning'>[name] effortlessly dodges the [proj.name]!</span>", \
	"<span class='xenodanger'>We effortlessly dodge the [proj.name]![evasion_stacks > 0 ? " We can dodge [evasion_stacks] more projectile damage." : ""]</span>")

	var/turf/T = get_turf(src) //after image SFX
	playsound(T, pick('sound/effects/throw.ogg','sound/effects/alien_tail_swipe1.ogg', 'sound/effects/alien_tail_swipe2.ogg'), 25, 1) //sound effects

	add_filter("runner_evasion", 2, list("type" = "blur", 5)) //Cool SFX
	addtimer(CALLBACK(src, /atom.proc/remove_filter, "runner_evasion"), 0.5 SECONDS)
	do_jitter_animation(1000) //Dodgy animation!

	var/i = 0
	var/obj/effect/temp_visual/xenomorph/runner_afterimage/A
	while(i < 2) //number after images
		A = new(T) //Create the after image.
		A.pixel_x = pick(rand(src.pixel_x * 3, src.pixel_x * 1.5), rand(0, src.pixel_x * -1)) //Variation on the X position
		A.pixel_y = pick(rand(src.pixel_y * 3, src.pixel_y * 1.5), rand(0, src.pixel_y * -1)) //Variation on the Y position
		A.dir = src.dir //match the direction of the runner
		i++

	if(evasion_stacks > RUNNER_EVASION_DANGER_RATIO * RUNNER_EVASION_STACKS) //We have more evasion stacks than needed to trigger alerts.
		return FALSE

	to_chat(src, "<span class='highdanger'>We [evasion_stacks > 0 ? "can dodge only [evasion_stacks] more projectile damage!" : "can't dodge any more projectile damage!"] </span>")
	if(!evasion_stacks) //Audio warning
		playsound_local(src, 'sound/voice/hiss5.ogg', 50)

	return FALSE
