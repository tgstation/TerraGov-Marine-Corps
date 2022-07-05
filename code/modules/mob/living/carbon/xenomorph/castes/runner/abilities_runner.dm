// ***************************************
// *********** Savage
// ***************************************
/datum/action/xeno_action/toggle_savage
	name = "Toggle Savage"
	action_icon_state = "savage_on"
	mechanics_text = "Toggle on to add a vicious attack to your pounce."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_SAVAGE
	use_state_flags = XACT_USE_LYING|XACT_USE_BUCKLED

/datum/action/xeno_action/toggle_savage/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	if(!X.check_state())
		return

	if(X.savage)
		X.savage = FALSE
		X.balloon_alert(X, "No longer savaging")
	else
		X.savage = TRUE
		X.balloon_alert(X, "Will savage on pounce")
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
		to_chat(src, span_xenowarning("We're too tired to savage right now."))
		return

	if(stagger)
		to_chat(src, span_xenodanger("We're too disoriented from the shock to savage!"))
		return

	playsound(src, "alien_roar[rand(1,6)]", 50)
	use_plasma(10) //Base cost of the Savage
	visible_message(span_danger("\ [src] savages [M]!"), \
	span_xenodanger("We savage [M]!"), null, 5)
	var/extra_dam = max(15, plasma_stored * 0.15)
	GLOB.round_statistics.runner_savage_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_savage_attacks")
	M.attack_alien_harm(src, extra_dam, FALSE, TRUE, TRUE, TRUE) //Inflict a free attack on pounce that deals +1 extra damage per 4 plasma stored, up to 35 or twice the max damage of an Ancient Runner attack.
	use_plasma(extra_dam * 2)
	savage_used = TRUE
	addtimer(CALLBACK(src, .proc/savage_cooldown), xeno_caste.savage_cooldown)

	return TRUE

/mob/living/carbon/xenomorph/proc/savage_cooldown()
	if(!savage_used)//sanity check/safeguard
		return
	savage_used = FALSE
	to_chat(src, span_xenowarning("<b>We can now savage our victims again.</b>"))
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
	use_state_flags = XACT_USE_BUCKLED
	///How far can we pounce.
	var/range = 6
	///For how long will we stun the victim
	var/victim_paralyze_time = 2 SECONDS
	///For how long will we freeze upon hitting our target
	var/freeze_on_hit_time = 0.5 SECONDS

// TODO: merge defender/ravager pounces into this typepath since they are essentially the same thing
/datum/action/xeno_action/activable/pounce/proc/pounce_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE_END)

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

	X.visible_message(span_danger("[X] pounces on [M]!"),
					span_xenodanger("We pounce on [M]!"), null, 5)

	if(victim_paralyze_time)
		M.Paralyze(victim_paralyze_time)

	X.forceMove(get_turf(M))
	if(freeze_on_hit_time)
		X.Immobilize(freeze_on_hit_time)
	if(X.savage) //If Runner Savage is toggled on, attempt to use it.
		if(!X.savage_used)
			if(X.plasma_stored >= 10)
				INVOKE_ASYNC(X, /mob/living/carbon/xenomorph/.proc/Savage, M)
			else
				X.balloon_alert(X, "Cannot savage, no plasma")
				to_chat(X, span_xenodanger("We attempt to savage our victim but we need at least [10-X.plasma_stored] more plasma."))
		else
			X.balloon_alert(X, "Cannot savage, not ready")

	playsound(X.loc, 'sound/voice/alien_pounce.ogg', 25, TRUE)

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
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)

/datum/action/xeno_action/activable/pounce/get_cooldown()
	var/mob/living/carbon/xenomorph/X = owner
	return X.xeno_caste.pounce_delay

/datum/action/xeno_action/activable/pounce/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We're ready to pounce again."))
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	var/mob/living/carbon/xenomorph/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/pounce/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, .proc/pounce_complete)

	prepare_to_pounce()

	X.visible_message(span_xenowarning("\The [X] pounces at [A]!"), \
	span_xenowarning("We pounce at [A]!"))

	SEND_SIGNAL(X, COMSIG_XENOMORPH_POUNCE)

	succeed_activate()
	add_cooldown()
	X.usedPounce = TRUE // this is needed for throwing code
	X.flags_pass = PASSTABLE|PASSFIRE
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

/datum/action/xeno_action/activable/pounce/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 6))
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Evasion
// ***************************************
/datum/action/xeno_action/evasion
	name = "Evasion"
	action_icon_state = "evasion"
	mechanics_text = "Take evasive action, forcing non-friendly projectiles that would hit you to miss for a short duration so long as you keep moving."
	plasma_cost = 75
	cooldown_timer = 10 SECONDS
	keybind_signal = COMSIG_XENOABILITY_EVASION
	///Whether evasion is currently active
	var/evade_active = FALSE
	///Number of successful cooldown clears in a row
	var/evasion_streak = 0
	///How much damage we need to dodge to trigger Evasion's cooldown reset
	var/evasion_stack_target = RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD
	///Whether we clear the streaks; if we scored a streak, we set this to false. Set back to true upon cooldown completion.
	var/clear_streaks = TRUE
	///Number of evasion stacks we've accumulated
	var/evasion_stacks = 0

/datum/action/xeno_action/evasion/can_use_action(silent = FALSE, override_flags)
	. = ..()

	if(evade_active) //Can't evade while we're already evading.
		if(!silent)
			owner.balloon_alert(owner, "Already evading")
		return FALSE

/datum/action/xeno_action/evasion/action_activate()
	var/mob/living/carbon/xenomorph/runner/R = owner

	R.balloon_alert(R, "Begin evasion: [RUNNER_EVASION_DURATION * 0.1] sec.")
	to_chat(R, span_highdanger("We take evasive action, making us impossible to hit with projectiles for the next [RUNNER_EVASION_DURATION * 0.1] seconds."))

	addtimer(CALLBACK(src, .proc/evasion_deactivate), RUNNER_EVASION_DURATION)

	RegisterSignal(R, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER), .proc/evasion_debuff_check)

	RegisterSignal(R, COMSIG_XENO_PROJECTILE_HIT, .proc/evasion_dodge) //This is where we actually check to see if we dodge the projectile.
	RegisterSignal(R, COMSIG_XENOMORPH_FIRE_BURNING, .proc/evasion_burn_check) //Register status effects and fire which impact evasion.
	RegisterSignal(R, COMSIG_ATOM_BULLET_ACT, .proc/evasion_flamer_hit) //Register status effects and fire which impact evasion.
	RegisterSignal(R, COMSIG_LIVING_PRE_THROW_IMPACT, .proc/evasion_throw_dodge) //Register status effects and fire which impact evasion.

	evade_active = TRUE //evasion is currently active

	GLOB.round_statistics.runner_evasions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_evasions") //Statistics

	succeed_activate()
	add_cooldown()

///Called when the owner is hit by a flamethrower projectile; reduces evasion stacks proportionate to damage
/datum/action/xeno_action/evasion/proc/evasion_flamer_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER

	if(!(proj.ammo.flags_ammo_behavior & AMMO_FLAME)) //If it's not from a flamethrower, we don't care
		return

	evasion_stacks = max(0, evasion_stacks - proj.damage) //We lose evasion stacks equal to the burn damage
	if(evasion_stacks)
		owner.balloon_alert(owner, "Evasion reduced, damaged")
		to_chat(owner, span_danger("The searing fire compromises our ability to dodge![RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks > 0 ? " We must dodge [RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD - evasion_stacks] more projectile damage before Evasion's cooldown refreshes." : ""]"))
	else //If all of our evasion stacks have burnt away, cancel out
		evasion_deactivate()

///Called when the owner is burning; reduces evasion stacks proportionate to fire stacks
/datum/action/xeno_action/evasion/proc/evasion_burn_check()
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/runner/R = owner
	evasion_stacks = 0 //We lose all evasion stacks
	to_chat(R, span_danger("Being on fire compromises our ability to dodge! We have lost all evasion stacks!"))

///After getting hit with an Evasion disabling debuff, this is where we check to see if evasion is active, and if we actually have debuff stacks
/datum/action/xeno_action/evasion/proc/evasion_debuff_check(datum/source, amount)
	SIGNAL_HANDLER
	if(!(amount > 0) || !evade_active) //If evasion isn't active, or we're not actually receiving debuff stacks, we don't care
		return
	to_chat(owner, span_highdanger("Our movements have been interrupted!"))
	clear_streaks = FALSE //We definitely ain't streaking
	evasion_deactivate()


///Where we deactivate evasion and unregister the signals/zero out vars, etc.
/datum/action/xeno_action/evasion/proc/evasion_deactivate()

	UnregisterSignal(owner, list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_XENO_PROJECTILE_HIT,
		COMSIG_XENOMORPH_FIRE_BURNING,
		COMSIG_LIVING_PRE_THROW_IMPACT,
		COMSIG_ATOM_BULLET_ACT
		))

	evade_active = FALSE //Evasion is no longer active

	evasion_stacks = 0
	owner.balloon_alert(owner, "Evasion ended")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 50)


/datum/action/xeno_action/evasion/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to take evasive action again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

	if(clear_streaks) //Clear streaks if we haven't earned a streak
		evasion_streak = 0
	else //Otherwise prime us to clear streaks on the next cooldown finish
		clear_streaks = TRUE

	return ..()

///Determines whether or not a thrown projectile is dodged while the Evasion ability is active
/datum/action/xeno_action/evasion/proc/evasion_throw_dodge(datum/source, atom/movable/proj)
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/X = owner
	if(!evade_active) //If evasion is not active we don't dodge
		return NONE

	if((X.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return NONE

	if(isitem(proj))
		var/obj/item/I = proj
		evasion_stacks += I.throwforce //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes equal to the thrown force

	evasion_dodge_sfx(proj)

	return COMPONENT_PRE_THROW_IMPACT_HIT

///This is where the dodgy magic happens
/datum/action/xeno_action/evasion/proc/evasion_dodge(datum/source, obj/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/runner/R = owner
	if(!evade_active) //If evasion is not active we don't dodge
		return FALSE

	if((R.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return FALSE

	if(R.issamexenohive(proj.firer)) //We automatically dodge allied projectiles at no cost, and no benefit to our evasion stacks
		return COMPONENT_PROJECTILE_DODGE

	if(proj.ammo.flags_ammo_behavior & AMMO_FLAME) //We can't dodge literal fire
		return FALSE

	if(!(proj.ammo.flags_ammo_behavior & AMMO_SENTRY) && !R.fire_stacks) //We ignore projectiles from automated sources/sentries for the purpose of contributions towards our cooldown refresh; also fire prevents accumulation of evasion stacks
		evasion_stacks += proj.damage //Add to evasion stacks for the purposes of determining whether or not our cooldown refreshes

	evasion_dodge_sfx(proj)

	return COMPONENT_PROJECTILE_DODGE

///Handles dodge effects and visuals for the Evasion ability.
/datum/action/xeno_action/evasion/proc/evasion_dodge_sfx(atom/movable/proj)
	evasion_stack_target = RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD * (1 + evasion_streak)

	var/mob/living/carbon/xenomorph/X = owner

	X.visible_message(span_warning("[X] effortlessly dodges the [proj.name]!"), \
	span_xenodanger("We effortlessly dodge the [proj.name]![(evasion_stack_target - evasion_stacks) > 0 && evasion_stacks > 0 ? " We must dodge [evasion_stack_target - evasion_stacks] more projectile damage before [src]'s cooldown refreshes." : ""]"))

	X.add_filter("runner_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(X, /atom.proc/remove_filter, "runner_evasion"), 0.5 SECONDS)
	X.do_jitter_animation(4000)

	if(evasion_stacks >= evasion_stack_target && cooldown_remaining()) //We have more evasion stacks than needed to refresh our cooldown, while being on cooldown.
		X.balloon_alert(X, "Evasion refreshed")
		clear_streaks = FALSE //We just scored a streak so we're not clearing our streaks on cooldown finish
		evasion_streak++ //Increment our streak count
		clear_cooldown() //Clear our cooldown
		if(evasion_streak > 3) //Easter egg shoutout
			X.balloon_alert(X, "Damn we're good.")

	var/turf/T = get_turf(X) //location of after image SFX
	playsound(T, pick('sound/effects/throw.ogg','sound/effects/alien_tail_swipe1.ogg', 'sound/effects/alien_tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/xenomorph/afterimage/A
	for(var/i=0 to 2) //number of after images
		A = new /obj/effect/temp_visual/xenomorph/afterimage(T, owner) //Create the after image.
		A.pixel_x = pick(rand(X.pixel_x * 3, X.pixel_x * 1.5), rand(0, X.pixel_x * -1)) //Variation on the X position

/datum/action/xeno_action/activable/snatch
	name = "Snatch"
	action_icon_state = "snatch"
	mechanics_text = "Take an item equipped by your target in your mouth, and carry it away."
	plasma_cost = 75
	cooldown_timer = 60 SECONDS
	keybind_signal = COMSIG_XENOABILITY_SNATCH
	target_flags = XABB_MOB_TARGET
	///If the runner have an item
	var/obj/item/stolen_item = FALSE
	///Mutable appearance of the stolen item
	var/mutable_appearance/stolen_appearance
	///A list of slot to check for items, in order of priority
	var/static/list/slots_to_steal_from = list(
		SLOT_S_STORE,
		SLOT_BACK,
		SLOT_SHOES,
	)

/datum/action/xeno_action/activable/snatch/action_activate()
	if(!stolen_item)
		return ..()
	drop_item()

/datum/action/xeno_action/activable/snatch/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!owner.Adjacent(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot reach")
		return FALSE
	if(!ishuman(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE
	var/mob/living/carbon/human/target = A
	if(target.stat == DEAD)
		if(!silent)
			owner.balloon_alert(owner, "Cannot snatch")
		return FALSE

/datum/action/xeno_action/activable/snatch/use_ability(atom/A)
	succeed_activate()
	var/mob/living/carbon/xenomorph/X = A
	if(!do_after(owner, 0.5 SECONDS, FALSE, A, BUSY_ICON_DANGER, extra_checks = CALLBACK(owner, /mob.proc/break_do_after_checks, list("health" = X.health))))
		return FALSE
	var/mob/living/carbon/human/victim = A
	stolen_item = victim.get_active_held_item()
	if(!stolen_item)
		stolen_item = victim.get_inactive_held_item()
		for(var/slot in slots_to_steal_from)
			stolen_item = victim.get_item_by_slot(slot)
			if(stolen_item)
				break
	if(!stolen_item)
		victim.balloon_alert(owner, "Snatch failed, no item")
		return fail_activate()
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30)
	victim.dropItemToGround(stolen_item, TRUE)
	stolen_item.forceMove(owner)
	stolen_appearance = mutable_appearance(stolen_item.icon, stolen_item.icon_state)
	stolen_appearance.layer = ABOVE_OBJ_LAYER
	addtimer(CALLBACK(src, .proc/drop_item, stolen_item), 3 SECONDS)
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, .proc/owner_turned)
	owner.add_movespeed_modifier(MOVESPEED_ID_SNATCH, TRUE, 0, NONE, TRUE, 2)
	owner_turned(null, null, owner.dir)
	add_cooldown()

///Signal handler to update the item overlay when the owner is changing dir
/datum/action/xeno_action/activable/snatch/proc/owner_turned(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!new_dir || new_dir == old_dir)
		return
	owner.overlays -= stolen_appearance
	var/matrix/new_transform  = stolen_appearance.transform
	switch(old_dir)
		if(NORTH)
			new_transform.Translate(-15, -12)
		if(SOUTH)
			new_transform.Translate(-15, 12)
		if(EAST)
			new_transform.Translate(-35, 0)
		if(WEST)
			new_transform.Translate(5, 0)
	switch(new_dir)
		if(NORTH)
			new_transform.Translate(15, 12)
		if(SOUTH)
			new_transform.Translate(15, -12)
		if(EAST)
			new_transform.Translate(35, 0)
		if(WEST)
			new_transform.Translate(-5, 0)
	stolen_appearance.transform = new_transform
	owner.overlays += stolen_appearance

///Force the xeno owner to drop the stolen item
/datum/action/xeno_action/activable/snatch/proc/drop_item()
	if(!stolen_item)
		return
	owner.remove_movespeed_modifier(MOVESPEED_ID_SNATCH)
	stolen_item.forceMove(get_turf(owner))
	stolen_item = null
	owner.overlays -= stolen_appearance
	playsound(owner, 'sound/voice/alien_pounce2.ogg', 30, frequency = -1)
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)

