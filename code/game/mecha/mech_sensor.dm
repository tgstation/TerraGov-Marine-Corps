/obj/machinery/mech_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "mechatronic sensor"
	desc = "Regulates mech movement."
	anchored = 1
	density = 1
	throwpass = 1
	use_power = 1
	layer = 3.3
	power_channel = EQUIP
	var/on = 0
	var/id_tag = null

	var/frequency = 1379
	var/datum/radio_frequency/radio_connection

/obj/machinery/mech_sensor/CanPass(atom/movable/mover, turf/target)
	if(!enabled()) return 1

	if((get_dir(loc, target) & dir) && is_blocked(mover))
		give_feedback(mover)
		return 0
	return 1

/obj/machinery/mech_sensor/proc/is_blocked(O as obj)
	if(istype(O, /obj/mecha/medical/odysseus))
		var/obj/mecha/medical/odysseus/M = O
		for(var/obj/item/mecha_parts/mecha_equipment/ME in M.equipment)
			if(istype(ME, /obj/item/mecha_parts/mecha_equipment/tool/sleeper))
				var/obj/item/mecha_parts/mecha_equipment/tool/sleeper/S = ME
				if(S.occupant != null)
					return 0

	return istype(O, /obj/mecha) || istype(O, /obj/vehicle)

/obj/machinery/mech_sensor/proc/give_feedback(O as obj)
	var/block_message = "<span class='warning'>Movement control overridden. Area denial active.</span>"
	var/feedback_timer = 0
	if(feedback_timer)
		return

	if(istype(O, /obj/mecha))
		var/obj/mecha/R = O
		if(R && R.occupant)
			to_chat(R.occupant, block_message)

	feedback_timer = 1
	spawn(50) //Without this timer the feedback becomes horribly spamy
		feedback_timer = 0

/obj/machinery/mech_sensor/proc/enabled()
	return on && !(machine_stat & NOPOWER)

/obj/machinery/mech_sensor/power_change()
	var/old_stat = machine_stat
	..()
	if(old_stat != machine_stat)
		update_icon()

/obj/machinery/mech_sensor/update_icon(var/safety = 0)
	if (enabled())
		icon_state = "airlock_sensor_standby"
	else
		icon_state = "airlock_sensor_off"

/obj/machinery/mech_sensor/Initialize()
	. = ..()
	set_frequency(frequency)

/obj/machinery/mech_sensor/proc/set_frequency(new_frequency)
	if(radio_connection)
		SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency)

/obj/machinery/mech_sensor/receive_signal(datum/signal/signal)
	if(machine_stat & NOPOWER)
		return

	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return

	if(signal.data["command"] == "enable")
		on = 1
	else if (signal.data["command"] == "disable")
		on = 0

	update_icon()
