// ***************************************
// *********** Stealth
// ***************************************
/datum/action/xeno_action/stealth
	name = "Toggle Stealth"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	ability_name = "stealth"
	plasma_cost = 10
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH
	cooldown_timer = HUNTER_STEALTH_COOLDOWN


/datum/action/xeno_action/stealth/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/stealthy_beno = owner
	if(stealthy_beno.legcuffed)
		to_chat(stealthy_beno, "<span class='warning'>We can't enter Stealth with that thing on our leg!</span>")
		return FALSE
	if(stealthy_beno.on_fire)
		to_chat(stealthy_beno, "<span class='warning'>We're too busy being on fire to enter Stealth!</span>")
		return FALSE
	return TRUE


/datum/action/xeno_action/stealth/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/stealthy_beno = owner
	to_chat(stealthy_beno, "<span class='xenodanger'><b>We're ready to use Stealth again.</b></span>")
	playsound(stealthy_beno, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
	return ..()


/datum/action/xeno_action/stealth/action_activate()
	var/mob/living/carbon/xenomorph/hunter/stealthy_beno = owner
	if(stealthy_beno.stealth)
		stealthy_beno.cancel_stealth()
		add_cooldown()
		return TRUE
	
	succeed_activate()
	to_chat(stealthy_beno, "<span class='xenodanger'>We vanish into the shadows...</span>")
	stealthy_beno.last_stealth = world.time
	stealthy_beno.stealth = TRUE
	stealthy_beno.handle_stealth()
	add_cooldown()
	addtimer(CALLBACK(stealthy_beno, /mob/living/carbon/xenomorph/hunter/.proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.


/mob/living/carbon/xenomorph/hunter/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	if(!stealth)//sanity check/safeguard
		return
	to_chat(src, "<span class='xenodanger'>We emerge from the shadows.</span>")
	stealth = FALSE
	can_sneak_attack = FALSE
	alpha = 255 //no transparency/translucency

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
		to_chat(X, "<span class='xenodanger'>Our pounce has left us off-balance; we'll need to wait [HUNTER_POUNCE_SNEAKATTACK_DELAY*0.1] seconds before we can Sneak Attack again.</span>")
		X.can_sneak_attack = FALSE
		addtimer(CALLBACK(X, /mob/living/carbon/xenomorph/hunter/.proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY)

/mob/living/carbon/xenomorph/hunter/proc/sneak_attack_cooldown()
	if(!stealth || can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(src, "<span class='xenodanger'>We're ready to use Sneak Attack while stealthed.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
