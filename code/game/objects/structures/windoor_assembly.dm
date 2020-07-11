/* Windoor (window door) assembly -Nodrak
* Step 1: Create a windoor out of rglass
* Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
* Step 3: Rotate or Flip the assembly to face and open the way you want
* Step 4: Wrench the assembly in place
* Step 5: Add cables to the assembly
* Step 6: Set access for the door.
* Step 7: Screwdriver the door to complete
*/

/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'
	name = "Windoor Assembly"
	icon_state = "left_assembly_1"
	anchored = FALSE
	density = FALSE
	dir = NORTH

	///What type of windoor does this asembly build.
	var/windoor_type = /obj/machinery/door/window

	///Determines sprite and animation variant, according to from which direction it opens.
	var/facing_direction = OPENS_TO_LEFT
	///Icon base state to apply variants.
	var/state_variant = ""
	///Construction state of the windoor.
	var/construction_state = WINDOOR_ASSEMBLY_UNWIRED

	///Circuit to build new of this kind of machine.
	var/obj/item/circuitboard/airlock/electronics = null


/obj/structure/windoor_assembly/Initialize(mapload, start_dir = NORTH, facing_direction, construction_state)
	. = ..()
	if(facing_direction != src.facing_direction)
		set_facing_direction(facing_direction)
	if(construction_state != src.construction_state)
		set_construction_state(construction_state)
	//Icon will be updated once setDir() gets called
	switch(start_dir)
		if(NORTH, SOUTH, EAST, WEST)
			setDir(start_dir)
		else //If the user is facing northeast. northwest, southeast, southwest or north, default to north
			setDir(NORTH)


obj/structure/windoor_assembly/Destroy()
	density = FALSE
	if(electronics)
		QDEL_NULL(electronics)
	return ..()


/obj/structure/windoor_assembly/setDir(newdir)
	. = ..()
	update_icon()


/obj/structure/windoor_assembly/update_icon()
	icon_state = "[facing_direction][state_variant]_assembly_[construction_state]"


/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/windoor_assembly/attackby(obj/item/I, mob/user, params)
	. = ..()

	switch(construction_state)
		if(WINDOOR_ASSEMBLY_UNWIRED)
			if(iswelder(I) && !anchored)
				var/obj/item/tool/weldingtool/WT = I
				if(!WT.remove_fuel(0, user))
					to_chat(user, "<span class='notice'>You need more welding fuel to dissassemble the windoor assembly.</span>")
					return

				user.visible_message("[user] dissassembles the windoor assembly.", "You start to dissassemble the windoor assembly.")
				playsound(loc, 'sound/items/welder2.ogg', 25, 1)

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				if(!src || !WT.isOn())
					return
				to_chat(user, "<span class='notice'>You dissasembled the windoor assembly!</span>")
				deconstruct(TRUE)

			//Wrenching an unsecure assembly anchors it in place. Step 4 complete
			else if(iswrench(I) && !anchored)
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				user.visible_message("[user] secures the windoor assembly to the floor.", "You start to secure the windoor assembly to the floor.")

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, "<span class='notice'>You've secured the windoor assembly!</span>")
				anchored = TRUE

			//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
			else if(iswrench(I) && anchored)
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				user.visible_message("[user] unsecures the windoor assembly to the floor.", "You start to unsecure the windoor assembly to the floor.")

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, "<span class='notice'>You've unsecured the windoor assembly!</span>")
				anchored = FALSE

			//Adding cable to the assembly. Step 5 complete.
			else if(iscablecoil(I) && anchored)
				user.visible_message("[user] wires the windoor assembly.", "You start to wire the windoor assembly.")

				var/obj/item/stack/cable_coil/CC = I
				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				if(!CC.use(1))
					return

				to_chat(user, "<span class='notice'>You wire the windoor!</span>")
				set_construction_state(WINDOOR_ASSEMBLY_WIRED)

		if(WINDOOR_ASSEMBLY_WIRED)
			//Removing wire from the assembly. Step 5 undone.
			if(iswirecutter(I) && !electronics)
				playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
				user.visible_message("[user] cuts the wires from the airlock assembly.", "You start to cut the wires from airlock assembly.")

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, "<span class='notice'>You cut the windoor wires.!</span>")
				new /obj/item/stack/cable_coil(get_turf(user), 1)
				set_construction_state(WINDOOR_ASSEMBLY_UNWIRED)

			//Adding airlock electronics for access. Step 6 complete.
			else if(istype(I, /obj/item/circuitboard/airlock) && I.icon_state != "door_electronics_smoked")
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				user.visible_message("[user] installs the electronics into the airlock assembly.", "You start to install electronics into the airlock assembly.")

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				user.drop_held_item()
				I.forceMove(src)
				to_chat(user, "<span class='notice'>You've installed the airlock electronics!</span>")
				electronics = I

			//Screwdriver to remove airlock electronics. Step 6 undone.
			else if(isscrewdriver(I) && electronics)
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to uninstall electronics from the airlock assembly.")

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				if(!electronics)
					return

				to_chat(user, "<span class='notice'>You've removed the airlock electronics!</span>")
				var/obj/item/circuitboard/airlock/ae = electronics
				if(electronics.is_general_board)
					ae.set_general()
				electronics = null
				ae.forceMove(loc)

			//Crowbar to complete the assembly, Step 7 complete.
			else if(iscrowbar(I))
				if(!electronics)
					to_chat(user, "<span class='warning'>The assembly is missing electronics.</span>")
					return
				DIRECT_OUTPUT(user, browse(null, "window=windoor_access"))
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				user.visible_message("[user] pries the windoor into the frame.", "You start prying the windoor into the frame.")

				if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
					return

				density = TRUE //Shouldn't matter but just incase
				to_chat(user, "<span class='notice'>You finish the windoor!</span>")

				new windoor_type(loc, dir, electronics, facing_direction, state_variant)

				qdel(src)

	//Update to reflect changes(if applicable)
	update_icon()


/obj/structure/windoor_assembly/examine(mob/user)
	. = ..()
	if(anchored)
		to_chat(user, "<span class='notice'>It seems firmly held in place!.</span>")


/obj/structure/windoor_assembly/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/glass/reinforced(get_turf(src), 5)
	return ..()


///Reaction to the event of the facing direction state changing.
/obj/structure/windoor_assembly/proc/set_facing_direction(new_facing_state, updating_icon = FALSE)
	if(facing_direction == new_facing_state)
		return
	. = facing_direction
	facing_direction = new_facing_state
	if(updating_icon)
		update_icon()


///Reaction to the event of the construction state changing.
/obj/structure/windoor_assembly/proc/set_construction_state(new_state, updating_icon = FALSE)
	if(construction_state == new_state)
		return
	. = construction_state
	construction_state = new_state
	if(new_state == WINDOOR_ASSEMBLY_WIRED)
		anchored = TRUE
		name = "Wired [initial(name)]"
	if(updating_icon)
		update_icon()


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor; therefore, you can't rotate it!</span>")
		return
	setDir(turn(dir, 270))


//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(facing_direction == OPENS_TO_LEFT)
		to_chat(usr, "<span class='warning'>The windoor will now open to the right.</span>")
		set_facing_direction(OPENS_TO_RIGHT, TRUE)
	else
		set_facing_direction(OPENS_TO_LEFT, TRUE)
		to_chat(usr, "<span class='warning'>The windoor will now open to the left.</span>")


/obj/structure/windoor_assembly/secure
	name = "Secure Windoor Assembly"
	icon_state = "leftsecure_assembly_1"
	state_variant = "secure"
	windoor_type = /obj/machinery/door/window/brigdoor

/obj/structure/windoor_assembly/secure/deconstruct(disassembled = TRUE)
	new /obj/item/stack/rods(get_turf(src), 4)
	return ..()

/obj/structure/windoor_assembly/secure/right
	facing_direction = OPENS_TO_RIGHT


/obj/structure/windoor_assembly/short
	icon_state = "leftshort_assembly_1"
	state_variant = "short"
	windoor_type = /obj/machinery/door/window/short

/obj/structure/windoor_assembly/short/right
	facing_direction = OPENS_TO_RIGHT

/obj/structure/windoor_assembly/short/secure
	name = "Secure Windoor Assembly"
	icon_state = "leftshortsecure_assembly_1"
	state_variant = "shortsecure"
	windoor_type = /obj/machinery/door/window/short/secure

/obj/structure/windoor_assembly/short/secure/right
	facing_direction = OPENS_TO_RIGHT


