/**
  *This proc is called when a atom is crashed into by a [armored vehicle][/obj/vehicle/armored]. Damage is then dealt to both the vehicle and atom
  *
  * * Arguments:
  * * veh is the vehicle that is ramming
  * * facing is the direction the vehicle is facing for when we ram it
  * * T is the turf where the vehicle is used with-
  * * temp to check whether a mob is squished
  */
/atom/proc/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	if(!veh.demolish_on_ram)
		return NONE // 0 Damage

	var/damage = veh.ram_damage // Each vehicle gets its own damage
	var/veh_damage = 25

	if(world.time > veh.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[veh] crushes \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 45)
		veh.lastsound = world.time
		veh.take_damage(veh_damage)
	return damage

/obj/structure/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	var/damage = . //If it has a snowplow, add extra damage
	take_damage(damage)

/obj/vehicle/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)	//MONSTER TRUCKS
	. = ..()
	var/damage = .
	take_damage(damage)

/obj/machinery/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	var/damage = .
	take_damage(damage)

/turf/closed/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	if(prob(15))
		ex_act(3)

/mob/living/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp) //If theyre alive, yeet them
	if(stat == DEAD)	//Cant make horizontal spacemen more horizontal
		return NONE
	if(lying_angle)
		return NONE
	if(!veh.demolish_on_ram)
		return NONE

	if(src in get_turf(veh)) // trodden over.
		if(!IsKnockdown())
			Knockdown(1)	//We got squished
		var/target_dir = turn(veh.dir, 180)
		temp = get_step(veh.loc, target_dir)
		T = temp
		target_dir = turn(veh.dir, 180)
		T = get_step(T, target_dir)
		face_atom(T)
		throw_at(T, 3, 2, veh, 1)
		apply_damage(rand(20, 30), BRUTE)
		return

	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	if(mob_size == MOB_SIZE_BIG)
		throw_at(T, 3, 2, veh, 0)
	else
		throw_at(T, 3, 2, veh, 1)
	if(!IsKnockdown())
		Knockdown(1 SECONDS)
	apply_damage(rand(40, 55), BRUTE)
	visible_message("<span class='danger'>[veh] bumps into [src], throwing [p_them()] away!</span>", "<span class='danger'>[veh] violently bumps into you!</span>")

/mob/living/carbon/xenomorph/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	if(lying_angle || loc == veh.loc)
		return
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	throw_at(T, 2, 2, veh, 0)
	visible_message("<span class='danger'>[veh] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[veh] bumps into you!</span>")

/mob/living/carbon/Xenomorph/larva/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	gib() //fuck you

/obj/effect/alien/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	take_damage(40)

/obj/effect/alien/weeds/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	return
