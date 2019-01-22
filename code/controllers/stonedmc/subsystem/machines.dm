SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	var/list/currentrunmachines
	var/list/currentrunpowernets
	var/list/currentrunareas

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()

/datum/controller/subsystem/machines/stat_entry()
	..("AA:[active_areas.len]|PN:[powernets.len]|PM:[processing_machines.len]")


/datum/controller/subsystem/machines/fire(resumed = 0)
	if (!resumed)
		currentrunmachines = processing_machines.Copy()
		currentrunpowernets = powernets.Copy()
		currentrunareas = active_areas.Copy()

	while (currentrunmachines.len)
		var/obj/machinery/M = currentrunmachines[currentrunmachines.len]
		currentrunmachines.len--

		if (!M || M.gc_destroyed) // should never happen
			processing_machines -= M
			continue

		M.process()

		if (MC_TICK_CHECK)
			return

	while (currentrunareas.len)
		var/area/A = currentrunareas[currentrunareas.len]
		currentrunareas.len--

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
				if (MC_TICK_CHECK)
					return
				continue

		A.powerupdate = 0

		if (MC_TICK_CHECK)
			return

	while(currentrunpowernets.len)
		var/datum/powernet/Powernet = currentrunpowernets[currentrunpowernets.len]
		currentrunpowernets.len--
		if(Powernet)
			Powernet.process()
		if (MC_TICK_CHECK)
			return
