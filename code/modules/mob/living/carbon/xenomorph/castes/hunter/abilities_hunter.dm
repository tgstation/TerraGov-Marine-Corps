// ***************************************
// *********** Stealth
// ***************************************
/datum/action/xeno_action/activable/stealth
	name = "Toggle Stealth"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	ability_name = "stealth"
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH

/datum/action/xeno_action/activable/stealth/action_activate()
	var/mob/living/carbon/xenomorph/hunter/X = owner
	X.Stealth()

/datum/action/xeno_action/activable/stealth/action_cooldown_check()
	var/mob/living/carbon/xenomorph/hunter/X = owner
	return !X.used_stealth

/mob/living/carbon/xenomorph/hunter/proc/Stealth()

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

/mob/living/carbon/xenomorph/hunter/proc/stealth_cooldown()
	if(!used_stealth)//sanity check/safeguard
		return
	used_stealth = FALSE
	to_chat(src, "<span class='xenodanger'><b>You're ready to use Stealth again.</b></span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
	update_action_button_icons()

/mob/living/carbon/xenomorph/hunter/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
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
/datum/action/xeno_action/activable/pounce/hunter
	plasma_cost = 20
	range = 7

/datum/action/xeno_action/activable/pounce/hunter/prepare_to_pounce()
	. = ..()
	if(owner.m_intent == MOVE_INTENT_WALK) //Hunter that is currently using its stealth ability, need to unstealth him
		owner.m_intent = MOVE_INTENT_RUN
		if(owner.hud_used?.move_intent)
			owner.hud_used.move_intent.icon_state = "running"
		owner.update_icons()

/datum/action/xeno_action/activable/pounce/hunter/sneak_attack()
	var/mob/living/carbon/xenomorph/hunter/X = owner
	if(X.can_sneak_attack) //If we could sneak attack, add a cooldown to sneak attack
		to_chat(X, "<span class='xenodanger'>Your pounce has left you off-balance; you'll need to wait [HUNTER_POUNCE_SNEAKATTACK_DELAY*0.1] seconds before you can Sneak Attack again.</span>")
		X.can_sneak_attack = FALSE
		addtimer(CALLBACK(X, /mob/living/carbon/xenomorph/hunter/.proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY)

/mob/living/carbon/xenomorph/hunter/proc/sneak_attack_cooldown()
	if(can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(src, "<span class='xenodanger'>You're ready to use Sneak Attack while stealthed.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
