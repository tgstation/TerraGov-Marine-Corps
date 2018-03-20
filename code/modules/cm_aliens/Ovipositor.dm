#define QUEEN_OVIPOSITOR_DECAY_TIME 500

/obj/ovipositor
	name = "Egg Sac"
	icon = 'icons/Xeno/Ovipositor.dmi'
	icon_state = "ovipositor"
	unacidable = 1
	var/begin_decay_time = 0
	var/health = 50
	var/decay_ready = 0
	var/decayed = 0		// This is here so later on we can use the ovpositor molt for research. ~BMC777
	var/destroyed = 0

/obj/ovipositor/New()
	..()
	begin_decay_time = world.timeofday + QUEEN_OVIPOSITOR_DECAY_TIME
	process_decay()

/obj/ovipositor/proc/process_decay()
	set background = 1

	spawn while (!decayed && !destroyed)
		if (world.timeofday > begin_decay_time)
			decayed = 1
			do_decay()

		if (health < 0)
			destroyed = 1
			explode()

		sleep(10)	// Process every second.

/obj/ovipositor/proc/do_decay()
	icon_state = "ovipositor_molted"
	flick("ovipositor_decay", src)
	sleep(15)

	var/turf/T = get_turf(src)
	if (T)
		T.overlays += image('icons/Xeno/Ovipositor.dmi', "ovipositor_molted")

	cdel(src)

/obj/ovipositor/proc/explode()
	icon_state = "ovipositor_gibbed"
	flick("ovipositor_explosion", src)
	sleep(15)

	var/turf/T = get_turf(src)
	if (T)
		T.overlays += image('icons/Xeno/Ovipositor.dmi', "ovipositor_gibbed")

	cdel(src)

/obj/ovipositor/ex_act(severity)
	if (3)
		health -= 25
	else
		health -= 75

//Every other type of nonhuman mob
/obj/ovipositor/attack_alien(mob/living/carbon/Xenomorph/M)
	switch(M.a_intent)
		if("help")
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>")
			return 0

		if("grab")
			if(M == src || anchored)
				return 0

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

		if("hurt")
			var/damage = (rand(M.melee_damage_lower, M.melee_damage_upper) + 3)
			M.visible_message("<span class='danger'>\The [M] bites [src]!</span>", \
			"<span class='danger'>You bite [src]!</span>")
			health -= damage
			return 1

		if("disarm")
			M << "<span class='warning'>There's nothing to disarm!</span>"

	return 0

/obj/ovipositor/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	M.visible_message("<span class='danger'>[M] nudges its head against [src].</span>", \
	"<span class='danger'>You nudge your head against [src].</span>")

// Density override
/obj/ovipositor/get_projectile_hit_chance(obj/item/projectile/P)
	return TRUE

/obj/ovipositor/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	return 1