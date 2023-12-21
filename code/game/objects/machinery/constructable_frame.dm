/obj/machinery/constructable_frame
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/list/components
	var/list/req_components
	var/state = 1


/obj/machinery/constructable_frame/proc/update_desc()
	var/D
	if(req_components)
		D = "Requires "
		var/first = 1
		for(var/I in req_components)
			if(req_components[I] > 0)
				var/atom/A = I
				D += "[first?"":", "][num2text(req_components[I])] [initial(A.name)]"
				first = 0
		if(first) // nothing needs to be added, then
			D += "nothing"
		D += "."
	desc = D


/obj/machinery/constructable_frame/state_2
	icon_state = "box_1"
	state = 2


/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/I, mob/living/user, params)
	if(I.crit_fail)
		to_chat(user, span_warning("This part is faulty, you cannot add this to the machine!"))
		return

	switch(state)
		if(1)
			if(iscablecoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.get_amount() < 5)
					to_chat(user, span_warning("You need five lengths of cable to add them to the frame."))
					return

				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				user.visible_message(span_notice("[user] starts adding cables to [src]."),
				span_notice("You start adding cables to [src]."))
				if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD) || state != 1 || QDELETED(C))
					return

				if(!C.use(5))
					return

				user.visible_message(span_notice("[user] adds cables to [src]."),
				span_notice("You add cables to [src]."))
				state = 2
				icon_state = "box_1"

			if(iswrench(I))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				to_chat(user, span_notice("You dismantle the frame"))
				new /obj/item/stack/sheet/metal(loc, 5)
				qdel(src)

		if(2)
			if(istype(I, /obj/item/circuitboard/machine))
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				to_chat(user, span_notice("You add the circuit board to the frame."))
				var/obj/item/circuitboard/machine/circuit = I
				if(!user.transferItemToLoc(I, src))
					return

				icon_state = "box_2"
				state = 3
				components = list()
				req_components = circuit.req_components.Copy()
				for(var/A in circuit.req_components)
					req_components[A] = circuit.req_components[A]
				if(circuit.frame_desc)
					desc = circuit.frame_desc
				else
					update_desc()
				to_chat(user, desc)

			if(iswirecutter(I))
				playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
				to_chat(user, span_notice("You remove the cables."))
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
				A.amount = 5

		if(3)
			if(iscrowbar(I))
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				state = 2
				circuit.forceMove(loc)
				circuit = null
				if(!length(components))
					to_chat(user, span_notice("You remove the circuit board."))
				else
					to_chat(user, span_notice("You remove the circuit board and other components."))
					for(var/obj/item/W in components)
						W.forceMove(loc)

				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"

			if(isscrewdriver(I))
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break

				if(component_check)
					playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
					var/obj/machinery/new_machine = new circuit.build_path(loc)
					new_machine.component_parts.Cut()
					circuit.construct(new_machine)
					for(var/obj/O in src)
						O.forceMove(new_machine)
						new_machine.component_parts += O
					circuit.loc = new_machine
					new_machine.RefreshParts()
					qdel(src)

			for(var/i in req_components)
				if(istype(I, text2path(i)) && (req_components[i] > 0))
					playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
					if(iscablecoil(I))
						var/obj/item/stack/cable_coil/CP = I
						if(CP.get_amount() > 1)
							var/camt = min(CP.amount, req_components[i]) // amount of cable to take, idealy amount required, but limited by amount provided
							var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(src)
							CC.amount = camt
							CC.update_icon()
							CP.use(camt)
							components += CC
							req_components[i] -= camt
							update_desc()
							break
					if(user.transferItemToLoc(I, src))
						components += I
						req_components[i]--
						update_desc()
					break
