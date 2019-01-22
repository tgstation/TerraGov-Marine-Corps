//these are probably broken

/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = 1
	anchored = 1
	var/on = 0
	var/obj/item/cell/cell = null
	var/use = 0
	var/unlocked = 0
	var/open = 0
	var/brightness_on = 7		//can't remember what the maxed out value is
	unacidable = 1

	New()
		..()
		spawn(1)
			cell = new /obj/item/cell(src)

	Destroy()
		SetLuminosity(0)
		. = ..()

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
/obj/machinery/floodlight/attack_hand(mob/user as mob)
	if(open && cell)
		if(ishuman(user))
			if(!user.get_active_held_item())
				user.put_in_hands(cell)
				cell.loc = user.loc
		else
			cell.loc = loc

		cell.add_fingerprint(user)
		cell.updateicon()

		src.cell = null
		to_chat(user, "You remove the power cell.")
		updateicon()
		return

	if(on)
		on = 0
		to_chat(user, "<span class='notice'>You turn off the light.</span>")
		SetLuminosity(0)
		unacidable = 1
	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		on = 1
		to_chat(user, "<span class='notice'>You turn on the light.</span>")
		SetLuminosity(brightness_on)
		unacidable = 0

	updateicon()


/obj/machinery/floodlight/attackby(obj/item/W as obj, mob/user as mob)
	if(!ishuman(user))
		return

	if (istype(W, /obj/item/tool/wrench))
		if (!anchored)
			anchored = 1
			to_chat(user, "You anchor the [src] in place.")
		else
			anchored = 0
			to_chat(user, "You remove the bolts from the [src].")

	if (istype(W, /obj/item/tool/screwdriver))
		if (!open)
			if(unlocked)
				unlocked = 0
				to_chat(user, "You screw the battery panel in place.")
			else
				unlocked = 1
				to_chat(user, "You unscrew the battery panel.")

	if (istype(W, /obj/item/tool/crowbar))
		if(unlocked)
			if(open)
				open = 0
				overlays = null
				to_chat(user, "You crowbar the battery panel in place.")
			else
				if(unlocked)
					open = 1
					to_chat(user, "You remove the battery panel.")

	if (istype(W, /obj/item/cell))
		if(open)
			if(cell)
				to_chat(user, "There is a power cell already installed.")
			else
				if(user.transferItemToLoc(W, src))
					cell = W
					to_chat(user, "You insert the power cell.")
	updateicon()

//Magical floodlight that cannot be destroyed or interacted with.
/obj/machinery/floodlight/landing
	name = "Landing Light"
	desc = "A powerful light stationed near landing zones to provide better visibility."
	icon_state = "flood01"
	on = 1
	in_use = 1
	luminosity = 5
	use_power = 0

	attack_hand()
		return

	attackby()
		return