/obj/machinery/portable_atmospherics/powered/pump
	name = "portable air pump"

	icon = 'icons/obj/machines/atmos.dmi'
	icon_state = "psiphon:0"
	density = 1

	var/on = 0
	var/direction_out = 0 //0 = siphoning, 1 = releasing
	var/target_pressure = 100

	volume = 1000

	power_rating = 750 //7500 W ~ 10 HP
	power_losses = 150

/obj/machinery/portable_atmospherics/powered/pump/New()
	..()
	cell = new/obj/item/cell(src)

/obj/machinery/portable_atmospherics/powered/pump/update_icon()
	src.overlays = 0

	if(on && cell && cell.charge)
		icon_state = "psiphon:1"
	else
		icon_state = "psiphon:0"

	if(connected_port)
		overlays += "siphon-connector"

	return

/obj/machinery/portable_atmospherics/powered/pump/CanPass(atom/movable/mover, turf/target)
	if(density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/powered/pump/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on

	if(prob(100/severity))
		direction_out = !direction_out

	target_pressure = rand(0,1300)
	update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/powered/pump/process()
	return

/obj/machinery/portable_atmospherics/powered/pump/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/powered/pump/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/powered/pump/attack_hand(var/mob/user as mob)

	user.set_interaction(src)

	var/output_text = {"<TT><B>[capitalize(name)]</B><BR>
Pressure: [round(pressure, 0.01)] kPa<BR>
Flow Rate: [round(last_flow_rate, 0.1)] L/s<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]<BR>
<BR>
Cell Charge: [cell? "[round(cell.percent())]%" : "N/A"]|Load: [round(last_power_draw)] W<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Pump Direction: <A href='?src=\ref[src];direction=1'>[direction_out?("Out"):("In")]</A><BR>
Target Pressure: <A href='?src=\ref[src];pressure_adj=-1000'>-</A> <A href='?src=\ref[src];pressure_adj=-100'>-</A> <A href='?src=\ref[src];pressure_adj=-10'>-</A> <A href='?src=\ref[src];pressure_adj=-1'>-</A> [target_pressure] kPa<A href='?src=\ref[src];pressure_adj=1'>+</A> <A href='?src=\ref[src];pressure_adj=10'>+</A> <A href='?src=\ref[src];pressure_adj=100'>+</A> <A href='?src=\ref[src];pressure_adj=1000'>+</A><BR>
<HR>
<A href='?src=\ref[user];mach_close=pump'>Close</A><BR>
"}

	user << browse(output_text, "window=pump;size=600x300")
	onclose(user, "pump")

	return

/obj/machinery/portable_atmospherics/powered/pump/Topic(href, href_list)
	..()
	if (usr.stat || usr.is_mob_restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.set_interaction(src)

		if(href_list["power"])
			on = !on

		if(href_list["direction"])
			direction_out = !direction_out

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			target_pressure = min(10*ONE_ATMOSPHERE, max(0, target_pressure+diff))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=pump")
		return
	return