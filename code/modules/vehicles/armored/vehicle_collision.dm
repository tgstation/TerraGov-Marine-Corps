/**
 *This proc is called when a atom is crashed into by a [armored vehicle][/obj/vehicle/sealed/armored]. Damage is then dealt to both the vehicle and atom
 *
 * * Arguments:
 * * veh is the vehicle that is ramming
 * * facing is the direction the vehicle is facing for when we ram it
 * * T is the turf where the vehicle is used with-
 * * temp to check whether a mob is squished
 */
/atom/proc/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	var/damage = veh.ram_damage // Each vehicle gets its own damage, you can modify it with snowplows and such ideally

	if(!TIMER_COOLDOWN_CHECK(veh, COOLDOWN_VEHICLE_CRUSHSOUND))
		visible_message(span_danger("[veh] rams [src]!"))
		playsound(src, 'sound/effects/metal_crash.ogg', 45)
		TIMER_COOLDOWN_START(veh, COOLDOWN_VEHICLE_CRUSHSOUND, 1 SECONDS)
	return damage

/obj/structure/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(., BRUTE, MELEE, TRUE, facing, 0)

/obj/structure/barricade/plasteel/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	toggle_open(FALSE)

/obj/vehicle/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)	//MONSTER TRUCKS
	. = ..()
	take_damage(., BRUTE, MELEE, TRUE, facing, 0)

/obj/machinery/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(., BRUTE, MELEE, TRUE, facing, 0)

/turf/closed/wall/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(., BRUTE, MELEE, TRUE, facing, 0)

/mob/living/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp, mob/pilot)
	. = ..()
	if(stat == DEAD)
		return 0
	if(lying_angle)
		return 0
	log_attack("[key_name(pilot)] drove into [key_name(src)] with [veh]")
	temp = get_step(veh.loc, facing)
	T = temp
	T = get_step(T, facing)
	T = get_step(T, facing)
	T = get_step(T, facing)
	face_atom(T)
	throw_at(T, 3, 2, veh, 1)
	return take_overall_damage(., BRUTE, MELEE, FALSE, FALSE, TRUE, 0, 4)


/mob/living/carbon/xenomorph/larva/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	gib() //fuck you

/obj/effect/alien/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(., BRUTE, MELEE, TRUE, facing, 0)

/obj/effect/alien/weeds/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	return
