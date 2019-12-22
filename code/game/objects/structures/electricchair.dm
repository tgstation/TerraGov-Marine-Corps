/obj/structure/bed/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair1"
	var/last_time = 1.0

/obj/structure/bed/chair/e_chair/Initialize()
	. = ..()
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)


/obj/structure/bed/chair/e_chair/rotate()
	..()
	overlays.Cut()
	overlays += image('icons/obj/objects.dmi', src, "echair_over", MOB_LAYER + 1, dir)	//there's probably a better way of handling this, but eh. -Pete
	return

/obj/structure/bed/chair/e_chair/proc/use_power(amount, channel)
	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A) || !A.powered(channel))
		return FALSE
	A.use_power(amount, channel)
	return TRUE

/obj/structure/bed/chair/e_chair/proc/shock()
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	if(!use_power(5000, EQUIP))
		return

	flick("echair1", src)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(12, 1, src)
	s.start()
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		buckled_mob.adjustFireLoss(85)
		to_chat(buckled_mob, "<span class='danger'>You feel a deep shock course through your body!</span>")
		sleep(1)
		buckled_mob.adjustFireLoss(85)
		buckled_mob.Stun(20 MINUTES)
	visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='danger'>You hear a deep sharp shock!</span>")
	return
