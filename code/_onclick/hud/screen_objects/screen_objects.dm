/atom/movable/screen
	name = ""
	icon = 'icons/mob/screen/generic.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	resistance_flags = RESIST_ALL | PROJECTILE_IMMUNE
	appearance_flags = APPEARANCE_UI
	var/obj/master //A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud // A reference to the owner HUD, if any./atom/movable/screen

	//Map popups
	/**
	 * Map name assigned to this object.
	 * Automatically set by /client/proc/add_obj_to_map.
	 */
	var/assigned_map
	/**
	 * Mark this object as garbage-collectible after you clean the map
	 * it was registered on.
	 *
	 * This could probably be changed to be a proc, for conditional removal.
	 * But for now, this works.
	 */
	var/del_on_map_removal = TRUE

/atom/movable/screen/Destroy()
	master = null
	hud = null
	return ..()


/atom/movable/screen/proc/component_click(atom/movable/screen/component_button/component, params)
	return



/atom/movable/screen/swap_hand
	name = "swap hand"
	name = "swap"
	icon_state = "swap_1_m"
	screen_loc = ui_swaphand1

/atom/movable/screen/swap_hand/Click()
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/M = usr
	M.swap_hand()

/atom/movable/screen/swap_hand/right
	icon_state = "swap_2"
	screen_loc = ui_swaphand2

/atom/movable/screen/swap_hand/human
	icon_state = "swap_1"

/atom/movable/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/atom/movable/screen/language_menu/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.language_menu()

/atom/movable/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	var/list/object_overlays = list()


/atom/movable/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(isobserver(usr) || usr.incapacitated(TRUE))
		return TRUE

	if(istype(usr.loc, /obj/vehicle/multitile/root/cm_armored)) // stops inventory actions in a mech/tank
		return TRUE

	//If there is an item in the slot you are clicking on, this will relay the click to the item within the slot
	var/atom/item_in_slot = usr.get_item_by_slot(slot_id)
	if(item_in_slot)
		return item_in_slot.Click(location, control, params)

	if(!istype(src, /atom/movable/screen/inventory/hand) && usr.attack_ui(slot_id)) // until we get a proper hands refactor
		usr.update_inv_l_hand()
		usr.update_inv_r_hand()
		return TRUE

/atom/movable/screen/inventory/hand
	name = "l_hand"
	icon_state = "hand_l"
	screen_loc = ui_lhand
	var/hand_tag = "l"

/atom/movable/screen/inventory/hand/update_icon(active = FALSE)
	cut_overlays()
	if(active)
		add_overlay("hand_active")

/atom/movable/screen/inventory/hand/Click(location, control, params)
	. = ..()
	if(.)
		var/mob/living/carbon/C = usr
		C.activate_hand(hand_tag)

/atom/movable/screen/inventory/hand/right
	name = "r_hand"
	icon_state = "hand_r"
	screen_loc = ui_rhand
	hand_tag = "r"

/atom/movable/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	icon_state = "backpack_close"


/atom/movable/screen/close/Click()
	if(istype(master, /obj/item/storage))
		var/obj/item/storage/S = master
		S.close(usr)
	return TRUE


/atom/movable/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti


/atom/movable/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)


/atom/movable/screen/act_intent/corner/Click(location, control, params)
	var/_x = text2num(params2list(params)["icon-x"])
	var/_y = text2num(params2list(params)["icon-y"])

	if(_x<=16 && _y<=16)
		usr.a_intent_change(INTENT_HARM)

	else if(_x<=16 && _y>=17)
		usr.a_intent_change(INTENT_HELP)

	else if(_x>=17 && _y<=16)
		usr.a_intent_change(INTENT_GRAB)

	else if(_x>=17 && _y>=17)
		usr.a_intent_change(INTENT_DISARM)


/atom/movable/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "running"
	screen_loc = ui_movi


/atom/movable/screen/mov_intent/Click()
	usr.toggle_move_intent()


/atom/movable/screen/mov_intent/update_icon(mob/user)
	if(!user)
		return

	switch(user.m_intent)
		if(MOVE_INTENT_RUN)
			icon_state = "running"
		if(MOVE_INTENT_WALK)
			icon_state = "walking"

/atom/movable/screen/mov_intent/alien
	icon = 'icons/mob/screen/alien.dmi'

/atom/movable/screen/rest
	name = "rest"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "act_rest"
	screen_loc = ui_above_movement

/atom/movable/screen/rest/Click()
	if(!isliving(usr))
		return
	var/mob/living/L = usr
	L.lay_down()

/atom/movable/screen/rest/update_icon(mob/mymob)
	if(!isliving(mymob))
		return
	var/mob/living/L = mymob
	icon_state = "act_rest[L.resting ? "0" : ""]"

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "pull0"
	screen_loc = ui_above_movement


/atom/movable/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()


/atom/movable/screen/pull/update_icon(mob/user)
	if(!user)
		return
	if(user.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"


/atom/movable/screen/resist
	name = "resist"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "act_resist"
	screen_loc = ui_above_intent


/atom/movable/screen/resist/Click()
	if(!isliving(usr))
		return

	var/mob/living/L = usr
	L.resist()


/atom/movable/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"


/atom/movable/screen/storage/proc/update_fullness(obj/item/storage/S)
	if(!length(S.contents))
		color = null
		return

	var/total_w = 0
	for(var/obj/item/I in S)
		total_w += I.w_class
	var/fullness = round(10 * max(length(S.contents) / S.storage_slots, total_w / S.max_storage_space))
	switch(fullness)
		if(10)
			color = "#ff0000"
		if(7 to 9)
			color = "#ffa500"
		else
			color = null


/atom/movable/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw

/atom/movable/screen/throw_catch/Click()
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/C = usr
	C.toggle_throw_mode()

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"
	var/list/hover_overlays_cache = list()
	var/hovering
	var/z_prefix

/atom/movable/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if (!choice)
		return TRUE

	return set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[z_prefix][choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/mob/screen/zone_sel.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_PRECISE_R_FOOT
				if(17 to 22)
					return BODY_ZONE_PRECISE_L_FOOT
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_R_LEG
				if(17 to 22)
					return BODY_ZONE_L_LEG
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_PRECISE_R_HAND
				if(12 to 20)
					return BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					return BODY_ZONE_PRECISE_L_HAND
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_R_ARM
				if(12 to 20)
					return BODY_ZONE_CHEST
				if(21 to 24)
					return BODY_ZONE_L_ARM
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return BODY_ZONE_PRECISE_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return BODY_ZONE_PRECISE_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							return BODY_ZONE_PRECISE_EYES
				return BODY_ZONE_HEAD

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(isobserver(user))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(user)
	return TRUE

/atom/movable/screen/zone_sel/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen/zone_sel.dmi', "[z_prefix][selecting]"))
	user.zone_selected = selecting

/atom/movable/screen/zone_sel/alien
	icon = 'icons/mob/screen/alien.dmi'
	z_prefix = "ay_"

/atom/movable/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health
	icon = 'icons/mob/screen/health.dmi'

/atom/movable/screen/healths/alien
	icon = 'icons/mob/screen/alien.dmi'
	screen_loc = ui_alien_health

/atom/movable/screen/stamina_hud
	icon = 'icons/mob/screen/health.dmi'
	name = "stamina"
	icon_state = "staminaloss0"
	screen_loc = UI_STAMINA
	mouse_opacity = MOUSE_OPACITY_ICON

/atom/movable/screen/stamina_hud/Click(location, control, params)
	if(!isliving(usr))
		return
	var/mob/living/living_user = usr
	if(living_user.getStaminaLoss() < 0 && living_user.max_stamina)
		living_user.balloon_alert(living_user, "Stamina buffer:[(-living_user.getStaminaLoss() * 100 / living_user.max_stamina)]%")
		return
	living_user.balloon_alert(living_user, "You have [living_user.getStaminaLoss()] stamina loss")


/atom/movable/screen/component_button
	var/atom/movable/screen/parent

/atom/movable/screen/component_button/Initialize(mapload, atom/movable/screen/parent)
	. = ..()
	src.parent = parent

/atom/movable/screen/component_button/Click(params)
	parent?.component_click(src, params)

/atom/movable/screen/action_button
	icon = 'icons/mob/actions.dmi'
	icon_state = "template"
	var/datum/action/source_action

/atom/movable/screen/action_button/Click(location, control, params)
	if(!usr || !source_action)
		return TRUE
	if(usr.next_move >= world.time)
		return TRUE
	var/list/modifiers = params2list(params)
	if(modifiers["right"])
		source_action.alternate_action_activate()
		return
	if(source_action.can_use_action(FALSE, NONE, TRUE))
		source_action.action_activate()
	else
		source_action.fail_activate()

/atom/movable/screen/action_button/Destroy()
	source_action = null
	return ..()

/atom/movable/screen/action_button/proc/get_button_screen_loc(button_number)
	var/row = round((button_number-1)/13) //13 is max amount of buttons per row
	var/col = ((button_number - 1)%(13)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = 26
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"

/atom/movable/screen/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/mob/actions.dmi'
	icon_state = "hide"
	var/hidden = 0

/atom/movable/screen/action_button/hide_toggle/Click()
	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden
	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
		icon_state = "show"
	else
		name = "Hide Buttons"
		icon_state = "hide"
	usr.update_action_buttons()
	return TRUE

/atom/movable/screen/SL_locator
	name = "sl locator"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "Blue_arrow"
	alpha = 0 //invisible
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_sl_dir

/atom/movable/screen/drop
	name = "drop"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	layer = HUD_LAYER

/atom/movable/screen/drop/Click()
	usr.drop_item_v()

/atom/movable/screen/bodytemp
	name = "body temperature"
	icon_state = "temp0"
	screen_loc = ui_temp


/atom/movable/screen/oxygen
	name = "oxygen"
	icon_state = "oxy0"
	screen_loc = ui_oxygen


/atom/movable/screen/fire
	name = "fire"
	icon_state = "fire0"
	screen_loc = ui_fire


/atom/movable/screen/toggle_inv
	name = "toggle"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "toggle"
	screen_loc = ui_inventory

/atom/movable/screen/toggle_inv/Click()
	if(usr.hud_used.inventory_shown)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= usr.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += usr.hud_used.toggleable_inventory

	usr.hud_used.hidden_inventory_update()


#define AMMO_HUD_ICON_NORMAL 1
#define AMMO_HUD_ICON_EMPTY 2
/**
 * HUD ammo indicator
 *
 * Displays a number and an icon representing the ammo for up to 4 at a time
 */
/atom/movable/screen/ammo
	name = "ammo"
	icon = 'icons/mob/ammoHUD.dmi'
	icon_state = "ammo"
	screen_loc = ui_ammo1
	///If the user has already had their warning played for running out of ammo
	var/warned = FALSE
	///Holder for playing a out of ammo animation so that it doesnt get cut during updates
	var/atom/movable/flash_holder
	///List of possible screen locs
	var/static/list/ammo_screen_loc_list = list(ui_ammo1, ui_ammo2, ui_ammo3, ui_ammo4)

/atom/movable/screen/ammo/Initialize(mapload)
	. = ..()
	flash_holder = new
	flash_holder.icon_state = "frame"
	flash_holder.icon = icon
	flash_holder.plane = plane
	flash_holder.layer = layer+0.001
	flash_holder.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_contents += flash_holder

/atom/movable/screen/ammo/Destroy()
	QDEL_NULL(flash_holder)
	return ..()

///wrapper to add this to the users screen with a owner
/atom/movable/screen/ammo/proc/add_hud(mob/living/user, datum/ammo_owner)
	if(isnull(ammo_owner))
		CRASH("/atom/movable/screen/ammo/proc/add_hud() has been called from [src] without the required param of ammo_owner")
	user?.client.screen += src

///wrapper to removing this ammo hud from the users screen
/atom/movable/screen/ammo/proc/remove_hud(mob/living/user)
	user?.client?.screen -= src

///actually handles upadating the hud
/atom/movable/screen/ammo/proc/update_hud(mob/living/user, list/ammo_type, rounds)
	overlays.Cut()

	if(rounds <= 0)
		overlays += image('icons/mob/ammoHUD.dmi', src, "o0")
		var/image/empty_state = image('icons/mob/ammoHUD.dmi', src, ammo_type[AMMO_HUD_ICON_EMPTY])
		overlays += empty_state
		if(warned)
			return
		warned = TRUE
		flick("[ammo_type[AMMO_HUD_ICON_EMPTY]]_flash", flash_holder)
		return

	warned = FALSE
	overlays += image('icons/mob/ammoHUD.dmi', src, "[ammo_type[AMMO_HUD_ICON_NORMAL]]")

	rounds = num2text(rounds)

	//Handle the amount of rounds
	switch(length(rounds))
		if(1)
			overlays += image('icons/mob/ammoHUD.dmi', src, "o[rounds[1]]")
		if(2)
			overlays += image('icons/mob/ammoHUD.dmi', src, "o[rounds[2]]")
			overlays += image('icons/mob/ammoHUD.dmi', src, "t[rounds[1]]")
		if(3)
			overlays += image('icons/mob/ammoHUD.dmi', src, "o[rounds[3]]")
			overlays += image('icons/mob/ammoHUD.dmi', src, "t[rounds[2]]")
			overlays += image('icons/mob/ammoHUD.dmi', src, "h[rounds[1]]")
		else //"0" is still length 1 so this means it's over 999
			overlays += image('icons/mob/ammoHUD.dmi', src, "o9")
			overlays += image('icons/mob/ammoHUD.dmi', src, "t9")
			overlays += image('icons/mob/ammoHUD.dmi', src, "h9")

#undef AMMO_HUD_ICON_NORMAL
#undef AMMO_HUD_ICON_EMPTY

/atom/movable/screen/arrow
	icon = 'icons/Marine/marine-items.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_sl_dir
	alpha = 128 //translucent
	///The mob for which the arrow appears
	var/mob/living/carbon/tracker
	///The target which the arrow points to
	var/atom/target
	///The duration of the effect
	var/duration = 1
	///holder for the deletation timer
	var/del_timer

/atom/movable/screen/arrow/proc/add_hud(mob/living/carbon/tracker_input, atom/target_input)
	if(!tracker_input?.client)
		return
	if(target_input == tracker_input)
		return
	tracker = tracker_input
	target = target_input
	tracker.client.screen += src
	RegisterSignal(tracker, COMSIG_QDELETING, PROC_REF(kill_arrow))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(kill_arrow))
	process() //Ping immediately after parameters have been set

///Stop the arrow to avoid runtime and hard del
/atom/movable/screen/arrow/proc/kill_arrow()
	SIGNAL_HANDLER
	if(tracker?.client)
		tracker.client.screen -= src
	deltimer(del_timer)
	qdel(src)

/atom/movable/screen/arrow/Initialize(mapload) //Self-deletes
	. = ..()
	START_PROCESSING(SSprocessing, src)
	del_timer = addtimer(CALLBACK(src, PROC_REF(kill_arrow)), duration, TIMER_STOPPABLE)

/atom/movable/screen/arrow/process() //We ping the target, revealing its direction with an arrow
	if(!target || !tracker)
		return PROCESS_KILL
	if(target.z != tracker.z || get_dist(tracker, target) < 2 || tracker == target)
		alpha = 0
	else
		alpha = 128
		transform = 0 //Reset and 0 out
		transform = turn(transform, Get_Angle(tracker, target))

/atom/movable/screen/arrow/Destroy()
	target = null
	tracker = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/atom/movable/screen/arrow/leader_tracker_arrow
	name = "hive leader tracker arrow"
	icon_state = "Blue_arrow"
	duration = XENO_RALLYING_POINTER_DURATION

/atom/movable/screen/arrow/silo_damaged_arrow
	name = "Hive damaged tracker arrow"
	icon_state = "Red_arrow"
	duration = XENO_SILO_DAMAGE_POINTER_DURATION

/atom/movable/screen/arrow/turret_attacking_arrow
	name = "Turret attacking arrow"
	icon_state = "Green_arrow"
	duration = XENO_SILO_DAMAGE_POINTER_DURATION

/atom/movable/screen/arrow/attack_order_arrow
	name = "attack order arrow"
	icon_state = "Attack_arrow"
	duration = ORDER_DURATION

/atom/movable/screen/arrow/rally_order_arrow
	name = "Rally order arrow"
	icon_state = "Rally_arrow"
	duration = RALLY_ORDER_DURATION

/atom/movable/screen/arrow/defend_order_arrow
	name = "Defend order arrow"
	icon_state = "Defend_arrow"
	duration = ORDER_DURATION

/atom/movable/screen/arrow/hunter_mark_arrow
	name = "hunter mark arrow"
	icon_state = "Red_arrow"
	duration = HUNTER_PSYCHIC_TRACE_COOLDOWN
	color = COLOR_ORANGE
