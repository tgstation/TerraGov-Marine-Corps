///Notifies the npc_controller component of a new NPC to slave to the atom
/atom/proc/add_slaved_npc(mob/living/new_slave)
	SEND_SIGNAL(src, COMSIG_COMPONENT_ADD_NEW_SLAVE_NPC, new_slave)

///Allows an atom to rally NPC's to it
/datum/component/npc_controller
	var/faction
	///Escort priority
	var/npc_priority
	///list of slaved NPC's
	var/list/npc_list = list()

/datum/component/npc_controller/Initialize(new_faction, priority_rating = AI_ESCORT_RATING_ENSALVED_STRONG, list/slaved_npc_list)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	faction = new_faction
	npc_priority = priority_rating
	for(var/slave in slaved_npc_list)
		register_slave(slave)

/datum/component/npc_controller/Destroy(force, silent)
	for(var/slave in npc_list)
		unregister_slave(slave)
	return ..()

/datum/component/npc_controller/RegisterWithParent()
	//sig to add/remove npc slaves
	RegisterSignal(parent, COMSIG_COMPONENT_ADD_NEW_SLAVE_NPC, PROC_REF(register_slave))

/datum/component/npc_controller/UnregisterFromParent()

///Offers the parent as an escort target
/datum/component/npc_controller/proc/get_escort_target(mob/living/source, list/goal_list)
	SIGNAL_HANDLER
	goal_list[parent] = npc_priority

///Tie an NPC to parent
/datum/component/npc_controller/proc/register_slave(mob/living/new_slave)
	SIGNAL_HANDLER
	RegisterSignal(new_slave, COMSIG_NPC_FIND_NEW_ESCORT, PROC_REF(get_escort_target))
	RegisterSignal(new_slave, COMSIG_QDELETING, PROC_REF(unregister_slave))
	npc_list += new_slave

///Release an NPC from parent
/datum/component/npc_controller/proc/unregister_slave(mob/living/old_slave)
	SIGNAL_HANDLER
	UnregisterSignal(old_slave, list(COMSIG_NPC_FIND_NEW_ESCORT, COMSIG_QDELETING))
	npc_list -= old_slave
