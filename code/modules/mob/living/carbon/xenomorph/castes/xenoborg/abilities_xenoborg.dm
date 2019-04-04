// ***************************************
// *********** Fire cannon
// ***************************************
/datum/action/xeno_action/activable/fire_cannon
	name = "Fire Cannon (5)"
	action_icon_state = "fire_cannon"
	mechanics_text = "Pew pew pew, shoot your arm guns!"
	ability_name = "fire cannon"

/datum/action/xeno_action/activable/fire_cannon/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Xenoborg/X = owner
	X.fire_cannon(A)

/mob/living/carbon/Xenomorph/Xenoborg/proc/fire_cannon(atom/T)
	if(!T)
		return

	if(!check_state())
		return

	if(!gun_on)
		to_chat(src, "<span class='warning'>Your autocannon is currently retracted.</span>")
		return

	if(usedPounce)
		return

	if(!check_plasma(5))
		return
	use_plasma(5)

	var/turf/M = get_turf(src)
	var/turf/U = get_turf(T)
	if (!istype(M) || !istype(U))
		return
	face_atom(T)

	visible_message("<span class='xenowarning'>\The [src] fires its autocannon!</span>", \
	"<span class='xenowarning'>You fire your autocannon!</span>" )
	playsound(src.loc,'sound/weapons/gun_smg.ogg', 75, 1)
	usedPounce = TRUE
	addtimer(CALLBACK(src, .proc/reset_pounce_delay), 1)

/datum/action/xeno_action/activable/salvage_plasma/improved
	plasma_salvage_amount = PLASMA_SALVAGE_AMOUNT * 2
	salvage_delay = 3 SECONDS
	max_range = 4
