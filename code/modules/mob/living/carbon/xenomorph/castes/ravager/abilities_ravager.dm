// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 7 tiles and viciously attack your target."
	ability_name = "charge"
	cooldown_timer = 30 SECONDS
	plasma_cost = 80
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

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

	X.visible_message("<span class='danger'>[X] charges towards \the [A]!</span>", \
	"<span class='danger'>We charge towards \the [A]!</span>" )
	X.emote("roar") //heheh
	X.usedPounce = TRUE //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	X.throw_at(A, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, X)

	add_cooldown()

// ***************************************
// *********** Ravage
// ***************************************
/datum/action/xeno_action/activable/ravage
	name = "Ravage"
	action_icon_state = "ravage"
	mechanics_text = "Release all of your rage in a vicious melee attack against a single target. The more rage you have, the more damage is done."
	ability_name = "ravage"
	plasma_cost = 40
	var/last_victim_count = 0
	cooldown_timer = 10 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGE

/datum/action/xeno_action/activable/ravage/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to Ravage again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/ravage/get_cooldown()
	return CLAMP(cooldown_timer - (last_victim_count * 30),10,100) //10 second cooldown base, minus 3 seconds per victim

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	GLOB.round_statistics.ravager_ravages++
	X.visible_message("<span class='danger'>\The [X] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>We thrash about in a murderous frenzy!</span>")

	X.face_atom(A)
	var/sweep_range = 1
	var/list/L = orange(sweep_range, X)		// Not actually the fruit
	var/victims = 0
	var/target_facing
	for (var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(X, H)
		if(target_facing != X.dir && target_facing != turn(X.dir,45) && target_facing != turn(X.dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !isnestedhost(H) ) //No bully
			var/extra_dam = rand(X.xeno_caste.melee_damage_lower, X.xeno_caste.melee_damage_upper) * round(RAV_RAVAGE_DAMAGE_MULITPLIER + X.rage * RAV_RAVAGE_RAGE_MULITPLIER, 0.01)
			H.attack_alien(X, extra_dam, FALSE, TRUE, FALSE, TRUE, INTENT_HARM)
			victims++
			GLOB.round_statistics.ravager_ravage_victims++
			step_away(H, X, sweep_range, 2)
			shake_camera(H, 2, 1)
			H.KnockDown(1, 1)

	victims = CLAMP(victims,0,3) //Just to be sure
	X.rage = (0 + 10 * victims) //rage resets to 0, though we regain 10 rage per victim.

	succeed_activate()
	last_victim_count = victims
	add_cooldown()
	X.reset_movement()

// ***************************************
// *********** Second wind
// ***************************************
/datum/action/xeno_action/second_wind
	name = "Second Wind"
	action_icon_state = "second_wind"
	mechanics_text = "A channeled ability to restore health that uses plasma and rage. Must stand still for it to work."
	cooldown_timer = 240 SECONDS
	var/last_rage = 0
	keybind_signal = COMSIG_XENOABILITY_SECOND_WIND

/datum/action/xeno_action/second_wind/get_cooldown()
	return cooldown_timer * round((1 - (last_rage * 0.015) ),0.01)

/datum/action/xeno_action/second_wind/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to use Second Wind again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/second_wind/action_activate(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	to_chat(X, "<span class='xenodanger'>Our coursing adrenaline stimulates tissues into a spat of rapid regeneration...</span>")
	var/current_rage = CLAMP(X.rage,0,RAVAGER_MAX_RAGE) //lock in the value at the time we use it; min 0, max 50.
	X.do_jitter_animation(1000)
	if(!do_after(X, 50, FALSE))
		return fail_activate()
	X.do_jitter_animation(1000)
	playsound(X, "sound/effects/alien_drool2.ogg", 50, 0)
	to_chat(X, "<span class='xenodanger'>We recoup our health, our tapped rage restoring our body, flesh and chitin reknitting themselves...</span>")
	X.adjustFireLoss(-CLAMP( (X.getFireLoss()) * (0.25 + current_rage * 0.015), 0, X.getFireLoss()) )//Restore HP equal to 25% + 1.5% of the difference between min and max health per rage
	X.adjustBruteLoss(-CLAMP( (X.getBruteLoss()) * (0.25 + current_rage * 0.015), 0, X.getBruteLoss()) )//Restore HP equal to 25% + 1.5% of the difference between min and max health per rage
	X.plasma_stored += CLAMP( (X.xeno_caste.plasma_max - X.plasma_stored) * (0.25 + current_rage * 0.015), 0, X.xeno_caste.plasma_max - X.plasma_stored) //Restore Plasma equal to 25% + 1.5% of the difference between min and max health per rage
	X.updatehealth()
	X.hud_set_plasma()

	GLOB.round_statistics.ravager_second_winds++

	last_rage = current_rage
	add_cooldown()

	X.rage = 0
