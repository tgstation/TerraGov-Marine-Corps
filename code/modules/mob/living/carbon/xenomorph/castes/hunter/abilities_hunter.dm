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
	var/last_stealth = null
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	var/stealth_alpha_multiplier = 1

/datum/action/xeno_action/stealth/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_POUNCE, .proc/sneak_attack_pounce)
	RegisterSignal(L, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/sneak_attack_slash)
	RegisterSignal(L, COMSIG_XENOMORPH_DISARM_HUMAN, .proc/sneak_attack_disarm)
	RegisterSignal(L, COMSIG_XENOMORPH_ZONE_SELECT, .proc/sneak_attack_zone)
	RegisterSignal(L, COMSIG_XENOMORPH_PLASMA_REGEN, .proc/plasma_regen)

	// TODO: attack_alien() overrides are a mess and need a lot of work to make them require parentcalling
	RegisterSignal(L, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_ATTACK_BARRICADE,
		COMSIG_XENOMORPH_ATTACK_CLOSET,
		COMSIG_XENOMORPH_ATTACK_RAZORWIRE,
		COMSIG_XENOMORPH_ATTACK_BED,
		COMSIG_XENOMORPH_ATTACK_NEST,
		COMSIG_XENOMORPH_ATTACK_TABLE,
		COMSIG_XENOMORPH_ATTACK_RACK,
		COMSIG_XENOMORPH_ATTACK_SENTRY,
		COMSIG_XENOMORPH_ATTACK_M56_POST,
		COMSIG_XENOMORPH_ATTACK_M56,
		COMSIG_XENOMORPH_ATTACK_TANK,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_XENOMORPH_FIRE_BURNING,
		COMSIG_LIVING_ADD_VENTCRAWL), .proc/cancel_stealth)
		
	RegisterSignal(L, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_ADDTRAIT(TRAIT_FLOORED)), .proc/cancel_stealth)

	RegisterSignal(src, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/damage_taken)

/datum/action/xeno_action/stealth/remove_action(mob/living/L)
	UnregisterSignal(L, list(
		COMSIG_XENOMORPH_POUNCE, 
		COMSIG_XENO_LIVING_THROW_HIT, 
		COMSIG_XENOMORPH_ATTACK_LIVING, 
		COMSIG_XENOMORPH_DISARM_HUMAN,
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_ATTACK_BARRICADE,
		COMSIG_XENOMORPH_ATTACK_CLOSET,
		COMSIG_XENOMORPH_ATTACK_RAZORWIRE,
		COMSIG_XENOMORPH_ATTACK_BED,
		COMSIG_XENOMORPH_ATTACK_NEST,
		COMSIG_XENOMORPH_ATTACK_TABLE,
		COMSIG_XENOMORPH_ATTACK_RACK,
		COMSIG_XENOMORPH_ATTACK_SENTRY,
		COMSIG_XENOMORPH_ATTACK_M56_POST,
		COMSIG_XENOMORPH_ATTACK_M56,
		COMSIG_XENOMORPH_ATTACK_TANK,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_XENOMORPH_FIRE_BURNING,
		COMSIG_LIVING_ADD_VENTCRAWL,
		SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
		SIGNAL_ADDTRAIT(TRAIT_FLOORED),
		COMSIG_XENOMORPH_ZONE_SELECT,
		COMSIG_XENOMORPH_PLASMA_REGEN))
	return ..()

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
	to_chat(owner, "<span class='xenodanger'><b>We're ready to use Stealth again.</b></span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
	return ..()

/datum/action/xeno_action/stealth/action_activate()
	if(stealth)
		cancel_stealth()
		add_cooldown()
		return TRUE

	succeed_activate()
	to_chat(owner, "<span class='xenodanger'>We vanish into the shadows...</span>")
	last_stealth = world.time
	stealth = TRUE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/handle_stealth)
	handle_stealth()
	add_cooldown()
	addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.

/datum/action/xeno_action/stealth/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	if(!stealth)//sanity check/safeguard
		return
	to_chat(owner, "<span class='xenodanger'>We emerge from the shadows.</span>")
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED) //This should be handled on the ability datum or a component.
	stealth = FALSE
	can_sneak_attack = FALSE
	owner.alpha = 255 //no transparency/translucency

/datum/action/xeno_action/stealth/proc/sneak_attack_cooldown()
	if(!stealth || can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(owner, "<span class='xenodanger'>We're ready to use Sneak Attack while stealthed.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)

/datum/action/xeno_action/stealth/proc/handle_stealth()
	if(!stealth)
		return

	var/mob/living/carbon/xenomorph/xenoowner = owner
	//Initial stealth
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY) //We don't start out at max invisibility
		owner.alpha = HUNTER_STEALTH_RUN_ALPHA * stealth_alpha_multiplier
		return
	//Stationary stealth
	else if(owner.last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY) //If we're standing still for 4 seconds we become almost completely invisible
		owner.alpha = HUNTER_STEALTH_STILL_ALPHA * stealth_alpha_multiplier
	//Walking stealth
	else if(owner.m_intent == MOVE_INTENT_WALK)
		xenoowner.use_plasma(HUNTER_STEALTH_WALK_PLASMADRAIN)
		owner.alpha = HUNTER_STEALTH_WALK_ALPHA * stealth_alpha_multiplier
	//Running stealth
	else
		xenoowner.use_plasma(HUNTER_STEALTH_RUN_PLASMADRAIN)
		owner.alpha = HUNTER_STEALTH_RUN_ALPHA * stealth_alpha_multiplier
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!xenoowner.plasma_stored)
		to_chat(xenoowner, "<span class='xenodanger'>We lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/// Callback listening for a xeno using the pounce ability
/datum/action/xeno_action/stealth/proc/sneak_attack_pounce()
	// TODO: find out if this is needed
	if(owner.m_intent == MOVE_INTENT_WALK) //Hunter that is currently using its stealth ability, need to unstealth him
		owner.toggle_move_intent(MOVE_INTENT_RUN)
		if(owner.hud_used?.move_intent)
			owner.hud_used.move_intent.icon_state = "running"
		owner.update_icons()

	cancel_stealth()

	if(!can_sneak_attack)
		return
	to_chat(owner, "<span class='xenodanger'>Our pounce has left us off-balance; we'll need to wait [HUNTER_POUNCE_SNEAKATTACK_DELAY*0.1] seconds before we can Sneak Attack again.</span>")
	can_sneak_attack = FALSE
	addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY)

/// Callback for when a mob gets hit as part of a pounce
/datum/action/xeno_action/stealth/proc/mob_hit(datum/source, mob/living/M)
	if(M.stat || isxeno(M))
		return
	if(can_sneak_attack)
		M.adjust_stagger(3)
		M.add_slowdown(1)
		to_chat(owner, "<span class='xenodanger'>Pouncing from the shadows, we stagger our victim.</span>")

/datum/action/xeno_action/stealth/proc/sneak_attack_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	if(!stealth || !can_sneak_attack)
		return

	var/staggerslow_stacks = 2
	var/flavour
	if(owner.m_intent == MOVE_INTENT_RUN && ( owner.last_move_intent > (world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY) ) ) //Allows us to slash while running... but only if we've been stationary for awhile
		flavour = "vicious"
	else
		armor_mod += HUNTER_SNEAK_SLASH_ARMOR_PEN
		staggerslow_stacks *= 2
		flavour = "deadly"

	owner.visible_message("<span class='danger'>\The [owner] strikes [target] with [flavour] precision!</span>", \
	"<span class='danger'>We strike [target] with [flavour] precision!</span>")
	target.adjust_stagger(staggerslow_stacks)
	target.add_slowdown(staggerslow_stacks)
	
	cancel_stealth()

/datum/action/xeno_action/stealth/proc/sneak_attack_disarm(datum/source, mob/living/target, tackle_pain, list/pain_mod)
	if(!stealth || !can_sneak_attack)
		return

	var/staggerslow_stacks = 2
	var/flavour
	if(owner.m_intent == MOVE_INTENT_RUN && ( owner.last_move_intent > (world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY) ) ) //Allows us to slash while running... but only if we've been stationary for awhile
		pain_mod += 1.75
		flavour = "vicious"
	else
		pain_mod += 3.5
		staggerslow_stacks *= 2
		flavour = "deadly"

	owner.visible_message("<span class='danger'>\The [owner] strikes [target] with [flavour] precision!</span>", \
	"<span class='danger'>We strike [target] with [flavour] precision!</span>")
	target.ParalyzeNoChain(1.5 SECONDS)
	target.adjust_stagger(staggerslow_stacks)
	target.add_slowdown(staggerslow_stacks)
	
	cancel_stealth()

/datum/action/xeno_action/stealth/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	if(damage_taken > 15)
		cancel_stealth()

/datum/action/xeno_action/stealth/proc/plasma_regen(datum/source, list/plasma_mod)
	handle_stealth()

	if(stealth && owner.last_move_intent > world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		plasma_mod += 0.0
	else
		plasma_mod += 0.5

/datum/action/xeno_action/stealth/proc/sneak_attack_zone()
	if(!stealth || !can_sneak_attack)
		return
	return COMSIG_ACCURATE_ZONE

// ***************************************
// *********** Pounce/sneak attack
// ***************************************
/datum/action/xeno_action/activable/pounce/hunter
	plasma_cost = 20
	range = 7
	freeze_on_hit_time = 2 SECONDS
