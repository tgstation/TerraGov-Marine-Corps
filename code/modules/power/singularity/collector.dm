//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33
var/global/list/rad_collectors = list()

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and phoron to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = 0
	density = 1
	directwired = 1
	req_access = list(ACCESS_MARINE_ENGINEERING)
//	use_power = 0
	var/obj/item/tank/phoron/P = null
	var/last_power = 0
	var/last_power_new = 0
	var/active = 0
	var/locked = 0
	var/drainratio = 1

/obj/machinery/power/rad_collector/New()
	..()
	rad_collectors += src
	start_processing()

/obj/machinery/power/rad_collector/Dispose()
	rad_collectors -= src
	. = ..()

/obj/machinery/power/rad_collector/process()
	//so that we don't zero out the meter if the SM is processed first.
	last_power = last_power_new
	last_power_new = 0


	if(P)
		if(P.gas_type != GAS_TYPE_PHORON || P.pressure == 0)
			investigate_log("<font color='red'>out of fuel</font>.","singulo")
			eject()
		else
			P.pressure -= 0.001
	return


/obj/machinery/power/rad_collector/attack_hand(mob/user as mob)
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			"You turn the [src.name] [active? "on":"off"].")
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [P?"Fuel: [round(P.pressure)]kPa":"<font color='red'>It is empty</font>"].","singulo")
			return
		else
			user << "\red The controls are locked!"
			return
	..()


/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tank/phoron))
		if(!src.anchored)
			user << "\red The [src] needs to be secured to the floor first."
			return 1
		if(src.P)
			user << "\red There's already a phoron tank loaded."
			return 1
		if(user.drop_inv_item_to_loc(W, src))
			P = W
			update_icon()
		return 1
	else if(istype(W, /obj/item/tool/crowbar))
		if(P && !src.locked)
			eject()
			return 1
	else if(istype(W, /obj/item/tool/wrench))
		if(P)
			user << "\blue Remove the phoron tank first."
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
		src.anchored = !src.anchored
		user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
			"You [anchored? "secure":"undo"] the external bolts.", \
			"You hear a ratchet")
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		return 1
	else if(istype(W, /obj/item/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			if(active)
				src.locked = !src.locked
				user << "The controls are now [src.locked ? "locked." : "unlocked."]"
			else
				src.locked = 0 //just in case it somehow gets locked
				user << "\red The controls can only be locked when the [src] is active"
		else
			user << "\red Access denied!"
		return 1
	return ..()

/obj/machinery/power/rad_collector/examine(mob/user)
	..()
	if (get_dist(user, src) <= 3)
		user << "The meter indicates that \the [src] is collecting [last_power] W."

/obj/machinery/power/rad_collector/ex_act(severity)
	switch(severity)
		if(2, 3)
			eject()
	return ..()


/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	var/obj/item/tank/phoron/Z = src.P
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	src.P = null
	if(active)
		toggle_power()
	else
		update_icon()

/obj/machinery/power/rad_collector/proc/receive_pulse(var/pulse_strength)
	if(P && active)
		var/power_produced = 0
		power_produced = P.pressure*pulse_strength*20
		add_avail(power_produced)
		last_power_new = power_produced



/obj/machinery/power/rad_collector/update_icon()
	overlays.Cut()
	if(P)
		overlays += image('icons/obj/singularity.dmi', "ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		overlays += image('icons/obj/singularity.dmi', "on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icon()
	return
