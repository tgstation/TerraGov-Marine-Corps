/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/machines/computer.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	layer = BELOW_OBJ_LAYER
	idle_power_usage = 300
	active_power_usage = 300
	var/circuit = null //The path to the circuit board type. If circuit==null, the computer can't be disassembled.
	var/processing = 0
	var/exproof = 0

/obj/machinery/computer/Initialize()
	. = ..()
	start_processing()
	power_change()

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	if(exproof)
		return
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		if(3.0)
			if (prob(25))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		else
	return

/obj/machinery/computer/bullet_act(var/obj/item/projectile/Proj)
	if(exproof)
		visible_message("[Proj] ricochets off [src]!")
		return 0
	else
		if(prob(round(Proj.ammo.damage /2)))
			set_broken()
		..()
		return 1

/obj/machinery/computer/update_icon()
	..()
	icon_state = initial(icon_state)
	// Broken
	if(machine_stat & BROKEN)
		icon_state += "b"

	// Powered
	else if(machine_stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"



/obj/machinery/computer/power_change()
	..()
	update_icon()


/obj/machinery/computer/proc/set_broken()
	machine_stat |= BROKEN
	update_icon()

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = oldreplacetext(text, "\n", "<BR>")
	return text


/obj/machinery/computer/attackby(obj/item/I, mob/user)
	if(isscrewdriver(I) && circuit)
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_MT)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to deconstruct [src].</span>",
			"<span class='notice'>You fumble around figuring out how to deconstruct [src].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_MT - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
		if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			var/obj/item/circuitboard/computer/M = new circuit( A )
			A.circuit = M
			A.anchored = 1
			for (var/obj/C in src)
				C.loc = src.loc
			if (src.machine_stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				new /obj/item/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
			M.deconstruct(src)
			qdel(src)
	else
		if(isxeno(user))
			src.attack_alien(user)
			return
		src.attack_hand(user)
	return

/obj/machinery/computer/attack_hand()
	. = ..()
	if(!.) //not broken or unpowered
		if(ishuman(usr))
			pick(playsound(src, 'sound/machines/computer_typing1.ogg', 5, 1), playsound(src, 'sound/machines/computer_typing2.ogg', 5, 1), playsound(src, 'sound/machines/computer_typing3.ogg', 5, 1))
