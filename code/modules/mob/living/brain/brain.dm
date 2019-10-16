/mob/living/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "brain1"

/mob/living/brain/Initialize()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

/mob/living/brain/Destroy()
	if(key)
		if(stat != DEAD)
			death()
		ghostize()
	return ..()


/mob/living/brain/update_canmove()
	canmove = FALSE
	return canmove
