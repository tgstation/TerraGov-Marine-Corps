

//Cleanbot assembly
/obj/item/frame/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/created_name = "Cleanbot"


/obj/item/frame/bucket_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		user.drop_held_item()
		cdel(W)
		var/turf/T = get_turf(src.loc)
		var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot(T)
		A.name = src.created_name
		user << "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>"
		user.temp_drop_inv_item(src)
		cdel(src)

	else if (istype(W, /obj/item/tool/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t



//Floorbot assemblies
/obj/item/frame/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/created_name = "Floorbot"


/obj/item/frame/toolbox_tiles/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(isprox(W))
		cdel(W)
		var/obj/item/frame/toolbox_tiles_sensor/B = new /obj/item/frame/toolbox_tiles_sensor()
		B.created_name = src.created_name
		user.put_in_hands(B)
		user << "<span class='notice'>You add the sensor to the toolbox and tiles!</span>"
		user.temp_drop_inv_item(src)
		cdel(src)

	else if (istype(W, /obj/item/tool/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t



/obj/item/frame/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/created_name = "Floorbot"

/obj/item/frame/toolbox_tiles_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		cdel(W)
		var/turf/T = get_turf(user.loc)
		var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot(T)
		A.name = src.created_name
		user << "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>"
		user.temp_drop_inv_item(src)
		cdel(src)
	else if (istype(W, /obj/item/tool/pen))
		var/t = stripped_input(user, "Enter new robot name", src.name, src.created_name)

		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t







/obj/item/frame/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = 3.0

	New()
		..()
		spawn(5)
			if(src.skin)
				src.overlays += image('icons/obj/aibots.dmi', "kit_skin_[src.skin]")


/obj/item/frame/firstaid_arm_assembly/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/tool/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/device/healthanalyzer))
					user.drop_held_item()
					cdel(W)
					src.build_step++
					user << "<span class='notice'>You add the health sensor to [src].</span>"
					src.name = "First aid/robot arm/health analyzer assembly"
					src.overlays += image('icons/obj/aibots.dmi', "na_scanner")

			if(1)
				if(isprox(W))
					user.drop_held_item()
					cdel(W)
					src.build_step++
					user << "<span class='notice'>You complete the Medibot! Beep boop.</span>"
					var/turf/T = get_turf(src)
					var/obj/machinery/bot/medbot/S = new /obj/machinery/bot/medbot(T)
					S.skin = src.skin
					S.name = src.created_name
					user.temp_drop_inv_item(src)
					cdel(src)
