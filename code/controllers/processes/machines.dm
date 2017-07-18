/var/global/machinery_sort_required = 0

datum/controller/process/machines

datum/controller/process/machines/setup()
	name = "Machines"
	schedule_interval = 33 //3.3 seconds

datum/controller/process/machines/doWork()
	process_machines_sort()
	process_machines_process()
	process_machines_power()

datum/controller/process/machines/proc/process_machines_sort()
	if(machinery_sort_required)
		machinery_sort_required = 0
		machines = dd_sortedObjectList(machines)

datum/controller/process/machines/proc/process_machines_process()
	for(var/obj/machinery/M in machines)
		if(istype(M) && M.process() != PROCESS_KILL) //Doesn't actually have a process, just remove it.
			continue
		machines.Remove(M)

datum/controller/process/machines/proc/process_machines_power()
	// O(n^3) complexity. No wonder this is slower than shit. TODO: Get rid of one of these loops somehow. ~Bmc777
	var/i=1
	while(i<=active_areas.len)
		var/area/A = active_areas[i]
		if(A.powerupdate && A.master == A)
			A.powerupdate -= 1
			A.clear_usage()
			for(var/j = 1; j <= A.related.len; j++)
				var/area/SubArea = A.related[j]
				for(var/obj/machinery/M in SubArea)
					if(M)
						//check if the area has power for M's channel
						//this will keep stat updated in case the machine is moved from one area to another.
						M.power_change(A)	//we've already made sure A is a master area, above.

						if(!(M.stat & NOPOWER) && M.use_power)
							M.auto_use_power()

		if(A.apc.len && A.master == A)
			i++
			continue

		A.powerupdate = 0
		active_areas.Cut(i,i+1)