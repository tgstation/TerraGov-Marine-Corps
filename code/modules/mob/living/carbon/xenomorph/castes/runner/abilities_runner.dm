// ***************************************
// *********** Savage
// ***************************************
/datum/action/xeno_action/toggle_savage
	name = "Toggle Savage"
	action_icon_state = "savage_on"
	mechanics_text = "Toggle on to add a vicious attack to your pounce."
	plasma_cost = 0

/datum/action/xeno_action/toggle_savage/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner

	if(!X.check_state())
		return

	if(X.savage)
		X.savage = FALSE
		to_chat(X, "<span class='xenowarning'>You untense your muscles, and relax. You will no longer savage when pouncing.</span>")
		button.overlays.Cut()
		button.overlays += image('icons/mob/actions.dmi', button, "savage_off")
	else
		X.savage = TRUE
		to_chat(X, "You ready yourself for a killing stroke. You will savage when pouncing.[X.savage_used ? " However, you're not quite yet able to savage again." : ""]")
		button.overlays.Cut()
		button.overlays += image('icons/mob/actions.dmi', button, "savage_on")

/mob/living/carbon/Xenomorph/proc/Savage(var/mob/living/carbon/M)

	if(!check_state())
		return

	if(savage_used)
		to_chat(src, "<span class='xenowarning'>You're too tired to savage right now.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't savage with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenodanger'>You're too disoriented from the shock to savage!</span>")
		return

	var/alien_roar = "alien_roar[rand(1,6)]"
	playsound(src, alien_roar, 50)
	use_plasma(10) //Base cost of the Savage
	src.visible_message("<span class='danger'>\ [src] savages [M]!</span>", \
	"<span class='xenodanger'>You savage [M]!</span>", null, 5)
	var/extra_dam = min(15, plasma_stored * 0.2)
	round_statistics.runner_savage_attacks++
	M.attack_alien(src,  extra_dam, FALSE, TRUE, TRUE, TRUE) //Inflict a free attack on pounce that deals +1 extra damage per 4 plasma stored, up to 35 or twice the max damage of an Ancient Runner attack.
	use_plasma(extra_dam * 5) //Expend plasma equal to 4 times the extra damage.
	savage_used = TRUE
	addtimer(CALLBACK(src, .savage_cooldown), xeno_caste.savage_cooldown)

	return TRUE

/mob/living/carbon/Xenomorph/proc/savage_cooldown()
	if(!savage_used)//sanity check/safeguard
		return
	savage_used = FALSE
	to_chat(src, "<span class='xenowarning'><b>You can now savage your victims again.</b></span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()
	