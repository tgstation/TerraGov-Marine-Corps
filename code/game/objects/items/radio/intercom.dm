/obj/item/radio/intercom
	name = "station intercom"
	desc = "Talk through this. To speak directly into an intercom next to you, use :i."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "intercom"
	pixel_x = -16
	pixel_y = -16
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	flags_atom = CONDUCT|NOBLOODY
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck

/obj/item/radio/intercom/Initialize()
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32
	START_PROCESSING(SSobj, src)


/obj/item/radio/intercom/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/radio/intercom/attack_ai(mob/user as mob)
	spawn (0)
		attack_self(user)

/obj/item/radio/intercom/attack_paw(mob/living/carbon/human/user)
	return src.attack_hand(user)


/obj/item/radio/intercom/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	spawn (0)
		attack_self(user)


/obj/item/radio/intercom/can_receive(freq, level)
	if(!on)
		return FALSE
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in level))
			return FALSE
	if(!listening)
		return FALSE

	return TRUE


/obj/item/radio/intercom/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	if(message_mode == MODE_INTERCOM)
		return  // Avoid hearing the same thing twice
	if(!anyai && !(speaker in ai))
		return
	return ..()


/obj/item/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday

		var/area/A = get_area(src)
		if(!A)
			on = FALSE
		else
			on = A.powered(EQUIP) // set "on" to the power status

		if(!on)
			icon_state = "intercom-p"
		else
			icon_state = initial(icon_state)


/obj/item/radio/intercom/general
	name = "General Listening Channel"
	anyai = TRUE
	freerange = TRUE


/obj/item/radio/intercom/general/colony
	freqlock = TRUE
	frequency = FREQ_CIV_GENERAL

/obj/item/radio/intercom/dropship
	name = "\improper Alamo dropship intercom"
	canhear_range = 7
	frequency = FREQ_DROPSHIP_1

/obj/item/radio/intercom/dropship/normandy
	name = "\improper Normandy dropship intercom"
	frequency = FREQ_DROPSHIP_2
