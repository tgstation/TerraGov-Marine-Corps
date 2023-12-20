/obj/item/radio/intercom
	name = "station intercom"
	desc = "Talk through this. To speak directly into an intercom next to you, use :i."
	icon = 'icons/obj/machines/radio.dmi'
	icon_state = "intercom"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	flags_atom = CONDUCT|NOBLOODY
	light_range = 1.5
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_YELLOW
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()
	var/last_tick //used to delay the powercheck

/obj/item/radio/intercom/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32
	START_PROCESSING(SSobj, src)
	become_hearing_sensitive()
	update_icon()


/obj/item/radio/intercom/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/radio/intercom/update_icon()
	. = ..()
	if(!on)
		set_light(0)
		return

	set_light(initial(light_range))

/obj/item/radio/intercom/update_icon_state()
	if(!on)
		icon_state = "intercom_unpowered"
	else
		icon_state = "intercom"

/obj/item/radio/intercom/update_overlays()
	. = ..()
	if(!on)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive")

/obj/item/radio/intercom/attack_ai(mob/user as mob)
	spawn (0)
		attack_self(user)


/obj/item/radio/intercom/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	spawn (0)
		attack_self(user)


/obj/item/radio/intercom/can_receive(freq, list/levels)
	if(levels != RADIO_NO_Z_LEVEL_RESTRICTION)
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in levels))
			return FALSE
	if(!listening)
		return FALSE

	return TRUE


/obj/item/radio/intercom/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	if(message_mode == MODE_INTERCOM)
		return FALSE // Avoid hearing the same thing twice
	if(!anyai && !(speaker in ai))
		return FALSE
	return ..()


/obj/item/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday
		var/new_state
		var/area/A = get_area(src)
		if(!A)
			new_state = FALSE
		else
			new_state = A.powered(EQUIP) // set "on" to the power status
		if(on == new_state)
			return
		else
			on = new_state
			update_icon()

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

/obj/item/radio/intercom/dropship/triumph
	name = "\improper Triumph dropship intercom"
	frequency = FREQ_DROPSHIP_2
