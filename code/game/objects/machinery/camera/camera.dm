/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "camera_icon"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	light_power = 0

	var/datum/cameranet/parent_cameranet
	var/list/network = list("marinemainship")
	var/c_tag = null
	var/status = TRUE
	var/area/myarea = null

	var/view_range = 7
	var/short_range = 2

	var/in_use_lights = FALSE
	var/internal_light = TRUE //Whether it can light up when an AI views it


/obj/machinery/camera/Initialize(mapload, newDir)
	. = ..()
	icon_state = "camera"

	if(newDir)
		setDir(newDir)

	switch(dir)
		if(NORTH)
			pixel_y = -16
		if(SOUTH)
			pixel_y = 16
		if(EAST)
			pixel_x = -16
		if(WEST)
			pixel_x = 16

	for(var/i in network)
		network -= i
		network += lowertext(i)


	if(SOM_CAMERA_NETWORK in network)
		parent_cameranet = GLOB.som_cameranet
	else
		parent_cameranet = GLOB.cameranet


	parent_cameranet.cameras += src
	parent_cameranet.addCamera(src)

	myarea = get_area(src)
	if(myarea)
		LAZYADD(myarea.cameras, src)

	update_icon()


/obj/machinery/camera/Destroy()
	if(can_use())
		toggle_cam(null, 0) //kick anyone viewing out and remove from the camera chunks

	parent_cameranet.cameras -= src
	if(isarea(myarea))
		LAZYREMOVE(myarea.cameras, src)

	return ..()


/obj/machinery/camera/examine(mob/user)
	. = ..()

	if(!status)
		. += span_info("It's currently deactivated.")
		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN) && powered())
			. += span_notice("You'll need to open its maintenance panel with a <b>screwdriver</b> to turn it back on.")
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		. += span_info("Its maintenance panel is currently open.")
		if(!status && powered())
			. += span_info("It can reactivated with a <b>screwdriver</b>.")


/obj/machinery/camera/proc/setViewRange(num = 7)
	view_range = num

	parent_cameranet.updateVisibility(src, 0)


/obj/machinery/camera/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper) && isliving(user))
		var/mob/living/U = user
		var/obj/item/paper/X = I
		var/itemname = X.name
		var/info = X.info

		to_chat(U, span_notice("You hold \the [itemname] up to the camera..."))
		U.changeNext_move(CLICK_CD_MELEE)
		for(var/mob/O in GLOB.player_list)
			if(isAI(O))
				var/mob/living/silicon/ai/AI = O
				if(AI.control_disabled || (AI.stat == DEAD))
					return
				if(U.name == "Unknown")
					to_chat(AI, "<b>[U]</b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				else
					to_chat(AI, "<b><a href='?src=[REF(AI)];track=[html_encode(U.name)]'>[U]</a></b> holds <a href='?_src_=usr;show_paper=1;'>\a [itemname]</a> up to one of your cameras ...")
				AI.last_paper_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"
			else if(O.client && O.client.eye == src)
				to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
				O << browse("<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>", "window=[itemname]")


/obj/machinery/camera/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
	to_chat(user, span_notice("You screw the camera's panel [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "closed"]."))
	I.play_tool_sound(src)
	update_icon()
	return TRUE


/obj/machinery/camera/wirecutter_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE
	repair_damage(max_integrity, user)
	toggle_cam(user, TRUE)
	I.play_tool_sound(src)
	update_icon()
	return TRUE


/obj/machinery/camera/multitool_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE

	setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
	to_chat(user, span_notice("You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus."))
	return TRUE


/obj/machinery/camera/welder_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE

	if(!I.tool_start_check(user, amount = 0))
		return TRUE

	to_chat(user, span_notice("You start to weld [src]..."))

	if(I.use_tool(src, user, 100, volume = 50))
		user.visible_message(span_warning("[user] unwelds [src], leaving it as just a frame bolted to the wall."),
			span_warning("You unweld [src], leaving it as just a frame bolted to the wall"))
		deconstruct(TRUE)

	return TRUE


/obj/machinery/camera/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(obj_integrity <= 0)
		to_chat(X, span_warning("The camera is already disabled."))
		return

	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	X.visible_message(span_danger("[X] slashes \the [src]!"), \
	span_danger("We slash \the [src]!"))
	playsound(loc, "alien_claw_metal", 25, 1)

	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(machine_stat, PANEL_OPEN)
		update_icon()
		visible_message(span_danger("\The [src]'s cover swings open, exposing the wires!"))
		return

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)
	sparks.start()

	deactivate()
	visible_message(span_danger("\The [src]'s wires snap apart in a rain of sparks!"))


/obj/machinery/camera/proc/deactivate(mob/user)
	status = FALSE
	obj_integrity = 0
	set_light(0)
	parent_cameranet.removeCamera(src)
	if(isarea(myarea))
		LAZYREMOVE(myarea.cameras, src)
	parent_cameranet.updateChunk(x, y, z)
	update_icon()

	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(M.client?.eye && M.client.eye == src)
			M.unset_interaction()
			M.reset_perspective(null)
			to_chat(M, "The screen bursts into static.")

	if(!powered())
		return

	for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
		if(!AI.client)
			continue
		to_chat(AI, span_notice("[src] has been deactivated at [myarea]"))

/obj/machinery/camera/update_icon_state()
	if(obj_integrity <= 0)
		icon_state = "camera_assembly"
	else
		icon_state = "camera"

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = TRUE)
	status = !status
	if(can_use())
		parent_cameranet.addCamera(src)
		if(isturf(loc))
			myarea = get_area(src)
			LAZYADD(myarea.cameras, src)
			set_light(initial(light_range), initial(light_power))
		else
			myarea = null
	else
		parent_cameranet.removeCamera(src)
		if(isarea(myarea))
			LAZYREMOVE(myarea.cameras, src)
		deactivate()
	parent_cameranet.updateChunk(x, y, z)

	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"

	if(displaymessage)
		if(user)
			visible_message(span_danger("[user] [change_msg] [src]!"))
		else
			visible_message(span_danger("\The [src] [change_msg]!"))

	update_icon() //update Initialize() if you remove this.

	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	for(var/mob/O in GLOB.player_list)
		if(O.client && O.client.eye == src)
			O.unset_interaction()
			O.reset_perspective(null)
			to_chat(O, "The screen bursts into static.")


/obj/machinery/camera/proc/can_use()
	if(!status)
		return FALSE
	if(machine_stat & EMPED)
		return FALSE
	return TRUE


/obj/machinery/camera/proc/can_see()
	return get_hear(view_range, get_turf(src))


//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C


/proc/near_range_camera(mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C


/obj/machinery/camera/proc/Togglelight(on = FALSE)
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY, AI_CAMERA_LUMINOSITY)
	else
		set_light(initial(light_range), initial(light_power))


/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)


/obj/machinery/camera/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	user.sight = NONE
	user.see_in_dark = 2
	return TRUE

/obj/machinery/camera/autoname
	light_range = 1
	light_power = 0.2
	var/number = 0 //camera number in area

/obj/machinery/camera/autoname/update_overlays()
	. = ..()
	if(obj_integrity <= 0)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive")

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize(mapload)
	. = ..()
	var/static/list/id_by_area = list()
	var/area/A = get_area(src)
	c_tag = "[A.name] #[++id_by_area[A]]"

/obj/machinery/camera/autoname/mainship
	name = "military-grade camera"
	network = list("marinemainship")

/obj/machinery/camera/autoname/mainship/somship
	network = list(SOM_CAMERA_NETWORK)

//cameras installed inside the dropships, accessible via both cockpit monitor and ship camera computers
/obj/machinery/camera/autoname/mainship/dropship_one
	network = list("marinemainship", "dropship1")


/obj/machinery/camera/autoname/mainship/dropship_two
	network = list("marinemainship", "dropship2")

/obj/machinery/camera/headset
	name = "headset camera"
	network = list("marine")
	resistance_flags = RESIST_ALL //If the containing headset is not destroyed, neither should this be.

/obj/machinery/camera/headset/som
	network = list(SOM_CAMERA_NETWORK)

//used by the laser camera dropship equipment
/obj/machinery/camera/laser_cam
	name = "laser camera"
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	network = list("laser targets")
	resistance_flags = RESIST_ALL
	view_range = 12

/obj/machinery/camera/laser_cam/Initialize(mapload, laser_name)
	. = ..()
	if(!c_tag && laser_name)
		var/area/A = get_area(src)
		c_tag = "[laser_name] ([A.name])"

/obj/machinery/camera/beacon_cam
	name = "beacon camera"
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	network = list("supply beacons")
	resistance_flags = RESIST_ALL

/obj/machinery/camera/beacon_cam/bomb
	network = list("bomb beacons")

/obj/machinery/camera/beacon_cam/Initialize(mapload, beacon_name)
	. = ..()
	if(!c_tag && beacon_name)
		var/area/A = get_area(src)
		c_tag = "[beacon_name] ([A.name])"


//used by the landing camera dropship equipment. Do not place them right under where the dropship lands.
//Should place them near each corner of your LZs.
/obj/machinery/camera/autoname/lz_camera
	name = "landing zone camera"
	icon_state = "editor_icon"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	network = list("landing zones")

/obj/machinery/camera/autoname/lz_camera/Initialize(mapload)
	. = ..()
	icon_state = "" //remove visibility on map load

/obj/machinery/camera/autoname/lz_camera/emp_act(severity)
	return


/obj/machinery/camera/autoname/lz_camera/ex_act()
	return


/obj/machinery/camera/autoname/lz_camera/update_icon()
	return

//Thunderdome cameras
/obj/machinery/camera/autoname/thunderdome
	name = "thunderdome camera"
	network = list("thunder")
	resistance_flags = RESIST_ALL

//Special invisible cameras, to get even better angles without looking ugly
/obj/machinery/camera/autoname/thunderdome/hidden

/obj/machinery/camera/autoname/thunderdome/hidden/update_icon()
	icon_state = "nothing"
