///var/global/machinery_sort_required = 0

datum/controller/process/machines

datum/controller/process/machines/setup()
	name = "Machines"
	schedule_interval = 33 //3.3 seconds

/*
datum/controller/process/machines/doWork()
	process_machines_sort()
	process_machines_process()
	process_machines_power()

datum/controller/process/machines/proc/process_machines_sort()
	if (machinery_sort_required)
		machines = dd_sortedObjectList(machines)
		machinery_sort_required = 0

datum/controller/process/machines/proc/process_machines_process()
	for (var/obj/machinery/M in machines)
		if (M.process() != PROCESS_KILL) //Doesn't actually have a process, just remove it.
			continue

		machines.Remove(M)

datum/controller/process/machines/proc/process_machines_power()
	// O(n^3) complexity. No wonder this is slower than shit. TODO: Get rid of one of these loops somehow. ~Bmc777
	for (var/area/A in active_areas)
		if (A.powerupdate && A.master == A)
			A.powerupdate -= 1
			A.clear_usage()

			// Condense these loops in the future. ~Bmc777
			for (var/area/SubArea in A.related)
				for (var/obj/machinery/M in SubArea)
					//check if the area has power for M's channel
					//this will keep stat updated in case the machine is moved from one area to another.
					M.power_change(A)	//we've already made sure A is a master area, above.

					if(!(M.stat & NOPOWER) && M.use_power)
						M.auto_use_power()

		if (A.apc.len && A.master == A)
			continue

		A.powerupdate = 0*/