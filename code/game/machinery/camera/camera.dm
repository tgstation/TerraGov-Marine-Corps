/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	layer = FLY_LAYER

	var/list/network = list("military")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1.0
	anchored = 1.0
	var/invuln = null
	var/bugged = FALSE
	var/obj/item/frame/camera/assembly = null

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/light_disabled = FALSE
	var/alarm_on = FALSE

/obj/machinery/camera/Initialize()
	assembly = new(src)
	assembly.state = 4
	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			log_world("[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]")
	*/
	if(!src.network || src.network.len < 1)
		if(loc)
			stack_trace("[src.name] in [get_area(src)] (x:[src.x] y:[src.y] z:[src.z] has errored. [src.network?"Empty network list":"Null network list"]")
		else
			stack_trace("[src.name] in [get_area(src)]has errored. [src.network?"Empty network list":"Null network list"]")
		ASSERT(src.network)
		ASSERT(src.network.len > 0)

	switch(dir)
		if(1)	pixel_y = 40
		if(2)	pixel_y = -18
		if(4)	pixel_x = -27
		if(8)	pixel_x = 27

	. = ..()

/obj/machinery/camera/emp_act(severity)
	if(!isEmpProof())
		if(prob(100/severity))
			icon_state = "[initial(icon_state)]emp"
			var/list/previous_network = network
			network = list()
			cameranet.removeCamera(src)
			machine_stat |= EMPED
			SetLuminosity(0)
			triggerCameraAlarm()
			spawn(900)
				network = previous_network
				icon_state = initial(icon_state)
				machine_stat &= ~EMPED
				cancelCameraAlarm()
				if(can_use())
					cameranet.addCamera(src)
			kick_viewers()
			..()


/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/proc/setViewRange(var/num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/attack_alien(mob/living/carbon/Xenomorph/M)
	if(status)
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
		playsound(loc, "alien_claw_metal", 25, 1)
		light_disabled = 0
		toggle_cam_status(M, TRUE)

/obj/machinery/camera/attack_hand(mob/living/carbon/human/user as mob)

	if(!istype(user))
		return

	if(user.species.can_shred(user))
		visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
		playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1)
		light_disabled = FALSE
		toggle_cam_status(user, TRUE)

/obj/machinery/camera/attackby(W as obj, mob/living/user as mob)

	// DECONSTRUCTION
	if(isscrewdriver(W))
		//to_chat(user, "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>")
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		panel_open = !panel_open
		user.visible_message("<span class='warning'>[user] screws the camera's panel [panel_open ? "open" : "closed"]!</span>",
		"<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>")
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)

	else if((iswirecutter(W) || ismultitool(W)) && panel_open)
		interact(user)

	else if(iswelder(W))
		if(weld(W, user))
			if(assembly)
				assembly.loc = src.loc
				assembly.state = 1
			qdel(src)


	// OTHER
	else if (istype(W, /obj/item/paper) && isliving(user))
		var/mob/living/U = user
		var/obj/item/paper/X = null

		var/itemname = ""
		var/info = ""
		if(istype(W, /obj/item/paper))
			X = W
			itemname = X.name
			info = X.info

		to_chat(U, "You hold \a [itemname] up to the camera ...")
		for(var/mob/living/silicon/ai/O in GLOB.ai_list)
			if(!O.client)
				continue
			if(U.name == "Unknown")
				to_chat(O, "<b>[U]</b> holds \a [itemname] up to one of your cameras ...")
			else
				to_chat(O, "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></b> holds \a [itemname] up to one of your cameras...")
			O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
		for(var/mob/O in GLOB.player_list)
			if (istype(O.interactee, /obj/machinery/computer/security))
				var/obj/machinery/computer/security/S = O.interactee
				if (S.current == src)
					to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
					O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
	else if (istype(W, /obj/item/camera_bug))
		if (!src.can_use())
			to_chat(user, "<span class='notice'>Camera non-functional</span>")
			return
		if (src.bugged)
			to_chat(user, "<span class='notice'>Camera bug removed.</span>")
			src.bugged = FALSE
		else
			to_chat(user, "<span class='notice'>Camera bugged.</span>")
			src.bugged = TRUE
	else
		..()
	return

/obj/machinery/camera/proc/toggle_cam_status(mob/user, silent)
	status = !status
	add_hiddenprint(user)
	if(!silent)
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
		if(status)
			visible_message("<span class='warning'>[user] has reactivated [src]!</span>")
		else
			visible_message("<span class='warning'>[user] has deactivated [src]!</span>")
	if(status)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]1"
	// now disconnect anyone using the camera
	//Apparently, this will disconnect anyone even if the camera was re-activated.
	//I guess that doesn't matter since they can't use it anyway?
	kick_viewers()

//This might be redundant, because of check_eye()
/obj/machinery/camera/proc/kick_viewers()
	for(var/mob/O in GLOB.player_list)
		if (istype(O.interactee, /obj/machinery/computer/security))
			var/obj/machinery/computer/security/S = O.interactee
			if (S.current == src)
				O.unset_interaction()
				O.reset_view(null)
				to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = TRUE
	for(var/mob/living/silicon/S in GLOB.silicon_mobs)
		S.triggerAlarm("Camera", get_area(src), list(src), src)


/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = FALSE
	for(var/mob/living/silicon/S in GLOB.silicon_mobs)
		S.cancelAlarm("Camera", get_area(src), src)

/obj/machinery/camera/proc/can_use()
	if(!status)
		return FALSE
	if(machine_stat & EMPED)
		return FALSE
	return TRUE

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/closed/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					setDir(SOUTH)
				if(SOUTH)
					setDir(NORTH)
				if(WEST)
					setDir(EAST)
				if(EAST)
					setDir(WEST)
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(var/mob/M)

	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

/obj/machinery/camera/proc/weld(var/obj/item/tool/weldingtool/WT, var/mob/user)

	if(user.action_busy || !WT.isOn())
		return FALSE

	//Do after stuff here
	user.visible_message("<span class='notice'>[user] starts to weld [src].</span>",
	"<span class='notice'>You start to weld [src].</span>")
	playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
	WT.eyecheck(user)
	if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
		return FALSE
	playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
	user.visible_message("<span class='notice'>[user] welds [src].</span>",
	"<span class='notice'>You weld [src].</span>")
	return TRUE
