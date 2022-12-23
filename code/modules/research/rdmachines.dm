
//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.

/obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE
	var/busy = FALSE
	var/hacked = FALSE
	var/locked = FALSE // Researcher priority usage
	var/console_link = FALSE //allow console link.
	var/disabled = FALSE

/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/rnd(src)

/obj/machinery/rnd/Destroy()
	QDEL_NULL(wires)
	return ..()

//
/// enable tools and hacking
//
/obj/machinery/rnd/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/rnd/screwdriver_act(mob/living/user, obj/item/tool)
	if((flags_atom & NODECONSTRUCT) || tool.tool_behaviour != TOOL_SCREWDRIVER)
		return FALSE

	tool.play_tool_sound(src, 50)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		icon_state = "[initial(icon_state)]_t"
		to_chat(user, span_notice("You open the maintenance hatch of [src]."))
	else
		icon_state = initial(icon_state)
		to_chat(user, span_notice("You close the maintenance hatch of [src]."))
	TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
	return TRUE

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		wires.interact(user)
		return TRUE

/obj/machinery/rnd/wirecutter_act(mob/living/user, obj/item/tool)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		wires.interact(user)
		return TRUE

//whether the machine can have an item inserted in its current state.
/obj/machinery/rnd/proc/is_insertion_ready(mob/user)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		to_chat(user, span_warning("You can't load [src] while it's opened!"))
		return FALSE
	if(disabled)
		to_chat(user, span_warning("The insertion belts of [src] won't engage!"))
		return FALSE
	if(busy)
		to_chat(user, span_warning("[src] is busy right now."))
		return FALSE
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("[src] is broken."))
		return FALSE
	if(machine_stat & NOPOWER)
		to_chat(user, span_warning("[src] has no power."))
		return FALSE
	return TRUE
