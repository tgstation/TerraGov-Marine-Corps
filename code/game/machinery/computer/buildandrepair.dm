//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/computerframe
	density = 0
	anchored = 0
	name = "Computer-frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/circuitboard/computer/circuit = null
//	weight = 1.0E8

/obj/structure/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/tool/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					user << "\blue You wrench the frame into place."
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/tool/weldingtool))
				var/obj/item/tool/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					user << "[WT] must be on to complete this task."
					return
				playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					if(!src || !WT.isOn()) return
					user << "\blue You deconstruct the frame."
					new /obj/item/stack/sheet/metal( src.loc, 5 )
					cdel(src)
		if(1)
			if(istype(P, /obj/item/tool/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					user << "\blue You unfasten the frame."
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/circuitboard/computer) && !circuit)
				if(user.drop_held_item())
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
					user << "\blue You place the circuit board inside the frame."
					icon_state = "1"
					circuit = P
					P.forceMove(src)

			if(istype(P, /obj/item/tool/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user << "\blue You screw the circuit board into place."
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/tool/crowbar) && circuit)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
				user << "\blue You remove the circuit board."
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(istype(P, /obj/item/tool/screwdriver) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user << "\blue You unfasten the circuit board."
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if (C.get_amount() < 5)
					user << "<span class='warning'>You need five coils of wire to add them to the frame.</span>"
					return
				user << "<span class='notice'>You start to add cables to the frame.</span>"
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD) && state == 2)
					if (C.use(5))
						user << "<span class='notice'>You add cables to the frame.</span>"
						state = 3
						icon_state = "3"
		if(3)
			if(istype(P, /obj/item/tool/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
				user << "\blue You remove the cables."
				src.state = 2
				src.icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if (G.get_amount() < 2)
					user << "<span class='warning'>You need two sheets of glass to put in the glass panel.</span>"
					return
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
				user << "<span class='notice'>You start to put in the glass panel.</span>"
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD) && state == 3)
					if (G.use(2))
						user << "<span class='notice'>You put in the glass panel.</span>"
						src.state = 4
						src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/tool/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
				user << "\blue You remove the glass panel."
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(istype(P, /obj/item/tool/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user << "\blue You connect the monitor."
				var/B = new src.circuit.build_path ( src.loc )
				src.circuit.construct(B)
				cdel(src)
