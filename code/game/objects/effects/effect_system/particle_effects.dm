

//the objects used by /datum/effect_system

/obj/effect/particle_effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = 0
	flags_pass = PASSTABLE|PASSGRILLE|PASSMOB

	//Fire
/obj/effect/particle_effect/fire  //Fire that ignites mobs and deletes itself after some time, but doesn't mess with atmos. Good fire flamethrowers and incendiary stuff.
	name = "fire"
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"
	var/life = 0.5 //In seconds
	mouse_opacity = 0


/obj/effect/particle_effect/fire/Initialize(mapload, ...)
	. = ..()

	if(!isturf(loc))
		return INITIALIZE_HINT_QDEL

	QDEL_IN(src, life SECONDS)

	setDir(pick(GLOB.cardinals))
	set_light(3)

	for(var/mob/living/L in loc)//Mobs
		L.fire_act()
	for(var/obj/effect/alien/weeds/W in loc)//Weeds
		W.fire_act()
	for(var/obj/effect/alien/egg/E in loc)//Eggs
		E.fire_act()
	for(var/obj/structure/bed/nest/N in loc)//Nests
		N.fire_act()

/obj/effect/particle_effect/fire/Crossed(mob/living/L)
	..()
	if(isliving(L))
		L.fire_act()

	//End fire

/obj/effect/particle_effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	var/life = 15.0
	mouse_opacity = 0

/obj/effect/particle_effect/water/Move(turf/newloc)
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	if (--src.life < 1)
		//SN src = null
		qdel(src)
	if(newloc.density)
		return 0
	.=..()

/obj/effect/particle_effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	return ..()
