//these are probably broken

/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	anchored = TRUE
	density = TRUE
	var/on = 0
	var/obj/item/cell/cell = null
	var/use = 0
	var/unlocked = 0
	var/open = 0
	var/brightness_on = 7		//can't remember what the maxed out value is
	resistance_flags = UNACIDABLE

/obj/machinery/floodlight/Initialize()
	. = ..()
	cell = new /obj/item/cell(src)


/obj/machinery/floodlight/proc/updateicon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"
/*
/obj/machinery/floodlight/process()
	if(on && cell)
		if(cell.charge >= use)
			cell.use(use)
		else
			on = 0
			updateicon()
			SetLuminosity(0)
			src.visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			return
*/
//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/machinery/floodlight/attack_hand(mob/living/user)
	. = ..()
	if(open && cell)
		if(ishuman(user))
			if(!user.get_active_held_item())
				user.put_in_hands(cell)
				cell.loc = user.loc
		else
			cell.loc = loc

		cell.update_icon()

		src.cell = null
		to_chat(user, "You remove the power cell.")
		updateicon()
		return

	if(on)
		on = 0
		to_chat(user, "<span class='notice'>You turn off the light.</span>")
		set_light(0)
		ENABLE_BITFIELD(resistance_flags, UNACIDABLE)
	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		on = 1
		to_chat(user, "<span class='notice'>You turn on the light.</span>")
		set_light(brightness_on)
		DISABLE_BITFIELD(resistance_flags, UNACIDABLE)

	updateicon()


/obj/machinery/floodlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return

	if(iswrench(I))
		anchored = !anchored
		if(anchored)
			to_chat(user, "You anchor the [src] in place.")
		else
			to_chat(user, "You remove the bolts from the [src].")

	else if(isscrewdriver(I))
		if(open)
			return
		unlocked = !unlocked
		if(unlocked)
			to_chat(user, "You unscrew the battery panel.")
		else
			to_chat(user, "You screw the battery panel in place.")

	else if(iscrowbar(I))
		if(!unlocked)
			return
		open = !open
		if(open)
			to_chat(user, "You remove the battery panel.")
		else if(unlocked)
			overlays.Cut()
			to_chat(user, "You crowbar the battery panel in place.")

	else if(istype(I, /obj/item/cell))
		if(!open)
			return

		if(cell)
			to_chat(user, "There is a power cell already installed.")
			return

		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, "You insert the power cell.")

	updateicon()

//Magical floodlight that cannot be destroyed or interacted with.
/obj/machinery/floodlight/landing
	name = "Landing Light"
	desc = "A powerful light stationed near landing zones to provide better visibility."
	icon_state = "flood01"
	on = 1
	use_power = 0


/obj/machinery/floodlight/landing/Initialize(mapload, ...)
	. = ..()
	set_light(5)


/obj/machinery/floodlight/landing/attack_hand(mob/living/user)
	return


/obj/machinery/floodlight/landing/attackby()
	return


/obj/machinery/floodlight/outpost
	name = "Outpost Light"
	icon_state = "flood01"
	on = TRUE
	use_power = FALSE
