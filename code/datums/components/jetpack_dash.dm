/datum/component/jetpack_dash
	var/expected_parent = /obj/item/tank
	var/dash_cost 		= 5  	// gas pressure used for one dash
	var/dash_speed      = 1 	// speed with which victim is thrown at during dash
	var/dash_distance 	= 2  	// turfs to move in one dash
	var/dashing 		= 0   	// busy flag
	var/dash_cooldown 	= 10  	// ds until can dash again
	var/active			= FALSE	// is the backpack currently active?

/datum/component/jetpack_dash/Initialize()
	. = ..()
	if(!istype(parent, expected_parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_TOGGLE_JETPACK_DASH, .proc/toggle_backpack)

/datum/component/jetpack_dash/proc/toggle_backpack()
	active = !active

/datum/component/jetpack_dash/proc/dash(mob/victim, direction)
	if(!active)
		return FALSE
	if(!istype(victim))
		return FALSE
	if(dashing)
		to_chat(victim, "<spawn class='warning'>\The [parent] is not ready to dash again!</span>")
		return FALSE

	if(!use_gas(dash_cost))
		to_chat(victim, "<spawn class='warning'>\The [parent] does not have enough gas for this maneuver!</span>")
		return FALSE
	
	. = TRUE
	dashing = TRUE

	var/old_dir = victim.dir
	playsound(victim, 'sound/effects/extinguish.ogg', 20, 1, 7)
	new/obj/effect/temp_visual/dir_setting/jetpack_poof(get_turf(victim), reverse_direction(direction))
	victim.throw_at(get_edge_target_turf(victim, direction), dash_distance, 10, spin = FALSE)
	victim.setDir(old_dir)

	if(dash_cooldown)
		addtimer(CALLBACK(src, /datum/component/jetpack_dash.proc/stop_dashing), dash_cooldown)
	else
		dashing = FALSE

/datum/component/jetpack_dash/proc/stop_dashing()
	dashing = FALSE

//override this if you put it on something that isn't a tank
/datum/component/jetpack_dash/proc/use_gas(cost)
	var/obj/item/tank/T = parent
	if(T.return_pressure() < cost)
		return FALSE
	T.remove_pressure(cost)
	return TRUE
