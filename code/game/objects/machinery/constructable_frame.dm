/obj/machinery/constructable_frame
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	max_integrity = 250
	obj/item/circuitboard/machine/circuit = null
	var/state = 0

/obj/machinery/constructable_frame/examine(user)
	. = ..()
	if(circuit)
		. += "It has \a [circuit] installed."


/obj/machinery/constructable_frame/deconstruct(disassembled = TRUE)
	if(!NODECONSTRUCT)
		new /obj/item/stack/sheet/metal(loc, 5)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	qdel(src)


/obj/machinery/constructable_frame/machine
	name = "machine frame"
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components

/obj/machinery/constructable_frame/machine/examine(user)
	. = ..()
	if(state == 3 && req_components && req_component_names)
		var/hasContent = 0
		var/requires = "It requires"

		for(var/p = 1 to req_components.len)
			var/tname = req_components[p]
			var/amt = req_components[tname]
			if(amt == 0)
				continue
			var/use_and = p == req_components.len
			requires += "[(hasContent ? (use_and ? ", and" : ",") : "")] [amt] [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
			hasContent = 1

		if(hasContent)
			. +=  "[requires]."
		else
			. += "It does not require any more components."

/obj/machinery/constructable_frame/machine/proc/update_namelist()
	if(!req_components)
		to_chat(world, "namelist works(?)")
		return

	req_component_names = new()
	for(var/tname in req_components)
		if(ispath(tname, /obj/item/stack))
			var/obj/item/stack/S = tname
			var/singular_name = initial(S.singular_name)
			if(singular_name)
				req_component_names[tname] = singular_name
			else
				req_component_names[tname] = initial(S.name)
		else
			var/obj/O = tname
			req_component_names[tname] = initial(O.name)
		to_chat(world, "var/tname works")

/obj/machinery/constructable_frame/machine/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
		to_chat(world, "amt thing works")
	return amt
/*
/obj/machinery/constructable_frame/machine/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(1)
			if(istype(P, /obj/item/circuitboard/machine))
				to_chat(user, "<span class='warning'>The frame needs wiring first!</span>")
				return
			else if(istype(P, /obj/item/circuitboard))
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(iscablecoil(P))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five lengths of cable to add them to the frame.</span>")
					return

				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] starts adding cables to [src].</span>",
				"<span class='notice'>You start adding cables to [src].</span>")
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || state != 1 || QDELETED(C))
					return

				if(!C.use(5))
					return

				user.visible_message("<span class='notice'>[user] adds cables to [src].</span>",
				"<span class='notice'>You add cables to [src].</span>")
				state = 2
				icon_state = "box_1"
				return

			if(P.tool_behaviour == TOOL_SCREWDRIVER && !anchored)
				user.visible_message("<span class='warning'>[user] disassembles the frame.</span>", \
									"<span class='notice'>You start to disassemble the frame...</span>", "<span class='hear'>You hear banging and clanking.</span>")
				if(P.use_tool(src, user, 40, volume=50))
					if(state == 1)
						to_chat(user, "<span class='notice'>You disassemble the frame.</span>")
						var/obj/item/stack/sheet/metal/M = new (loc, 5)
						M.add_fingerprint(user)
						qdel(src)
				return
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				if(P.use_tool(src, user, 40, volume=75))
					if(state == 1)
						to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
						setAnchored(!anchored)
				return

		if(2)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				if(P.use_tool(src, user, 40, volume=75))
					to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
					setAnchored(!anchored)
				return

			if(istype(P, /obj/item/circuitboard/machine))
				var/obj/item/circuitboard/machine/B = P
				if(!anchored)
					to_chat(user, "<span class='warning'>The frame needs to be secured first!</span>")
					return
				if(!user.transferItemToLoc(B, src))
					return
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
				circuit = B
				icon_state = "box_2"
				state = 3
				components = list()
				req_components = B.req_components.Copy()
					to_chat(world, "components copied")
				update_namelist()
				return

			else if(istype(P, /obj/item/circuitboard))
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return

			if(P.tool_behaviour == TOOL_WIRECUTTER)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				new /obj/item/stack/cable_coil(drop_location(), 5)
				return

		if(3)
			if(P.tool_behaviour == TOOL_CROWBAR)
				P.play_tool_sound(src)
				state = 2
				circuit.forceMove(drop_location())
				components.Remove(circuit)
				circuit = null
				if(components.len == 0)
					to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				else
					to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
					for(var/atom/movable/AM in components)
						AM.forceMove(drop_location())
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"
				return

			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				if(P.use_tool(src, user, 40, volume=75))
					to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
					setAnchored(!anchored)
				return

			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					P.play_tool_sound(src)
					var/obj/machinery/new_machine = new circuit.build_path(loc)
					new_machine.setAnchored(anchored)
					new_machine.on_construction()
					for(var/obj/O in new_machine.component_parts)
						qdel(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						O.moveToNullspace()
						new_machine.component_parts += O
					if(new_machine.circuit)
						QDEL_NULL(new_machine.circuit)
					new_machine.circuit = circuit
					circuit.moveToNullspace()
					new_machine.RefreshParts()
					qdel(src)
				return

			if(isitem(P) && get_req_components_amt())
				for(var/I in req_components)
					if(istype(P, I) && (req_components[I] > 0))
						if(istype(P, /obj/item/stack))
							var/obj/item/stack/S = P
							var/used_amt = min(round(S.get_amount()), req_components[I])

							if(used_amt && S.use(used_amt))
								var/obj/item/stack/NS = locate(S.merge_type) in components

								if(!NS)
									NS = new S.merge_type(src, used_amt)
									components += NS
								else
									NS.add(used_amt)

								req_components[I] -= used_amt
								to_chat(user, "<span class='notice'>You add [P] to [src].</span>")
							return
						if(!user.transferItemToLoc(P, src))
							to_chat(world, "Looks important enough to warrant a message")
							break
						to_chat(user, "<span class='notice'>You add [P] to [src].</span>")
						components += P
						req_components[I]--
						return 1
				to_chat(user, "<span class='warning'>You cannot add that to the machine!</span>")
				return 0
	if(user.a_intent == INTENT_HARM)
		return ..()
*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/constructable_frame/machine/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			if(iswrench(I))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
				anchored = TRUE
				state = 1

			else if(iswelder(I))
				var/obj/item/tool/weldingtool/WT = I
				if(!WT.remove_fuel(0, user))
					to_chat(user, "[WT] must be on to complete this task.")
					return

				playsound(loc, 'sound/items/welder.ogg', 25, 1)
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
					return FALSE

				to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
				new /obj/item/stack/sheet/metal(loc, 5)
				qdel(src)
		if(1)
			if(iswrench(I))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					return

				to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
				anchored = FALSE
				state = 0

			else if(iscablecoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five coils of wire to add them to the frame.</span>")
					return
				to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")

				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || state != 1 || !C.use(5))
					return FALSE

				to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
				state = 2
				icon_state = "box_1"

		if(2)
			if(iswirecutter(I))
				playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new(loc)
				A.amount = 5

			else if(!(/obj/item/circuitboard/machine))
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return

			else if(istype(I, /obj/item/circuitboard/machine) && !circuit)
				if(!user.drop_held_item())
					return

				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				icon_state = "box_2"
				var/obj/item/circuitboard/machine/B
				B.forceMove(src)
				circuit = B
				components = list()
				req_components = B.req_components.Copy()
				to_chat(user, "components copied")
				update_namelist()

			else if(isscrewdriver(I) && circuit)
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 3

		if(3)
			if(isscrewdriver(I) && circuit)
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")

			else if(attackby(usr) && circuit)
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 2
				icon_state = "box_1"
				circuit.forceMove(loc)
				circuit = null

			else if(iscrowbar(I))
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				//to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				/*circuit.forceMove(drop_location())
				components.Remove(circuit)
				circuit = null*/
				if(components.len > 0)
					to_chat(user, "<span class='notice'>You remove the components.</span>")
					for(var/atom/movable/AM in components)
						AM.forceMove(drop_location())
					desc = initial(desc)
					req_components = null
					components = null
					return

			else if(isscrewdriver(I))
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You finish [src].</span>")
				var/B = new circuit.build_path(loc)
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					I.play_tool_sound(src)
					/*var/obj/machinery/new_machine = new circuit.build_path(loc)
					new_machine.setAnchored(anchored)
					new_machine.on_construction()*/
					circuit.construct(B)
					/*for(var/obj/O in new_machine.component_parts)
						qdel(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						O.moveToNullspace()
						new_machine.component_parts += O
					if(new_machine.circuit)
						QDEL_NULL(new_machine.circuit)
					new_machine.circuit = circuit
					circuit.moveToNullspace()
					new_machine.RefreshParts()*/
					qdel(src)
				return

			if(isitem(I) && get_req_components_amt())
				for(var/P in req_components)
					if(istype(I, P) && (req_components[P] > 0))
						if(istype(I, /obj/item/stack))
							var/obj/item/stack/S = I
							var/used_amt = min(round(S.get_amount()), req_components[P])

							if(used_amt && S.use(used_amt))
								var/obj/item/stack/NS = locate(S.merge_type) in components

								if(!NS)
									NS = new S.merge_type(src, used_amt)
									components += NS
								else
									NS.add(used_amt)

								req_components[P] -= used_amt
								to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
							return
						if(!user.transferItemToLoc(I, src))
							to_chat(world, "Looks important enough to warrant a message")
							break
						to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
						components += I
						req_components[P]--
						return 1
				to_chat(user, "<span class='warning'>You cannot add that to the machine!</span>")
				return 0
/*
/obj/machinery/constructable_frame/machine/deconstruct(disassembled = TRUE)
	if(!NODECONSTRUCT)
		if(state >= 2)
			new /obj/item/stack/cable_coil(loc , 5)
		for(var/X in components)
			var/obj/item/I = X
			I.forceMove(loc)
	..()*/
