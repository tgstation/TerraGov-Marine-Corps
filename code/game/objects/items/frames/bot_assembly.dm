

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


/obj/item/frame/bucket_sensor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/robot_parts/l_arm) || istype(I, /obj/item/robot_parts/r_arm))
		user.drop_held_item()
		qdel(I)
		var/obj/machinery/bot/cleanbot/A = new(get_turf(src))
		A.name = created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>")
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

	else if(istype(I, /obj/item/tool/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if(!t)
			return

		if(!in_range(src, user) && loc != user)
			return

		created_name = t



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


/obj/item/frame/toolbox_tiles/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isprox(I))
		qdel(I)
		var/obj/item/frame/toolbox_tiles_sensor/B = new
		B.created_name = created_name
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You add the sensor to the toolbox and tiles!</span>")
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

	else if(istype(I, /obj/item/tool/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name), 1, MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, user) && loc != user)
			return

		created_name = t



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

/obj/item/frame/toolbox_tiles_sensor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/robot_parts/l_arm) || istype(I, /obj/item/robot_parts/r_arm))
		qdel(I)
		var/obj/machinery/bot/floorbot/A = new(get_turf(user))
		A.name = created_name
		to_chat(user, "<span class='notice'>You add the robot arm to the odd looking toolbox assembly! Boop beep!</span>")
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

	else if(istype(I, /obj/item/tool/pen))
		var/t = stripped_input(user, "Enter new robot name", name, created_name)
		if(!t)
			return

		if(!in_range(src, user) && loc != user)
			return

		created_name = t







/obj/item/frame/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = 3.0

/obj/item/frame/firstaid_arm_assembly/Initialize()
	. = ..()
	if(src.skin)
		src.overlays += image('icons/obj/aibots.dmi', "kit_skin_[src.skin]")


/obj/item/frame/firstaid_arm_assembly/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if(!t)
			return

		if(!in_range(src, user) && loc != user)
			return

		created_name = t

	switch(build_step)
		if(0)
			if(istype(I, /obj/item/healthanalyzer))
				user.drop_held_item()
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
				name = "First aid/robot arm/health analyzer assembly"
				overlays += image('icons/obj/aibots.dmi', "na_scanner")
		if(1)
			if(isprox(I))
				user.drop_held_item()
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You complete the Medibot! Beep boop.</span>")
				var/obj/machinery/bot/medbot/S = new /obj/machinery/bot/medbot(get_turf(src))
				S.skin = skin
				S.name = created_name
				user.temporarilyRemoveItemFromInventory(src)
				qdel(src)