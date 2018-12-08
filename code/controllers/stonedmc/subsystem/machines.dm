SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()

// CM codebase has a global proc for this.
/*/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in GLOB.cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)*/

/datum/controller/subsystem/machines/stat_entry()
	..("M:[processing.len]|PN:[powernets.len]|PM:[processing_machines.len]")


/datum/controller/subsystem/machines/fire(resumed = 0)
	for(var/obj/machinery/M in processing_machines)
		if(istype(M) && M.process())// != PROCESS_KILL) //Doesn't actually have a process, just remove it.
			continue

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

	i = 1
	while(i<=powernets.len)
		var/datum/powernet/Powernet = powernets[i]
		if(Powernet)
			Powernet.process()
			i++
			continue
		powernets.Cut(i,i+1)
