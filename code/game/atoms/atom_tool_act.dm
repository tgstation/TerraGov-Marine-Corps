/**
 * Handles the usage of items with tool behaviors on this atom directly.
 *
 * Handles the tool_acts in particular, such as wrenches and screwdrivers.
 */
/atom/proc/tool_act(mob/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	var/tool_type = tool.tool_behaviour
	if(!tool_type)
		return

	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/is_left_clicking = !is_right_clicking

	var/signal_result = is_left_clicking \
		? SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, tool) \
		: SEND_SIGNAL(src, COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type), user, tool)
	if(signal_result)
		return signal_result
	if(QDELETED(tool))
		return TRUE // Safe-ish to assume that if we deleted our item something succeeded.

	var/act_result
	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = is_left_clicking ? crowbar_act(user, tool) : crowbar_act_secondary(user, tool)
		if(TOOL_MULTITOOL)
			act_result = is_left_clicking ? multitool_act(user, tool) : multitool_act_secondary(user, tool)
		if(TOOL_SCREWDRIVER)
			act_result = is_left_clicking ? screwdriver_act(user, tool) : screwdriver_act_secondary(user, tool)
		if(TOOL_WRENCH)
			act_result = is_left_clicking ? wrench_act(user, tool) : wrench_act_secondary(user, tool)
		if(TOOL_WIRECUTTER)
			act_result = is_left_clicking ? wirecutter_act(user, tool) : wirecutter_act_secondary(user, tool)
		if(TOOL_WELDER)
			act_result = is_left_clicking ? welder_act(user, tool) : welder_act_secondary(user, tool)
		if(TOOL_ANALYZER)
			act_result = is_left_clicking ? analyzer_act(user, tool) : analyzer_act_secondary(user, tool)
		if(TOOL_FULTON)
			act_result = is_left_clicking ? fulton_act(user, tool) : fulton_act_secondary(user, tool)
		if(TOOL_PLASMACUTTER)
			act_result = is_left_clicking ? plasmacutter_act(user, tool) : plasmacutter_act_secondary(user, tool)

	if(!act_result)
		return

	// A tooltype_act has completed successfully.
	if(is_left_clicking)
		log_tool("[key_name(user)] used [tool] on [src] at [AREACOORD(src)]")
		SEND_SIGNAL(tool, COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_type), src)
	else
		log_tool("[key_name(user)] used [tool] on [src] (right click) at [AREACOORD(src)]")
		SEND_SIGNAL(tool, COMSIG_TOOL_ATOM_ACTED_SECONDARY(tool_type), src)
	SEND_SIGNAL(tool, COMSIG_ITEM_TOOL_ACTED, src, user, tool_type)
	return act_result


/**
 * Tool-specific behavior procs.
 *
 * Return TRUE to cancel the attack.
 * Return FALSE (or null) to continue the attack.
 */

/// Called on an object when a tool with crowbar capabilities is used to LEFT CLICK an atom.
/atom/proc/crowbar_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with crowbar capabilities is used to RIGHT CLICK an atom.
/atom/proc/crowbar_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to LEFT CLICK an atom.
/atom/proc/multitool_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to RIGHT CLICK an atom.
/atom/proc/multitool_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to LEFT CLICK an atom.
/atom/proc/screwdriver_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to RIGHT CLICK an atom.
/atom/proc/screwdriver_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to LEFT CLICK an atom.
/atom/proc/wrench_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to RIGHT CLICK an atom.
/atom/proc/wrench_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to LEFT CLICK an atom.
/atom/proc/wirecutter_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to RIGHT CLICK an atom.
/atom/proc/wirecutter_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to LEFT CLICK an atom.
/atom/proc/welder_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to RIGHT CLICK an atom.
/atom/proc/welder_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to LEFT CLICK an atom.
/atom/proc/analyzer_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to RIGHT CLICK an atom.
/atom/proc/analyzer_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with fulton capabilities is used to LEFT CLICK an atom.
/atom/proc/fulton_act(mob/user, obj/item/tool)
	if(!isturf(loc))
		return FALSE // Storage screens, worn containers, anything we want to be able to interact otherwise.
	to_chat(user, span_warning("Cannot extract [src]."))
	return TRUE

/// Called on an object when a tool with fulton capabilities is used to RIGHT CLICK an atom.
/atom/proc/fulton_act_secondary(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with plasma cutter capabilities is used to LEFT CLICK an atom.
/atom/proc/plasmacutter_act(mob/user, obj/item/tool)
	return

/// Called on an object when a tool with plasma cutter capabilities is used to RIGHT CLICK an atom.
/atom/proc/plasmacutter_act_secondary(mob/user, obj/item/tool)
	return
