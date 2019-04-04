// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge (80)"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 7 tiles and viciously attack your target."
	ability_name = "charge"

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.charge(A)

/datum/action/xeno_action/activable/charge/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.usedPounce

/mob/living/carbon/Xenomorph/Ravager/proc/charge(atom/T)
	if(!T) return

	if(!check_state())
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before using Eviscerating Charge. It can be used in: [(charge_delay - world.time) * 0.1] seconds.</span>")
		return

	if(!check_plasma(80))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't charge with that thing on your leg!</span>")
		return

	visible_message("<span class='danger'>[src] charges towards \the [T]!</span>", \
	"<span class='danger'>You charge towards \the [T]!</span>" )
	emote("roar") //heheh
	usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	use_plasma(80)

	throw_at(T, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, src)

	charge_delay = world.time + RAV_CHARGECOOLDOWN

	addtimer(CALLBACK(src, .charge_cooldown), RAV_CHARGECOOLDOWN)

/mob/living/carbon/Xenomorph/Ravager/proc/charge_cooldown()
	usedPounce = FALSE
	to_chat(src, "<span class='xenodanger'>Your exoskeleton quivers as you get ready to use Eviscerating Charge again.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	update_action_button_icons()

// ***************************************
// *********** Ravage
// ***************************************
/datum/action/xeno_action/activable/ravage
	name = "Ravage (40)"
	action_icon_state = "ravage"
	mechanics_text = "Release all of your rage in a vicious melee attack against a single target. The more rage you have, the more damage is done."
	ability_name = "ravage"

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.Ravage(A)

/datum/action/xeno_action/activable/ravage/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.ravage_used

/mob/living/carbon/Xenomorph/Ravager/proc/Ravage(atom/A)
	if (!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if (ravage_used)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before Ravaging. Ravage can be used in [(ravage_delay - world.time) * 0.1] seconds.</span>")
		return

	if (!check_plasma(40))
		return

	emote("roar")
	round_statistics.ravager_ravages++
	visible_message("<span class='danger'>\The [src] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>You thrash about in a murderous frenzy!</span>")

	face_atom(A)
	var/sweep_range = 1
	var/list/L = orange(sweep_range)		// Not actually the fruit
	var/victims
	var/target_facing
	for (var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(src, H)
		if(target_facing != dir && target_facing != turn(dir,45) && target_facing != turn(dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !(istype(H.buckled, /obj/structure/bed/nest) && H.status_flags & XENO_HOST) ) //No bully
			var/extra_dam = rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper) * round(RAV_RAVAGE_DAMAGE_MULITPLIER + rage * RAV_RAVAGE_RAGE_MULITPLIER, 0.01)
			H.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, INTENT_HARM)
			victims++
			round_statistics.ravager_ravage_victims++
			step_away(H, src, sweep_range, 2)
			shake_camera(H, 2, 1)
			H.KnockDown(1, 1)

	victims = CLAMP(victims,0,3) //Just to be sure
	rage = (0 + 10 * victims) //rage resets to 0, though we regain 10 rage per victim.

	ravage_used = TRUE
	use_plasma(40)

	ravage_delay = world.time + (RAV_RAVAGE_COOLDOWN - (victims * 30))

	reset_movement()

	//10 second cooldown base, minus 3 seconds per victim
	addtimer(CALLBACK(src, .ravage_cooldown), CLAMP(RAV_RAVAGE_COOLDOWN - (victims * 30),10,100))

/mob/living/carbon/Xenomorph/Ravager/proc/ravage_cooldown()
	ravage_used = FALSE
	to_chat(src, "<span class='xenodanger'>You gather enough strength to Ravage again.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	update_action_button_icons()

// ***************************************
// *********** Second wind
// ***************************************
/datum/action/xeno_action/activable/second_wind
	name = "Second Wind"
	action_icon_state = "second_wind"
	mechanics_text = "A channeled ability to restore health that uses plasma and rage. Must stand still for it to work."

/datum/action/xeno_action/activable/second_wind/action_activate(atom/A)
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	X.Second_Wind()

/datum/action/xeno_action/activable/second_wind/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Ravager/X = owner
	return !X.second_wind_used

/mob/living/carbon/Xenomorph/Ravager/proc/Second_Wind()
	if(!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if(second_wind_used)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before using Second Wind. Second Wind can be used in [(second_wind_delay - world.time) * 0.1] seconds.</span>")
		return

	to_chat(src, "<span class='xenodanger'>Your coursing adrenaline stimulates tissues into a spat of rapid regeneration...</span>")
	var/current_rage = CLAMP(rage,0,RAVAGER_MAX_RAGE) //lock in the value at the time we use it; min 0, max 50.
	do_jitter_animation(1000)
	if(!do_after(src, 50, TRUE, 5, BUSY_ICON_FRIENDLY))
		return
	do_jitter_animation(1000)
	playsound(src, "sound/effects/alien_drool2.ogg", 50, 0)
	to_chat(src, "<span class='xenodanger'>You recoup your health, your tapped rage restoring your body, flesh and chitin reknitting themselves...</span>")
	adjustFireLoss(-CLAMP( (getFireLoss()) * (0.25 + current_rage * 0.015), 0, getFireLoss()) )//Restore HP equal to 25% + 1.5% of the difference between min and max health per rage
	adjustBruteLoss(-CLAMP( (getBruteLoss()) * (0.25 + current_rage * 0.015), 0, getBruteLoss()) )//Restore HP equal to 25% + 1.5% of the difference between min and max health per rage
	plasma_stored += CLAMP( (xeno_caste.plasma_max - plasma_stored) * (0.25 + current_rage * 0.015), 0, xeno_caste.plasma_max - plasma_stored) //Restore Plasma equal to 25% + 1.5% of the difference between min and max health per rage
	updatehealth()
	hud_set_plasma()

	round_statistics.ravager_second_winds++

	second_wind_used = TRUE

	var/cooldown = (RAV_SECOND_WIND_COOLDOWN * round((1 - (current_rage * 0.015) ),0.01) )

	second_wind_delay = world.time + cooldown

	addtimer(CALLBACK(src, .second_wind_cooldown), cooldown) //4 minute cooldown, minus 0.75 seconds per rage to minimum 60 seconds.

	rage = 0

/mob/living/carbon/Xenomorph/Ravager/proc/second_wind_cooldown()
	second_wind_used = FALSE
	to_chat(src, "<span class='xenodanger'>You gather enough strength to use Second Wind again.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	update_action_button_icons()
