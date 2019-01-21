/obj/item/device/suit_cooling_unit
	name = "portable suit cooling unit"
	desc = "A portable heat sink and liquid cooled radiator that can be hooked up to a space suit's existing temperature controls to provide industrial levels of cooling."
	w_class = 4
	icon_state = "suitcooler0"
	flags_equip_slot = ITEM_SLOT_BACK	//you can carry it on your back if you want, but it won't do anything unless attached to suit storage

	//copied from tank.dm
	flags_atom = CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	origin_tech = "magnets=2;materials=2"

	var/on = 0				//is it turned on?
	var/cover_open = 0		//is the cover open?
	var/obj/item/cell/cell
	var/max_cooling = 12				//in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 16.6		//charge per second at max_cooling
	var/thermostat = T20C

	//TODO: make it heat up the surroundings when not in space

/obj/item/device/suit_cooling_unit/New()
	START_PROCESSING(SSobj, src)

	cell = new/obj/item/cell()	//comes with the crappy default power cell - high-capacity ones shouldn't be hard to find
	cell.loc = src

/obj/item/device/suit_cooling_unit/process()
	if (!on || !cell)
		return

	if (!ismob(loc))
		return

	if (!attached_to_suit(loc))		//make sure they have a suit and we are attached to it
		return

	var/mob/living/carbon/human/H = loc

	var/efficiency = 1 - H.get_pressure_weakness()		//you need to have a good seal for effective cooling
	var/env_temp = get_environment_temperature()		//wont save you from a fire
	var/temp_adj = min(H.bodytemperature - max(thermostat, env_temp), max_cooling)

	if (temp_adj < 0.5)	//only cools, doesn't heat, also we don't need extreme precision
		return

	var/charge_usage = (temp_adj/max_cooling)*charge_consumption

	H.adjust_bodytemperature(-temp_adj*efficiency)

	cell.use(charge_usage)

	if(cell.charge <= 0)
		turn_off()

/obj/item/device/suit_cooling_unit/proc/get_environment_temperature()
	if (ishuman(loc))
		var/mob/living/carbon/human/H = loc
		return H.return_temperature()

	var/turf/T = get_turf(src)
	return T.return_temperature()

/obj/item/device/suit_cooling_unit/proc/attached_to_suit(mob/M)
	if (!ishuman(M))
		return 0

	var/mob/living/carbon/human/H = M

	if (!H.wear_suit || H.s_store != src)
		return 0

	return 1

/obj/item/device/suit_cooling_unit/proc/turn_on()
	if(!cell)
		return
	if(cell.charge <= 0)
		return

	on = 1
	updateicon()

/obj/item/device/suit_cooling_unit/proc/turn_off()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.show_message("\The [src] clicks and whines as it powers down.", 2)	//let them know in case it's run out of power.
	on = 0
	updateicon()

/obj/item/device/suit_cooling_unit/attack_self(mob/user as mob)
	if(cover_open && cell)
		if(ishuman(user))
			user.put_in_hands(cell)
		else
			cell.loc = get_turf(loc)

		cell.add_fingerprint(user)
		cell.updateicon()

		to_chat(user, "You remove the [src.cell].")
		src.cell = null
		updateicon()
		return

	//TODO use a UI like the air tanks
	if(on)
		turn_off()
	else
		turn_on()
		if (on)
			to_chat(user, "You switch on the [src].")

/obj/item/device/suit_cooling_unit/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/tool/screwdriver))
		if(cover_open)
			cover_open = 0
			to_chat(user, "You screw the panel into place.")
		else
			cover_open = 1
			to_chat(user, "You unscrew the panel.")
		updateicon()
		return

	if (istype(W, /obj/item/cell))
		if(cover_open)
			if(cell)
				to_chat(user, "There is a [cell] already installed here.")
			else
				if(user.drop_held_item())
					W.forceMove(src)
					cell = W
					to_chat(user, "You insert the [cell].")
		updateicon()
		return

	return ..()

/obj/item/device/suit_cooling_unit/proc/updateicon()
	if (cover_open)
		if (cell)
			icon_state = "suitcooler1"
		else
			icon_state = "suitcooler2"
	else
		icon_state = "suitcooler0"

/obj/item/device/suit_cooling_unit/examine(mob/user)
	..()
	if (on)
		if (attached_to_suit(src.loc))
			to_chat(user, "It's switched on and running.")
		else
			to_chat(user, "It's switched on, but not attached to anything.")
	else
		to_chat(user, "It is switched off.")

	if (cover_open)
		if(cell)
			to_chat(user, "The panel is open, exposing the [cell].")
		else
			to_chat(user, "The panel is open.")

	if (cell)
		to_chat(user, "The charge meter reads [round(cell.percent())]%.")
	else
		to_chat(user, "It doesn't have a power cell installed.")
