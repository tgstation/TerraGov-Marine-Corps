//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "brain1"

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		..()

	Destroy()
		if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
			if(stat!=DEAD)	//If not dead.
				death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
			ghostize()		//Ghostize checks for key so nothing else is necessary.
		. = ..()


/mob/living/brain/update_canmove()
	canmove = 0
	return canmove





/mob/living/brain/update_sight()
	if (stat == DEAD)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		return

	sight &= ~SEE_TURFS
	sight &= ~SEE_MOBS
	sight &= ~SEE_OBJS
	see_in_dark = 2
	see_invisible = SEE_INVISIBLE_LIVING

