//Fire
/obj/effect/particle_effect/fire  //Fire that ignites mobs and deletes itself after some time, but doesn't mess with atmos. Good fire flamethrowers and incendiary stuff.
	name = "fire"
	icon = 'icons/effects/fire.dmi'
	icon_state = "f3"
	var/life = 0.5 //In seconds
	mouse_opacity = 0

/obj/effect/particle_effect/fire/Initialize()
	. = ..()
	if(!isturf(loc))
		qdel(src)
		return
	QDEL_IN(src, life SECONDS)

	setDir(pick(GLOB.cardinals))
	SetLuminosity(3)

	for(var/i in loc)
		var/atom/movable/AM = i
		AM.fire_act()
	
/obj/effect/particle_effect/fire/Destroy()
	if(isturf(loc))
		SetLuminosity(0)
	return ..()


/obj/effect/particle_effect/fire/Crossed(mob/living/L)
	. = ..()
	if(istype(L))
		L.fire_act()

	//End fire


/turf/proc/detonate_banshee()
	var/obj/structure/ship_ammo/rocket/banshee/B = new(src)
	B.detonate_on(src)