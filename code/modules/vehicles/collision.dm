/atom/proc/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	if(!veh.demolish_on_ram)
		return NONE // 0 Damage

	var/damage = 30 // TODO: Better damage scaling?
	var/veh_damage = 2
	
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

/obj/machinery/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	var/damage = .
	take_damage(damage)

/turf/closed/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	if(prob(15))
		ex_act(3)

/mob/living/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp) //If theyre alive, yeet them
	if(stat == DEAD) //We don't care about the dead
		return NONE
	if(lying)
		return NONE
	if(!veh.demolish_on_ram)
		return NONE

	if(src in get_turf(veh)) // trodden over.
		if(!knocked_down)
			set_knocked_down(1)
		var/target_dir = turn(veh.dir, 180)
		temp = get_step(veh.loc, target_dir)
		T = temp
		target_dir = turn(veh.dir, 180)
		T = get_step(T, target_dir)
		face_atom(T)
		throw_at(T, 3, 2, veh, 1)
		apply_damage(rand(5, 7.5), BRUTE)
		return
	
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	if(mob_size == MOB_SIZE_BIG)
		throw_at(T, 3, 2, veh, 0)
	else
		throw_at(T, 3, 2, veh, 1)
	if(!knocked_down)
		set_knocked_down(1)
	apply_damage(rand(10, 15), BRUTE)
	visible_message("<span class='danger'>[veh] bumps into [src], throwing [p_them()] away!</span>", "<span class='danger'>[veh] violently bumps into you!</span>")

/mob/living/carbon/Xenomorph/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	. = ..()
	if(lying || loc == veh.loc)
		return
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	throw_at(T, 2, 2, veh, 0)
	visible_message("<span class='danger'>[veh] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[veh] bumps into you!</span>")

/mob/living/carbon/Xenomorph/Larva/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	gib() //fuck you

/obj/effect/alien/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	take_damage(40)

/obj/effect/alien/weeds/vehicle_collision(obj/vehicle/veh, facing, turf/T, turf/temp)
	return