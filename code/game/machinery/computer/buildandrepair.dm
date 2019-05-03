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
			if(iswrench(P))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					src.anchored = 1
					src.state = 1
			if(iswelder(P))
				var/obj/item/tool/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					to_chat(user, "[WT] must be on to complete this task.")
					return
				playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
					return FALSE
				to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
				new /obj/item/stack/sheet/metal( src.loc, 5 )
				qdel(src)
		if(1)
			if(iswrench(P))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/circuitboard/computer) && !circuit)
				if(user.drop_held_item())
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					icon_state = "1"
					circuit = P
					P.forceMove(src)

			if(isscrewdriver(P) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				src.state = 2
				src.icon_state = "2"
			if(iscrowbar(P) && circuit)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(isscrewdriver(P) && circuit)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				src.state = 1
				src.icon_state = "1"
			if(iscablecoil(P))
				var/obj/item/stack/cable_coil/C = P
				if (C.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five coils of wire to add them to the frame.</span>")
					return
				to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || state != 2 || !C.use(5))
					return FALSE
				to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
				state = 3
				icon_state = "3"
		if(3)
			if(iswirecutter(P))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				src.state = 2
				src.icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if (G.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of glass to put in the glass panel.</span>")
					return
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You start to put in the glass panel.</span>")
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || state != 3 || !G.use(2))
					return FALSE
				to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
				state = 4
				icon_state = "4"
		if(4)
			if(iscrowbar(P))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(isscrewdriver(P))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new src.circuit.build_path ( src.loc )
				src.circuit.construct(B)
				qdel(src)
