#define STATE_WRENCHED 1
#define STATE_WELDED 2
#define STATE_WIRED 3
#define STATE_FINISHED 4


/obj/item/frame/camera
	name = "camera assembly"
	desc = "The basic construction for cameras."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "cameracase"

/obj/item/frame/camera/proc/try_build(turf/wall, mob/user)
	if(get_dist(wall, user) > 1)
		return

	var/ndir = get_dir(user, wall)
	if(!(ndir in GLOB.cardinals))
		return

	var/turf/loc = get_turf(user)
	if(!isfloorturf(loc))
		loc.balloon_alert(user, "bad spot")
		return

	user.balloon_alert_to_viewers("attaching")
	playsound(loc, 'sound/machines/click.ogg', 15, 1)
	var/constrdir = REVERSE_DIR(user.dir)
	var/constrloc = user.loc

	if(!do_after(user, 30, NONE, wall, BUSY_ICON_BUILD))
		return

	new /obj/structure/camera_assembly(constrloc, constrdir)

	user.visible_message("[user] attaches [src] to the wall.", \
		"You attach [src] to the wall.")

	qdel(src)


/obj/structure/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for cameras."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "camera_assembly"
	max_integrity = 150
	var/state = STATE_WRENCHED


/obj/structure/camera_assembly/examine(mob/user)
	. = ..()

	switch(state)
		if(STATE_WRENCHED)
			. += span_info("You can secure it in place with a <b>welder</b>, or removed with a <b>wrench</b>.")
		if(STATE_WELDED)
			. += span_info("You can add <b>wires</b> to it, or <b>unweld</b> it from the wall.")
		if(STATE_WIRED)
			. += span_info("You can complete it with a <b>screwdriver</b>, or <b>unwire</b> it to start removal.")
		if(STATE_FINISHED)
			. += span_boldwarning("You shouldn't be seeing this, tell a coder!")


/obj/structure/camera_assembly/Initialize(mapload, newDir)
	. = ..()

	if(newDir)
		setDir(newDir)

	switch(dir)
		if(NORTH)
			pixel_y = 16
		if(SOUTH)
			pixel_y = -16
		if(EAST)
			pixel_x = -16
		if(WEST)
			pixel_x = 16


/obj/structure/camera_assembly/attackby(obj/item/I, mob/living/user, params)
	. = ..()

	switch(state)
		if(STATE_WRENCHED)
			if(I.tool_behaviour != TOOL_WELDER)
				return

			if(!weld(I, user))
				return

			to_chat(user, span_notice("You weld [src] securely into place."))
			anchored = TRUE
			state = STATE_WELDED

		if(STATE_WELDED)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if(!C.use(2))
					to_chat(user, span_warning("You need two lengths of cable to wire a camera!"))
					return

				to_chat(user, span_notice("You add wires to [src]."))
				state = STATE_WIRED

			else if(I.tool_behaviour == TOOL_WELDER)

				if(!weld(I, user))
					return

				to_chat(user, span_notice("You unweld [src] from its place."))
				anchored = TRUE
				state = STATE_WRENCHED


/obj/structure/camera_assembly/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(.)
		return TRUE

	if(state != STATE_WIRED)
		return FALSE

	tool.play_tool_sound(src)
	var/input = stripped_input(user, "Which networks would you like to connect this camera to? Separate networks with a comma. No Spaces!\nFor example: marinemainship, marine, dropship1, dropship2", "Set Network", "marinemainship")
	if(!input)
		to_chat(user, span_warning("No network entered."))
		return
	var/list/tempnetwork = splittext(input, ",")
	if(!length(tempnetwork))
		to_chat(user, span_warning("Invalid network entry."))
		return
	for(var/i in tempnetwork)
		tempnetwork -= i
		tempnetwork += lowertext(i)
	state = STATE_FINISHED
	var/obj/machinery/camera/autoname/C = new(loc, dir)
	forceMove(C)
	C.network = tempnetwork
	return TRUE


/obj/structure/camera_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != STATE_WIRED)
		return FALSE

	new /obj/item/stack/cable_coil(drop_location(), 2)
	I.play_tool_sound(src)
	to_chat(user, span_notice("You cut the wires from the circuits."))
	state = STATE_WELDED
	return TRUE


/obj/structure/camera_assembly/wrench_act(mob/user, obj/item/I)
	if(state != STATE_WRENCHED)
		return FALSE
	I.play_tool_sound(src)
	to_chat(user, span_notice("You detach [src] from its place."))
	new /obj/item/frame/camera(drop_location())

	qdel(src)
	return TRUE


/obj/structure/camera_assembly/proc/weld(obj/item/tool/weldingtool/W, mob/living/user)
	if(!W.tool_start_check(user, amount = 3))
		return FALSE
	to_chat(user, span_notice("You start to weld [src]..."))
	if(W.use_tool(src, user, 20, amount = 3, volume = 50))
		return TRUE
	return FALSE


/obj/structure/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	return ..()


#undef STATE_WRENCHED
#undef STATE_WELDED
#undef STATE_WIRED
#undef STATE_FINISHED
