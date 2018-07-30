
datum/controller/process/machines

datum/controller/process/machines/setup()
	name = "Machines"
	schedule_interval = 35 //3.5 seconds

datum/controller/process/machines/doWork()
	process_machines_process()
	process_machines_power()
	process_powernet()

datum/controller/process/machines/proc/process_machines_process()
	for(var/obj/machinery/M in processing_machines)
		if(istype(M) && M.process())// != PROCESS_KILL) //Doesn't actually have a process, just remove it.
			continue


datum/controller/process/machines/proc/process_machines_power()
	// O(n^3) complexity. No wonder this is slower than shit. TODO: Get rid of one of these loops somehow. ~Bmc777
	var/i=1
	while(i<=active_areas.len)
		var/area/A = active_areas[i]
		if(A.master == A)
			if(A.powerupdate)
				A.powerupdate -= 1
				A.clear_usage()
				for(var/obj/machinery/M in A.area_machines) // should take it to O(n^2) and hopefully less expensive.
					if(M)
						//check if the area has power for M's channel
						//this will keep stat updated in case the machine is moved from one area to another.
						M.power_change(A)	//we've already made sure A is a master area, above.

						if(!(M.stat & NOPOWER) && M.use_power)
							M.auto_use_power()

			if(A.apc.len)
				i++
				continue

		A.powerupdate = 0
		active_areas.Cut(i,i+1)


///powernets are processed with machines so we're sure power generating machines
// and powernets are processed together in sync.
datum/controller/process/machines/proc/process_powernet()
	var/i = 1
	while(i<=powernets.len)
		var/datum/powernet/Powernet = powernets[i]
		if(Powernet)
			Powernet.process()
			i++
			continue
		powernets.Cut(i,i+1)
