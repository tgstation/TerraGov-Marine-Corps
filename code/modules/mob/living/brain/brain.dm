/mob/living/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "brain1"

/mob/living/brain/Initialize(mapload)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = WEAKREF(src)
	ADD_TRAIT(src, TRAIT_IMMOBILE, INNATE_TRAIT)

/mob/living/brain/Destroy()
	if(key)
		if(stat != DEAD)
			death()
		ghostize()
	return ..()

/mob/living/brain/ghost()
	if(stat == DEAD)
		ghostize(TRUE)
		return

	if(tgui_alert(src, "Are you sure you want to ghost?\n(You are alive, as much as a head can be. If you ghost, you won't be able to chat when you return unless someone revives you.)", "Ghost", list("Yes", "No")) != "Yes")
		return

	death()
	ghostize(TRUE)
