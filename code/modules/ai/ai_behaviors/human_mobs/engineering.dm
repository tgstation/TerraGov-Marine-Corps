/datum/ai_behavior/human
	///A list of engineering related actions
	var/list/engineering_list = list()
	///Chat lines for trying to build
	var/list/building_chat = list("Building.", "Building, cover me!", "Give me some cover!", "Starting construction.", "Working here.", "Working.", "Cover me, building here.", "Cover me!", "I'm working on it.", "Something need building?", "Work, work.")
	///Chat lines for being unable to build something
	var/list/unable_to_build_chat = list("Can we build it? No, it's FUBAR.", "Unable to build.", "I can't build that.", "Negative.", "Get someone else on it!", "Can't do it, sorry.")

///Checks if we should be building anything
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
	var/target_dist = 10 //lets just check screen range, more or less
	for(var/atom/potential AS in engineering_list)
		if(QDELETED(potential))
			remove_from_engineering_list(potential)
		var/dist = get_dist(mob_parent, potential)
		if(dist >= target_dist)
			continue
		if(istype(potential, /obj/effect/build_designator))
			var/obj/effect/build_designator/hologram = potential
			if(hologram.builder)
				continue
		engie_target = potential
		target_dist = dist
	if(!engie_target)
		return

	set_interact_target(engie_target)
	return TRUE

///Adds atom to list
/datum/ai_behavior/human/proc/add_to_engineering_list(atom/new_target)
	engineering_list |= new_target

///Removes atom from list
/datum/ai_behavior/human/proc/remove_from_engineering_list(atom/old_target)
	engineering_list -= old_target

///Our building ended, successfully or otherwise
/datum/ai_behavior/human/proc/on_engineering_end(atom/old_target)
	SIGNAL_HANDLER
	human_ai_state_flags &= ~HUMAN_AI_BUILDING
	if(QDELETED(old_target))
		remove_from_engineering_list(old_target)
	unset_target(old_target)
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

///Tries to build a holo designation
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

///Repairs an object if possible
/datum/ai_behavior/human/proc/repair_obj(obj/repair_target)
	if(repair_target.obj_integrity >= repair_target.max_integrity)
		remove_from_engineering_list(repair_target)
		on_engineering_end(repair_target)
		return
	var/obj/item/tool/weldingtool/welder = mob_inventory.find_tool(TOOL_WELDER)
	if(!welder)
		remove_from_engineering_list(repair_target)
		on_engineering_end(repair_target)
		return

	human_ai_state_flags |= (HUMAN_AI_BUILDING|HUMAN_AI_NEED_WEAPONS)
	store_hands()
	mob_parent.a_intent = INTENT_HELP
	welder.do_ai_interact(mob_parent, src)

	var/repair_success = FALSE
	if(repair_target.welder_act(mob_parent, welder))
		repair_success = TRUE

	mob_parent.a_intent = INTENT_HARM
	if(welder.isOn())
		welder.toggle()

	var/mob/living/carbon/human/human_owner = mob_parent
	if(welder.get_fuel() < welder.max_fuel && human_owner?.back?.reagents?.get_reagent_amount(/datum/reagent/fuel))
		human_owner.back.attackby(welder, human_owner)

	try_store_item(welder)
	if(!repair_success || (!QDELETED(repair_target) && repair_target.obj_integrity >= repair_target.max_integrity))
		remove_from_engineering_list(repair_target)
	on_engineering_end(repair_target)
