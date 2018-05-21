datum/controller/process/atmospherics

datum/controller/process/atmospherics/setup()
	name = "Atmospherics"
	schedule_interval = 25 // 2.5 seconds

	world << "\red \b Initializing pipe networks"
	sleep(-1)
	for (var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	world << "\red \b Initializing atmos machinery."
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