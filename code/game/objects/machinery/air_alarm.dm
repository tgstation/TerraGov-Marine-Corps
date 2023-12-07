// Please note this is cosmetic only and not buildable by players.
/obj/machinery/air_alarm
	name = "air alarm"
	icon = 'icons/obj/machines/air_alarm.dmi'
	icon_state = "alarm_powered"
	power_channel = ENVIRON
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_GREEN

/obj/machinery/air_alarm/Initialize(mapload, direction)
	. = ..()

	if(direction)
		setDir(direction)
	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

	var/area/our_area = get_area(src)
	name = "[our_area.name] Air Alarm"
	update_icon()

/obj/machinery/air_alarm/update_icon()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return

	set_light(initial(light_range))

/obj/machinery/air_alarm/update_icon_state()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "alarm_unpowered"
	else
		icon_state = "alarm_powered"

/obj/machinery/air_alarm/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	. += emissive_appearance(icon, "[icon_state]_emissive")

/obj/machinery/air_alarm/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	balloon_alert_to_viewers("[user] starts trying to pry [src] off the wall..")
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	if(!do_after(user, 5 SECONDS, NONE, src))
		return

	qdel(src)
	new /obj/item/stack/sheet/metal(user.drop_location(), 2)
