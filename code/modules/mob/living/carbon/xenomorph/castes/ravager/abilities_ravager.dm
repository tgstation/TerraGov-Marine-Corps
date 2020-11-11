// ***************************************
// *********** Drain blood
// ***************************************
/datum/action/xeno_action/activable/sample
	name = "Sample"
	action_icon_state = "sample"
	mechanics_text = "Hold a marine for 1s while draining 2% of their blood."
	ability_name = "sample"
	cooldown_timer = 2 SECONDS
	plasma_cost = 200

/datum/action/xeno_action/activable/sample/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!.)
		return
	if(!A.can_sting())
		to_chat(owner, "<span class='warning'>This won't do!</span>")
		return FALSE
	if(X.blood_bank >= 100)
		to_chat(owner, "<span class='warning'>Somehow we feel sated for now...</span>")
		return FALSE
	if(get_dist(owner, A) > 1)
		to_chat(owner, "<span class='warning'>It is outside of our reach! We need to be</span>")
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/sample/use_ability(mob/living/carbon/A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(A)
	X.emote("roar")
	X.visible_message(A, "<span class='danger'>The [X] grabs [A]!</span>")
	X.start_pulling(A)
	A.setGrabState(GRAB_NECK)
	A.drop_all_held_items()
	if(!do_after(X, 1 SECONDS, TRUE, A, BUSY_ICON_HOSTILE, ignore_turf_checks = FALSE))
		A.drop_all_held_items()
		X.stop_pulling(A)
		return
	A.emote("scream")
	A.apply_damage(damage = 20, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	X.visible_message(A, "<span class='danger'>The [X] bites into [A]!</span>")
	playsound(A, "alien_claw_flesh", 25, TRUE)
	A.blood_volume -= 10
	X.blood_bank += 10
	to_chat(X, "<span class='notice'>Blood bank: [X.blood_bank]%</span>")
	X.stop_pulling(A)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Rejuvenate/Transfusion
// ***************************************
/datum/action/xeno_action/activable/rejuvenate
	name = "Rejuvenate/Transfusion"
	action_icon_state = "Rejuvenate"
	mechanics_text = "When activated on self after 20s of not taking damage drains 10 blood and restores 40% health/plasma over 5s. When activated on another xenomorph - restores 30% of their health after 2s. When activated on a dead human you grab them and heal by draining their blood"
	ability_name = "rejuvenate"
	cooldown_timer = 2 SECONDS
	plasma_cost = 0
	use_state_flags = XACT_TARGET_SELF
	COOLDOWN_DECLARE(rejuvenate_self_cooldown)

/datum/action/xeno_action/activable/rejuvenate/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!.)
		return
	if(ishuman(target))
		if(isdead(target))
			to_chat(X, "<span class='notice'>We can only use still, dead hosts to heal.</span>")
			return FALSE
		else if(get_dist(X, target) > 1)
			to_chat(X, "<span class='notice'>We need to be next to our meal.</span>")
			return FALSE
		return TRUE
	if(isxeno(target))
		if(get_dist(X, target) == -1)
			if(!COOLDOWN_CHECK(src, rejuvenate_self_cooldown))
				to_chat(X, "<span class='notice'>We need to rest another [COOLDOWN_TIMELEFT(src, rejuvenate_self_cooldown)] seconds before we can revitalize ourselves.</span>")
				return FALSE
			if(X.blood_bank < 10)
				to_chat(X, "<span class='notice'>We need [10 - X.blood_bank]u more blood to revitalize ourselves.</span>")
				return FALSE
		else
			if(!X.line_of_sight(target) || get_dist(X, target) > 2)
				to_chat(X, "<span class='notice'>Beyond our reach, we must be close and our way clear.</span>")
				return FALSE
			if(X.blood_bank < 5)
				to_chat(X, "<span class='notice'>We need [5 - X.blood_bank]u more blood to restore a sister.</span>")
				return FALSE
			if(isdead(target))
				to_chat(X, "<span class='notice'>We can only help living sisters.</span>")
				return FALSE
		return TRUE
	to_chat(X, "<span class='notice'>We can only drain or restore familiar biological lifeforms.</span>")
	return FALSE

/datum/action/xeno_action/activable/rejuvenate/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(isxeno(A) && get_dist(X, A) == -1)
		var/mob/living/carbon/xenomorph/target = A
		X.blood_bank -= 10
		to_chat(X, "<span class='notice'>Blood bank: [X.blood_bank]%</span>")
		to_chat(X, "<span class='notice'>We tap into our reserves for nourishment.</span>")
		for(var/i in 1 to 5)
			X.adjustBruteLoss(-X.maxHealth*0.1)
			X.adjustFireLoss(-X.maxHealth*0.1)
			target.gain_plasma(X.xeno_caste.plasma_max*0.1)
			new /obj/effect/temp_visual/telekinesis(get_turf(X))
			do_after(X, 1 SECONDS, FALSE, null, , ignore_turf_checks = TRUE)
		COOLDOWN_START(src, rejuvenate_self_cooldown, 20 SECONDS)
	else if(ishuman(A))
		var/mob/living/carbon/human/target = A
		while(X.health < X.maxHealth && do_after(X, 2 SECONDS, TRUE, A, BUSY_ICON_HOSTILE, ignore_turf_checks = FALSE))
			X.adjustBruteLoss(-X.maxHealth*0.08)
			X.adjustFireLoss(-X.maxHealth*0.08)
			X.adjust_sunder(-1.5)
			target.blood_volume -= 2
	else
		var/mob/living/carbon/xenomorph/target = A
		if(!do_mob(X, A, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			return
		if(!X.line_of_sight(target) || get_dist(X, target) > 2)
			to_chat(X, "<span class='notice'>Beyond our reach, we must be close and our way clear.</span>")
			return
		target.adjustBruteLoss(-X.maxHealth*0.3)
		target.adjustFireLoss(-X.maxHealth*0.3)
		X.blood_bank -= 5
		to_chat(X, "<span class='notice'>Blood bank: [X.blood_bank]%</span>")
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Carnage
// ***************************************
/datum/action/xeno_action/carnage
	name = "Carnage"
	action_icon_state = "Carnage"
	mechanics_text = ""
	ability_name = "carnage"
	cooldown_timer = 40 SECONDS
	plasma_cost = 0
	COOLDOWN_DECLARE(carnage_duration)

/datum/action/xeno_action/carnage/action_activate()
	COOLDOWN_START(src, carnage_duration, 20 SECONDS)
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/carnage/proc/carnage_slash(datum/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(COOLDOWN_CHECK(src, carnage_duration))
		UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)
		return
	X.blood_bank += 5
	to_chat(X, "<span class='notice'>Blood bank: [X.blood_bank]%</span>")
	for(var/mob/living/carbon/xenomorph/H in range(4, owner))
		H.emote("roar")
		H.adjustBruteLoss(-damage*0.4)
		H.adjustFireLoss(-damage*0.4)

// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 4 tiles and viciously attack your target."
	ability_name = "charge"
	cooldown_timer = 10 SECONDS //Balanced by the inability to use either ability more than twice in a row without needing a lengthy plasma charge
	plasma_cost = 300
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

/datum/action/xeno_action/activable/charge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_NONE_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/charge/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack))
		var/obj/structure/S = target
		X.visible_message("<span class='danger'>[X] plows straight through [S]!</span>", null, null, 5)
		S.deconstruct(FALSE) //We want to continue moving, so we do not reset throwing.
		return //stay registered
	else
		target.hitby(X, speed) //This resets throwing.
	charge_complete()

/datum/action/xeno_action/activable/charge/proc/mob_hit(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	return COMPONENT_KEEP_THROWING //Ravagers plow straight through humans; we only stop on hitting a dense turf

/datum/action/xeno_action/activable/charge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/xeno_action/activable/charge/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>Our exoskeleton quivers as we get ready to use Eviscerating Charge again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_XENO_NONE_THROW_HIT, .proc/charge_complete)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)

	X.visible_message("<span class='danger'>[X] charges towards \the [A]!</span>", \
	"<span class='danger'>We charge towards \the [A]!</span>" )
	X.emote("roar") //heheh
	X.usedPounce = TRUE //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	X.throw_at(A, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, X)

	add_cooldown()

/datum/action/xeno_action/activable/charge/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/charge/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 4)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


// ***************************************
// *********** Ravage
// ***************************************
/datum/action/xeno_action/activable/ravage
	name = "Ravage"
	action_icon_state = "ravage"
	mechanics_text = "Attacks and knockbacks enemies in the direction your facing."
	ability_name = "ravage"
	plasma_cost = 250
	cooldown_timer = 6 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGE

/datum/action/xeno_action/activable/ravage/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to Ravage again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message("<span class='danger'>\The [X] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>We thrash about in a murderous frenzy!</span>")

	X.face_atom(A)
	var/sweep_range = 1
	var/list/L = orange(sweep_range, X) // Not actually the fruit
	var/victims = 0
	var/target_facing
	for(var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(X, H)
		if(target_facing != X.dir && target_facing != turn(X.dir,45) && target_facing != turn(X.dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !isnestedhost(H)) //No bully
			H.attack_alien(X, X.xeno_caste.melee_damage * 0.25, FALSE, TRUE, FALSE, TRUE, INTENT_HARM)
			victims++
			step_away(H, X, sweep_range, 2)
			shake_camera(H, 2, 1)
			H.Paralyze(2 SECONDS)

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/activable/ravage/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/ravage/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


// ***************************************
// *********** Ignore pain
// ***************************************
/datum/action/xeno_action/activable/ignore_pain
	name = "Ignore Pain"
	action_icon_state = "ignore_pain"
	mechanics_text = "For the next few moments you will not go into crit, but you still die."
	ability_name = "ignore pain"
	plasma_cost = 50
	cooldown_timer = 2 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_IGNORE_PAIN

/datum/action/xeno_action/activable/ignore_pain/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We feel able to imbue ourselves with plasma to ignore pain once again!</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, FALSE, 1)
	return ..()

/datum/action/xeno_action/activable/ignore_pain/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message("<span class='danger'>\The skin on the [X] begins to glow!</span>", \
	"<span class='xenowarning'>We feel the plasma flowing through our veins!</span>")

	X.ignore_pain = addtimer(VARSET_CALLBACK(X, ignore_pain, FALSE), 10 SECONDS)
	X.ignore_pain_state = 0
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, X, "<span class='xenodanger'>We feel the plasma draining from our veins.</span>"), 7 SECONDS)
	addtimer(CALLBACK(X, /mob/living/.proc/do_jitter_animation, 1000), 7 SECONDS)

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/activable/ignore_pain/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/ignore_pain/ai_should_use(target)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > WORLD_VIEW_NUM) // If we can be seen.
		return ..()
	if(X.health > 50)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE
