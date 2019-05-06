// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/xeno_action/activable/spray_acid/cone
	name = "Spray Acid Cone"
	action_icon_state = "spray_acid"
	mechanics_text = "Spray a cone of dangerous acid at your target."
	ability_name = "spray acid"
	plasma_cost = 200
	cooldown_timer = 20 SECONDS

/datum/action/xeno_action/activable/spray_acid/cone/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(!do_after(X, 5, TRUE, 5, BUSY_ICON_HOSTILE))
		return fail_activate()

	if(!can_use_ability(A, TRUE))
		return fail_activate()

	round_statistics.praetorian_acid_sprays++

	succeed_activate()

	playsound(X.loc, 'sound/effects/refill.ogg', 25, 1)
	X.visible_message("<span class='xenowarning'>\The [X] spews forth a wide cone of acid!</span>", \
	"<span class='xenowarning'>You spew forth a cone of acid!</span>", null, 5)

	X.speed += 2
	do_acid_spray_cone(target, X.xeno_caste.acid_spray_range)
	add_cooldown()
	addtimer(CALLBACK(X, /mob/living/carbon/Xenomorph/.proc/reset_speed), rand(20,30))

/mob/living/carbon/Xenomorph/proc/reset_speed()
	speed = xeno_caste.speed

GLOBAL_LIST_INIT(acid_spray_hit, typecacheof(list(/obj/structure/barricade, /obj/vehicle/multitile/root/cm_armored, /obj/structure/razorwire)))

/datum/action/xeno_action/activable/spray_acid/cone/proc/do_acid_spray_cone(turf/T, range)
	set waitfor = FALSE

	var/facing = get_cardinal_dir(owner, T)
	owner.setDir(facing)

	T = get_turf(owner)
	for (var/i in 1 to range)

		var/turf/next_T = get_step(T, facing)

		for (var/obj/O in T)
			if(!O.CheckExit(owner, next_T))
				if(is_type_in_typecache(O, GLOB.acid_spray_hit) && O.acid_spray_act(owner))
					return // returned true if normal density applies

		T = next_T

		if (T.density)
			return

		for (var/obj/O in T)
			if(!O.CanPass(owner, get_turf(owner)))
				if(is_type_in_typecache(O, GLOB.acid_spray_hit) && O.acid_spray_act(owner))
					return // returned true if normal density applies

		var/obj/effect/xenomorph/spray/S = acid_splat_turf(T)
		do_acid_spray_cone_normal(T, i, facing, S)
		sleep(3)

// Normal refers to the mathematical normal
/datum/action/xeno_action/activable/spray_acid/cone/proc/do_acid_spray_cone_normal(turf/T, distance, facing, obj/effect/xenomorph/spray/source_spray)
	if (!distance)
		return

	var/obj/effect/xenomorph/spray/left_S = source_spray
	var/obj/effect/xenomorph/spray/right_S = source_spray

	var/normal_dir = turn(facing, 90)
	var/inverse_normal_dir = turn(facing, -90)

	var/turf/normal_turf = T
	var/turf/inverse_normal_turf = T

	var/normal_density_flag = 0
	var/inverse_normal_density_flag = 0

	for (var/i in 1 to distance)
		if (normal_density_flag && inverse_normal_density_flag)
			return

		if (!normal_density_flag)
			var/next_normal_turf = get_step(normal_turf, normal_dir)

			for (var/obj/O in normal_turf)
				if(!O.CheckExit(left_S, next_normal_turf))
					normal_density_flag = TRUE
					if(is_type_in_typecache(O, GLOB.acid_spray_hit))
						normal_density_flag = O.acid_spray_act(owner)
					break

			normal_turf = next_normal_turf

			if(!normal_density_flag)
				normal_density_flag = normal_turf.density

			if(!normal_density_flag)
				for (var/obj/O in normal_turf)
					if(!O.CanPass(left_S, left_S.loc))
						normal_density_flag = TRUE
						if(is_type_in_typecache(O, GLOB.acid_spray_hit))
							normal_density_flag = O.acid_spray_act(owner)
						break

			if (!normal_density_flag)
				left_S = acid_splat_turf(normal_turf)


		if (!inverse_normal_density_flag)

			var/next_inverse_normal_turf = get_step(inverse_normal_turf, inverse_normal_dir)

			for (var/obj/O in inverse_normal_turf)
				if(!O.CheckExit(right_S, next_inverse_normal_turf))
					inverse_normal_density_flag = TRUE
					if(is_type_in_typecache(O, GLOB.acid_spray_hit))
						inverse_normal_density_flag = O.acid_spray_act(owner)
					break

			inverse_normal_turf = next_inverse_normal_turf

			if(!inverse_normal_density_flag)
				inverse_normal_density_flag = inverse_normal_turf.density

			if(!inverse_normal_density_flag)
				for (var/obj/O in inverse_normal_turf)
					if(!O.CanPass(right_S, right_S.loc))
						inverse_normal_density_flag = TRUE //passable for acid spray
						if(is_type_in_typecache(O, GLOB.acid_spray_hit))
							inverse_normal_density_flag = O.acid_spray_act(owner)
						break

			if (!inverse_normal_density_flag)
				right_S = acid_splat_turf(inverse_normal_turf)
