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


/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/attackedby, mob/user, params)
	if(attackedby.crit_fail)
		to_chat(user, "<span class='warning'>This part is faulty, you cannot add this to the machine!</span>")
		return

	switch(state)
		if(1)
			if(iscablecoil(attackedby))
				var/obj/item/stack/cable_coil/C = attackedby
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

			if(iswrench(attackedby))
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You dismantle the frame</span>")
				new /obj/item/stack/sheet/metal(loc, 5)
				qdel(src)

		if(2)
			if(istype(attackedby, /obj/item/circuitboard/machine))
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
				var/obj/item/circuitboard/machine/circuit = attackedby
				if(!user.transferItemToLoc(attackedby, src))
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

			if(iswirecutter(attackedby))
				playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(loc)
				A.amount = 5

		if(3)
			if(iscrowbar(attackedby))
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				state = 2
				circuit.forceMove(loc)
				circuit = null
				if(!length(components))
					to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				else
					to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
					for(var/obj/item/W in components)
						W.forceMove(loc)

				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"

			if(isscrewdriver(attackedby))
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
				if(istype(attackedby, text2path(i)) && (req_components[i] > 0))
					playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
					if(iscablecoil(attackedby))
						var/obj/item/stack/cable_coil/CP = attackedby
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
					if(user.transferItemToLoc(attackedby, src))
						components += attackedby
						req_components[i]--
						update_desc()
					break
