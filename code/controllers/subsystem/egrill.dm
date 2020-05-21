#define SPARK_FACTOR 0.10 // 1 in 10 will spark

SUBSYSTEM_DEF(egrill)
	name = "egrills"
	priority = FIRE_PRIORITY_PROCESS
	flags = SS_NO_INIT
	wait = 50

	var/idle_usage = 10000

	var/list/processing = list()
	var/list/currentrun = list()
	var/sparksleft = 0

/datum/controller/subsystem/egrill/fire(resumed)
	if(!resumed)
		currentrun = processing.Copy()
		sparksleft = round(length(currentrun) * SPARK_FACTOR)
	while(sparksleft && length(currentrun))
		var/obj/O = pick_n_take(currentrun)
		var/turf/T = get_turf(O)
		var/obj/structure/cable/C = T.get_cable_node()
		if(!C)
			continue
		var/datum/powernet/PN = C.powernet
		if(PN.delayedload >= PN.newavail)
			continue
		PN.delayedload += (min(idle_usage, max(PN.newavail - PN.delayedload, 0)))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, O)
		s.start()
		sparksleft--
