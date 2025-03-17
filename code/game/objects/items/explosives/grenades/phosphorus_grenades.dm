/obj/item/explosive/grenade/phosphorus
	name = "\improper M40 HPDP grenade"
	desc = "The M40 HPDP is a small, but powerful phosphorus grenade. It is set to detonate in 2 seconds."
	icon_state = "grenade_phos"
	worn_icon_state = "grenade_phos"
	det_time = 2 SECONDS
	hud_state = "grenade_hide"
	var/datum/effect_system/smoke_spread/phosphorus/smoke
	icon_state_mini = "grenade_cyan"

/obj/item/explosive/grenade/phosphorus/Initialize(mapload)
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/phosphorus/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/explosive/grenade/phosphorus/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, loc, 7)
	smoke.start()
	flame_radius(4, get_turf(src))
	flame_radius(1, get_turf(src), burn_intensity = 75, burn_duration = 45, burn_damage = 15, fire_stacks = 75)	//The closer to the middle you are the more it hurts
	qdel(src)

/obj/item/explosive/grenade/phosphorus/activate(mob/user)
	. = ..()
	if(!.)
		return FALSE
	user?.record_war_crime()

/obj/item/explosive/grenade/phosphorus/upp
	name = "\improper Type 8 WP grenade"
	desc = "A deadly gas grenade found within the ranks of the USL. Designed to spill white phosphorus on the target. It explodes 2 seconds after the pin has been pulled."
	icon_state = "grenade_upp_wp"
	worn_icon_state = "grenade_upp_wp"
	arm_sound = 'sound/weapons/armbombpin_1.ogg'
