/datum/sex_action/vaginal_ride_sex
	name = "Ride them"
	stamina_cost = 1.0
	aggro_grab_instead_same_tile = FALSE
	check_incapacitated = FALSE

/datum/sex_action/vaginal_ride_sex/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE



	return TRUE

/datum/sex_action/vaginal_ride_sex/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/vaginal_ride_sex/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] gets on top of [target] and begins riding them with [user.p_their()] cunt!"))
	playsound(target, pick(list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg')), 20, TRUE, 7, ignore_walls = FALSE)

/datum/sex_action/vaginal_ride_sex/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] rides [target]."))
	playsound(target, 'ntf_modular/sound/misc/mat/segso.ogg', 50, TRUE, 5, ignore_walls = FALSE)
	do_thrust_animate(user, target)


	if(target.sexcon.considered_limp())
		user.sexcon.perform_sex_action(user, 1.2, 0, TRUE)
		user.sexcon.perform_sex_action(target, 1.2, 3, TRUE)
	else
		user.sexcon.perform_sex_action(user, 2.4, 0, TRUE)
		user.sexcon.perform_sex_action(target, 2.4, 7, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	if(target.sexcon.check_active_ejaculation())
		target.visible_message(span_lovebold("[target] cums into [user]'s cunt!"))
		target.sexcon.cum_into(FALSE, user)
		if(isxeno(target))
			var/mob/living/carbon/xenomorph/X = target
			X.impregify(user, "pussy")
		if(isxeno(user) && ishuman(target))
			var/mob/living/carbon/xenomorph/X = user
			var/hivenumber = X.get_xeno_hivenumber()
			if(X.xenoimpregify() && HAS_TRAIT(target, TRAIT_HIVE_TARGET))
				var/psy_points_reward = PSY_DRAIN_REWARD_MIN + ((HIGH_PLAYER_POP - SSmonitor.maximum_connected_players_count) / HIGH_PLAYER_POP * (PSY_DRAIN_REWARD_MAX - PSY_DRAIN_REWARD_MIN))
				psy_points_reward = clamp(psy_points_reward, PSY_DRAIN_REWARD_MIN, PSY_DRAIN_REWARD_MAX)
				SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HIVE_TARGET_DRAINED, X, target)
				psy_points_reward = psy_points_reward * 5
				SSpoints.add_strategic_psy_points(hivenumber, psy_points_reward)
				GLOB.round_statistics.strategic_psypoints_from_hive_target_rewards += psy_points_reward
				GLOB.round_statistics.hive_target_rewards++
				GLOB.round_statistics.biomass_from_hive_target_rewards += MUTATION_BIOMASS_PER_HIVE_TARGET_REWARD
				SSpoints.add_biomass_points(hivenumber, MUTATION_BIOMASS_PER_HIVE_TARGET_REWARD)
				SSpoints.add_tactical_psy_points(hivenumber, psy_points_reward*0.25)



/datum/sex_action/vaginal_ride_sex/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] gets off [target]."))

/datum/sex_action/vaginal_ride_sex/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
