/obj/structure/computerframe
	density = TRUE
	anchored = TRUE
	name = "Computer-frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/circuitboard/computer/circuit

/obj/structure/computerframe/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			if(iswrench(I))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, span_notice("You wrench the frame into place."))
				anchored = TRUE
				state = 1

			else if(iswelder(I))
				var/obj/item/tool/weldingtool/WT = I
				if(!WT.remove_fuel(0, user))
					to_chat(user, "[WT] must be on to complete this task.")
					return

				playsound(loc, 'sound/items/welder.ogg', 25, 1)
				if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
					return FALSE

				to_chat(user, span_notice("You deconstruct the frame."))
				new /obj/item/stack/sheet/metal(loc, 5)
				qdel(src)
		if(1)
			if(iswrench(I))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, span_notice("You unfasten the frame."))
				anchored = FALSE
				state = 0

			else if(istype(I, /obj/item/circuitboard/computer) && !circuit)
				if(!user.drop_held_item())
					return

				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				to_chat(user, span_notice("You place the circuit board inside the frame."))
				icon_state = "1"
				circuit = I
				I.forceMove(src)

			else if(isscrewdriver(I) && circuit)
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, span_notice("You screw the circuit board into place."))
				state = 2
				icon_state = "2"

			else if(iscrowbar(I) && circuit)
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				to_chat(user, span_notice("You remove the circuit board."))
				state = 1
				icon_state = "0"
				circuit.forceMove(loc)
				circuit = null
		if(2)
			if(isscrewdriver(I) && circuit)
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, span_notice("You unfasten the circuit board."))
				state = 1
				icon_state = "1"

			else if(iscablecoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.get_amount() < 5)
					to_chat(user, span_warning("You need five coils of wire to add them to the frame."))
					return
				to_chat(user, span_notice("You start to add cables to the frame."))

				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

				if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD) || state != 2 || !C.use(5))
					return FALSE

				to_chat(user, span_notice("You add cables to the frame."))
				state = 3
				icon_state = "3"
		if(3)
			if(iswirecutter(I))
				playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
				to_chat(user, span_notice("You remove the cables."))
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new(loc)
				A.amount = 5

			else if(istype(I, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = I
				if(G.get_amount() < 2)
					to_chat(user, span_warning("You need two sheets of glass to put in the glass panel."))
					return
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				to_chat(user, span_notice("You start to put in the glass panel."))

				if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD) || state != 3 || !G.use(2))
					return FALSE

				to_chat(user, span_notice("You put in the glass panel."))
				state = 4
				icon_state = "4"
		if(4)
			if(iscrowbar(I))
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				to_chat(user, span_notice("You remove the glass panel."))
				state = 3
				icon_state = "3"
				new /obj/item/stack/sheet/glass(loc, 2)

			else if(isscrewdriver(I))
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, span_notice("You connect the monitor."))
				var/B = new circuit.build_path(loc)
				circuit.construct(B)
				qdel(src)
