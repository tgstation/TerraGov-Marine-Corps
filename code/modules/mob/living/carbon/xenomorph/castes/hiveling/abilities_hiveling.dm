
// ***************************************
// *********** Resin building
// ***************************************

/datum/action/ability/activable/xeno/secrete_resin/hiveling
	ability_cost = 100
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating/weak,
		/obj/alien/resin/sticky,
		/obj/structure/mineral_door/resin,
	)

// ***************************************
// *********** Weed Walker
// ***************************************

/datum/action/ability/activable/xeno/weedwalker
	name = "Weed Walker"
	action_icon_state = "weedwalker_off"
	ability_cost = 75
	desc = "Spread weeds while you move, placing a pod every 5 tiles"
	var/cost_per_tile = 25
	var/cost_per_node = 75
	var/weednode_countdown = 4
	var/weedwalker_toggle = FALSE
	var/planting_node = FALSE
	var/weeding_active = FALSE

/datum/action/ability/activable/xeno/weedwalker/action_activate()
	if(weeding_active)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		to_chat(owner, span_xenonotice("We will no longer automatically spread weeds as we move."))
		weeding_active = FALSE
		action_icon_state = "weedwalker_off"
		update_button_icon()
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(weeding_tiles_on_move))
	to_chat(owner, span_xenonotice("We will now automatically spread weeds as we move."))
	weeding_active = TRUE
	action_icon_state = "weedwalker_on"
	update_button_icon()
	return ..()


///Used for performing automatic weeding
/datum/action/ability/activable/xeno/weedwalker/proc/weeding_tiles_on_move(datum/source)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.loc_weeds_type)
		return
	if(!can_use_ability(xeno_owner.loc, TRUE, ABILITY_IGNORE_SELECTED_ABILITY))
		return
	if(weednode_countdown <= 0)
		planting_node = TRUE
		create_weeds_or_node(owner)
		return
	planting_node = FALSE
	create_weeds_or_node(owner)

// either plants a node, or creates weeds and subtracts 1 from the counter
/datum/action/ability/activable/xeno/weedwalker/proc/create_weeds_or_node(atom/A)
	var/turf/T = get_turf(A)

	if(!T.check_alien_construction(owner, FALSE))
		return fail_activate()

	if(locate(/obj/structure/xeno/trap) in T)
		to_chat(owner, span_warning("There is a resin trap in the way!"))
		return fail_activate()

	if(!T.is_weedable())
		to_chat(owner, span_warning("Bad place for a garden!"))
		return fail_activate()

	if(locate(/obj/alien/weeds/node) in T)
		to_chat(owner, span_warning("There's a pod here already!"))
		return fail_activate()

	if(planting_node == TRUE)
		owner.visible_message(span_xenonotice("\The [owner] regurgitates a pulsating node and plants it on the ground!"), \
			span_xenonotice("We regurgitate a pulsating node and plant it on the ground!"), null, 5)
		new /obj/alien/weeds/node(T)
		playsound(T, "alien_resin_build", 25)
		GLOB.round_statistics.weeds_planted++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_planted")
		if(owner.client)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
			personal_statistics.weeds_planted++
		weednode_countdown += 4 //reset the countdown to 4
		return succeed_activate(SSmonitor.gamestate == SHUTTERS_CLOSED ? cost_per_node/2 : cost_per_node)
	new /obj/alien/weeds(T)
	playsound(T, "alien_resin_move_2", 35) //louder cause its placement
	weednode_countdown -= 1 //ticks down the countdown by 1
	return succeed_activate(cost_per_tile)

//AI stuff
/datum/action/ability/activable/xeno/weedwalker/ai_should_start_consider()
	if(weeding_active == TRUE)
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/weedwalker/ai_should_use(target)
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	return TRUE
