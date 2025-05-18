//build mode designation specific procs
//will populate after other prs merged

///build designation side of use_ability
/datum/action/ability/activable/build_designator/proc/use_build_ability(atom/target)
	if(!isturf(target) || !update_hologram(target))
		owner.balloon_alert(owner, "Invalid spot")
		return FALSE
	new /obj/effect/build_designator(target, construct_type, owner)
	return TRUE
