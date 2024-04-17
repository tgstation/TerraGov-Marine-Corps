/datum/reagents_recipes

//In the future porting over TGs reagents

	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()


	var/required_container = null
	var/required_other = 0

	var/mob_react = TRUE

	var/required_temp = 0
	var/is_cold_recipe = 0
	var/mix_message
	var/mix_sound

/datum/reagents_recipes/proc/on_reaction(datum/reagents/holder, created_volume)
	return


/datum/reagents_recipes/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " (<A HREF='?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/blank.ogg', 100, TRUE)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S
			if(random)
				S = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				S = new mob_class(get_turf(holder.my_atom))
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH,SOUTH,EAST,WEST))


/proc/rogue_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in view(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2)
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_away), X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_towards), X, T), 2)
