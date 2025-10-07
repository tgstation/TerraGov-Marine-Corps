/obj/machinery/power/apc/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item.tool_behaviour)
		switch(held_item.tool_behaviour)
			if(TOOL_CROWBAR)
				if(opened)
					if(opened != APC_COVER_REMOVED)
						context[SCREENTIP_CONTEXT_LMB] = "Open cover"
					else
						context[SCREENTIP_CONTEXT_LMB] = "Remove APC board"
				else
					context[SCREENTIP_CONTEXT_LMB] = "Open Cover"
			if(TOOL_SCREWDRIVER)
				if(opened)
					if(cell)
						context[SCREENTIP_CONTEXT_LMB] = "Remove cell"
					else
						switch(has_electronics)
							if(APC_ELECTRONICS_INSTALLED)
								context[SCREENTIP_CONTEXT_LMB] = "Secure circuit board"
							if(APC_ELECTRONICS_SECURED)
								context[SCREENTIP_CONTEXT_LMB] = "Unfasten electronics"
				else
					context[SCREENTIP_CONTEXT_LMB] = "Expose wires"
			if(TOOL_WIRECUTTER)
				if(terminal && opened)
					context[SCREENTIP_CONTEXT_LMB] = "Cut terminal wires"
				else if (opened)
					context[SCREENTIP_CONTEXT_LMB] = "Cut wires"
			if(TOOL_WELDER)
				if(opened && !has_electronics && !terminal)
					context[SCREENTIP_CONTEXT_LMB] = "Cut APC from wall"
			if(TOOL_MULTITOOL)
				context[SCREENTIP_CONTEXT_LMB] = "Pulse terminal wires"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/cell))
		if(opened && !cell)
			context[SCREENTIP_CONTEXT_LMB] = "Insert cell"
	else if(istype(held_item, /obj/item/card/id))
		if(!opened && !(CHECK_BITFIELD(machine_stat, PANEL_OPEN)) && !(machine_stat & (BROKEN|MAINT)))
			context[SCREENTIP_CONTEXT_LMB] = locked ? "Unlock interface" : "Lock interface"
	else if(iscablecoil(held_item))
		if(!terminal && opened && has_electronics != APC_ELECTRONICS_SECURED)
			context[SCREENTIP_CONTEXT_LMB] = "Wire APC to network"
	else if(istype(held_item, /obj/item/circuitboard/apc))
		if(opened && has_electronics == APC_ELECTRONICS_MISSING && !(machine_stat & BROKEN))
			context[SCREENTIP_CONTEXT_LMB] = "Insert APC board"
	else if(istype(held_item, /obj/item/frame/apc))
		if(opened && (machine_stat & BROKEN) && !has_electronics)
			context[SCREENTIP_CONTEXT_LMB] = "Replace front panel"
		else if(opened && !(machine_stat & BROKEN))
			context[SCREENTIP_CONTEXT_LMB] = "Replace front panel"

	return CONTEXTUAL_SCREENTIP_SET
