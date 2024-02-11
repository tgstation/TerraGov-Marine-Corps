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
		visible_message(span_danger("[veh] crushes the [src]!"))
		playsound(src, 'sound/effects/metal_crash.ogg', 45)
		TIMER_COOLDOWN_START(veh, COOLDOWN_VEHICLE_CRUSHSOUND, 1 SECONDS)
	return damage

/obj/structure/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(.)

/obj/structure/barricade/plasteel/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	toggle_open(FALSE)

/obj/vehicle/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)	//MONSTER TRUCKS
	. = ..()
	take_damage(.)

/obj/machinery/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(.)

/turf/closed/wall/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	take_damage(. += rand(200, 225))

/mob/living/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp, mob/pilot) //If theyre alive, yeet them
	if(stat == DEAD)	//Cant make horizontal spacemen more horizontal
		return 0
	if(lying_angle)
		return 0
	log_attack("[key_name(pilot)] drove over [key_name(src)] with [veh]")
	KnockdownNoChain(1)
	if(src in veh.loc) // trodden over.
		var/target_dir = turn(veh.dir, 180)
		temp = get_step(veh.loc, target_dir)
		T = temp
		target_dir = turn(veh.dir, 180)
		T = get_step(T, target_dir)
		face_atom(T)
		throw_at(T, 3, 2, veh, 1)
		return apply_damage(rand(20, 30), BRUTE)

	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	if(mob_size == MOB_SIZE_BIG)
		throw_at(T, 3, 2, veh, 0)
	else
		throw_at(T, 3, 2, veh, 1)
	visible_message(span_danger("[veh] bumps into [src], throwing [p_them()] away!"), span_danger("[veh] violently bumps into you!"))
	return apply_damage(rand(40, 55), BRUTE)

/mob/living/carbon/xenomorph/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	. = ..()
	if(lying_angle || loc == veh.loc)
		return
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	throw_at(T, 2, 2, veh, 0)
	visible_message(span_danger("[veh] bumps into [src], pushing [p_them()] away!"), span_danger("[veh] bumps into us!"))

/mob/living/carbon/xenomorph/larva/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	gib() //fuck you

/obj/effect/alien/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	take_damage(veh.ram_damage/2)

/obj/effect/alien/weeds/vehicle_collision(obj/vehicle/sealed/armored/veh, facing, turf/T, turf/temp)
	return
