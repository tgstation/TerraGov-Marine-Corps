//todo: add a mobs to help list so we can record who needs help, even if we're too busy to help right now
/datum/ai_behavior/human
	///A list of engineering related actions
	var/list/engineering_list = list()
	///Chat lines for trying to heal
	var/list/building_chat = list("Building.")
	///Chat lines for trying to heal
	//var/list/self_heal_chat = list("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!.")
	///Chat lines for someone being perma
	var/list/unable_to_build_chat = list("Unable to build.")


///Checks if we should be healing somebody
/datum/ai_behavior/human/proc/engineer_process()
	if(!length(engineering_list))
		return
	if(interact_target && (interact_target in engineering_list))
		return
	if(human_ai_state_flags & HUMAN_AI_FIRING)
		return
	if(current_action == MOVING_TO_SAFETY)
		return
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return

	var/atom/engie_target
	var/patient_dist = 10 //lets just check screen range, more or less
	for(var/atom/potential AS in engineering_list)
		var/dist = get_dist(mob_parent, potential)
		if(dist >= patient_dist)
			continue
		if(istype(potential, /obj/effect/build_designator))
			var/obj/effect/build_designator/hologram = potential
			if(hologram.builder)
				continue
		engie_target = potential
		patient_dist = dist
	if(!engie_target)
		return

	set_interact_target(engie_target)
	return TRUE

///Our building ended, successfully or otherwise
/datum/ai_behavior/human/proc/on_engineering_end(atom/old_target)
	SIGNAL_HANDLER
	human_ai_state_flags &= ~HUMAN_AI_BUILDING
	remove_from_engineering_list(old_target) //this creates issues if we get interrupted somehow... probably same in medical
	late_initialize()

///Decides if we should do something when another mob goes crit
/datum/ai_behavior/human/proc/on_holo_build_init(datum/source, obj/effect/build_designator/new_holo)
	SIGNAL_HANDLER
	if(new_holo.faction != mob_parent.faction)
		return
	if(new_holo.z != mob_parent.z)
		return

	add_to_engineering_list(new_holo)
	if(get_dist(mob_parent, new_holo) > 5)
		return
	set_interact_target(new_holo)

///Adds mob to list
/datum/ai_behavior/human/proc/add_to_engineering_list(atom/new_target)
	if(new_target in engineering_list)
		return
	engineering_list += new_target

///Removes mob from list
/datum/ai_behavior/human/proc/remove_from_engineering_list(atom/old_target)
	engineering_list -= old_target



///Tries to heal another mob
/datum/ai_behavior/human/proc/try_build_holo(obj/effect/build_designator/hologram)
	if(hologram.builder)
		//Someone else is building it, but we put it at the end of the queue in case its not completed
		remove_from_engineering_list(hologram)
		add_to_engineering_list(hologram)
		return
	human_ai_state_flags |= HUMAN_AI_BUILDING
	do_unset_target(hologram, FALSE)

	var/obj/item/stack/building_stack
	for(var/candidate in mob_inventory.engineering_list)
		if(!istype(candidate, hologram.material_type))
			continue
		var/obj/item/stack/candi_stack = candidate
		if(candi_stack.amount < hologram.recipe.req_amount)
			continue
		building_stack = candi_stack
		break

	if(!building_stack)
		remove_from_engineering_list(hologram)
		try_speak(pick(unable_to_build_chat))
		return

	try_speak(pick(building_chat))
	hologram.attackby(building_stack, mob_parent)
	on_engineering_end(hologram)
