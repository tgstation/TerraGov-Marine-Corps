#define STATE_WRENCHED 1
#define STATE_WELDED 2
#define STATE_WIRED 3
#define STATE_FINISHED 4


/obj/item/frame/camera
	name = "camera assembly"
	desc = "The basic construction for cameras."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "cameracase"
	matter = list("metal" = 400, "glass" = 250)


/obj/item/frame/camera/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)


/obj/item/frame/camera/proc/try_build(turf/wall, mob/user)
	if(get_dist(wall, user) > 1)
		return

	var/ndir = get_dir(user, wall)
	if(!(ndir in GLOB.cardinals))
		return

	var/turf/loc = get_turf(user)
	if(!isfloorturf(loc))
		to_chat(user, "<span class='warning'>[src] cannot be placed on this spot.</span>")
		return

	user.visible_message("[user] begins attaching [src] to the wall.", "You being attaching [src] to the wall.")
	playsound(loc, 'sound/machines/click.ogg', 15, 1)
	var/constrdir = reverse_direction(user.dir)
	var/constrloc = user.loc

	if(!do_after(user, 30, TRUE, wall, BUSY_ICON_BUILD))
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
			to_chat(user, "<span class='info'>You can secure it in place with a <b>welder</b>, or removed with a <b>wrench</b>.</span>")
		if(STATE_WELDED)
			to_chat(user, "<span class='info'>You can add <b>wires</b> to it, or <b>unweld</b> it from the wall.</span>")
		if(STATE_WIRED)
			to_chat(user, "<span class='info'>You can complete it with a <b>screwdriver</b>, or <b>unwire</b> it to start removal.</span>")
		if(STATE_FINISHED)
			to_chat(user, "<span class='boldwarning'>You shouldn't be seeing this, tell a coder!</span>")


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

			to_chat(user, "<span class='notice'>You weld [src] securely into place.</span>")
			anchored = TRUE
			state = STATE_WELDED

		if(STATE_WELDED)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if(!C.use(2))
					to_chat(user, "<span class='warning'>You need two lengths of cable to wire a camera!</span>")
					return

				to_chat(user, "<span class='notice'>You add wires to [src].</span>")
				state = STATE_WIRED

			else if(I.tool_behaviour == TOOL_WELDER)

				if(!weld(I, user))
					return

				to_chat(user, "<span class='notice'>You unweld [src] from its place.</span>")
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
		to_chat(user, "<span class='warning'>No network entered.</span>")
		return
	var/list/tempnetwork = splittext(input, ",")
	if(!length(tempnetwork))
		to_chat(user, "<span class='warning'>Invalid network entry.</span>")
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
	to_chat(user, "<span class='notice'>You cut the wires from the circuits.</span>")
	state = STATE_WELDED
	return TRUE


/obj/structure/camera_assembly/wrench_act(mob/user, obj/item/I)
	if(state != STATE_WRENCHED)
		return FALSE
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You detach [src] from its place.</span>")
	new /obj/item/frame/camera(drop_location())

	qdel(src)
	return TRUE


/obj/structure/camera_assembly/proc/weld(obj/item/tool/weldingtool/W, mob/living/user)
	if(!W.tool_start_check(user, amount = 3))
		return FALSE
	to_chat(user, "<span class='notice'>You start to weld [src]...</span>")
	if(W.use_tool(src, user, 20, amount = 3, volume = 50))
		return TRUE
	return FALSE


/obj/structure/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)


#undef STATE_WRENCHED
#undef STATE_WELDED
#undef STATE_WIRED
#undef STATE_FINISHED
