/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	anchored = TRUE

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

	GLOB.cameranet.cameras += src
	GLOB.cameranet.addCamera(src)

	myarea = get_area(src)
	if(myarea)
		LAZYADD(myarea.cameras, src)

	update_icon()


/obj/machinery/camera/Destroy()
	if(can_use())
		toggle_cam(null, 0) //kick anyone viewing out and remove from the camera chunks
	
	GLOB.cameranet.cameras -= src
	if(isarea(myarea))
		LAZYREMOVE(myarea.cameras, src)

	return ..()


/obj/machinery/camera/examine(mob/user)
	. = ..()

	if(!status)
		to_chat(user, "<span class='info'>It's currently deactivated.</span>")
		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN) && powered())
			to_chat(user, "<span class='notice'>You'll need to open its maintenance panel with a <b>screwdriver</b> to turn it back on.</span>")
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		to_chat(user, "<span class='info'>Its maintenance panel is currently open.</span>")
		if(!status && powered())
			to_chat(user, "<span class='info'>It can reactivated with a <b>screwdriver</b>.</span>")


/obj/machinery/camera/proc/setViewRange(num = 7)
	view_range = num
	GLOB.cameranet.updateVisibility(src, 0)


/obj/machinery/camera/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper) && isliving(user))
		var/mob/living/U = user
		var/obj/item/paper/X = I
		var/itemname = X.name
		var/info = X.info

		to_chat(U, "<span class='notice'>You hold \the [itemname] up to the camera...</span>")
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
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))


/obj/machinery/camera/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
	to_chat(user, "<span class='notice'>You screw the camera's panel [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "closed"].</span>")
	I.play_tool_sound(src)
	update_icon()
	return TRUE


/obj/machinery/camera/wirecutter_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE
	toggle_cam(user, TRUE)
	obj_integrity = max_integrity
	I.play_tool_sound(src)
	update_icon()
	return TRUE


/obj/machinery/camera/multitool_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE

	setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
	to_chat(user, "<span class='notice'>You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus.</span>")
	return TRUE


/obj/machinery/camera/welder_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE

	if(!I.tool_start_check(user, amount = 0))
		return TRUE

	to_chat(user, "<span class='notice'>You start to weld [src]...</span>")

	if(I.use_tool(src, user, 100, volume = 50))
		user.visible_message("<span class='warning'>[user] unwelds [src], leaving it as just a frame bolted to the wall.</span>",
			"<span class='warning'>You unweld [src], leaving it as just a frame bolted to the wall</span>")
		deconstruct(TRUE)

	return TRUE


/obj/machinery/camera/attack_alien(mob/living/carbon/xenomorph/X)
	if(obj_integrity <= 0)
		to_chat(X, "<span class='warning'>The camera is already disabled.</span>")
		return

	X.animation_attack_on(src)
	X.visible_message("<span class='danger'>[X] slashes \the [src]!</span>", \
	"<span class='danger'>You slash \the [src]!</span>")
	playsound(loc, "alien_claw_metal", 25, 1)

	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(machine_stat, PANEL_OPEN)
		update_icon()
		visible_message("<span class='danger'>\The [src]'s cover swings open, exposing the wires!</span>")
		return

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)
	sparks.start()

	deactivate()
	visible_message("<span class='danger'>\The [src]'s wires snap apart in a rain of sparks!</span>")


/obj/machinery/camera/proc/deactivate(mob/user)
	status = FALSE
	obj_integrity = 0
	set_light(0)
	GLOB.cameranet.removeCamera(src)
	if(isarea(myarea))
		LAZYREMOVE(myarea.cameras, src)
	GLOB.cameranet.updateChunk(x, y, z)
	update_icon()

	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(M.client?.eye && M.client.eye == src)
			M.unset_interaction()
			M.reset_perspective(null)
			to_chat(M, "The screen bursts into static.")


/obj/machinery/camera/update_icon()
	if(obj_integrity <= 0)
		icon_state = "camera_assembly"
	else
		icon_state = "camera"


/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = TRUE)
	status = !status
	if(can_use())
		GLOB.cameranet.addCamera(src)
		if(isturf(loc))
			myarea = get_area(src)
			LAZYADD(myarea.cameras, src)
		else
			myarea = null
	else
		set_light(0)
		GLOB.cameranet.removeCamera(src)
		if(isarea(myarea))
			LAZYREMOVE(myarea.cameras, src)
	GLOB.cameranet.updateChunk(x, y, z)

	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"

	if(displaymessage)
		if(user)
			visible_message("<span class='danger'>[user] [change_msg] [src]!</span>")
		else
			visible_message("<span class='danger'>\The [src] [change_msg]!</span>")

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
			break
	return null


/proc/near_range_camera(mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null


/obj/machinery/camera/proc/Togglelight(on = FALSE)
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY)
	else
		set_light(0)


/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)


/obj/machinery/camera/update_remote_sight(mob/living/user)
	user.see_invisible = SEE_INVISIBLE_LIVING //can't see ghosts through cameras
	user.sight = NONE
	user.see_in_dark = 2
	return TRUE


/obj/machinery/camera/autoname
	var/number = 0 //camera number in area


//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize()
	. =  ..()
	var/static/list/id_by_area = list()
	var/area/A = get_area(src)
	c_tag = "[A.name] #[++id_by_area[A]]"


//cameras installed inside the dropships, accessible via both cockpit monitor and Theseus camera computers
/obj/machinery/camera/autoname/almayer/dropship_one
	network = list("marinemainship", "dropship1")


/obj/machinery/camera/autoname/almayer/dropship_two
	network = list("marinemainship", "dropship2")


/obj/machinery/camera/autoname/almayer
	name = "military-grade camera"
	network = list("marinemainship")


/obj/machinery/camera/headset
	name = "headset camera"
	network = list("marine")


//used by the laser camera dropship equipment
/obj/machinery/camera/laser_cam
	name = "laser camera"
	icon_state = ""
	mouse_opacity = 0
	network = list("laser targets")
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/camera/laser_cam/New(loc, laser_name)
	. = ..()
	if(!c_tag && laser_name)
		var/area/A = get_area(src)
		c_tag = "[laser_name] ([A.name])"

/obj/machinery/camera/beacon_cam
	name = "beacon camera"
	icon_state = ""
	mouse_opacity = 0
	network = list("supply beacons")
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/camera/beacon_cam/bomb
	network = list("bomb beacons")

/obj/machinery/camera/beacon_cam/New(loc, beacon_name)
	. = ..()
	if(!c_tag && beacon_name)
		var/area/A = get_area(src)
		c_tag = "[beacon_name] ([A.name])"


//used by the landing camera dropship equipment. Do not place them right under where the dropship lands.
//Should place them near each corner of your LZs.
/obj/machinery/camera/autoname/lz_camera
	name = "landing zone camera"
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	network = list("landing zones")


/obj/machinery/camera/autoname/lz_camera/emp_act(severity)
	return


/obj/machinery/camera/autoname/lz_camera/ex_act()
	return


/obj/machinery/camera/autoname/lz_camera/update_icon()
	return