/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = HUD_LAYER
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.


/obj/screen/Destroy()
	master = null
	hud = null
	return ..()


/obj/screen/examine(mob/user)
	return


/obj/screen/proc/component_click(obj/screen/component_button/component, params)
	return


/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480


/obj/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	var/list/object_overlays = list()


/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated(TRUE))
		return TRUE

	if(istype(usr.loc,/obj/mecha) || istype(usr.loc, /obj/vehicle/multitile/root/cm_armored)) // stops inventory actions in a mech/tank
		return TRUE

	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")

		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")

		if("swap")
			usr:swap_hand()

		if("hand")
			usr:swap_hand()

		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand()
				usr.update_inv_r_hand()

	return TRUE



/obj/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	icon_state = "x"


/obj/screen/close/Click()
	if(istype(master, /obj/item/storage))
		var/obj/item/storage/S = master
		S.close(usr)
	return TRUE


/obj/screen/act_intent
	name = "intent"
	icon_state = "intent_help"
	screen_loc = ui_acti


/obj/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)


/obj/screen/act_intent/corner/Click(location, control, params)
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


/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal


/obj/screen/internals/Click()
	if(!iscarbon(usr))
		return

	var/mob/living/carbon/C = usr
	if(C.incapacitated())
		return

	if(C.internal)
		C.internal = null
		to_chat(C, "<span class='notice'>No longer running on internals.</span>")
		icon_state = "internal0"
		return

	if(!istype(C.wear_mask, /obj/item/clothing/mask))
		to_chat(C, "<span class='notice'>You are not wearing a mask.</span>")
		return TRUE

	var/list/nicename = null
	var/list/tankcheck = null
	var/breathes = "oxygen"    //default, we'll check later

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		breathes = H.species.breath_type
		nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
		tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)

	else
		nicename = list("Right Hand", "Left Hand", "Back")
		tankcheck = list(C.r_hand, C.l_hand, C.back)

	var/best = 0
	var/bestpressure = 0

	for(var/i = 1 to length(tankcheck))
		if(!istype(tankcheck[i], /obj/item/tank))
			continue

		var/obj/item/tank/t = tankcheck[i]
		var/goodtank
		if(t.gas_type == GAS_TYPE_N2O) //anesthetic
			goodtank = TRUE
		else
			switch(breathes)

				if("nitrogen")
					if(t.gas_type == GAS_TYPE_NITROGEN)
						goodtank = TRUE

				if("oxygen")
					if(t.gas_type == GAS_TYPE_OXYGEN || t.gas_type == GAS_TYPE_AIR)
						goodtank = TRUE

				if("carbon dioxide")
					if(t.gas_type == GAS_TYPE_CO2)
						goodtank = TRUE
		if(goodtank)
			if(t.pressure >= 20 && t.pressure > bestpressure)
				best = i
				bestpressure = t.pressure

	if(best)
		to_chat(C, "<span class='notice'>You are now running on internals from [tankcheck[best]] on your [nicename[best]].</span>")
		C.internal = tankcheck[best]


	if(C.internal)
		icon_state = "internal1"
	else
		to_chat(C, "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>")


/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "running"
	screen_loc = ui_movi


/obj/screen/mov_intent/Click()
	usr.toggle_move_intent()


/obj/screen/mov_intent/update_icon(mob/user)
	if(!user)
		return

	switch(user.m_intent)
		if(MOVE_INTENT_RUN)
			icon_state = "running"
		if(MOVE_INTENT_WALK)
			icon_state = "walking"


/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "pull0"
	screen_loc = ui_pull_resist


/obj/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()


/obj/screen/pull/update_icon(mob/user)
	if(!user) 
		return
	if(user.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"


/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_resist"
	screen_loc = ui_pull_resist


/obj/screen/resist/Click()
	if(!isliving(usr))
		return

	var/mob/living/L = usr
	L.resist()


/obj/screen/resist/alien
	icon = 'icons/mob/screen1_alien.dmi'
	screen_loc = ui_storage2



/obj/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"


/obj/screen/storage/New(new_master, mapload)
	. = ..()
	master = new_master


/obj/screen/storage/proc/update_fullness(obj/item/storage/S)
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



/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw


/obj/screen/throw_catch/Click()
	if(!iscarbon(usr))
		return

	var/mob/living/carbon/C = usr
	C.toggle_throw_mode()



/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"


/obj/screen/zone_sel/update_icon(mob/living/user)
	if(!user)
		return
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")
	user.zone_selected = selecting


/obj/screen/zone_sel/Click(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = "r_foot"
				if(17 to 22)
					selecting = "l_foot"
				else
					return TRUE
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return TRUE
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_hand"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_hand"
				else
					return TRUE
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return TRUE
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon(usr)
	return TRUE


/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen1_alien.dmi'


/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen1_robot.dmi'


/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health
	icon = 'icons/mob/screen1_Midnight.dmi'


/obj/screen/healths/alien
	icon = 'icons/mob/screen1_alien.dmi'
	screen_loc = ui_alien_health


/obj/screen/healths/robot
	icon = 'icons/mob/screen1_robot.dmi'
	screen_loc = ui_borg_health


/obj/screen/component_button
	var/obj/screen/parent


/obj/screen/component_button/Initialize(mapload, obj/screen/parent)
	. = ..()
	src.parent = parent


/obj/screen/component_button/Click(params)
	parent?.component_click(src, params)


/obj/screen/cinematic
	layer = CINEMATIC_LAYER
	mouse_opacity = 0
	screen_loc = "1,0"


/obj/screen/cinematic/explosion
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "intro_ship"


/obj/screen/action_button
	icon = 'icons/mob/actions.dmi'
	icon_state = "template"
	var/datum/action/source_action


/obj/screen/action_button/Click()
	if(!usr || !source_action)
		return TRUE
	if(usr.next_move >= world.time)
		return TRUE

	if(source_action.can_use_action())
		source_action.action_activate()
	else
		source_action.fail_activate()


/obj/screen/action_button/Destroy()
	source_action = null
	. = ..()


/obj/screen/action_button/proc/get_button_screen_loc(button_number)
	var/row = round((button_number-1)/13) //13 is max amount of buttons per row
	var/col = ((button_number - 1)%(13)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = 26
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"


/obj/screen/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/mob/actions.dmi'
	icon_state = "hide"
	var/hidden = 0


/obj/screen/action_button/hide_toggle/Click()
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


/obj/screen/Click()
	if(!usr)	
		return TRUE

	switch(name)
		if("equip")
			if(istype(usr.loc,/obj/mecha) || istype(usr.loc, /obj/vehicle/multitile/root/cm_armored)) // stops inventory actions in a mech/tank
				return TRUE
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()
			return TRUE

		if("Reset Machine")
			usr.unset_interaction()
			return TRUE

		if("module")
			if(issilicon(usr))
				if(usr:module)
					return TRUE
				usr:pick_module()
			return TRUE

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
			return TRUE
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()
			return TRUE

		if("store")
			if(issilicon(usr))
				usr:uneq_active()
			return TRUE

		if("module1")
			if(iscyborg(usr))
				usr:toggle_module(1)
			return TRUE

		if("module2")
			if(iscyborg(usr))
				usr:toggle_module(2)
			return TRUE

		if("module3")
			if(iscyborg(usr))
				usr:toggle_module(3)
			return TRUE

		if("Activate weapon attachment")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G))
				G.activate_attachment_verb()
			return TRUE

		if("Toggle Rail Flashlight")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(!istype(G)) 
				return
			if(!G.get_active_firearm(usr)) 
				return
			var/obj/item/attachable/flashlight/F = G.rail
			if(F?.activate_attachment(G, usr))
				playsound(usr, F.activation_sound, 15, 1)
			return TRUE

		if("Eject magazine")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.empty_mag()
			return TRUE

		if("Toggle burst fire")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.toggle_burst()
			return TRUE

		if("Use unique action")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.use_unique_action()
			return TRUE

	return FALSE


/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	layer = HUD_LAYER


/obj/screen/drop/Click()
	usr.drop_item_v()


/obj/screen/queen_locator
	icon = 'icons/mob/screen1_alien.dmi'
	icon_state = "trackoff"
	name = "queen locator (click for hive status)"
	screen_loc = ui_queen_locator


/obj/screen/queen_locator/Click()
	if(!isxeno(usr))
		return

	var/mob/living/carbon/Xenomorph/X = usr
	X.hive_status()


/obj/screen/xenonightvision
	icon = 'icons/mob/screen1_alien.dmi'
	name = "toggle night vision"
	icon = 'icons/mob/screen1_alien.dmi'
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision


/obj/screen/xenonightvision/Click()
	if(!isxeno(usr))
		return

	var/mob/living/carbon/Xenomorph/X = usr
	X.toggle_nightvision()
	if(icon_state == "nightvision1")
		icon_state = "nightvision0"
	else
		icon_state = "nightvision1"


/obj/screen/bodytemp
	name = "body temperature"
	icon_state = "temp0"
	screen_loc = ui_temp


/obj/screen/oxygen
	name = "oxygen"
	icon_state = "oxy0"
	screen_loc = ui_oxygen


/obj/screen/fire
	name = "fire"
	icon_state = "fire0"
	screen_loc = ui_fire


/obj/screen/toggle_inv
	name = "toggle"
	icon_state = "other"
	screen_loc = ui_inventory


/obj/screen/SL_locator
	name = "sl locator"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "SL_locator"
	alpha = 0 //invisible
	mouse_opacity = 0
	screen_loc = ui_sl_dir


/obj/screen/toggle_inv/Click()
	if(usr.hud_used.inventory_shown)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= usr.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += usr.hud_used.toggleable_inventory

	usr.hud_used.hidden_inventory_update()


/obj/screen/ammo
	name = "ammo"
	icon = 'icons/mob/ammoHUD.dmi'
	icon_state = "ammo"
	screen_loc = ui_ammo
	var/warned = FALSE


/obj/screen/ammo/proc/add_hud(mob/living/user)
	if(!user?.client)
		return

	var/obj/item/weapon/gun/G = user.get_active_held_item()

	if(!G?.hud_enabled || !(G.flags_gun_features & GUN_AMMO_COUNTER))
		return

	user.client.screen += src


/obj/screen/ammo/proc/remove_hud(mob/living/user)
	user?.client?.screen -= src


/obj/screen/ammo/proc/update_hud(mob/living/user)
	if(!user?.client?.screen.Find(src))
		return

	var/obj/item/weapon/gun/G = user.get_active_held_item()

	if(!istype(G) || !(G.flags_gun_features & GUN_AMMO_COUNTER) || !G.hud_enabled || !G.get_ammo_type() || isnull(G.get_ammo_count()))
		remove_hud(user)
		return

	var/list/ammo_type = G.get_ammo_type()
	var/rounds = G.get_ammo_count()

	var/hud_state = ammo_type[1]
	var/hud_state_empty = ammo_type[2]

	overlays.Cut()

	var/empty = image('icons/mob/ammoHUD.dmi', src, "[hud_state_empty]")

	if(rounds == 0)
		if(warned)
			overlays += empty
		else
			warned = TRUE
			var/obj/screen/ammo/F = new /obj/screen/ammo(src)
			F.icon_state = "frame"
			user.client.screen += F
			flick("[hud_state_empty]_flash", F)
			spawn(20)
				user.client.screen -= F
				qdel(F)
				overlays += empty
	else
		warned = FALSE
		overlays += image('icons/mob/ammoHUD.dmi', src, "[hud_state]")

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