datum/controller/process/atmospherics

datum/controller/process/atmospherics/setup()
	name = "Atmospherics"
	schedule_interval = 25 // 2.5 seconds

	to_chat(world, "<span class='danger'>Initializing pipe networks</span>")
	sleep(-1)
	for (var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	to_chat(world, "<span class='danger'>Initializing atmos machinery.</span>")
	sleep(-1)
	for (var/obj/machinery/atmospherics/unary/U in machines)
		if (istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()

		else if (istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

datum/controller/process/atmospherics/doWork()
	return