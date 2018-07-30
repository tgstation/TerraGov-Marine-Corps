//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 0
	anchored = 1
	use_power = 0
	var/obj/item/circuitboard/machine/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null
	var/state = 1

	proc/update_desc()
		var/D
		if(req_components)
			D = "Requires "
			var/first = 1
			for(var/I in req_components)
				if(req_components[I] > 0)
					D += "[first?"":", "][num2text(req_components[I])] [req_component_names[I]]"
					first = 0
			if(first) // nothing needs to be added, then
				D += "nothing"
			D += "."
		desc = D

/obj/machinery/constructable_frame/machine_frame
	attackby(obj/item/P as obj, mob/user as mob)
		if(P.crit_fail)
			user << "\red This part is faulty, you cannot add this to the machine!"
			return
		switch(state)
			if(1)
				if(iscoil(P))
					var/obj/item/stack/cable_coil/C = P
					if(C.get_amount() < 5)
						user << "<span class='warning'>You need five lengths of cable to add them to the frame.</span>"
						return
					playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] starts adding cables to [src].</span>",
					"<span class='notice'>You start adding cables to [src].</span>")
					if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD) && state == 1)
						if(C && istype(C) && C.use(5))
							user.visible_message("<span class='notice'>[user] adds cables to [src].</span>",
							"<span class='notice'>You add cables to [src].</span>")
							state = 2
							icon_state = "box_1"
				else
					if(iswrench(P))
						playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
						user << "\blue You dismantle the frame"
						new /obj/item/stack/sheet/metal(src.loc, 5)
						cdel(src)
			if(2)
				if(istype(P, /obj/item/circuitboard/machine))
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
					user << "\blue You add the circuit board to the frame."
					circuit = P
					if(user.drop_inv_item_to_loc(P, src))
						icon_state = "box_2"
						state = 3
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						req_component_names = circuit.req_components.Copy()
						for(var/A in req_components)
							var/cp = text2path(A)
							var/obj/ct = new cp() // have to quickly instantiate it get name
							req_component_names[A] = ct.name
						if(circuit.frame_desc)
							desc = circuit.frame_desc
						else
							update_desc()
						user << desc

				else
					if(istype(P, /obj/item/tool/wirecutters))
						playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
						user << "\blue You remove the cables."
						state = 1
						icon_state = "box_0"
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
						A.amount = 5

			if(3)
				if(istype(P, /obj/item/tool/crowbar))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					state = 2
					circuit.loc = src.loc
					circuit = null
					if(components.len == 0)
						user << "\blue You remove the circuit board."
					else
						user << "\blue You remove the circuit board and other components."
						for(var/obj/item/W in components)
							W.loc = src.loc
					desc = initial(desc)
					req_components = null
					components = null
					icon_state = "box_1"
				else
					if(istype(P, /obj/item/tool/screwdriver))
						var/component_check = 1
						for(var/R in req_components)
							if(req_components[R] > 0)
								component_check = 0
								break
						if(component_check)
							playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
							var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
							new_machine.component_parts.Cut()
							src.circuit.construct(new_machine)
							for(var/obj/O in src)
								O.loc = new_machine
								new_machine.component_parts += O
							circuit.loc = new_machine
							new_machine.RefreshParts()
							cdel(src)
					else
						if(istype(P, /obj/item))
							for(var/I in req_components)
								if(istype(P, text2path(I)) && (req_components[I] > 0))
									playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
									if(istype(P, /obj/item/stack/cable_coil))
										var/obj/item/stack/cable_coil/CP = P
										if(CP.get_amount() > 1)
											var/camt = min(CP.amount, req_components[I]) // amount of cable to take, idealy amount required, but limited by amount provided
											var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(src)
											CC.amount = camt
											CC.update_icon()
											CP.use(camt)
											components += CC
											req_components[I] -= camt
											update_desc()
											break
									if(user.drop_inv_item_to_loc(P, src))
										components += P
										req_components[I]--
										update_desc()
									break
							user << desc
							if(P && P.loc != src && !istype(P, /obj/item/stack/cable_coil))
								user << "\red You cannot add that component to the machine!"

