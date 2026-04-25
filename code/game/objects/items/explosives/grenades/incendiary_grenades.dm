/obj/item/explosive/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon_state = "grenade_fire"
	worn_icon_state = "grenade_fire"
	det_time = 4 SECONDS
	hud_state = "grenade_fire"
	icon_state_mini = "grenade_orange"

/obj/item/explosive/grenade/incendiary/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, SFX_INCENDIARY_EXPLOSION, 35)
	qdel(src)


/proc/flame_radius(radius = 1, turf/epicenter, burn_intensity = 25, burn_duration = 25, burn_damage = 25, fire_stacks = 15, colour = "red", fire_type = /obj/fire/flamer) //~Art updated fire.
	if(!isturf(epicenter))
		CRASH("flame_radius used without a valid turf parameter")
	radius = clamp(radius, 1, 50) //Sanitize inputs

	for(var/t in filled_turfs(epicenter, radius, "circle", pass_flags_checked = PASS_AIR))
		var/turf/turf_to_flame = t
		turf_to_flame.ignite(randfloat(burn_duration*0.75, burn_duration), burn_intensity, colour, burn_damage, fire_stacks, fire_type)

/obj/item/explosive/grenade/incendiary/som
	name = "\improper S30-I incendiary grenade"
	desc = "A reliable incendiary grenade utilised by SOM forces. Based off the S30 platform shared by most SOM grenades. Designed for hand or grenade launcher use."
	icon_state = "grenade_fire_som"
	worn_icon_state = "grenade_fire_som"

/obj/item/explosive/grenade/incendiary/molotov
	name = "improvised firebomb"
	desc = "A potent, improvised firebomb, coupled with a pinch of gunpowder. Cheap, very effective, and deadly in confined spaces. Commonly found in the hands of rebels and terrorists. It can be difficult to predict how many seconds you have before it goes off, so be careful. Chances are, it might explode in your face."
	icon_state = "molotov"
	worn_icon_state = "molotov"
	arm_sound = 'sound/items/welder2.ogg'

/obj/item/explosive/grenade/incendiary/molotov/Initialize(mapload)
	. = ..()
	det_time = rand(1 SECONDS, 4 SECONDS)//Adds some risk to using this thing.

/obj/item/explosive/grenade/incendiary/molotov/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, SFX_MOLOTOV, 35)
	qdel(src)

/obj/item/explosive/grenade/incendiary/molotov/throw_impact(atom/hit_atom, speed, bounce = TRUE)
	. = ..()
	if(!.)
		return
	if(!hit_atom.density || prob(35))
		return
	prime()
