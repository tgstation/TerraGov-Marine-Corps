/obj/effect/step_trigger/message
	var/message	//the message to give to the mob
	var/once = 1

/obj/effect/step_trigger/message/Trigger(mob/M as mob)
	if(M.client)
		M << "<span class='info'>[message]</span>"
		if(once)
			cdel(src)

/obj/effect/step_trigger/teleport_fancy
	var/locationx
	var/locationy
	var/uses = 1	//0 for infinite uses
	var/entersparks = 0
	var/exitsparks = 0
	var/entersmoke = 0
	var/exitsmoke = 0

/obj/effect/step_trigger/teleport_fancy/Trigger(mob/M as mob)
	var/dest = locate(locationx, locationy, z)
	if(!M || !istype(M))
		return

	M.Move(dest)

	if(entersparks)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(4, 1, src)
		s.start()
	if(exitsparks)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(4, 1, dest)
		s.start()

	if(entersmoke)
		var/datum/effect_system/smoke_spread/s = new /datum/effect_system/smoke_spread
		s.set_up(2, 1, src, 0)
		s.start()
	if(exitsmoke)
		var/datum/effect_system/smoke_spread/s = new /datum/effect_system/smoke_spread
		s.set_up(2, 1, dest, 0)
		s.start()

	uses--
	if(uses == 0)
		cdel(src)