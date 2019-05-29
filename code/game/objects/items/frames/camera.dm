/obj/item/frame/camera
	name = "camera assembly"
	desc = "The basic construction for Corporate-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = 2
	anchored = 0

	matter = list("metal" = 700,"glass" = 300)

	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/assembly/prox_sensor, /obj/item/stack/sheet/mineral/osmium, /obj/item/stock_parts/scanning_module)
	var/list/upgrades = list()
	var/state = 0

	/*
				0 = Nothing done to it
				1 = Wrenched in place
				2 = Welded in place
				3 = Wires attached to it (you can now attach/dettach upgrades)
				4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/item/frame/camera/attackby(obj/item/I, mob/user, params)
	. = ..()

	switch(state)
		if(0)
			if(iswrench(I) && isturf(loc))
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				to_chat(user, "You wrench the assembly into place.")
				anchored = TRUE
				state = 1
				update_icon()
				auto_turn()
		if(1)
			if(iswelder(I))
				if(!weld(I, user))
					return

				to_chat(user, "You weld the assembly securely into place.")
				anchored = TRUE
				state = 2

			else if(iswrench(I))
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				to_chat(user, "You unattach the assembly from it's place.")
				anchored = FALSE
				update_icon()
				state = 0
		if(2)
			if(iscablecoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(!C.use(2))
					to_chat(user, "<span class='warning'>You need 2 coils of wire to wire the assembly.</span>")
					return

				to_chat(user, "<span class='notice'>You add wires to the assembly.</span>")
				state = 3

			else if(iswelder(I))
				if(!weld(I, user))
					return

				to_chat(user, "You unweld the assembly from it's place.")
				state = 1
				anchored = TRUE
		if(3)
			if(isscrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)

				var/input = strip_html(input(user, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: military, Security,Secret ", "Set Network", "military"))
				if(!input)
					to_chat(user, "No input found please hang up and try your call again.")
					return

				var/list/tempnetwork = text2list(input, ",")
				if(!length(tempnetwork))
					to_chat(user, "No network found please hang up and try your call again.")
					return

				var/area/camera_area = get_area(src)
				var/temptag = "[sanitize(camera_area.name)] ([rand(1, 999)])"
				input = strip_html(input(usr, "How would you like to name the camera?", "Set Camera Name", temptag))

				state = 4
				var/obj/machinery/camera/C = new(loc)
				forceMove(C)
				C.assembly = src
				C.auto_turn()
				C.network = uniquelist(tempnetwork)
				tempnetwork = difflist(C.network,RESTRICTED_CAMERA_NETWORKS)
				if(!length(tempnetwork))//Camera isn't on any open network - remove its chunk from AI visibility.
					cameranet.removeCamera(C)

				C.c_tag = input

				var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
				if(direct != "LEAVE IT")
					C.setDir(text2dir(direct))

			else if(iswirecutter(I))
				new /obj/item/stack/cable_coil(get_turf(src), 2)
				playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
				to_chat(user, "You cut the wires from the circuits.")
				state = 2

	if(is_type_in_list(I, possible_upgrades) && !is_type_in_list(I, upgrades)) // Is a possible upgrade and isn't in the camera already.
		to_chat(user, "You attach \the [I] into the assembly inner circuits.")
		upgrades += I
		user.drop_held_item()
		I.forceMove(src)

	else if(iscrowbar(I) && length(upgrades))
		var/obj/U = pick(upgrades)
		if(!U)
			return

		to_chat(user, "You unattach an upgrade from the assembly.")
		playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
		U.forceMove(loc)
		upgrades -= U

/obj/item/frame/camera/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/frame/camera/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/frame/camera/proc/weld(var/obj/item/tool/weldingtool/WT, var/mob/user)

	if(user.action_busy || !WT.isOn())
		return FALSE

	to_chat(user, "<span class='notice'>You start to weld the [src]..</span>")
	playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
	WT.eyecheck(user)
	if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
		return TRUE
	return FALSE
