#define EMITTER_DAMAGE_POWER_TRANSFER 450 //used to transfer power to containment field generators

/obj/machinery/power/emitter
	name = "Emitter"
	desc = "It is a heavy duty industrial laser."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	req_access = list(ACCESS_MARINE_ENGINEERING)
	var/id = null

	use_power = 0	//uses powernet power, not APC power
	active_power_usage = 30000	//30 kW laser. I guess that means 30 kJ per shot.

	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/max_burst_delay = 100
	var/min_burst_delay = 20
	var/burst_shots = 3
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0
	var/datum/ammo/energy/emitter/ammo = /datum/ammo/energy/emitter

	New()
		..()
		ammo = GLOB.ammo_list[ammo]
		start_processing()

	Destroy()
		ammo = null
		. = ..()


/obj/machinery/power/emitter/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	setDir(turn(dir, 90))
	return 1

/obj/machinery/power/emitter/Initialize()
	..()
	if(state == 2 && anchored)
		connect_to_network()
		src.directwired = 1

/obj/machinery/power/emitter/Destroy()
	log_game("Emitter deleted at [AREACOORD(src.loc)].")
	message_admins("Emitter deleted at [ADMIN_VERBOSEJMP(src.loc)].")
	. = ..()

/obj/machinery/power/emitter/update_icon()
	if (active && powernet && avail(active_power_usage))
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"

/obj/machinery/power/emitter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	activate(user)

/obj/machinery/power/emitter/proc/activate(mob/user as mob)
	if(state == 2)
		if(!powernet)
			to_chat(user, "The emitter isn't connected to a wire.")
			return 1
		if(!src.locked)
			if(src.active==1)
				src.active = 0
				to_chat(user, "You turn off the [src].")
				message_admins("Emitter turned off by [ADMIN_TPMONTY(user)].")
				log_game("Emitter turned off by [key_name(user)] in [AREACOORD(user.loc)].")
			else
				src.active = 1
				to_chat(user, "You turn on the [src].")
				src.shot_number = 0
				src.fire_delay = 100
				message_admins("Emitter turned on by [ADMIN_TPMONTY(usr)].")
				log_game("Emitter turned on by [key_name(user)] in [AREACOORD(user.loc)].")
			update_icon()
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
	else
		to_chat(user, "<span class='warning'>The [src] needs to be firmly secured to the floor first.</span>")
		return 1


/obj/machinery/power/emitter/emp_act(var/severity)//Emitters are hardened but still might have issues
	return 1

/obj/machinery/power/emitter/process()
	if(stat & BROKEN) return

	if(state != 2 || (!powernet && active_power_usage))
		active = 0
		update_icon()
		return
	if((last_shot + fire_delay <= world.time) && (active == 1))

		if(surplus() >= active_power_usage && add_load(active_power_usage) >= active_power_usage) //does the laser have enough power to shoot?
			if(!powered)
				powered = 1
				update_icon()
		else
			if(powered)
				powered = 0
				update_icon()
			return

		last_shot = world.time
		if(shot_number < burst_shots)
			fire_delay = 2
			shot_number ++
		else
			fire_delay = rand(min_burst_delay, max_burst_delay)
			shot_number = 0

		//need to calculate the power per shot as the emitter doesn't fire continuously.
		var/burst_time = (min_burst_delay + max_burst_delay)/2 + 2*(burst_shots-1)
		var/power_per_shot = active_power_usage * (burst_time/10) / burst_shots
		var/obj/item/projectile/A = new /obj/item/projectile(loc)
		A.generate_bullet(ammo, round(power_per_shot/EMITTER_DAMAGE_POWER_TRANSFER))

		playsound(src.loc, 'sound/weapons/emitter.ogg', 25, 1)
		var/turf/T = get_turf(src)

		var/turf/target
		switch(dir)
			if(NORTH) 	target = locate(T.x,T.y+3,T.z)
			if(EAST) 	target = locate(T.x+3,T.y,T.z)
			if(SOUTH) 	target = locate(T.x,T.y-3,T.z)
			if(WEST) 	target = locate(T.x-3,T.y,T.z)
			else 		target = locate(T.x,T.y+3,T.z)

		if(!target) //Off the edge of the map somehow.
			qdel(A)
			return

		A.fire_at(target,src,src,A.ammo.max_range,A.ammo.shell_speed) //Range, speed. Emitter shots are slow.

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)

	if(iswrench(W))
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				to_chat(user, "<span class='warning'>The [src.name] needs to be unwelded from the floor.</span>")
		return

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				to_chat(user, "<span class='warning'>The [src.name] needs to be wrenched to the floor.</span>")
			if(1)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"You start to weld the [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20, TRUE, 5, BUSY_ICON_BUILD))
						if(!src || !WT.isOn()) return
						state = 2
						to_chat(user, "You weld the [src] to the floor.")
						connect_to_network()
						src.directwired = 1
				else
					to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			if(2)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"You start to cut the [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20, TRUE, 5, BUSY_ICON_BUILD))
						if(!src || !WT.isOn()) return
						state = 1
						to_chat(user, "You cut the [src] free from the floor.")
						disconnect_from_network()
						src.directwired = 0
				else
					to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
		return

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock seems to be broken</span>")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when the [src] is online</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return


	if(istype(W, /obj/item/card/emag) && !emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags the [src.name].","<span class='warning'> You short out the lock.</span>")
		return

	..()
	return
