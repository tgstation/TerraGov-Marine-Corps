/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.
	var/lastclick
	var/category

/obj/screen/take_damage()
	return

/obj/screen/Destroy()
	master = null
	hud = null
	return ..()

/obj/screen/Click(location, control, params)
	if(!usr || !usr.client)
		return FALSE
	var/mob/user = usr
	var/paramslist = params2list(params)
	if(paramslist["shift"] && paramslist["left"]) // screen objects don't do the normal Click() stuff so we'll cheat
		examine_ui(user)
		return FALSE

/obj/screen/proc/examine_ui(mob/user)
	var/list/inspec = list("----------------------")
	inspec += "<br><span class='notice'><b>[name]</b></span>"
	if(desc)
		inspec += "<br>[desc]"

	inspec += "<br>----------------------"
	to_chat(user, "[inspec.Join()]")


/obj/screen/orbit()
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

/obj/screen/swap_hand
	layer = HUD_LAYER
	plane = HUD_PLANE
	name = "swap hand"

/obj/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/obj/screen/skills
	name = "skills"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "skills"
	screen_loc = ui_skill_menu

/obj/screen/skills/Click(location, control, params)
	var/list/modifiers = params2list(params)

	if(modifiers["right"])
		var/ht
		var/mob/living/L = usr
		to_chat(L, "*----*")
		if(ishuman(usr))
			var/mob/living/carbon/human/M = usr
			if(M.charflaw)
				to_chat(M, "<span class='info'>[M.charflaw.desc]</span>")
				to_chat(M, "*----*")
			if(M.mind)
				if(M.mind.language_holder)
					var/finn
					for(var/X in M.mind.language_holder.languages)
						var/datum/language/LA = new X()
						finn = TRUE
						to_chat(M, "<span class='info'>[LA.name] - ,[LA.key]</span>")
					if(!finn)
						to_chat(M, "<span class='warning'>I don't know any languages.</span>")
					to_chat(M, "*----*")
		for(var/X in GLOB.roguetraits)
			if(HAS_TRAIT(L, X))
				to_chat(L, "[X] - <span class='info'>[GLOB.roguetraits[X]]</span>")
				ht = TRUE
		if(!ht)
			to_chat(L, "<span class='warning'>I have no special traits.</span>")
		to_chat(L, "*----*")
		return

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.mind.print_levels(H)

/obj/screen/craft
	name = "crafting menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = rogueui_craft
	var/last_craft

/obj/screen/craft/Click(location, control, params)
	if(world.time < lastclick + 3 SECONDS)
		return
	lastclick = world.time
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.playsound_local(H, 'sound/misc/click.ogg', 100)
		if(H.craftingthing)
			last_craft = world.time
			var/datum/component/personal_crafting/C = H.craftingthing
			C.roguecraft(location, control, params, H)
		else
			testing("what")

/obj/screen/area_creator
	name = "create new area"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/obj/screen/area_creator/Click()
	if(usr.incapacitated() || (isobserver(usr) && !IsAdminGhost(usr)))
		return TRUE
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, "<span class='warning'>There is already a defined structure here.</span>")
		return TRUE
	create_area(usr)

/obj/screen/language_menu
	name = "language menu"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/obj/screen/language_menu/Click()
	var/mob/M = usr
	var/datum/language_holder/H = M.get_language_holder()
	H.open_language_menu(usr)

/obj/screen/inventory
	/// The identifier for the slot. It has nothing to do with ID cards.
	var/slot_id
	/// Icon when empty. For now used only by humans.
	var/icon_empty
	/// Icon when contains an item. For now used only by humans.
	var/icon_full = "genslot"
	/// The overlay when hovering over with an item in your hand
	layer = HUD_LAYER
	plane = HUD_PLANE
	nomouseover = FALSE


/obj/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated())
		return TRUE
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id, params))
		usr.update_inv_hands()
	return TRUE

/obj/screen/inventory/MouseEntered(location, control, params)
	. = ..()
	add_overlays()

/obj/screen/inventory/MouseExited()
	..()
	if(hud)
		cut_overlay(hud.object_overlay)
		QDEL_NULL(hud.object_overlay)

/obj/screen/inventory/update_icon_state()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud?.mymob && slot_id && icon_full)
		var/obj/item/I = hud.mymob.get_item_by_slot(slot_id)
		if(I)
			icon_state = icon_full
			if(I.max_integrity)
				if(I.obj_integrity < I.max_integrity)
					icon_state = "slotdmg"
					if(I.integrity_failure)
						if((I.obj_integrity / I.max_integrity) <= I.integrity_failure)
							icon_state = "slotbroke"
		else
			icon_state = icon_empty

/obj/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	cut_overlays()

	if(!user || !slot_id)
		return

	var/obj/item/holding = user.get_active_held_item()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!user.can_equip(holding, slot_id, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		item_overlay.color = "#fd0279"
	else
		item_overlay.color = "#c5c5c5"

	if(hud)
		if(hud.object_overlay)
			if(hud.overlay_curloc != src)
				hud.overlay_curloc.cut_overlay(hud.object_overlay)
		hud.overlay_curloc = src
		cut_overlay(hud.object_overlay)
		hud.object_overlay = item_overlay
		add_overlay(hud.object_overlay)


/obj/screen/inventory/hand
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")
	var/held_index = 0

/obj/screen/inventory/hand/update_overlays()
	. = ..()

	if(!handcuff_overlay)
		var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance('icons/mob/screen_gen.dmi', state)

	if(!hud?.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			. += handcuff_overlay

		if(held_index)
			if(!C.has_hand_for_held_index(held_index))
				. += blocked_overlay

	if(held_index == hud.mymob.active_hand_index)
		. += "hand_active"

/obj/screen/inventory/hand/add_overlays()
	return

/obj/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE
	if(world.time <= user.next_move)
		return TRUE
//	if(user.incapacitated())
//		return TRUE
	if (ismecha(user.loc)) // stops inventory actions in a mech
		return TRUE

	if(user.active_hand_index == held_index)
		var/obj/item/I = user.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		user.swap_hand(held_index)
	return TRUE

/obj/screen/close
	name = "close"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	icon_state = "backpack_close"

/obj/screen/close/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/close/Click()
	var/datum/component/storage/S = master
	S.hide_from(usr)
	return TRUE

/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/drop/Click()
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())

/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/obj/screen/act_intent/segmented/Click(location, control, params)
	if(usr.client.prefs.toggles & INTENT_STYLE)
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
	else
		return ..()

/obj/screen/act_intent/proc/switch_intent(index as num)
	return



/obj/screen/act_intent/rogintent
	name = ""
	desc = ""
	icon = 'icons/mob/rogueintentbase.dmi'
	icon_state = "intentbase"
	screen_loc = rogueui_intents
	var/intent1
	var/intent2
	var/intent3
	var/intent4
	var/border1
	var/border2

/obj/screen/act_intent/rogintent/update_icon(var/list/intentsl,var/list/intentsr, oactive = FALSE)
	..()
	cut_overlays(TRUE)
	if(!intentsl || !intentsr)
		return
	else
		var/lol = 0
//		intent1 = image(icon='icons/mob/rogueintentbase.dmi',icon_state="intentbase")
//		add_overlay(intent1, TRUE)
		var/list/used = intentsr
		if(hud.mymob.active_hand_index == 1)
			used = intentsl
		for(var/datum/intent/intenty in used)
			lol++
			switch(lol)
				if(1)
					intent1 = image(icon='icons/mob/roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 64, pixel_y = 16, layer = layer+0.02)
					add_overlay(intent1, TRUE)
				if(2)
					intent2 = image(icon='icons/mob/roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 96, pixel_y = 16, layer = layer+0.02)
					add_overlay(intent2, TRUE)
				if(3)
					intent3 = image(icon='icons/mob/roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 64, layer = layer+0.02)
					add_overlay(intent3, TRUE)
				if(4)
					intent4 = image(icon='icons/mob/roguehud.dmi',icon_state=intenty.icon_state, pixel_x = 96, layer = layer+0.02)
					add_overlay(intent4, TRUE)
		if(ismob(usr))
			var/mob/M = usr
			switch_intent(M.r_index, M.l_index, oactive)

/obj/screen/act_intent/rogintent/switch_intent(r_index, l_index, oactive = FALSE)
	cut_overlay(border1, TRUE)
	cut_overlay(border2, TRUE)
	var/used = "offintent"
	if(oactive)
		used = "offintentselected"
	if(!r_index || !l_index)
		return
	else
		var/used_index = r_index
		var/other = l_index
		if(hud.mymob.active_hand_index == 1)
			used_index = l_index
			other = r_index
		switch(used_index)
			if(1)
				border1 = image(icon='icons/mob/roguehud.dmi',icon_state="intentselected", pixel_x = 64, pixel_y = 16, layer = layer+0.01)
			if(2)
				border1 = image(icon='icons/mob/roguehud.dmi',icon_state="intentselected", pixel_x = 96, pixel_y = 16, layer = layer+0.01)
			if(3)
				border1 = image(icon='icons/mob/roguehud.dmi',icon_state="intentselected", pixel_x = 64, layer = layer+0.01)
			if(4)
				border1 = image(icon='icons/mob/roguehud.dmi',icon_state="intentselected", pixel_x = 96, layer = layer+0.01)
		switch(other)
			if(1)
				border2 = image(icon='icons/mob/roguehud.dmi',icon_state=used, pixel_x = 64, pixel_y = 16, layer = layer+0.01)
			if(2)
				border2 = image(icon='icons/mob/roguehud.dmi',icon_state=used, pixel_x = 96, pixel_y = 16, layer = layer+0.01)
			if(3)
				border2 = image(icon='icons/mob/roguehud.dmi',icon_state=used, pixel_x = 64, layer = layer+0.01)
			if(4)
				border2 = image(icon='icons/mob/roguehud.dmi',icon_state=used, pixel_x = 96, layer = layer+0.01)
		add_overlay(border2, TRUE)
		add_overlay(border1, TRUE)

/obj/screen/act_intent/rogintent/Click(location, control, params)

	var/list/modifiers = params2list(params)

	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE

	user.playsound_local(user, 'sound/misc/click.ogg', 100)

	if(usr.client.prefs.toggles & INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])
		var/clicked = get_index_at_loc(_x, _y)
		if(!clicked)
			return
/*		if(_x<=64)
			if(user.active_hand_index == 2)
				if(modifiers["right"])
					if(clicked != user.l_index)
						user.rog_intent_change(clicked,1)
					else
						if(user.oactive)
							user.oactive = FALSE
//						else
//							user.oactive = TRUE
						switch_intent(user.r_index, user.l_index, user.oactive)
					return
				if(!user.swap_hand(1))
					return
			if(modifiers["left"])
				if(modifiers["shift"])
					user.examine_intent(clicked, FALSE)
					return
			user.rog_intent_change(clicked)
		else*/
//			if(user.active_hand_index == 1)
//				if(modifiers["right"])
//					if(clicked != user.r_index)
//						user.rog_intent_change(clicked,1)
//					else
//						if(user.oactive)
//							user.oactive = FALSE
//						else
//							user.oactive = TRUE
//						switch_intent(user.r_index, user.l_index, user.oactive)
//					return
//				if(!user.swap_hand(2))
//					return
		if(modifiers["left"])
			if(modifiers["shift"])
				user.examine_intent(clicked, FALSE)
				return
		user.rog_intent_change(clicked)

/obj/screen/act_intent/rogintent/proc/get_index_at_loc(var/xl, var/yl)
/*	if(xl<=64)
		if(xl<32)
			if(yl>16)
				return 1
			else
				return 3
		else
			if(yl>16)
				return 2
			else
				return 4
	else*/
	if(xl > 64)
		if(xl<96)
			if(yl>16)
				return 1
			else
				return 3
		else
			if(yl>16)
				return 2
			else
				return 4

//

/obj/screen/quad_intents
	name = "mmb intents"
	icon_state = "mmbintents0"
	icon = 'icons/mob/roguehud.dmi'
	screen_loc = rogueui_quad

/obj/screen/quad_intents/proc/switch_intent(input)
	icon_state = "mmbintents0"
	if(input in 1 to 4)
		icon_state = "mmbintents[input]"

/obj/screen/quad_intents/Click(location, control, params)
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)

	var/_y = text2num(params2list(params)["icon-y"])

	if(_y<=9)
		usr.mmb_intent_change(QINTENT_STEAL)

	else if(_y>=9 && _y<=16)
		usr.mmb_intent_change(QINTENT_KICK)

	else if(_y>=17 && _y<=24)
		usr.mmb_intent_change(QINTENT_JUMP)

	else if(_y>=24 && _y<=32)
		usr.mmb_intent_change(QINTENT_BITE)


/obj/screen/give_intent
	name = "give/take"
	icon_state = "take0"
	icon = 'icons/mob/roguehud.dmi'
	screen_loc = rogueui_give
	var/giving = 0

/obj/screen/give_intent/proc/switch_intent(ass)
	if(ass == QINTENT_GIVE)
		giving = 1
	else
		giving = 0
	update_icon()

/obj/screen/give_intent/Click(location, control, params)
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)
	usr.mmb_intent_change(QINTENT_GIVE)

/obj/screen/give_intent/update_icon()
	..()
	if(ismob(usr))
		var/mob/M = usr
		if(M.get_active_held_item())
			icon_state = "give[giving]"
		else
			icon_state = "take[giving]"

//

/obj/screen/def_intent
	name = "defense intent"
	icon_state = "def1n"
	icon = 'icons/mob/roguehud.dmi'
	screen_loc = rogueui_def

/obj/screen/def_intent/update_icon()
	icon_state = "def[hud.mymob.d_intent]n"

/obj/screen/def_intent/Click(location, control, params)
	var/_y = text2num(params2list(params)["icon-y"])

	if(_y>=0 && _y<17)
		usr.def_intent_change(INTENT_DODGE)
	else if(_y>16 && _y<=32)
		usr.def_intent_change(INTENT_PARRY)


/obj/screen/cmode
	name = "combat mode"
	icon_state = "combat0"
	icon = 'icons/mob/roguehud.dmi'
	screen_loc = rogueui_cmode

/obj/screen/cmode/update_icon()
	icon_state = "combat[hud.mymob.cmode]"

/obj/screen/cmode/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(isliving(usr))
		var/mob/living/L = usr
		L.playsound_local(L, 'sound/misc/click.ogg', 100)
		if(modifiers["right"])
			L.submit()
		else
			L.toggle_cmode()
			update_icon()

/obj/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_movi

/obj/screen/act_intent/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = null

/obj/screen/internals/Click(location, control, params)
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/C = usr
	if(C.incapacitated())
		return

	if(C.internal)
		C.internal = null
		to_chat(C, "<span class='notice'>I are no longer running on internals.</span>")
		icon_state = "internal0"
	else
		if(!C.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			if(!istype(C.wear_mask, /obj/item/clothing/mask))
				to_chat(C, "<span class='warning'>I are not wearing an internals mask!</span>")
				return 1
			else
				var/obj/item/clothing/mask/M = C.wear_mask
				if(M.mask_adjusted) // if mask on face but pushed down
					M.adjustmask(C) // adjust it back
				if( !(M.clothing_flags & MASKINTERNALS) )
					to_chat(C, "<span class='warning'>I are not wearing an internals mask!</span>")
					return

		var/obj/item/I = C.is_holding_item_of_type(/obj/item/tank)
		if(I)
			to_chat(C, "<span class='notice'>I are now running on internals from [I] in your [C.get_held_index_name(C.get_held_index_of_item(I))].</span>")
			C.internal = I
		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.s_store, /obj/item/tank))
				to_chat(H, "<span class='notice'>I are now running on internals from [H.s_store] on your [H.wear_armor.name].</span>")
				H.internal = H.s_store
			else if(istype(H.belt, /obj/item/tank))
				to_chat(H, "<span class='notice'>I are now running on internals from [H.belt] on your belt.</span>")
				H.internal = H.belt
			else if(istype(H.l_store, /obj/item/tank))
				to_chat(H, "<span class='notice'>I are now running on internals from [H.l_store] in your left pocket.</span>")
				H.internal = H.l_store
			else if(istype(H.r_store, /obj/item/tank))
				to_chat(H, "<span class='notice'>I are now running on internals from [H.r_store] in your right pocket.</span>")
				H.internal = H.r_store

		//Separate so CO2 jetpacks are a little less cumbersome.
		if(!C.internal && istype(C.back, /obj/item/tank))
			to_chat(C, "<span class='notice'>I are now running on internals from [C.back] on your back.</span>")
			C.internal = C.back

		if(C.internal)
			icon_state = "internal1"
		else
			to_chat(C, "<span class='warning'>I don't have an oxygen tank!</span>")
			return
	C.update_action_buttons_icon()

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "running"

/obj/screen/mov_intent/Click(location, control, params)
	toggle(usr)

/obj/screen/mov_intent/update_icon_state()
	switch(hud?.mymob?.m_intent)
		if(MOVE_INTENT_WALK)
			icon_state = "walking"
		if(MOVE_INTENT_RUN)
			icon_state = "running"

/obj/screen/mov_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_move_intent(user)

/obj/screen/rogmove
	name = "sneak mode"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "sneak0"
	screen_loc = rogueui_moves

/obj/screen/rogmove/Click(location, control, params)
	var/mob/M = usr
	toggle(M)

/obj/screen/rogmove/proc/toggle(mob/user)
	if(isobserver(user))
		return
	if(user.m_intent == MOVE_INTENT_SNEAK)
		user.toggle_rogmove_intent(MOVE_INTENT_WALK)
	else
		user.toggle_rogmove_intent(MOVE_INTENT_SNEAK)
	update_icon_state()

/obj/screen/rogmove/update_icon_state()
	if(hud?.mymob?.m_intent == MOVE_INTENT_SNEAK)
		icon_state = "sneak1"
	else
		icon_state = "sneak0"

/obj/screen/rogmove/sprint
	name = "sprint mode"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "sprint0"
	screen_loc = rogueui_moves

/obj/screen/rogmove/sprint/toggle(mob/user)
	if(isobserver(user))
		return
	if(user.m_intent == MOVE_INTENT_RUN)
		user.toggle_rogmove_intent(MOVE_INTENT_WALK)
	else
		user.toggle_rogmove_intent(MOVE_INTENT_RUN)
	update_icon_state()

/obj/screen/rogmove/sprint/update_icon_state()
	if(hud?.mymob?.m_intent == MOVE_INTENT_RUN)
		icon_state = "sprint1"
	else
		icon_state = "sprint0"



/obj/screen/advsetup
	name = ""
	icon = null
	icon_state = ""

/obj/screen/advsetup/New(client/C) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()
	addtimer(CALLBACK(src, .proc/check_mob), 30)

/obj/screen/advsetup/Destroy()
	hud.static_inventory -= src
	return ..()

/obj/screen/advsetup/proc/check_mob()
	if(QDELETED(src))
		return
	if(!hud)
		qdel(src)
		return
	if(!ishuman(hud.mymob))
		qdel(src)
		return
	var/mob/living/carbon/human/H = hud.mymob
	if(H.advsetup)
		alpha = 0
		icon = 'icons/mob/advsetup.dmi'
		animate(src, alpha = 255, time = 30)

/obj/screen/advsetup/Click(location,control,params)
	if(!hud)
		qdel(src)
		return
	if(!ishuman(hud.mymob))
		qdel(src)
		return
	var/mob/living/carbon/human/H = hud.mymob
	if(!H.advsetup)
		qdel(src)
		return
	else
		if(H.advsetup())
			qdel(src)


/obj/screen/eye_intent
	name = "eye intent"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "eye"

/obj/screen/eye_intent/Click(location,control,params)
	var/list/modifiers = params2list(params)
	var/_y = text2num(params2list(params)["icon-y"])

	hud.mymob.playsound_local(hud.mymob, 'sound/misc/click.ogg', 100)
	if(isliving(hud?.mymob))
		var/mob/living/L = hud.mymob
		if(L.eyesclosed)
			L.eyesclosed = 0
			L.cure_blind("eyelids")

	if(modifiers["left"])
		if(_y>=29 || _y<=4)
			if(isliving(hud.mymob))
				var/mob/living/L = hud.mymob
				L.eyesclosed = 1
				L.become_blind("eyelids")
		else
			toggle(usr)

	if(modifiers["middle"])
		if(isliving(hud.mymob))
			var/mob/living/L = hud.mymob
			L.look_up()
	update_icon()

	if(modifiers["right"])
		if(isliving(hud.mymob))
			var/mob/living/L = hud.mymob
			L.look_around()

/obj/screen/eye_intent/update_icon(mob/user)
	if(!user && hud)
		user = hud.mymob
	if(!user)
		return
	if(!isliving(user))
		return
	cut_overlays()
	var/mob/living/L = user
	if(L.eyesclosed)
		icon_state = "eye_closed"
	else if(user.tempfixeye)
		icon_state = "eye_target"
	else if(user.fixedeye)
		icon_state = "eye_fixed"
	else
		icon_state = "eye"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.eye_color)
			var/mutable_appearance/MA = mutable_appearance(icon, "o[icon_state]")
			MA.color = "#[H.eye_color]"
			add_overlay(MA)

/obj/screen/eye_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_eye_intent(user)

/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "pull"

/obj/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/obj/screen/pull/update_icon_state()
	if(hud?.mymob?.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"

/obj/screen/rest
	name = "rest"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/rest/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.lay_down()

/obj/screen/rest/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user))
		return

	if(!user.resting)
		icon_state = "act_rest"
	else
		icon_state = "act_rest0"

/obj/screen/restup
	name = "stand up"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest_up"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/restup/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.stand_up()

/obj/screen/restdown
	name = "lay down"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "act_rest_down"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/restdown/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.lay_down()

/obj/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master

/obj/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated())
		return TRUE
	if (ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_held_item()
		if(I)
			master.attackby(null, I, usr, params)
	return TRUE

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/screen_midnight.dmi'
	icon_state = "catch0"
	var/throwy = 0

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/screen/throw_catch/update_icon()
	..()
	if(ismob(usr))
		var/mob/M = usr
		if(M.get_active_held_item())
			icon_state = "throw[throwy]"
		else
			icon_state = "catch[throwy]"

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "m-zone_sel"
	screen_loc = rogueui_targetdoll
	var/overlay_icon = 'icons/mob/roguehud64.dmi'
	var/static/list/hover_overlays_cache = list()
	var/hovering
	var/arrowheight = 0

/obj/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if(ismob(hud.mymob))
		var/mob/M = hud.mymob
		if(M.gender == FEMALE)
			choice = get_zone_at(icon_x, icon_y, FEMALE)
	if (!choice)
		return 1

	if(PL["right"] && ishuman(hud.mymob))
		var/mob/living/carbon/human/H = hud.mymob
		return H.check_limb_for_injuries(check_zone(choice))
	else
		return set_selected_zone(choice, usr)

/obj/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/obj/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	choice = "m_[choice]"
	if(ismob(hud.mymob))
		var/mob/M = hud.mymob
		if(M.gender == FEMALE)
			choice = get_zone_at(icon_x, icon_y, FEMALE)
			choice = "f_[choice]"

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice


	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
//		overlay_object.icon_state = "[basedholder]-[choice]"
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/mob/roguehud64.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	layer = ABOVE_HUD_LAYER+0.2
	plane = ABOVE_HUD_PLANE

/obj/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/obj/screen/zone_sel/proc/get_zone_at(icon_x, icon_y, gender = MALE)
	if(gender == MALE)
		switch(icon_y)
			if(1 to 3)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_R_INHAND
					if(17 to 28)
						return BODY_ZONE_PRECISE_R_FOOT
					if(38 to 49)
						return BODY_ZONE_PRECISE_L_FOOT
					if(59 to 61)
						return BODY_ZONE_L_INHAND
			if(4 to 5)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_R_INHAND
					if(17 to 28)
						return BODY_ZONE_PRECISE_R_FOOT
					if(38 to 49)
						return BODY_ZONE_PRECISE_L_FOOT
					if(59 to 61)
						return BODY_ZONE_L_INHAND
			if(6 to 15)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_R_INHAND
					if(20 to 29)
						return BODY_ZONE_R_LEG
					if(37 to 46)
						return BODY_ZONE_L_LEG
					if(59 to 61)
						return BODY_ZONE_L_INHAND
			if(16 to 21)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_R_INHAND
					if(12 to 18)
						return BODY_ZONE_PRECISE_R_HAND
					if(20 to 29)
						return BODY_ZONE_R_LEG
					if(37 to 46)
						return BODY_ZONE_L_LEG
					if(48 to 54)
						return BODY_ZONE_PRECISE_L_HAND
					if(59 to 61)
						return BODY_ZONE_L_INHAND
			if(22 to 24)
				switch(icon_x)
					if(5 to 7)
						return BODY_ZONE_R_INHAND
					if(12 to 18)
						return BODY_ZONE_PRECISE_R_HAND
					if(20 to 29)
						return BODY_ZONE_R_LEG
					if(30 to 36)
						return BODY_ZONE_PRECISE_GROIN
					if(37 to 46)
						return BODY_ZONE_L_LEG
					if(48 to 54)
						return BODY_ZONE_PRECISE_L_HAND
					if(59 to 61)
						return BODY_ZONE_L_INHAND
			if(25 to 29)
				switch(icon_x)
					if(16 to 22)
						return BODY_ZONE_R_ARM
					if(27 to 39)
						return BODY_ZONE_PRECISE_STOMACH
					if(44 to 50)
						return BODY_ZONE_L_ARM
			if(30 to 38)
				switch(icon_x)
					if(16 to 22)
						return BODY_ZONE_R_ARM
					if(24 to 42)
						return BODY_ZONE_CHEST
					if(44 to 50)
						return BODY_ZONE_L_ARM
			if(39)
				switch(icon_x)
					if(29 to 37)
						return BODY_ZONE_PRECISE_NECK
			if(40 to 46)
				switch(icon_x)
					if(27 to 39)
						if(icon_y in 40 to 41)
							if(icon_x in 29 to 37)
								return BODY_ZONE_PRECISE_NECK
						if(icon_y in 42 to 44)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_MOUTH
						if(icon_y == 46)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_NOSE
						return BODY_ZONE_HEAD
			if(47 to 50)
				switch(icon_x)
					if(24 to 26)
						return BODY_ZONE_PRECISE_EARS
					if(27 to 39)
						if(icon_y in 49 to 50)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						if(icon_y in 47 to 48)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_NOSE
						return BODY_ZONE_HEAD
					if(40 to 42)
						return BODY_ZONE_PRECISE_EARS
			if(51 to 55)
				switch(icon_x)
					if(27 to 39)
						if(icon_y == 51)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						if(icon_y in 53 to 55)
							if(icon_x in 29 to 37)
								return BODY_ZONE_PRECISE_HAIR
						return BODY_ZONE_HEAD
	else
		switch(icon_y)
			if(1 to 7)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_R_INHAND
					if(26 to 32)
						return BODY_ZONE_PRECISE_R_FOOT
					if(34 to 40)
						return BODY_ZONE_PRECISE_L_FOOT
					if(52 to 54)
						return BODY_ZONE_L_INHAND
			if(8 to 16)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_R_INHAND
					if(24 to 31)
						return BODY_ZONE_R_LEG
					if(35 to 42)
						return BODY_ZONE_L_LEG
					if(52 to 54)
						return BODY_ZONE_L_INHAND
			if(17 to 20)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_R_INHAND
					if(20 to 23)
						return BODY_ZONE_PRECISE_R_HAND
					if(24 to 31)
						return BODY_ZONE_R_LEG
					if(35 to 42)
						return BODY_ZONE_L_LEG
					if(43 to 46)
						return BODY_ZONE_PRECISE_L_HAND
					if(52 to 54)
						return BODY_ZONE_L_INHAND
			if(21)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_R_INHAND
					if(20 to 23)
						return BODY_ZONE_PRECISE_R_HAND
					if(30 to 36)
						return BODY_ZONE_PRECISE_GROIN
					if(43 to 46)
						return BODY_ZONE_PRECISE_L_HAND
					if(52 to 54)
						return BODY_ZONE_L_INHAND
			if(22 to 23)
				switch(icon_x)
					if(12 to 14)
						return BODY_ZONE_R_INHAND
					if(20 to 25)
						return BODY_ZONE_R_ARM
					if(30 to 36)
						return BODY_ZONE_PRECISE_GROIN
					if(41 to 46)
						return BODY_ZONE_L_ARM
					if(52 to 54)
						return BODY_ZONE_L_INHAND
			if(24 to 29)
				switch(icon_x)
					if(20 to 25)
						return BODY_ZONE_R_ARM
					if(28 to 38)
						return BODY_ZONE_PRECISE_STOMACH
					if(41 to 46)
						return BODY_ZONE_L_ARM
			if(30 to 37)
				switch(icon_x)
					if(20 to 25)
						return BODY_ZONE_R_ARM
					if(27 to 39)
						return BODY_ZONE_CHEST
					if(41 to 46)
						return BODY_ZONE_L_ARM
			if(38 to 39)
				switch(icon_x)
					if(30 to 36)
						return BODY_ZONE_PRECISE_NECK
			if(40 to 43)
				switch(icon_x)
					if(28 to 38)
						if(icon_y == 40)
							if(icon_x in 30 to 36)
								return BODY_ZONE_PRECISE_NECK
						if(icon_y in 41 to 43)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_MOUTH
						return BODY_ZONE_HEAD
			if(44 to 47)
				switch(icon_x)
					if(26 to 27)
						return BODY_ZONE_PRECISE_EARS
					if(28 to 38)
						if(icon_y in 44 to 46)
							if(icon_x in 32 to 34)
								return BODY_ZONE_PRECISE_NOSE
						if(icon_y == 47)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						return BODY_ZONE_HEAD
					if(39 to 40)
						return BODY_ZONE_PRECISE_EARS
			if(48 to 51)
				switch(icon_x)
					if(28 to 38)
						if(icon_y in 48 to 49)
							if(icon_x in 30 to 32)
								return BODY_ZONE_PRECISE_R_EYE
							if(icon_x in 34 to 36)
								return BODY_ZONE_PRECISE_L_EYE
						if(icon_y in 50 to 51)
							if(icon_x in 30 to 36)
								return BODY_ZONE_PRECISE_HAIR
						return BODY_ZONE_HEAD
			if(52)
				if(icon_x in 30 to 36)
					return BODY_ZONE_PRECISE_HAIR

/obj/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(user != hud?.mymob)
		return

	if(choice != hud.mymob.zone_selected)
		hud.mymob.select_zone(choice)
		update_icon()

	return TRUE

/obj/screen/zone_sel/update_overlays()
	. = ..()
	if(!hud?.mymob)
		return

	icon_state = "[hud.mymob.gender == "male" ? "m" : "f"]-zone_sel"

	if(hud.mymob.stat != DEAD && ishuman(hud.mymob))
		var/mob/living/carbon/human/H = hud.mymob
		for(var/X in H.bodyparts)
			var/obj/item/bodypart/BP = X
			if(BP.body_zone in H.get_missing_limbs())
				continue
			if(HAS_TRAIT(H, TRAIT_NOPAIN))
				var/mutable_appearance/limby = mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[BP.body_zone]")
				limby.color = "#78a8ba"
				. += limby
				continue
			var/damage = BP.burn_dam + BP.brute_dam
			if(BP.wounds.len)
				for(var/datum/wound/W in BP.wounds)
					damage = damage + W.woundpain
			if(damage > BP.max_damage)
				damage = BP.max_damage
			var/comparison = (damage/BP.max_damage)
			. += mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[BP.body_zone]") //apply healthy limb
			var/mutable_appearance/limby = mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]w-[BP.body_zone]") //apply wounded overlay
			limby.alpha = (comparison*255)*2
			. += limby
			if(BP.get_bleedrate())
				. += mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[BP.body_zone]-bleed") //apply healthy limb
		for(var/X in H.get_missing_limbs())
			var/mutable_appearance/limby = mutable_appearance('icons/mob/roguehud64.dmi', "[H.gender == "male" ? "m" : "f"]-[X]") //missing limb
			limby.color = "#2f002f"
			. += limby

	. += mutable_appearance(overlay_icon, "[hud.mymob.gender == "male" ? "m" : "f"]_[hud.mymob.zone_selected]")
//	. += mutable_appearance(overlay_icon, "height_arrow[hud.mymob.aimheight]")

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'
	overlay_icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'

/obj/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/obj/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/blob/naut
	name = "health"
	icon = 'icons/mob/blob.dmi'
	icon_state = "nauthealth"

/obj/screen/healths/blob/naut/core
	name = "overmind health"
	screen_loc = ui_health
	icon_state = "corehealth"

/obj/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions/backgrounds.dmi'
	icon_state = "bg_revenant"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/construct
	icon = 'icons/mob/screen_construct.dmi'
	icon_state = "artificer_health0"
	screen_loc = ui_construct_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/slime
	icon = 'icons/mob/screen_slime.dmi'
	icon_state = "slime_health0"
	screen_loc = ui_slime_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/lavaland_elite
	icon = 'icons/mob/screen_elite.dmi'
	icon_state = "elite_health0"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healthdoll
	name = "health doll"
	screen_loc = rogueui_targetdoll

/obj/screen/healthdoll/Click(location, control, params)
	if (ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.check_self_for_injuries()

/obj/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = null

/obj/screen/healths/blood
	name = "life"
	icon_state = "blood100"
	screen_loc = rogueui_blood
	icon = 'icons/mob/rogueheat.dmi'

/obj/screen/healths/blood/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(modifiers["left"])
			var/headpercent	= 0
			var/burnspercent	= 0
			var/toxpercent = H.getToxLoss()
			var/oxpercent = H.getOxyLoss()
			var/bloodpercent = (H.blood_volume / BLOOD_VOLUME_NORMAL) * 100
			for(var/X in H.bodyparts)	//hardcoded to streamline things a bit
				var/obj/item/bodypart/BP = X
				if(BP.name == "head")
					headpercent	+= (BP.brute_dam / BP.max_damage) * 100
					if(burnspercent < BP.burn_dam)
						burnspercent = (BP.burn_dam / BP.max_damage) * 100
				if(BP.name == "chest")
					if(burnspercent < BP.burn_dam)
						burnspercent = (BP.burn_dam / BP.max_damage) * 100

			if(headpercent)
				to_chat(H, "<span class='purple'>Mortal Wounds</span>")
			if(burnspercent)
				to_chat(H, "<span class='orange'>Mortal Burns</span>")
			if(bloodpercent < 100)
				to_chat(H, "<span class='red'>Bloodloss</span>")
			if(toxpercent)
				to_chat(H, "<span class='green'>Poisoned</span>")
			if(oxpercent)
				to_chat(H, "<span class='grey'>Suffocation</span>")
			if(H.nutrition < 0)
				to_chat(H, "<span class='red'>Starving to Death</span>")
		if(modifiers["right"])
			if(H.mind)
				if(H.mind.known_people.len)
					H.mind.display_known_people(H)
				else
					to_chat(H, "<span class='warning'>I don't know anyone.</span>")

/obj/screen/splash
	icon = 'icons/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER+1
	plane = SPLASHSCREEN_PLANE
	var/client/holder
	var/fucme = TRUE

/obj/screen/splash/credits
	icon = 'icons/fullblack.dmi'
	icon_state = ""
	screen_loc = ui_backhudl
	layer = SPLASHSCREEN_LAYER
	fucme = FALSE

/obj/screen/splash/New(client/C, visible, use_previous_title) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()

	holder = C

	if(!visible)
		alpha = 0

	if(fucme)
		if(!use_previous_title)
			if(SStitle.icon)
				icon = SStitle.icon
		else
			if(!SStitle.previous_icon)
				qdel(src)
				return
			icon = SStitle.previous_icon

	holder.screen += src

/obj/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/obj/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()

/obj/screen/gameover
	icon = 'icons/gameover.dmi'
	icon_state = ""
	screen_loc = ui_backhudl
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE

/obj/screen/gameover/proc/Fade(out = FALSE, qdel_after = FALSE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30, flags = ANIMATION_PARALLEL)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30, flags = ANIMATION_PARALLEL)
	if(qdel_after)
		QDEL_IN(src, 30)


/obj/screen/gameover/hog
	icon_state = "hog"
	alpha = 0

/obj/screen/gameover/hog/Fade(out = FALSE, qdel_after = FALSE)
	if(QDELETED(src))
		return
//	icon_state = "blank"
//	var/image/MA = image(icon, "hog")
//	MA.alpha = 0
//	add_overlay(MA)
//	animate(MA, alpha = 255, time = 30)
	if(!out)
		animate(src, alpha = 255, time = 30, flags = ANIMATION_PARALLEL)
	else
		animate(src, alpha = 0, time = 30, flags = ANIMATION_PARALLEL)
		QDEL_IN(src, 30)

/obj/screen/component_button
	var/obj/screen/parent

/obj/screen/component_button/Initialize(mapload, obj/screen/parent)
	. = ..()
	src.parent = parent

/obj/screen/component_button/Click(location, control, params)
	if(parent)
		parent.component_click(src, params)

//Roguehud objects

/obj/screen/backhudl
	icon = 'icons/mob/roguehudback2.dmi'
	icon_state = ""
	name = " "
	screen_loc = ui_backhudl
	layer = BACKHUD_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/backhudl/Click()
	return

/obj/screen/backhudl/ghost
	icon_state = "dead"
	icon = 'icons/mob/roguehudbackghost.dmi'

/obj/screen/backhudl/obs
	icon_state = "obs"
	icon = 'icons/mob/roguehudbackghost.dmi'

/obj/screen/aim
	name = ""
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "aimbg"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/aim/boxaim
	name = "tile selection indicator"
	icon_state = "boxoff"

/obj/screen/aim/boxaim/Click()
	if(ismob(usr))
		var/mob/M = usr
		if(M.boxaim == TRUE)
			M.boxaim = FALSE
		else
			M.boxaim = TRUE
		update_icon()

/obj/screen/aim/boxaim/update_icon()
	if(ismob(usr))
		var/mob/living/M = usr
		if(M.boxaim == TRUE)
			icon_state = "boxon"
		else
			icon_state = "boxoff"
			if(M.client)
				M.client.mouseoverbox.screen_loc = null
	..()


/obj/screen/stress
	name = "sanity"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "stressback"

/obj/screen/stress/update_icon()
	cut_overlays()
	var/state2use = "stress1"
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(!HAS_TRAIT(H, TRAIT_NOMOOD))
			if(H.stress)
				state2use = "stress2"
				if(H.stress >= 10)
					state2use = "stress3"
				if(H.stress >= 20)
					state2use = "stress4"
				if(H.stress >= 30)
					state2use = "stress5"
		if(H.has_status_effect(/datum/status_effect/buff/drunk))
			state2use = "mood_drunk"
		if(H.has_status_effect(/datum/status_effect/buff/druqks))
			state2use = "mood_high"
		if(H.InFullCritical())
			state2use = "mood_fear"
		if(H.mind)
			if(H.mind.has_antag_datum(/datum/antagonist/zombie))
				state2use = "mood_fear"
		if(H.stat == DEAD)
			state2use = "mood_dead"
	add_overlay(state2use)

/obj/screen/stress/Click(location,control,params)
	var/list/modifiers = params2list(params)

	if(ishuman(usr))
		var/mob/living/carbon/human/M = usr
		if(modifiers["left"])
			if(M.charflaw)
				to_chat(M, "*----*")
				to_chat(M, "<span class='info'>[M.charflaw.desc]</span>")
			to_chat(M, "*--------*")
			var/list/already_printed = list()
			for(var/datum/stressevent/S in M.positive_stressors)
				if(S in already_printed)
					continue
				var/cnt = 1
				for(var/datum/stressevent/CS in M.positive_stressors)
					if(CS == S)
						continue
					if(CS.type == S.type)
						cnt++
						already_printed += CS
				var/ddesc = S.desc
				if(islist(S.desc))
					ddesc = pick(S.desc)
				if(cnt > 1)
					to_chat(M, "[ddesc] (x[cnt])")
				else
					to_chat(M, "[ddesc]")
			for(var/datum/stressevent/S in M.negative_stressors)
				if(S in already_printed)
					continue
				var/cnt = 1
				for(var/datum/stressevent/CS in M.negative_stressors)
					if(CS == S)
						continue
					if(CS.type == S.type)
						cnt++
						already_printed += CS
				var/ddesc = S.desc
				if(islist(S.desc))
					ddesc = pick(S.desc)
				if(cnt > 1)
					to_chat(M, "[ddesc] (x[cnt])")
				else
					to_chat(M, "[ddesc]")
			already_printed = list()
			to_chat(M, "*--------*")
		if(modifiers["right"])
			if(M.get_triumphs() <= 0)
				to_chat(M, "<span class='warning'>I haven't TRIUMPHED.</span>")
				return
			if(alert("Do you want to remember a TRIUMPH?", "", "Yes", "No") == "Yes")
				if(M.add_stress(/datum/stressevent/triumph))
					M.adjust_triumphs(-1)
					M.playsound_local(M, 'sound/misc/notice (2).ogg', 100, FALSE)


/obj/screen/rmbintent
	name = "alt intents"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "rmbintent"
	var/list/shown_intents = list()
	var/showing = FALSE

/obj/screen/rmbintent/update_icon()
	testing("overlayscut")
	cut_overlays()
	if(isliving(hud?.mymob))
		var/mob/living/L = hud.mymob
		if(L.rmb_intent)
//			var/image/I = image(icon='icons/mob/roguehud.dmi',icon_state="[L.rmb_intent.icon_state]_x", layer = layer+0.01)
			add_overlay("[L.rmb_intent.icon_state]_x")
			name = L.rmb_intent.name
			desc = L.rmb_intent.desc

/obj/screen/rmbintent/Click(location,control,params)
	var/list/modifiers = params2list(params)

	if(isliving(usr))
		var/mob/living/M = usr
		if(modifiers["left"])
			if(showing)
				collapse_intents()
			else
				show_intents(M)
		if(modifiers["right"])
			if(M.rmb_intent)
				to_chat(M, "<span class='info'>* --- *</span>")
				to_chat(M, "<span class='info'>[name]: [desc]</span>")
				to_chat(M, "<span class='info'>* --- *</span>")

/obj/screen/rmbintent/proc/collapse_intents()
	if(!showing)
		return
	showing = FALSE
	QDEL_LIST(shown_intents)
	update_icon()

/obj/screen/rmbintent/proc/show_intents(mob/living/M)
	if(showing)
		return
	if(!M)
		return
	showing = TRUE
	var/cnt
	var/i = 15
	var/they = 0.02
	for(var/X in M.possible_rmb_intents)
		if(M.rmb_intent?.type == X)
			continue
		var/obj/screen/rintent_selection/R = new(M.client)
		var/datum/rmb_intent/RI = new X
		R.stored_intent = X
		R.icon_state = RI.icon_state
		R.name = RI.name
		R.desc = RI.desc
		shown_intents += R
		R.screen_loc = "WEST-4:0,SOUTH+8:[i]"
		R.layer = layer+they
		i += 15
		they += 0.01
		cnt++
	if(!cnt)
		showing = FALSE

/obj/screen/rmbintent/Destroy()
	QDEL_LIST(shown_intents)
	. = ..()

/obj/screen/rintent_selection
	name = "rmb intent"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "rmbaimed"
	var/stored_intent
	var/stored_name
	var/client/holder

/obj/screen/rintent_selection/New(client/C)
	if(C)
		holder = C
	. = ..()
	holder.screen += src

/obj/screen/rintent_selection/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()

/obj/screen/rintent_selection/Click(location,control,params)
	var/list/modifiers = params2list(params)

	if(isliving(usr))
		var/mob/living/M = usr
		if(modifiers["left"])
			if(stored_intent)
				M.swap_rmb_intent(type = stored_intent)
		if(modifiers["right"])
			to_chat(M, "<span class='info'>* --- *</span>")
			to_chat(M, "<span class='info'>[name]: [desc]</span>")
			to_chat(M, "<span class='info'>* --- *</span>")

/mob/living/proc/swap_rmb_intent(type, num)
	if(!possible_rmb_intents?.len)
		return
	if(type)
		if(type in possible_rmb_intents)
			rmb_intent = new type()
			if(hud_used?.rmb_intent)
				hud_used.rmb_intent.update_icon()
				hud_used.rmb_intent.collapse_intents()
	if(num)
		if(possible_rmb_intents.len < num)
			return
		var/A = possible_rmb_intents[num]
		if(A)
			rmb_intent = new A()
			if(hud_used?.rmb_intent)
				hud_used.rmb_intent.update_icon()
				hud_used.rmb_intent.collapse_intents()


/obj/screen/time
	name = "Sir Sun"
	icon = 'icons/time.dmi'
	icon_state = "day"

/obj/screen/time/update_icon()
	cut_overlays()
	switch(GLOB.tod)
		if("day")
			icon_state = "day"
			name = "Sir Sun"
		if("dusk")
			icon_state = "dusk"
			name = "Sir Sun - Dusk"
		if("night")
			icon_state = "night"
			name = "Miss Moon"
		if("dawn")
			icon_state = "dawn"
			name = "Sir Sun - Dawn"
	for(var/datum/weather/rain/R in SSweather.curweathers)
		if(R.stage < 2)
			add_overlay("clouds")
		if(R.stage == 2)
			add_overlay("rainlay")

/obj/screen/rogfat
	name = "stamina"
	icon_state = "fat100"
	icon = 'icons/mob/rogueheat.dmi'
	screen_loc = rogueui_fat

/obj/screen/rogstam
	name = "fatigue"
	icon_state = "stam100"
	icon = 'icons/mob/rogueheat.dmi'
	screen_loc = rogueui_fat

/obj/screen/heatstamover
	name = ""
	mouse_opacity = 0
	icon_state = "heatstamover"
	icon = 'icons/mob/rogueheat.dmi'
	screen_loc = rogueui_fat
	layer = HUD_LAYER+0.1

/obj/screen/grain
	icon = 'icons/grain.dmi'
	icon_state = "grain"
	name = ""
	screen_loc = "1,1"
	mouse_opacity = 0
	alpha = 70
//	layer = 20.5
//	plane = 20
	layer = 13
	plane = 0
	blend_mode = 4

/obj/screen/scannies
	icon = 'icons/mob/roguehudback2.dmi'
	icon_state = "crt"
	name = ""
	screen_loc = ui_backhudl
	mouse_opacity = 0
	alpha = 0
	layer = 24
	plane = 24
	blend_mode = BLEND_MULTIPLY

/obj/screen/char_preview
	name = "Me."
	icon_state = ""
//	var/list/prevcolors = list("background-color=#000000","background-color=#242f28","background-color=#302323","background-color=#999a63","background-color=#7e7e7e")

//obj/screen/char_preview/Click()
//	winset(usr.client, "preferences_window.character_preview_map", pick(prevcolors))

#define READ_RIGHT 1
#define READ_LEFT 2
#define READ_BOTH 3

/obj/screen/read
	icon = 'icons/roguetown/hud/read.dmi'
	icon_state = ""
	name = ""
	screen_loc = "1,1"
	layer = HUD_LAYER+0.01
	plane = HUD_PLANE
	alpha = 0
	var/obj/screen/readtext/textright
	var/obj/screen/readtext/textleft
	var/reading

/obj/screen/read/Click(location, control, params)
	. = ..()
	destroy_read()
	if(!usr || !usr.client)
		return FALSE
	var/mob/user = usr
	user << browse(null, "window=reading")

/obj/screen/read/proc/destroy_read()
	if(textright)
		textright.alpha = 0
		textleft.maptext = null
	if(textleft)
		textleft.alpha = 0
		textleft.maptext = null
	alpha = 0
	icon_state = ""
	reading = FALSE

/obj/screen/read/proc/show()
	alpha = 255
	reading = TRUE

/obj/screen/read/proc/show_text(input)
	reading = TRUE
	animate(src, alpha = 255, time = 5, easing = EASE_IN)
	if(input == READ_RIGHT)
		animate(textright, alpha = 255, time = 5, easing = EASE_IN)
		textleft.alpha = 0
	if(input == READ_LEFT)
		textright.alpha = 0
		animate(textleft, alpha = 255, time = 5, easing = EASE_IN)
	if(input == READ_BOTH)
		animate(textleft, alpha = 255, time = 5, easing = EASE_IN)
		animate(textright, alpha = 255, time = 5, easing = EASE_IN)

/obj/screen/readtext
	name = ""
	icon = null
	icon_state = ""
	screen_loc = "5,5"
	layer = HUD_LAYER+0.02
	plane = HUD_PLANE

/obj/screen/area_text
	icon = null
	icon_state = ""
	name = ""
	screen_loc = "5,5"
	layer = HUD_LAYER+0.02
	plane = HUD_PLANE
	alpha = 0
	var/reading

/obj/screen/daynight
	icon = 'icons/time.dmi'
	icon_state = ""
	screen_loc = "EAST-2:-14,CENTER-6:16"

/obj/screen/daynight/New(client/C) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()
	icon_state = GLOB.tod