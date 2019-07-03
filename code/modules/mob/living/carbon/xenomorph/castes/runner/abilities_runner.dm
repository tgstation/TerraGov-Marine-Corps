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
	var/range = 6
	keybind_signal = COMSIG_XENOABILITY_POUNCE

/datum/action/xeno_action/activable/pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	
	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/pounce/proc/prepare_to_pounce()
	if(owner.layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		owner.layer = MOB_LAYER

/datum/action/xeno_action/activable/pounce/proc/sneak_attack()
	return

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

	prepare_to_pounce()

	X.visible_message("<span class='xenowarning'>\The [X] pounces at [A]!</span>", \
	"<span class='xenowarning'>We pounce at [A]!</span>")

	sneak_attack()

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
