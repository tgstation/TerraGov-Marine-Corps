/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = ABOVE_HUD_LAYER
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/cinematic
	layer = CINEMATIC_LAYER
	mouse_opacity = 0
	screen_loc = "1,0"

/obj/screen/cinematic/explosion
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "intro_ship"

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"
	icon_state = "x"


/obj/screen/close/clicked(var/mob/user)
	if(master)
		if(istype(master, /obj/item/storage))
			var/obj/item/storage/S = master
			S.close(user)
	return 1


/obj/screen/action_button
	icon = 'icons/mob/actions.dmi'
	icon_state = "template"
	var/datum/action/source_action

/obj/screen/action_button/clicked(var/mob/user)
	if(!user || !source_action)
		return 1
	if(user.next_move >= world.time)
		return 1
	user.next_move = world.time + 6

	if(source_action.can_use_action())
		source_action.action_activate()
	return 1

/obj/screen/action_button/Dispose()
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

/obj/screen/action_button/hide_toggle/clicked(var/mob/user, mods)
	user.hud_used.action_buttons_hidden = !user.hud_used.action_buttons_hidden
	hidden = user.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
		icon_state = "show"
	else
		name = "Hide Buttons"
		icon_state = "hide"
	user.update_action_buttons()
	return 1


/obj/screen/storage
	name = "storage"


/obj/screen/storage/proc/update_fullness(obj/item/storage/S)
	if(!S.contents.len)
		color = null
	else
		var/total_w = 0
		for(var/obj/item/I in S)
			total_w += I.w_class
		var/fullness = round(10*max(S.contents.len/S.storage_slots, total_w/S.max_storage_space))
		switch(fullness)
			if(10) color = "#ff0000"
			if(7 to 9) color = "#ffa500"
			else color = null



/obj/screen/gun
	name = "gun"
	dir = 2
	var/gun_click_time = -100

/obj/screen/gun/move
	name = "Allow Walking"
	icon_state = "no_walk0"
	screen_loc = ui_gun2

	update_icon(mob/user)
		if(user.gun_mode)
			if(user.target_can_move)
				icon_state = "no_walk1"
				name = "Disallow Walking"
			else
				icon_state = "no_walk0"
				name = "Allow Walking"
			screen_loc = initial(screen_loc)
			return
		screen_loc = null

/obj/screen/gun/move/clicked(var/mob/user)
	if (..())
		return 1

	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return 1
	if(!istype(user.get_held_item(),/obj/item/weapon/gun))
		user << "You need your gun in your active hand to do that!"
		return 1
	user.AllowTargetMove()
	gun_click_time = world.time
	return 1


/obj/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"
	screen_loc = ui_gun3

	update_icon(mob/user)
		if(user.gun_mode)
			if(user.target_can_move)
				if(user.target_can_run)
					icon_state = "no_run1"
					name = "Disallow Running"
				else
					icon_state = "no_run0"
					name = "Allow Running"
				screen_loc = initial(screen_loc)
				return
		screen_loc = null

/obj/screen/gun/run/clicked(var/mob/user)
	if (..())
		return 1

	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return 1
	if(!istype(user.get_held_item(),/obj/item/weapon/gun))
		user << "You need your gun in your active hand to do that!"
		return 1
	user.AllowTargetRun()
	gun_click_time = world.time
	return 1


/obj/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

	update_icon(mob/user)
		if(user.gun_mode)
			if(user.target_can_click)
				icon_state = "no_item1"
				name = "Allow Item Use"
			else
				icon_state = "no_item0"
				name = "Disallow Item Use"
			screen_loc = initial(screen_loc)
			return
		screen_loc = null

/obj/screen/gun/item/clicked(var/mob/user)
	if (..())
		return 1

	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return 1
	if(!istype(user.get_held_item(),/obj/item/weapon/gun))
		user << "You need your gun in your active hand to do that!"
		return 1
	user.AllowTargetClick()
	gun_click_time = world.time
	return 1


/obj/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"
	screen_loc = ui_gun_select

	update_icon(mob/user)
		if(user.gun_mode) icon_state = "gun1"
		else icon_state = "gun0"

/obj/screen/gun/mode/clicked(var/mob/user)
	if (..())
		return 1
	user.ToggleGunMode()
	return 1


/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"

/obj/screen/zone_sel/update_icon(mob/living/user)
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")
	user.zone_selected = selecting

/obj/screen/zone_sel/clicked(var/mob/user, var/list/mods)
	if (..())
		return 1

	var/icon_x = text2num(mods["icon-x"])
	var/icon_y = text2num(mods["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = "r_foot"
				if(17 to 22)
					selecting = "l_foot"
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_hand"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_hand"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
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
		update_icon(user)
	return 1


/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen1_alien.dmi'

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen1_robot.dmi'







/obj/screen/clicked(var/mob/user)
	if(!user)	return 1

	switch(name)

		if("equip")
			if (istype(user.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.quick_equip()
			return 1

		if("Reset Machine")
			user.unset_interaction()
			return 1

		if("module")
			if(issilicon(user))
				if(usr:module)
					return 1
				user:pick_module()
			return 1

		if("radio")
			if(issilicon(user))
				user:radio_menu()
			return 1
		if("panel")
			if(issilicon(user))
				user:installed_modules()
			return 1

		if("store")
			if(issilicon(user))
				user:uneq_active()
			return 1

		if("module1")
			if(istype(user, /mob/living/silicon/robot))
				user:toggle_module(1)
			return 1

		if("module2")
			if(istype(user, /mob/living/silicon/robot))
				user:toggle_module(2)
			return 1

		if("module3")
			if(istype(user, /mob/living/silicon/robot))
				user:toggle_module(3)
			return 1

		if("Activate weapon attachment")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G))
				G.activate_attachment_verb()
			return 1

		if("Toggle Rail Flashlight")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(!istype(G)) return
			if(!G.get_active_firearm(usr)) return
			var/obj/item/attachable/flashlight/F = G.rail
			if(F && F.activate_attachment(G, user))
				playsound(user, F.activation_sound, 15, 1)
			return 1

		if("Eject magazine")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G)) G.empty_mag()
			return 1

		if("Toggle burst fire")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G)) G.toggle_burst()
			return 1

		if("Use unique action")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G)) G.use_unique_action()
			return 1

	return 0


/obj/screen/inventory/clicked(var/mob/user)
	if (..())
		return 1
	if(user.is_mob_incapacitated(TRUE))
		return 1
	if (istype(user.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = user
				C.activate_hand("r")
				user.next_move = world.time+2
			return 1
		if("l_hand")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.activate_hand("l")
				user.next_move = world.time+2
			return 1
		if("swap")
			user:swap_hand()
			return 1
		if("hand")
			user:swap_hand()
			return 1
		else
			if(user.attack_ui(slot_id))
				user.update_inv_l_hand(0)
				user.update_inv_r_hand(0)
				user.next_move = world.time+6
				return 1
	return 0





/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw

/obj/screen/throw_catch/clicked(var/mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.toggle_throw_mode()
		return 1

/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	layer = HUD_LAYER

/obj/screen/drop/clicked(var/mob/user)
	user.drop_item_v()
	return 1


/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_resist"
	layer = HUD_LAYER
	screen_loc = ui_pull_resist

/obj/screen/resist/clicked(var/mob/user)
	if(isliving(user))
		var/mob/living/L = user
		L.resist()
		return 1

/obj/screen/resist/alien
	icon = 'icons/mob/screen1_alien.dmi'
	screen_loc = ui_storage2


/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "running"
	screen_loc = ui_movi

/obj/screen/mov_intent/clicked(var/mob/user)
	if (..())
		return 1
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.legcuffed)
			C << "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>"
			C.m_intent = MOVE_INTENT_WALK	//Just incase
			icon_state = "walking"
			return
	switch(user.m_intent)
		if(MOVE_INTENT_RUN)
			user.m_intent = MOVE_INTENT_WALK
			icon_state = "walking"
		if(MOVE_INTENT_WALK)
			user.m_intent = MOVE_INTENT_RUN
			icon_state = "running"
	if(isXeno(user))
		user.update_icons()
	return 1


/obj/screen/act_intent
	name = "intent"
	icon_state = "intent_help"
	screen_loc = ui_acti

/obj/screen/act_intent/clicked(var/mob/user)
	user.a_intent_change("right")
	return 1

/obj/screen/act_intent/corner/clicked(var/mob/user, var/list/mods)
	var/_x = text2num(mods["icon-x"])
	var/_y = text2num(mods["icon-y"])

	if(_x<=16 && _y<=16)
		user.a_intent_change("hurt")

	else if(_x<=16 && _y>=17)
		user.a_intent_change("help")

	else if(_x>=17 && _y<=16)
		user.a_intent_change("grab")

	else if(_x>=17 && _y>=17)
		user.a_intent_change("disarm")

	return 1


/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/internals/clicked(var/mob/user)
	if (..())
		return 1
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(!C.is_mob_incapacitated())
			if(C.internal)
				C.internal = null
				C << "<span class='notice'>No longer running on internals.</span>"
				icon_state = "internal0"
			else
				if(!istype(C.wear_mask, /obj/item/clothing/mask))
					C << "<span class='notice'>You are not wearing a mask.</span>"
					return 1
				else
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

					for(var/i=1, i<tankcheck.len+1, ++i)
						if(istype(tankcheck[i], /obj/item/tank))
							var/obj/item/tank/t = tankcheck[i]
							var/goodtank
							if(t.gas_type == GAS_TYPE_N2O) //anesthetic
								goodtank = TRUE
							else
								switch(breathes)

									if("nitrogen")
										if(t.gas_type == GAS_TYPE_NITROGEN)
											goodtank = TRUE

									if ("oxygen")
										if(t.gas_type == GAS_TYPE_OXYGEN || t.gas_type == GAS_TYPE_AIR)
											goodtank = TRUE

									if ("carbon dioxide")
										if(t.gas_type == GAS_TYPE_CO2)
											goodtank = TRUE
							if(goodtank)
								if(t.pressure >= 20 && t.pressure > bestpressure)
									best = i
									bestpressure = t.pressure

					//We've determined the best container now we set it as our internals

					if(best)
						C << "<span class='notice'>You are now running on internals from [tankcheck[best]] on your [nicename[best]].</span>"
						C.internal = tankcheck[best]


					if(C.internal)
						icon_state = "internal1"
					else
						C << "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>"
	return 1



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



/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "pull0"
	screen_loc = ui_pull_resist

/obj/screen/pull/clicked(var/mob/user)
	if (..())
		return 1
	user.stop_pulling()
	return 1

/obj/screen/pull/update_icon(mob/user)
	if(!user) return
	if(user.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"



/obj/screen/squad_leader_locator
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "trackoff"
	name = "squad leader locator"
	alpha = 0 //invisible
	mouse_opacity = 0
	screen_loc = ui_sl_locator

/obj/screen/queen_locator
	icon = 'icons/mob/screen1_alien.dmi'
	icon_state = "trackoff"
	name = "queen locator"
	screen_loc = ui_queen_locator


/obj/screen/xenonightvision
	icon = 'icons/mob/screen1_alien.dmi'
	name = "toggle night vision"
	icon = 'icons/mob/screen1_alien.dmi'
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision

/obj/screen/xenonightvision/clicked(var/mob/user)
	if (..())
		return 1
	var/mob/living/carbon/Xenomorph/X = user
	X.toggle_nightvision()
	if(icon_state == "nightvision1")
		icon_state = "nightvision0"
	else
		icon_state = "nightvision1"
	return 1


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

/obj/screen/toggle_inv/clicked(var/mob/user)
	if (..())
		return 1

	if(user.hud_used.inventory_shown)
		user.hud_used.inventory_shown = 0
		user.client.screen -= user.hud_used.toggleable_inventory
	else
		user.hud_used.inventory_shown = 1
		user.client.screen += user.hud_used.toggleable_inventory

	user.hud_used.hidden_inventory_update()
	return 1
