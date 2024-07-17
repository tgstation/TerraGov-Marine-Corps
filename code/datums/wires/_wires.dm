#define MAXIMUM_EMP_WIRES 3

/datum/wires
	interaction_flags = INTERACT_UI_INTERACT
	var/atom/holder = null // The holder (atom that contains these wires).
	var/holder_type = null // The holder's typepath (used to make wire colors common to all holders).
	var/proper_name = "Unknown" // The display name for the wire set shown in station blueprints. Not used if randomize is true or it's an item NT wouldn't know about (Explosives/Nuke)

	var/list/wires = list() // List of wires.
	var/list/cut_wires = list() // List of wires that have been cut.
	var/list/colors = list() // Dictionary of colors to wire.
	var/list/assemblies = list() // List of attached assemblies.
	var/randomize = 0 // If every instance of these wires should be random.
						// Prevents wires from showing up in station blueprints


/datum/wires/New(atom/holder)
	. = ..()
	if(!istype(holder, holder_type))
		CRASH("Wire holder is not of the expected type! holder: [holder.type], holder_type: [holder_type]")

	src.holder = holder
	if(randomize)
		randomize()
	else
		if(!GLOB.wire_color_directory[holder_type])
			randomize()
			GLOB.wire_color_directory[holder_type] = colors
		else
			colors = GLOB.wire_color_directory[holder_type]


/datum/wires/Destroy()
	holder = null
	assemblies = list()
	return ..()


/datum/wires/proc/add_duds(duds)
	while(duds)
		var/dud = WIRE_DUD_PREFIX + "[--duds]"
		if(dud in wires)
			continue
		wires += dud


/datum/wires/proc/randomize()
	var/static/list/possible_colors = list(
	"blue",
	"brown",
	"crimson",
	"cyan",
	"gold",
	"grey",
	"green",
	"magenta",
	"orange",
	"pink",
	"purple",
	"red",
	"silver",
	"violet",
	"white",
	"yellow"
	)

	var/list/my_possible_colors = possible_colors.Copy()

	for(var/wire in shuffle(wires))
		colors[pick_n_take(my_possible_colors)] = wire


/datum/wires/proc/shuffle_wires()
	colors.Cut()
	randomize()


/datum/wires/proc/repair()
	cut_wires.Cut()


/datum/wires/proc/get_wire(color)
	return colors[color]


/datum/wires/proc/get_color_of_wire(wire_type)
	for(var/color in colors)
		var/other_type = colors[color]
		if(wire_type == other_type)
			return color


/datum/wires/proc/get_attached(color)
	if(assemblies[color])
		return assemblies[color]
	return null


/datum/wires/proc/is_attached(color)
	if(assemblies[color])
		return TRUE


/datum/wires/proc/is_cut(wire)
	return (wire in cut_wires)


/datum/wires/proc/is_color_cut(color)
	return is_cut(get_wire(color))


/datum/wires/proc/is_all_cut()
	if(length(cut_wires) == length(wires))
		return TRUE


/datum/wires/proc/is_dud(wire)
	return findtext(wire, WIRE_DUD_PREFIX, 1, length(WIRE_DUD_PREFIX) + 1)


/datum/wires/proc/is_dud_color(color)
	return is_dud(get_wire(color))

/datum/wires/proc/cut(wire, mob/user)
	if(user)
		var/skill = user.skills.getRating(SKILL_ENGINEER)
		if(skill < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out the wiring."),
			span_notice("You fumble around figuring out the wiring."))
			if(!do_after(user, 2 SECONDS * (SKILL_ENGINEER_ENGI - skill), NONE, holder, BUSY_ICON_UNSKILLED))
				return

	if(is_cut(wire))
		cut_wires -= wire
		on_cut(wire, mend = TRUE)
	else
		cut_wires += wire
		on_cut(wire, mend = FALSE)


/datum/wires/proc/cut_color(color, mob/user)
	cut(get_wire(color), user)


/datum/wires/proc/cut_random()
	cut(wires[rand(1, length(wires))])


/datum/wires/proc/cut_all()
	for(var/wire in wires)
		cut(wire)


/datum/wires/proc/pulse(wire, mob/user)
	if(is_cut(wire))
		return
	if(user) //Signalers skip pulse delay
		var/skill = user.skills.getRating(SKILL_ENGINEER)
		if(skill < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[usr] fumbles around figuring out the wiring."),
			span_notice("You fumble around figuring out the wiring."))
			if(!do_after(user, 2 SECONDS * (SKILL_ENGINEER_ENGI - skill), NONE, holder, BUSY_ICON_UNSKILLED) || is_cut(wire))
				return

	on_pulse(wire, user)


/datum/wires/proc/pulse_color(color, mob/user)
	pulse(get_wire(color), user)


/datum/wires/proc/pulse_assembly(obj/item/assembly/S)
	for(var/color in assemblies)
		if(S == assemblies[color])
			pulse_color(color)
			return TRUE


/datum/wires/proc/attach_assembly(color, obj/item/assembly/S)
	if(istype(S) && S.attachable && !is_attached(color))
		assemblies[color] = S
		S.forceMove(holder)
		S.connected = src
		return S


/datum/wires/proc/detach_assembly(color)
	var/obj/item/assembly/S = get_attached(color)
	if(!istype(S))
		return

	assemblies -= color
	S.connected = null
	S.forceMove(get_turf(S))
	return S


/datum/wires/proc/emp_pulse()
	var/list/possible_wires = shuffle(wires)
	var/remaining_pulses = MAXIMUM_EMP_WIRES

	for(var/wire in possible_wires)
		if(!prob(33))
			continue
		pulse(wire)
		remaining_pulses--
		if(!remaining_pulses)
			break

/datum/wires/proc/interactable(mob/user)
	return TRUE

/datum/wires/proc/get_status()
	return


/datum/wires/proc/on_cut(wire, mend = FALSE)
	return


/datum/wires/proc/on_pulse(wire, user)
	return
// End Overridable Procs


/datum/wires/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!user.CanReach(holder))
		return FALSE

	return TRUE


/datum/wires/ui_host()
	return holder

/datum/wires/ui_status(mob/user)
	if(interactable(user))
		return ..()
	return UI_CLOSE

/datum/wires/ui_state(mob/user)
	return GLOB.physical_state

/datum/wires/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Wires", "[holder.name] Wires")
		ui.open()

/datum/wires/ui_data(mob/user)
	var/list/data = list()
	var/list/payload = list()
	var/reveal_wires = FALSE

	// Admin ghost can see a purpose of each wire.
	if(IsAdminGhost(user))
		reveal_wires = TRUE

	for(var/color in colors)
		payload.Add(list(list(
			"color" = color,
			"wire" = ((reveal_wires && !is_dud_color(color)) ? get_wire(color) : null),
			"cut" = is_color_cut(color),
			"attached" = is_attached(color)
		)))
	data["wires"] = payload
	data["status"] = get_status()
	return data

/datum/wires/ui_act(action, list/params)
	. = ..()

	if(. || !interactable(usr))
		return
	var/target_wire = params["wire"]
	var/mob/living/L = usr
	var/obj/item/I
	switch(action)
		if("cut")
			I = L.is_holding_tool_quality(TOOL_WIRECUTTER)
			if(I || IsAdminGhost(usr))
				if(I && holder)
					I.play_tool_sound(holder, 20)
				cut_color(target_wire)
				. = TRUE
			else
				holder.balloon_alert(L, "You need wirecutters!")
		if("pulse")
			I = L.is_holding_tool_quality(TOOL_MULTITOOL)
			if(I || IsAdminGhost(usr))
				if(I && holder)
					I.play_tool_sound(holder, 20)
				pulse_color(target_wire, L)
				. = TRUE
			else
				holder.balloon_alert(L, "You need a multitool!")
		if("attach")
			if(is_attached(target_wire))
				I = detach_assembly(target_wire)
				if(I)
					L.put_in_hands(I)
					. = TRUE
			else
				I = L.get_active_held_item()
				if(istype(I, /obj/item/assembly))
					var/obj/item/assembly/A = I
					if(A.attachable)
						if(!L.temporarilyRemoveItemFromInventory(A))
							return
						if(!attach_assembly(target_wire, A))
							A.forceMove(L.drop_location())
						. = TRUE
					else
						holder.balloon_alert(L, "You need an attachable assembly!")

#undef MAXIMUM_EMP_WIRES
