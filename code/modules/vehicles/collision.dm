/atom/proc/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	if(!roadtrafficaccident.demolish_on_ram)
		return 0 //FALSE, also 0 damage.
	var/damage = 30
	var/tank_damage = 2
	if(world.time > roadtrafficaccident.lastsound + 1 SECONDS)
		visible_message("<span class='danger'>[roadtrafficaccident] crushes \the [src]!</span>")
		playsound(src, 'sound/effects/metal_crash.ogg', 45)
		roadtrafficaccident.lastsound = world.time
		roadtrafficaccident.take_damage(tank_damage)
	return damage

/obj/structure/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	. = ..()
	var/damage = . //If it has a snowplow, add extra damage
	take_damage(damage)

/obj/machinery/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	. = ..()
	var/damage = .
	take_damage(damage)

/turf/closed/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	. = ..()
	if(prob(15))
		ex_act(3)

/mob/living/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp) //If theyre alive, yeet them
	if(stat == DEAD) //We don't care about the dead
		return
	if(!roadtrafficaccident.demolish_on_ram)
		return 0 //FALSE, also 0 damage.

	if(src in get_turf(roadtrafficaccident)) // trodden over.
		if(!knocked_down)
			KnockDown(1)
		var/target_dir = turn(roadtrafficaccident.dir, 180)
		temp = get_step(roadtrafficaccident.loc, target_dir)
		T = temp
		target_dir = turn(roadtrafficaccident.dir, 180)
		T = get_step(T, target_dir)
		face_atom(T)
		throw_at(T, 3, 2, roadtrafficaccident, 1)
		apply_damage(rand(5, 7.5), BRUTE)
		return
	if(lying)
		return FALSE
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	if(mob_size == MOB_SIZE_BIG)
		throw_at(T, 3, 2, roadtrafficaccident, 0)
	else
		throw_at(T, 3, 2, roadtrafficaccident, 1)
	if(!knocked_down)
		KnockDown(1)
	apply_damage(rand(10, 15), BRUTE)
	visible_message("<span class='danger'>[roadtrafficaccident] bumps into [src], throwing [p_them()] away!</span>", "<span class='danger'>[roadtrafficaccident] violently bumps into you!</span>")

/mob/living/carbon/Xenomorph/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	if(lying || loc == roadtrafficaccident.loc)
		return ..()
	temp = get_step(T, facing)
	T = temp
	T = get_step(T, pick(GLOB.cardinals))
	throw_at(T, 2, 2, roadtrafficaccident, 0)
	visible_message("<span class='danger'>[roadtrafficaccident] bumps into [src], pushing [p_them()] away!</span>", "<span class='danger'>[roadtrafficaccident] bumps into you!</span>")

/mob/living/carbon/Xenomorph/Larva/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	gib() //fuck you

/obj/effect/alien/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	take_damage(40)

/obj/effect/alien/weeds/tank_collision(obj/vehicle/roadtrafficaccident, facing, turf/T, turf/temp)
	return