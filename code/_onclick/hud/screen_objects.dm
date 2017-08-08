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
	layer = 20.0
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
	layer = 21
	mouse_opacity = 0
	screen_loc = "1,0"

/obj/screen/cinematic/explosion
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "intro_ship"

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)
	return 1


/obj/screen/action_button
	icon = 'icons/mob/screen1_action.dmi'
	icon_state = "template"
	var/datum/action/source_action

/obj/screen/action_button/Click()
	if(!usr || !source_action)
		return 1
	if(usr.next_move >= world.time)
		return
	usr.next_move = world.time + 6

	source_action.action_activate()
	return 1

/obj/screen/action_button/Dispose()
	source_action = null
	. = ..()

/obj/screen/action_button/proc/get_button_screen_loc(button_number)
	var/row = round((button_number-1)/10) //10 is max amount of buttons per row
	var/col = ((button_number - 1)%(10)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = 26
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"



/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click()
	if(world.time <= usr.next_move)
		return 1
	if(usr.is_mob_incapacitated(TRUE))
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			usr.ClickOn(master)
			usr.next_move = world.time+2
	return 1

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
			for(var/obj/item/weapon/gun/G in user)
				if(G.target && G.target.len)
					if(user.target_can_move)
						icon_state = "no_walk1"
						name = "Disallow Walking"
					else
						icon_state = "no_walk0"
						name = "Allow Walking"
					screen_loc = initial(screen_loc)
					return
		screen_loc = null

	Click(location, control, params)
		if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
			return
		if(!istype(usr.get_held_item(),/obj/item/weapon/gun))
			usr << "You need your gun in your active hand to do that!"
			return
		usr.AllowTargetMove()
		gun_click_time = world.time


/obj/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"
	screen_loc = ui_gun3

	update_icon(mob/user)
		if(user.gun_mode)
			for(var/obj/item/weapon/gun/G in user)
				if(G.target && G.target.len)
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

	Click(location, control, params)
		if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
			return
		if(!istype(usr.get_held_item(),/obj/item/weapon/gun))
			usr << "You need your gun in your active hand to do that!"
			return
		usr.AllowTargetRun()
		gun_click_time = world.time


/obj/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

	update_icon(mob/user)
		if(user.gun_mode)
			for(var/obj/item/weapon/gun/G in user)
				if(G.target && G.target.len)
					if(user.target_can_click)
						icon_state = "no_item1"
						name = "Allow Item Use"
					else
						icon_state = "no_item0"
						name = "Disallow Item Use"
					screen_loc = initial(screen_loc)
					return
		screen_loc = null

	Click(location, control, params)
		if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
			return
		if(!istype(usr.get_held_item(),/obj/item/weapon/gun))
			usr << "You need your gun in your active hand to do that!"
			return
		usr.AllowTargetClick()
		gun_click_time = world.time


/obj/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"
	screen_loc = ui_gun_select

	update_icon(mob/user)
		if(user.gun_mode) icon_state = "gun1"
		else icon_state = "gun0"

	Click(location, control, params)
		usr.ToggleGunMode()


/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"

/obj/screen/zone_sel/update_icon(mob/living/user)
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")
	user.zone_selected = selecting

/obj/screen/zone_sel/Click(location, control,params)
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
		update_icon(usr)
	return 1


/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen1_alien.dmi'

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen1_robot.dmi'







/obj/screen/Click(location, control, params)
	if(!usr)	return 1

	switch(name)

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("Reset Machine")
			usr.unset_interaction()

		if("module")
			if(issilicon(usr))
				if(usr:module)
					return 1
				usr:pick_module()

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(issilicon(usr))
				usr:uneq_active()

		if("module1")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(1)

		if("module2")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(2)

		if("module3")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(3)

		if("ready tail")
			if(istype(usr,/mob/living/carbon/Xenomorph))
				if(/mob/living/carbon/Xenomorph/proc/tail_attack in usr:inherent_verbs)
					usr:tail_attack()
					if(usr:readying_tail)
						src.icon_state = "tail_ready"
					else
						src.icon_state = "tail_unready"
				else
					usr << "Your caste lacks the ability to do this."

		if("Activate weapon attachment")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.activate_attachment()

		if("Toggle Rail Flashlight")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(!istype(G)) return
			if(!G.get_active_firearm(usr)) return
			var/obj/item/attachable/flashlight/F = G.rail
			if(F) F.activate_attachment(G, usr)

		if("Eject magazine")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.empty_mag()

		if("Toggle burst fire")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.toggle_burst()

		if("Use unique action")
			var/obj/item/weapon/gun/G = usr.get_held_item()
			if(istype(G)) G.use_unique_action()

	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.is_mob_incapacitated(TRUE))
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
				usr.next_move = world.time+2
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
				usr.next_move = world.time+2
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
				usr.next_move = world.time+6
	return 1





/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	layer = 19

/obj/screen/drop/Click()
	usr.drop_item_v()


/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "act_resist"
	layer = 19
	screen_loc = ui_pull_resist

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/obj/screen/resist/alien
	icon = 'icons/mob/screen1_alien.dmi'
	screen_loc = ui_storage2


/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "running"
	screen_loc = ui_movi

	Click()
		if(iscarbon(usr))
			var/mob/living/carbon/C = usr
			if(C.legcuffed)
				C << "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>"
				C.m_intent = "walk"	//Just incase
				icon_state = "walking"
				return
		switch(usr.m_intent)
			if("run")
				usr.m_intent = "walk"
				icon_state = "walking"
			if("walk")
				usr.m_intent = "run"
				icon_state = "running"
		usr.update_icons()


/obj/screen/act_intent
	name = "intent"
	icon_state = "intent_help"
	screen_loc = ui_acti

	Click(location, control, params)
		usr.a_intent_change("right")

/obj/screen/act_intent/corner/Click(location, control, params)
	var/_x = text2num(params2list(params)["icon-x"])
	var/_y = text2num(params2list(params)["icon-y"])

	if(_x<=16 && _y<=16)
		usr.a_intent_change("hurt")

	else if(_x<=16 && _y>=17)
		usr.a_intent_change("help")

	else if(_x>=17 && _y<=16)
		usr.a_intent_change("grab")

	else if(_x>=17 && _y>=17)
		usr.a_intent_change("disarm")



/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/internals/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
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
					var/list/contents = list()

					if(ishuman(C))
						var/mob/living/carbon/human/H = C
						breathes = H.species.breath_type
						nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
						tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)

					else

						nicename = list("Right Hand", "Left Hand", "Back")
						tankcheck = list(C.r_hand, C.l_hand, C.back)

					for(var/i=1, i<tankcheck.len+1, ++i)
						if(istype(tankcheck[i], /obj/item/weapon/tank))
							var/obj/item/weapon/tank/t = tankcheck[i]
							if (!isnull(t.manipulated_by) && t.manipulated_by != C.real_name && findtext(t.desc,breathes))
								contents.Add(t.air_contents.total_moles)	//Someone messed with the tank and put unknown gasses
								continue					//in it, so we're going to believe the tank is what it says it is
							switch(breathes)
																//These tanks we're sure of their contents
								if("nitrogen") 							//So we're a bit more picky about them.

									if(t.air_contents.gas["nitrogen"] && !t.air_contents.gas["oxygen"])
										contents.Add(t.air_contents.gas["nitrogen"])
									else
										contents.Add(0)

								if ("oxygen")
									if(t.air_contents.gas["oxygen"] && !t.air_contents.gas["phoron"])
										contents.Add(t.air_contents.gas["oxygen"])
									else
										contents.Add(0)

								// No races breath this, but never know about downstream servers.
								if ("carbon dioxide")
									if(t.air_contents.gas["carbon_dioxide"] && !t.air_contents.gas["phoron"])
										contents.Add(t.air_contents.gas["carbon_dioxide"])
									else
										contents.Add(0)


						else
							//no tank so we set contents to 0
							contents.Add(0)

					//Alright now we know the contents of the tanks so we have to pick the best one.

					var/best = 0
					var/bestcontents = 0
					for(var/i=1, i <  contents.len + 1 , ++i)
						if(!contents[i])
							continue
						if(contents[i] > bestcontents)
							best = i
							bestcontents = contents[i]


					//We've determined the best container now we set it as our internals

					if(best)
						C << "<span class='notice'>You are now running on internals from [tankcheck[best]] on your [nicename[best]].</span>"
						C.internal = tankcheck[best]


					if(C.internal)
						icon_state = "internal1"
					else
						C << "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>"



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

/obj/screen/pull/Click()
	usr.stop_pulling()

/obj/screen/pull/update_icon(mob/user)
	if(!user) return
	if(user.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"


/obj/screen/blind
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "blackimageoverlay"
	name = " "
	screen_loc = "1,1"
	plane = -80

/obj/screen/flash
	icon = 'icons/mob/screen1.dmi'
	icon_state = "blank"
	name = "flash"
	screen_loc = "1,1 to 15,15"
	layer = 17

/obj/screen/damageoverlay
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	screen_loc = "1,1"
	mouse_opacity = 0
	layer = 18.1 //The black screen overlay sets layer to 18 to display it, this one has to be just on top.



/obj/screen/queen_locator
	icon = 'icons/mob/screen1_alien.dmi'
	icon_state = "trackoff"
	name = "queen locator"
	screen_loc = ui_queen_locator


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

	Click(location, control, params)
		if(usr.hud_used.inventory_shown)
			usr.hud_used.inventory_shown = 0
			usr.client.screen -= usr.hud_used.toggleable_inventory
		else
			usr.hud_used.inventory_shown = 1
			usr.client.screen += usr.hud_used.toggleable_inventory

		usr.hud_used.hidden_inventory_update()
