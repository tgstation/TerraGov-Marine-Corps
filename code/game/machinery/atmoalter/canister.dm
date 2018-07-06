/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/machines/atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0
	flags_atom = FPRINT|CONDUCT

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/canister_color = "yellow"
	var/can_label = 1
	var/filled = 0.5
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""
	var/update_flag = 0

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	canister_color = "red"
	can_label = 0
	gas_type = GAS_TYPE_NITROGEN

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
	can_label = 0
	gas_type = GAS_TYPE_OXYGEN

/obj/machinery/portable_atmospherics/canister/phoron
	name = "Canister \[Phoron\]"
	icon_state = "orange"
	canister_color = "orange"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	canister_color = "grey"
	can_label = 0
	gas_type = GAS_TYPE_AIR

/obj/machinery/portable_atmospherics/canister/air/airlock
	filled = 0.05

/obj/machinery/portable_atmospherics/canister/empty/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"

/obj/machinery/portable_atmospherics/canister/empty/phoron
	name = "Canister \[Phoron\]"
	icon_state = "orange"
	canister_color = "orange"

/obj/machinery/portable_atmospherics/canister/proc/check_change()
	var/old_flag = update_flag
	update_flag = 0

	if(connected_port)
		update_flag |= 2

	if(pressure < 10)
		update_flag |= 4
	else if(pressure < ONE_ATMOSPHERE)
		update_flag |= 8
	else if(pressure < 15*ONE_ATMOSPHERE)
		update_flag |= 16
	else
		update_flag |= 32

	if(update_flag == old_flag)
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/canister/update_icon()
/*
update_flag
2 = connected_port
4 = tank_pressure < 10
8 = tank_pressure < ONE_ATMOS
16 = tank_pressure < 15*ONE_ATMOS
32 = tank_pressure go boom.
*/

	if (src.destroyed)
		src.overlays = 0
		src.icon_state = text("[]-1", src.canister_color)
		return

	if(icon_state != "[canister_color]")
		icon_state = "[canister_color]"

	if(check_change()) //Returns 1 if no change needed to icons.
		return

	src.overlays = 0

	if(update_flag & 1)
		overlays += "can-open"
	if(update_flag & 2)
		overlays += "can-connector"
	if(update_flag & 4)
		overlays += "can-o0"
	if(update_flag & 8)
		overlays += "can-o1"
	else if(update_flag & 16)
		overlays += "can-o2"
	else if(update_flag & 32)
		overlays += "can-o3"
	return

/obj/machinery/portable_atmospherics/canister/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		src.destroyed = 1
		playsound(src.loc, 'sound/effects/spray.ogg', 25, 1, 5)
		src.density = 0
		update_icon()

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
		return

	..()

	if(pressure < 1)
		can_label = 1
	else
		can_label = 0


/obj/machinery/portable_atmospherics/canister/return_air()
	return list(gas_type, temperature, pressure)

/obj/machinery/portable_atmospherics/canister/return_temperature()
	return temperature

/obj/machinery/portable_atmospherics/canister/return_pressure()
	return pressure

/obj/machinery/portable_atmospherics/canister/return_gas()
	return gas_type

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.ammo.damage)
		src.health -= round(Proj.ammo.damage / 2)
		healthcheck()
	..()
	return 1

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(!istype(W, /obj/item/tool/wrench) && !istype(W, /obj/item/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		visible_message("\red [user] hits the [src] with a [W]!")
		src.health -= W.force
		src.add_fingerprint(user)
		healthcheck()

	else if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/tank/jetpack))
		var/obj/item/tank/jetpack/JT = W
		if(pressure > JT.pressure_full)
			JT.gas_type = gas_type
			JT.pressure = JT.pressure_full
			pressure -= 10
			user << "You pulse-pressurize your jetpack from [src]."
		return

	else if(istype(W, /obj/item/tank))
		var/obj/item/tank/TAK = W
		if(pressure > TAK.pressure_full)
			TAK.gas_type = gas_type
			TAK.pressure = TAK.pressure_full
			pressure -= 10
			user << "You pulse-pressurize [TAK] from [src]."
		return

	..()

	nanomanager.update_uis(src) // Update all NanoUIs attached to src

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	return src.ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if (src.destroyed)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["canLabel"] = can_label ? 1 : 0
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(pressure)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["minReleasePressure"] = round(ONE_ATMOSPHERE/10)
	data["maxReleasePressure"] = round(10*ONE_ATMOSPHERE)
	data["valveOpen"] = valve_open ? 1 : 0

	data["hasHoldingTank"] = 0

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "canister.tmpl", "Canister", 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)

	//Do not use "if(..()) return" here, canisters will stop working in unpowered areas like space or on the derelict. // yeah but without SOME sort of Topic check any dick can mess with them via exploits as he pleases -walter0o
	if (!istype(src.loc, /turf))
		return 0

	if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !in_range(loc, usr)) // exploit protection -walter0o
		usr << browse(null, "window=canister")
		onclose(usr, "canister")
		return

	if(href_list["toggle"])
		if (valve_open)
			release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the <font color='red'><b>air</b></font><br>"
		else
			release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the <font color='red'><b>air</b></font><br>"
		valve_open = !valve_open

	if (href_list["pressure_adj"])
		var/diff = text2num(href_list["pressure_adj"])
		if(diff > 0)
			release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
		else
			release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

	if (href_list["relabel"])
		if (can_label)
			var/list/colors = list(\
				"\[N2O\]" = "redws", \
				"\[N2\]" = "red", \
				"\[O2\]" = "blue", \
				"\[Toxin (Bio)\]" = "orange", \
				"\[CO2\]" = "black", \
				"\[Air\]" = "grey", \
				"\[CAUTION\]" = "yellow", \
			)
			var/label = input("Choose canister label", "Gas canister") as null|anything in colors
			if (label)
				src.canister_color = colors[label]
				src.icon_state = colors[label]
				src.name = "Canister: [label]"

	src.add_fingerprint(usr)
	update_icon()

	return 1

/obj/machinery/portable_atmospherics/canister/phoron/New()
	..()
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()
	..()
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()
	..()
	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/nitrogen/New()
	..()
	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()
	..()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()
	..()
	src.update_icon()
	return 1
