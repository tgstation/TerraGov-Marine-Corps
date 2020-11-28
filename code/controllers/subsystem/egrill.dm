SUBSYSTEM_DEF(egrill)
	name = "Egrills"
	priority = FIRE_PRIORITY_PROCESS
	flags = SS_NO_INIT
	wait = 20

	var/spark_factor = 10
	var/idle_usage = 10000

	var/list/datum/effect_system/spark_spread/sparks = list()
	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/egrill/fire(resumed)
	if(!resumed)
		currentrun = processing.Copy()
	while(length(currentrun))
		var/obj/O = currentrun[length(currentrun)]
		currentrun.len--
		var/turf/T = get_turf(O)
		var/obj/structure/cable/C = T.get_cable_node()
		if(!C)
			continue
		var/datum/powernet/PN = C.powernet
		if(PN.delayedload >= PN.newavail)
			continue
		PN.delayedload += (min(idle_usage, max(PN.newavail - PN.delayedload, 0)))
		if(prob(spark_factor))
			if(!sparks[O])
				sparks[O] = new /datum/effect_system/spark_spread(O, T, 1, FALSE, TRUE)
			else
				sparks[O].start()
