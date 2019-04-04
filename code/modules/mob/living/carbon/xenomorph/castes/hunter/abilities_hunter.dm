// ***************************************
// *********** Stealth
// ***************************************
/datum/action/xeno_action/activable/stealth
	name = "Toggle Stealth"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	ability_name = "stealth"

/datum/action/xeno_action/activable/stealth/action_activate()
	var/mob/living/carbon/Xenomorph/Hunter/X = owner
	X.Stealth()

/datum/action/xeno_action/activable/stealth/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Hunter/X = owner
	return !X.used_stealth

/mob/living/carbon/Xenomorph/Hunter/proc/Stealth()

	if(!check_state())
		return

	if(world.time < stealth_delay)
		to_chat(src, "<span class='xenodanger'><b>You're not yet ready to Stealth again. You'll be ready in [(stealth_delay - world.time)*0.1] seconds.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't enter Stealth with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenodanger'>You're too disoriented from the shock to enter Stealth!</span>")
		return

	if(on_fire)
		to_chat(src, "<span class='xenodanger'>You're too busy being on fire to enter Stealth!</span>")
		return

	if(!stealth)
		if (!check_plasma(10))
			return
		else
			use_plasma(10)
			to_chat(src, "<span class='xenodanger'>You vanish into the shadows...</span>")
			last_stealth = world.time
			stealth = TRUE
			handle_stealth()
			addtimer(CALLBACK(src, .stealth_cooldown), HUNTER_STEALTH_COOLDOWN)
			addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.
	else
		cancel_stealth()

/mob/living/carbon/Xenomorph/Hunter/proc/stealth_cooldown()
	if(!used_stealth)//sanity check/safeguard
		return
	used_stealth = FALSE
	to_chat(src, "<span class='xenodanger'><b>You're ready to use Stealth again.</b></span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
	update_action_button_icons()

/mob/living/carbon/Xenomorph/Hunter/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	if(!stealth)//sanity check/safeguard
		return
	to_chat(src, "<span class='xenodanger'>You emerge from the shadows.</span>")
	stealth = FALSE
	used_stealth = TRUE
	can_sneak_attack = FALSE
	alpha = 255 //no transparency/translucency
	stealth_delay = world.time + HUNTER_STEALTH_COOLDOWN
	addtimer(CALLBACK(src, .stealth_cooldown), HUNTER_STEALTH_COOLDOWN)

// ***************************************
// *********** Pounce/sneak attack
// ***************************************
/mob/living/carbon/Xenomorph/Hunter/Pounce(atom/T)

	if(!T || !check_state() || !check_plasma(20) || T.layer >= FLY_LAYER) //anything above that shouldn't be pounceable (hud stuff)
		return

	if(!isturf(loc))
		to_chat(src, "<span class='xenowarning'>You can't pounce from here!</span>")
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>You must wait before pouncing.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't pounce with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	if(layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		layer = MOB_LAYER

	if(m_intent == "walk") //Hunter that is currently using its stealth ability, need to unstealth him
		m_intent = "run"
		if(hud_used && hud_used.move_intent)
			hud_used.move_intent.icon_state = "running"
		update_icons()

	visible_message("<span class='xenowarning'>\The [src] pounces at [T]!</span>", \
	"<span class='xenowarning'>You pounce at [T]!</span>")

	if(can_sneak_attack) //If we could sneak attack, add a cooldown to sneak attack
		to_chat(src, "<span class='xenodanger'>Your pounce has left you off-balance; you'll need to wait [HUNTER_POUNCE_SNEAKATTACK_DELAY*0.1] seconds before you can Sneak Attack again.</span>")
		can_sneak_attack = FALSE
		addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY)

	usedPounce = TRUE
	flags_pass = PASSTABLE
	use_plasma(20)
	throw_at(T, 7, 2, src) //Victim, distance, speed
	addtimer(CALLBACK(src, .proc/reset_flags_pass), 6)
	addtimer(CALLBACK(src, .proc/reset_pounce_delay), xeno_caste.pounce_delay)



	return TRUE

/mob/living/carbon/Xenomorph/Hunter/proc/sneak_attack_cooldown()
	if(can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(src, "<span class='xenodanger'>You're ready to use Sneak Attack while stealthed.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
