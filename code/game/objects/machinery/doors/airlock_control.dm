#define AIRLOCK_CONTROL_RANGE 22

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	var/id_tag
	var/frequency
	var/shockedby = list()
	var/datum/radio_frequency/radio_connection
	var/cur_command = null	//the command the door is currently attempting to complete

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	if(frequency)
		set_frequency(frequency)

	wires = new /datum/wires/airlock(src)

	if(closeOtherId != null)
		for(var/obj/machinery/door/airlock/A in GLOB.machines)
			if(A.closeOtherId == src.closeOtherId && A != src)
				src.closeOther = A
				break

	update_icon()

/obj/machinery/door/airlock/Destroy()
	SSradio.remove_object(src, frequency)
	radio_connection?.devices -= src
	radio_connection = null
	return ..()

/obj/machinery/door/airlock/proc/can_radio()
	return hasPower()

/obj/machinery/door/airlock/receive_signal(datum/signal/signal)
	if(!hasPower())
		return

	if (!can_radio()) return //no radio

	if(!signal)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"]) return

	cur_command = signal.data["command"]
	INVOKE_ASYNC(src, PROC_REF(execute_current_command))

/obj/machinery/door/airlock/proc/execute_current_command()
	if(operating)
		return

	if (!cur_command)
		return

	do_command(cur_command)
	if (command_completed(cur_command))
		cur_command = null

/obj/machinery/door/airlock/proc/do_command(command)
	switch(command)
		if("open")
			open()

		if("close")
			close()

		if("unlock")
			unlock()

		if("lock")
			lock()

		if("secure_open")
			unlock()

			sleep(0.2 SECONDS)
			open()

			lock()

		if("secure_close")
			unlock()
			close()

			lock()
			sleep(0.2 SECONDS)

	send_status()

/obj/machinery/door/airlock/proc/command_completed(command)
	switch(command)
		if("open")
			return (!density)

		if("close")
			return density

		if("unlock")
			return !locked

		if("lock")
			return locked

		if("secure_open")
			return (locked && !density)

		if("secure_close")
			return (locked && density)

	return 1	//Unknown command. Just assume it's completed.

/obj/machinery/door/airlock/proc/send_status(bumped = FALSE)
	if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		signal.data["door_status"] = density?("closed"):("open")
		signal.data["lock_status"] = locked?("locked"):("unlocked")

		if (bumped)
			signal.data["bumped_with_access"] = 1

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

/obj/machinery/door/airlock/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	if(new_frequency)
		frequency = new_frequency
		radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "access button"

	anchored = TRUE
	power_channel = ENVIRON

	var/master_tag
	var/frequency = 1449
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1


/obj/machinery/access_button/update_icon_state()
	if(on)
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"

/obj/machinery/access_button/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/id))
		attack_hand(user)

/obj/machinery/access_button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		to_chat(user, span_warning("Access Denied"))

	else if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	flick("access_button_cycle", src)


/obj/machinery/access_button/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)


/obj/machinery/access_button/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/machinery/access_button/Destroy()
	SSradio.remove_object(src, frequency)
	radio_connection?.devices -= src
	radio_connection = null
	return ..()

/obj/machinery/access_button/airlock_interior
	frequency = 1379
	command = "cycle_interior"

/obj/machinery/access_button/airlock_exterior
	frequency = 1379
	command = "cycle_exterior"
