#define QUEEN_OVIPOSITOR_DECAY_TIME 10 MINUTES

/obj/ovipositor
	name = "Egg Sac"
	icon = 'icons/Xeno/Ovipositor.dmi'
	icon_state = "ovipositor"
	resistance_flags = UNACIDABLE


/obj/ovipositor/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/start_decay), QUEEN_OVIPOSITOR_DECAY_TIME)


/obj/ovipositor/proc/start_decay()
	icon_state = "ovipositor_molted"
	flick("ovipositor_decay", src)

	addtimer(CALLBACK(src, .proc/do_decay), 1.5 SECONDS)


/obj/ovipositor/proc/do_decay()
	var/turf/T = get_turf(src)
	if(T)
		T.overlays += image('icons/Xeno/Ovipositor.dmi', "ovipositor_molted")

	qdel(src)

/obj/ovipositor/ex_act(severity)
	switch(severity)
		if(3)
			take_damage(25)
		else
			take_damage(75)

// Density override
/obj/ovipositor/projectile_hit(obj/item/projectile/P)
	return TRUE
