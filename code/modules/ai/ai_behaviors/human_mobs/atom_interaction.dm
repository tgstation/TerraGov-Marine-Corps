/datum/ai_behavior/human/try_interact(atom/interactee)
	if(ishuman(interactee))
		var/mob/living/carbon/human/human = interactee
		if(mob_parent.faction != human.faction)
			return
		INVOKE_ASYNC(src, PROC_REF(try_heal_other), human)
		return TRUE
	INVOKE_ASYNC(interactee, TYPE_PROC_REF(/atom, do_ai_interact), mob_parent, src)
	return TRUE

///Makes the mob attempt to interact with a specified atom
/datum/ai_behavior/human/proc/interaction_designated(datum/source, atom/target)
	SIGNAL_HANDLER
	if(target?.z != mob_parent.z)
		return
	if(get_dist(target, mob_parent) > AI_ESCORTING_MAX_DISTANCE)
		return
	if(isturf(target))
		if(istype(target, /turf/closed/interior/tank/door))
			set_interact_target(target)
			try_speak(pick(receive_order_chat))
			return
		set_atom_to_walk_to(target)
		return
	var/atom/movable/movable_target = target
	if(!movable_target.faction) //atom defaults to null faction, so apc's etc
		set_interact_target(movable_target)
		try_speak(pick(receive_order_chat))
		return
	if(movable_target.faction != mob_parent.faction)
		set_combat_target(movable_target)
		return
	if(isliving(movable_target))
		var/mob/living/living_target = target
		if(!living_target.stat)
			set_escorted_atom(null, living_target)
	set_interact_target(movable_target)
	try_speak(pick(receive_order_chat))

///Adds an atom to the interest list
/datum/ai_behavior/human/proc/add_atom_of_interest(atom/new_atom)
	if(new_atom in atoms_to_interact)
		return
	RegisterSignal(new_atom, COMSIG_QDELETING, PROC_REF(unset_target), TRUE) //it might already be an interaction target
	atoms_to_interact += new_atom

///Removes an atom from the interest list
/datum/ai_behavior/human/proc/remove_atom_of_interest(atom/old_atom)
	UnregisterSignal(old_atom, COMSIG_QDELETING)
	atoms_to_interact -= old_atom

///If an item is considered important, we add it to the list to pick up later
/datum/ai_behavior/human/proc/on_item_unequip(mob/living/source, obj/item/dropped)
	SIGNAL_HANDLER
	if(QDELETED(dropped) || !dropped.is_npc_item_of_interest())
		return
	add_atom_of_interest(dropped)

///Attempts to pickup an item
/datum/ai_behavior/human/proc/pick_up_item(obj/item/new_item)
	store_hands()

	var/datum/limb/check_hand = mob_parent.get_limb(mob_parent.hand ? "l_hand" : "r_hand")
	if(mob_parent.get_active_held_item() || !check_hand?.is_usable()) //either occupied or unusable
		check_hand = mob_parent.get_limb(mob_parent.hand ? "r_hand" : "l_hand")
		if(mob_parent.get_inactive_held_item() || !check_hand?.is_usable()) //off hand is the same
			return
		mob_parent.swap_hand()

	mob_parent.UnarmedAttack(new_item, TRUE)


///Returns TRUE if an NPC should record this as an item of interest for later pickup/interaction
/obj/item/proc/is_npc_item_of_interest()
	return TRUE

/obj/item/explosive/grenade/is_npc_item_of_interest()
	return !active //don't try pick up a primed nade pls

/obj/item/ammo_magazine/is_npc_item_of_interest()
	return current_rounds

/obj/item/cell/is_npc_item_of_interest()
	return charge >= (maxcharge * 0.1) //ignore cells with trace power left since eguns and such might not empty them entirely

/obj/item/reagent_containers/is_npc_item_of_interest()
	return reagents?.total_volume
