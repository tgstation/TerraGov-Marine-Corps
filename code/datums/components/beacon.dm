///This component is used to give stuff beacon functionality.
/datum/component/beacon
	///Is the beacon active?
	var/active = FALSE
	///The reference to the beacon datum
	var/datum/supply_beacon/beacon_datum
	///The camera attached to the beacon
	var/obj/machinery/camera/beacon_cam
	///Should the parent anchor on activation?
	var/anchor = FALSE
	///How long it takes for this item to activate it's signal/deploy
	var/anchor_time = 0
	///The icon state when this beacon is active
	var/active_icon_state = ""
	///The mob who activated this beacon
	var/mob/activator
	///Initial name of the beacon, used in GLOB.supply_beacon
	var/beacon_name

/datum/component/beacon/Initialize(_anchor = FALSE, _anchor_time = 0, _active_icon_state = "")
	. = ..()
	if(_anchor && !_anchor_time || !_anchor && _anchor_time)
		stack_trace("The beacon component has been added to [parent.type] and is missing either the anchor var or the time to anchor")
		return COMPONENT_INCOMPATIBLE
	if(!ismovableatom(parent)) //if some goober admin tries to add it to a turf or something
		return COMPONENT_INCOMPATIBLE
	anchor = _anchor
	anchor_time = _anchor_time
	active_icon_state = _active_icon_state

/datum/component/beacon/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_NAME, PROC_REF(on_update_name))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))

/datum/component/beacon/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ATOM_UPDATE_NAME,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_MOVABLE_Z_CHANGED,
		))
	QDEL_NULL(beacon_datum)
	QDEL_NULL(beacon_cam)
	activator = null

///Toggles the active state of the beacon
/datum/component/beacon/proc/toggle_activation(atom/movable/source, mob/user)
	active = !active

	if(active)
		INVOKE_ASYNC(src, PROC_REF(activate), source, user)
	else
		INVOKE_ASYNC(src, PROC_REF(deactivate), source, user)

///The proc that gets called when the user uses the item in their hand
/datum/component/beacon/proc/on_attack_self(atom/movable/source, mob/user)
	SIGNAL_HANDLER

	if(!ishuman(user))
		return

	if(length(user.do_actions))
		user.balloon_alert(user, "Busy!")
		return

	INVOKE_ASYNC(src, PROC_REF(toggle_activation), source, user)

///This will only get called when you want to deactivate a beacon, ie clicking a deployed beacon
/datum/component/beacon/proc/on_attack_hand(atom/movable/source, mob/user)
	if(!source.anchored || !ishuman(user))
		return

	if(length(user.do_actions))
		user.balloon_alert(user, "Busy!")
		return

	INVOKE_ASYNC(src, PROC_REF(deactivate), source, user)

///Activates the beacon
/datum/component/beacon/proc/activate(atom/movable/source, mob/user)
	var/turf/location = get_turf(source)
	var/area/curr_area = get_area(location)
	if(check_for_blacklist(source))
		active = FALSE
		return FALSE
	if(length(user.do_actions))
		user.balloon_alert(user, "Busy!")
		active = FALSE
		return
	if(anchor && anchor_time)
		var/delay = max(1.5 SECONDS, anchor_time - 2 SECONDS * user.skills.getRating(SKILL_LEADERSHIP))
		user.visible_message(span_notice("[user] starts setting up [source] on the ground."),
		span_notice("You start setting up [source] on the ground and inputting all the data it needs."))
		if(!do_after(user, delay, NONE, source))
			user.balloon_alert(user, "Keep still!")
			active = FALSE
			return
	activator = user

	if(anchor) //Only anchored beacons have cameras and lights
		var/obj/machinery/camera/beacon_cam/BC = new(source, "[user.get_paygrade()] [user.name] [source]")
		user.dropItemToGround(source)
		beacon_cam = BC
		source.anchored = TRUE
		source.layer = ABOVE_OBJ_LAYER
		source.set_light(2, 1)
		var/marker_flags = GLOB.faction_to_minimap_flag[user.faction]
		if(!marker_flags)
			marker_flags = MINIMAP_FLAG_MARINE
		SSminimaps.add_marker(source, marker_flags, image('icons/UI_icons/map_blips.dmi', null, "supply", MINIMAP_BLIPS_LAYER))

	message_admins("[ADMIN_TPMONTY(user)] set up a supply beacon.") //do something with this
	playsound(source, 'sound/machines/twobeep.ogg', 15, 1)
	user.visible_message("[user] activates [source]'s signal.")
	user.show_message(span_notice("The [source] beeps and states, \"Your current coordinates were registered by the supply console. LONGITUDE [location.x]. LATITUDE [location.y]. Area ID: [get_area(source)]\""), EMOTE_AUDIBLE, span_notice("The [source] vibrates but you can not hear it!"))
	beacon_name = initial(source.name)
	beacon_datum = new /datum/supply_beacon("[curr_area] - [beacon_name] - [activator]", get_turf(source), user.faction)
	RegisterSignal(beacon_datum, COMSIG_QDELETING, PROC_REF(clean_beacon_datum))
	if(ismob(source.loc))
		RegisterSignal(source.loc, COMSIG_MOVABLE_MOVED, PROC_REF(updatepos))
	else
		RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(updatepos))
	RegisterSignal(source, COMSIG_ITEM_EQUIPPED, PROC_REF(equip))
	RegisterSignal(source, COMSIG_ITEM_DROPPED, PROC_REF(dropped))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SUPPLY_BEACON_CREATED, src)
	source.update_appearance()

///Deactivates the beacon
/datum/component/beacon/proc/deactivate(atom/movable/source, mob/user)
	if(length(user?.do_actions))
		user.balloon_alert(user, "Busy!")
		active = TRUE
		return
	if(source.anchored)
		if(user)
			var/delay = max(1 SECONDS, anchor_time * 0.5 - 2 SECONDS * user.skills.getRating(SKILL_LEADERSHIP)) //Half as long as setting it up.
			user.visible_message(span_notice("[user] starts removing [source] from the ground."),
			span_notice("You start removing [source] from the ground, deactivating it."))
			if(!do_after(user, delay, NONE, source, BUSY_ICON_GENERIC))
				user.balloon_alert(user, "Keep still!")
				active = TRUE
				return
			user.put_in_active_hand(source)
			user.show_message(span_warning("The [source] beeps and states, \"Your last position is no longer accessible by the supply console"), EMOTE_AUDIBLE, span_notice("The [source] vibrates but you can not hear it!"))
		source.anchored = FALSE
		source.layer = initial(source.layer)
		source.set_light(0)
		SSminimaps.remove_marker(source)

	source.visible_message(span_warning("[source] stops emitting a signal."))
	QDEL_NULL(beacon_cam)
	QDEL_NULL(beacon_datum)
	activator = null
	playsound(source, 'sound/machines/twobeep.ogg', 15, 1)
	active = FALSE //this is here because of attack hand
	UnregisterSignal(source,COMSIG_MOVABLE_MOVED)
	if(source.loc)
		UnregisterSignal(source.loc,COMSIG_MOVABLE_MOVED)
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	source.update_appearance()

///Updates position and name of the beacon, or alternatively turns if off if it's in a blacklisted area.
/datum/component/beacon/proc/updatepos(atom/movable/source)
	SIGNAL_HANDLER
	var/turf/location = get_turf(parent)
	var/area/curr_area = get_area(location)
	if(check_for_blacklist(source))
		INVOKE_ASYNC(src, PROC_REF(deactivate), parent)
		return
	beacon_datum.drop_location = location
	GLOB.supply_beacon -= beacon_datum.name //prevents duplicate entries in supply console
	beacon_datum.name = "[curr_area] - [beacon_name] - [activator]"
	GLOB.supply_beacon[beacon_datum.name] = src.beacon_datum
	var/atom/movable/movableparent = parent
	movableparent.update_appearance()

///Checks if the area is deep underground or is a dropship. Returns TRUE if there shouldn't be a beacon there
/datum/component/beacon/proc/check_for_blacklist(atom/movable/source)
	var/turf/location = get_turf(parent)
	var/area/curr_area = get_area(location)
	if(istype(curr_area) && curr_area.ceiling >= CEILING_DEEP_UNDERGROUND)
		source.balloon_alert_to_viewers("The beacon won't work if you're standing deep underground.")
		return TRUE
	if(istype(curr_area, /area/shuttle/dropship))
		source.balloon_alert_to_viewers("You have to be outside the dropship to use this or the beacon won't transmit.")
		return TRUE

///Called on picking up or otherwise equipping the beacon
/datum/component/beacon/proc/equip(obj/item/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(source.loc, COMSIG_MOVABLE_MOVED)
	RegisterSignal(source.loc, COMSIG_MOVABLE_MOVED, PROC_REF(updatepos))

///Called on dropping the beacon
/datum/component/beacon/proc/dropped(obj/item/source)
	SIGNAL_HANDLER
	UnregisterSignal(source.loc, COMSIG_MOVABLE_MOVED)

///Adds an extra line of instructions to the examine
/datum/component/beacon/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Activate in hand to create a supply beacon signal.")

///If the signal source dies, the beacon datum should as well
/datum/component/beacon/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

///Gives the beacon broadcaster object the appropriate, descriptive name
/datum/component/beacon/proc/on_update_name(atom/source, updates)
	SIGNAL_HANDLER
	if(active)
		source.name = "[initial(source.name)] - [get_area(source)] - [activator]" //Otherwise updatepos would stack the position - name
		return
	source.name = initial(source.name)

///Updates the icon state of the object to an active state, if it has one
/datum/component/beacon/proc/on_update_icon_state(atom/source, updates)
	SIGNAL_HANDLER
	if(active)
		source.icon = icon(source.icon, active_icon_state)
	else
		source.icon = initial(source.icon)

///What happens when we change Z level
/datum/component/beacon/proc/on_z_change(atom/source, old_z, new_z)
	SIGNAL_HANDLER
	if(active)
		beacon_datum.drop_location = get_turf(source)
		return

/datum/component/beacon/ai_droid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_UNMANNED_COORDINATES, PROC_REF(toggle_activation))

/datum/component/beacon/ai_droid/on_attack_hand(atom/movable/source, mob/user)
	return //dont want marines disabling ai droid by clicking it even if it would be funny

/datum/component/beacon/ai_droid/on_examine(atom/source, mob/user, list/examine_list)
	return //we can't attack this in hand

/datum/supply_beacon
	/// Name printed on the supply console
	var/name = ""
	/// Where the supply drops will land
	var/turf/drop_location
	/// The faction of the beacon
	var/faction = ""

/datum/supply_beacon/New(_name, turf/_drop_location, _faction, life_time = 0 SECONDS)
	name = _name
	drop_location = _drop_location
	faction = _faction
	GLOB.supply_beacon[name] = src
	if(life_time)
		QDEL_IN(src, life_time)

/// Remove that beacon from the list of glob supply beacon
/datum/supply_beacon/Destroy()
	GLOB.supply_beacon -= name
	return ..()
