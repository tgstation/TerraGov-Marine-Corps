//----------------------------------------------------------
			//							  \\
			// EQUIPMENT AND INTERACTION  \\
			//							  \\
			//						   	  \\
//----------------------------------------------------------

/obj/item/weapon/gun/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN_EJECTS))
		do_unique_action(user, TRUE)
		return
	unload(user)

/obj/item/weapon/gun/attack_hand_alternate(mob/user)
	. = ..()
	if(!active_attachable)
		return toggle_gun_safety()

	var/mob/living/living_user = user
	if(living_user.get_active_held_item() != src && living_user.get_inactive_held_item() != src)
		return

	active_attachable.unload(living_user)

/obj/item/weapon/gun/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(user.get_inactive_held_item() != src || istype(I, /obj/item/attachable) || isgun(I))
		return
	reload(I, user)

/obj/item/weapon/gun/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(!active_attachable || user.get_inactive_held_item() != src)
		return

	active_attachable.reload(I, user)

/obj/item/weapon/gun/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	//Cannot equip wielded items or items burst firing.
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return
	unwield(user)
	return ..()


/*
Note: pickup and dropped on weapons must have both the ..() to update zoom AND twohanded,
As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
*/
/obj/item/weapon/gun/dropped(mob/user)
	. = ..()

	unwield(user)


/obj/item/weapon/gun/pickup(mob/user)
	..()

	unwield(user)


/obj/item/weapon/gun/proc/police_allowed_check(mob/living/carbon/human/user)
	if(CONFIG_GET(flag/remove_gun_restrictions))
		return TRUE //Not if the config removed it.

	if(user.skills.getRating(SKILL_POLICE) >= SKILL_POLICE_MP)
		return TRUE
	if(user.mind && allowed(user))
		return TRUE
	to_chat(user, span_warning("[src] flashes a warning sign indicating unauthorized use!"))

/obj/item/weapon/gun/proc/do_wield(mob/user, wdelay) //*shrugs*
	if(wield_time > 0 && !do_after(user, wdelay, IGNORE_LOC_CHANGE, user, BUSY_ICON_HOSTILE, null, PROGRESS_CLOCK, CALLBACK(src, PROC_REF(is_wielded))))
		return FALSE
	flags_item |= FULLY_WIELDED
	setup_bullet_accuracy()
	return TRUE

/obj/item/weapon/gun/attack_self(mob/user)
	. = ..()
	//There are only two ways to interact here.
	if(!CHECK_BITFIELD(flags_item, TWOHANDED))
		return
	if(flags_item & WIELDED)
		unwield(user)//Trying to unwield it
		return
	wield(user)//Trying to wield it

//tactical reloads
/obj/item/weapon/gun/MouseDrop_T(atom/dropping, mob/living/carbon/human/user)
	if(istype(dropping, /obj/item/ammo_magazine) || istype(dropping, /obj/item/cell))
		tactical_reload(dropping, user)
	return ..()

///This performs a tactical reload with src using new_magazine to load the gun.
/obj/item/weapon/gun/proc/tactical_reload(obj/item/new_magazine, mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated(TRUE) || user.do_actions)
		return
	if(!(new_magazine.type in allowed_ammo_types))
		if(active_attachable)
			active_attachable.tactical_reload(new_magazine, user)
			return
		to_chat(user, span_warning("[new_magazine] cannot fit into [src]!"))
		return
	if(src != user.r_hand && src != user.l_hand && (!master_gun || (master_gun != user.r_hand && master_gun != user.l_hand)))
		to_chat(user, span_warning("[src] must be in your hand to do that."))
		return
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) || max_chamber_items > 1)
		to_chat(user, span_warning("Can't do tactical reloads with [src]."))
		return
	//no tactical reload for the untrained.
	if(user.skills.getRating(SKILL_FIREARMS) < SKILL_FIREARMS_DEFAULT)
		to_chat(user, span_warning("You don't know how to do tactical reloads."))
		return
	to_chat(user, span_notice("You start a tactical reload."))
	var/tac_reload_time = max(0.25 SECONDS, 0.75 SECONDS - user.skills.getRating(SKILL_FIREARMS) * 5)
	if(length(chamber_items))
		if(!do_after(user, tac_reload_time, IGNORE_USER_LOC_CHANGE, new_magazine) && loc == user)
			return
		unload(user)
	if(!do_after(user, tac_reload_time, IGNORE_USER_LOC_CHANGE, new_magazine) && loc == user)
		return
	if(istype(new_magazine.loc, /obj/item/storage))
		var/obj/item/storage/S = new_magazine.loc
		S.remove_from_storage(new_magazine, get_turf(user), user)
	if(!CHECK_BITFIELD(get_flags_magazine_features(new_magazine), MAGAZINE_WORN))
		user.put_in_any_hand_if_possible(new_magazine)
	reload(new_magazine, user)

//----------------------------------------------------------
				//						 \\
				// GENERIC HELPER PROCS  \\
				//						 \\
				//						 \\
//----------------------------------------------------------
/obj/item/weapon/gun/proc/check_inactive_hand(mob/user)
	if(user)
		var/obj/item/weapon/gun/in_hand = user.get_inactive_held_item()
		if( in_hand != src && !master_gun) //It has to be held.
			to_chat(user, span_warning("You have to hold [src] to do that!"))
			return
	return TRUE


/obj/item/weapon/gun/proc/check_both_hands(mob/user)
	if(user)
		var/obj/item/weapon/gun/in_handL = user.l_hand
		var/obj/item/weapon/gun/in_handR = user.r_hand
		if(in_handL != src && in_handR != src && !master_gun) //It has to be held.
			to_chat(user, span_warning("You have to hold [src] to do that!"))
			return
	return 1

/obj/item/weapon/gun/proc/is_wielded() //temporary proc until we get traits going
	return CHECK_BITFIELD(flags_item, WIELDED)

///Checks the gun to see if it has an attachment of type attachment_type
/obj/item/weapon/gun/proc/has_attachment(attachment_type)
	for(var/key in attachments_by_slot)
		var/obj/item/attachment = attachments_by_slot[key]
		if(!istype(attachment, attachment_type))
			continue
		return TRUE
	return FALSE


/obj/item/weapon/gun/proc/update_force_list()
	switch(force)
		if(-50 to 15)
			attack_verb = list("struck", "hit", "bashed") //Unlikely to ever be -50, but just to be safe.
		if(16 to 35)
			attack_verb = list("smashed", "struck", "whacked", "beaten", "cracked")
		else
			attack_verb = list("slashed", "stabbed", "speared", "torn", "punctured", "pierced", "gored") //Greater than 35


/proc/get_active_firearm(mob/user)
	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this."))
		return

	if(user.incapacitated() || !isturf(user.loc))
		to_chat(user, span_warning("You can't do this right now."))
		return

	var/obj/item/weapon/gun/G = user.get_active_held_item()
	if(!istype(G))
		G = user.get_inactive_held_item()

	if(!istype(G))
		to_chat(user, span_warning("You need a gun in your hands to do that!"))
		return

	if(HAS_TRAIT(G, TRAIT_GUN_BURST_FIRING))
		return

	return G

///Helper proc that processes a clicked target, if the target is not black tiles, it will not change it. If they are it will return the turf of the black tiles. It will return null if the object is a screen object other than black tiles.
/proc/get_turf_on_clickcatcher(atom/target, mob/user, params)
	var/list/modifiers = params2list(params)
	if(!istype(target, /atom/movable/screen))
		return target
	if(!istype(target, /atom/movable/screen/click_catcher))
		return null
	return params2turf(modifiers["screen-loc"], get_turf(user), user.client)

//----------------------------------------------------------
					//				   \\
					// GUN VERBS PROCS \\
					//				   \\
					//				   \\
//----------------------------------------------------------

/obj/item/weapon/gun/ui_action_click(mob/user, datum/action/item_action/action)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return
	var/datum/action/item_action/firemode/firemode_action = action
	if(!istype(firemode_action))
		if(master_gun)
			activate(user)
			return
		return ..()
	do_toggle_firemode()
	user.update_action_buttons()


/mob/living/carbon/human/verb/toggle_autofire()
	set category = "Weapons"
	set name = "Toggle Auto Fire"
	set desc = "Toggle automatic firemode, if the gun has it."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_autofire()


/obj/item/weapon/gun/verb/toggle_autofire()
	set category = null
	set name = "Toggle Auto Fire (Weapon)"
	set desc = "Toggle automatic firemode, if the gun has it."

	var/new_firemode
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			new_firemode = GUN_FIREMODE_AUTOMATIC
		if(GUN_FIREMODE_BURSTFIRE)
			new_firemode = GUN_FIREMODE_AUTOBURST
		if(GUN_FIREMODE_AUTOMATIC)
			new_firemode = GUN_FIREMODE_SEMIAUTO
		if(GUN_FIREMODE_AUTOBURST)
			new_firemode = GUN_FIREMODE_BURSTFIRE
	if(!(new_firemode in gun_firemode_list))
		to_chat(usr, span_warning("[src] lacks a [new_firemode]!"))
		return
	do_toggle_firemode(new_firemode = new_firemode)


/mob/living/carbon/human/verb/toggle_burstfire()
	set category = "Weapons"
	set name = "Toggle Burst Fire"
	set desc = "Toggle burst firemode, if the gun has it."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_burstfire()


/obj/item/weapon/gun/verb/toggle_burstfire()
	set category = null
	set name = "Toggle Burst Fire (Weapon)"
	set desc = "Toggle burst firemode, if the gun has it."

	var/new_firemode
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			new_firemode = GUN_FIREMODE_BURSTFIRE
		if(GUN_FIREMODE_BURSTFIRE)
			new_firemode = GUN_FIREMODE_SEMIAUTO
		if(GUN_FIREMODE_AUTOMATIC)
			new_firemode = GUN_FIREMODE_AUTOBURST
		if(GUN_FIREMODE_AUTOBURST)
			new_firemode = GUN_FIREMODE_AUTOMATIC
	if(!(new_firemode in gun_firemode_list))
		to_chat(usr, span_warning("[src] lacks a [new_firemode]!"))
		return
	do_toggle_firemode(new_firemode = new_firemode)


/mob/living/carbon/human/verb/toggle_firemode()
	set category = "Weapons"
	set name = "Toggle Fire Mode"
	set desc = "Toggle between fire modes, if the gun has more than has one."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_firemode()


/obj/item/weapon/gun/verb/toggle_firemode()
	set category = null
	set name = "Toggle Fire Mode (Weapon)"
	set desc = "Toggle between fire modes, if the gun has more than has one."

	do_toggle_firemode()


/obj/item/weapon/gun/proc/do_toggle_firemode(datum/source, datum/keybinding, new_firemode)
	SIGNAL_HANDLER
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))//can't toggle mid burst
		return

	if(!length(gun_firemode_list))
		CRASH("[src] called do_toggle_firemode() with an empty gun_firemode_list")

	if(length(gun_firemode) == 1)
		return

	if(new_firemode)
		if(!(new_firemode in gun_firemode_list))
			CRASH("[src] called do_toggle_firemode() with [new_firemode] new_firemode, not on gun_firemode_list")
		gun_firemode = new_firemode
	else
		var/mode_index = gun_firemode_list.Find(gun_firemode)
		if(++mode_index <= length(gun_firemode_list))
			gun_firemode = gun_firemode_list[mode_index]
		else
			gun_firemode = gun_firemode_list[1]

	if(ishuman(source))
		to_chat(source, span_notice("[icon2html(src, source)] You switch to <b>[gun_firemode]</b>."))
		if(source == gun_user)
			gun_user.update_action_buttons()
	playsound(src, 'sound/weapons/guns/interact/selector.ogg', 15, 1)
	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, gun_firemode)
	setup_bullet_accuracy()


/obj/item/weapon/gun/proc/add_firemode(added_firemode, mob/user)
	gun_firemode_list += added_firemode

	switch(length(gun_firemode_list))
		if(0)
			CRASH("add_firemode called with a resulting gun_firemode_list length of [length(gun_firemode_list)].")
		if(1) //No need to toggle anything if there's a single firemode.
			return
		if(2)
			LAZYADD(actions_types, /datum/action/item_action/firemode)
			var/datum/action/new_action = new /datum/action/item_action/firemode(src)
			if(user)
				var/mob/living/living_user = user
				if((src == living_user.l_hand || src == living_user.r_hand) && !CHECK_BITFIELD(flags_item, IS_DEPLOYED))
					new_action.give_action(living_user)
		else //The action should already be there by now.
			return


/obj/item/weapon/gun/proc/remove_firemode(removed_firemode, mob/user)
	switch(length(gun_firemode_list))
		if(0, 1)
			CRASH("remove_firemode called with gun_firemode_list length [length(gun_firemode_list)].")
		if(2)
			LAZYREMOVE(actions_types, /datum/action/item_action/firemode)
			var/datum/action/old_action = locate(/datum/action/item_action/firemode) in actions
			if(user)
				var/mob/living/living_user = user
				if((src == living_user.l_hand || src == living_user.r_hand) && !CHECK_BITFIELD(flags_item, IS_DEPLOYED))
					old_action.remove_action(living_user)
			qdel(old_action)

	gun_firemode_list -= removed_firemode

	if(gun_firemode == removed_firemode)
		gun_firemode = gun_firemode_list[1]
		do_toggle_firemode(user, gun_firemode)


/obj/item/weapon/gun/proc/setup_firemodes()
	if(burst_amount > 1 && !(GUN_FIREMODE_BURSTFIRE in  gun_firemode_list))
		gun_firemode_list += GUN_FIREMODE_BURSTFIRE

	switch(length(gun_firemode_list))
		if(0)
			CRASH("[src] called setup_firemodes() with an empty gun_firemode_list")
		if(1)
			gun_firemode = gun_firemode_list[1]
		else
			gun_firemode = gun_firemode_list[1]
			var/datum/action/new_action = new /datum/action/item_action/firemode(src)
			if(isliving(loc))
				var/mob/living/living_user = loc
				if(src == living_user.l_hand || src == living_user.r_hand)
					new_action.give_action(living_user)

// The section for where you can do a fancy change to ammo types for most weapons.
/obj/item/weapon/gun/proc/add_ammo_mod(ammo_mod)
	return

/obj/item/weapon/gun/proc/remove_ammo_mod()
	return

/obj/item/weapon/gun/energy/add_ammo_mod(ammo_mod)
	ammo_diff = ammo_mod

/obj/item/weapon/gun/energy/remove_ammo_mod()
	ammo_diff = initial(ammo_diff)

///Gets the attachents by slot and activates them.
/obj/item/weapon/gun/proc/activate_attachment(slot, mob/user)
	if(!(slot in attachments_by_slot))
		return FALSE
	var/obj/item/attachment = attachments_by_slot[slot]
	if(!attachment)
		return FALSE

	if(isgun(attachment)) //I wish I had a way to do this with the component. So that I wouldnt have to manually call the activate proc.
		var/obj/item/weapon/gun/gun = attachment
		return gun.activate(user)
	if(isgunattachment(attachment))
		var/obj/item/attachable/attachable = attachment
		return attachable.activate(user)


// todo destroy all verbs
/mob/living/carbon/human/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Weapon"
	set desc = "Removes the magazine from your current gun and drops it on the ground, or clears the chamber if your gun is already empty."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.empty_mag()


/obj/item/weapon/gun/verb/empty_mag()
	set category = null
	set name = "Unload Weapon (Weapon)"
	set desc = "Removes the magazine from your current gun and drops it on the ground, or clears the chamber if your gun is already empty."

	unload(usr) //We want to drop the mag on the ground.


/mob/living/carbon/human/verb/use_unique_action()
	set category = "Weapons"
	set name = "Unique Action"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.use_unique_action()


/obj/item/weapon/gun/verb/use_unique_action()
	set category = null
	set name = "Unique Action (Weapon)"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."

	do_unique_action(usr)


/mob/living/carbon/human/verb/toggle_gun_safety()
	set category = "Weapons"
	set name = "Toggle Gun Safety"
	set desc = "Toggle the safety of the held gun."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_gun_safety()


/obj/item/weapon/gun/verb/toggle_gun_safety()
	set category = null
	set name = "Toggle Gun Safety (Weapon)"
	set desc = "Toggle the safety of the held gun."

	balloon_alert(usr, "Safety [HAS_TRAIT(src, TRAIT_GUN_SAFETY) ? "off" : "on"].")
	playsound(usr, 'sound/weapons/guns/interact/selector.ogg', 15, 1)
	if(!HAS_TRAIT(src, TRAIT_GUN_SAFETY))
		ADD_TRAIT(src, TRAIT_GUN_SAFETY, GUN_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_GUN_SAFETY, GUN_TRAIT)


/mob/living/carbon/human/verb/activate_attachment_verb()
	set category = "Weapons"
	set name = "Load From Attachment"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.activate_attachment_verb()


/obj/item/weapon/gun/verb/activate_attachment_verb()
	set category = null
	set name = "Load From Attachment (Weapon)"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."

	var/list/usable_attachments = list()
	// rail attachment use the button to toggle flashlight instead.
	//	if(rail && (rail.flags_attach_features & ATTACH_ACTIVATION) )
	//		usable_attachments += rail
	if(!length(attachments_by_slot))
		balloon_alert(usr, "No usable attachments")
		return

	for(var/key in attachments_by_slot)
		var/obj/item/attachment = attachments_by_slot[key]
		if(!attachment)
			continue
		var/obj/item/attachable/attachable = attachment
		if(attachable.flags_attach_features & ATTACH_ACTIVATION)
			usable_attachments += attachment

	if(!length(usable_attachments)) //No usable attachments.
		balloon_alert(usr, "No usable attachments")
		return
	var/obj/item/attachable/usable_attachment
	if(length(usable_attachments) == 1)
		usable_attachment = usable_attachments[1]
	else
		usable_attachment = tgui_input_list(usr, "Which attachment to activate?", null, usable_attachments)

	if(!usable_attachment)
		return
	usable_attachment.ui_action_click(usr, null, src)


/mob/living/carbon/human/verb/toggle_rail_attachment()
	set category = "Weapons"
	set name = "Toggle Rail Attachment"
	set desc = "Uses the rail attachement currently attached to the gun."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_rail_attachment()

/obj/item/weapon/gun/verb/toggle_rail_attachment()
	set category = null
	set name = "Toggle Rail Attachment (Weapon)"
	set desc = "Uses the rail attachement currently attached to the gun."

	if(activate_attachment(ATTACHMENT_SLOT_RAIL, usr))
		return
	balloon_alert(usr, "No usable rail attachments")

/obj/item/weapon/gun/verb/toggle_underrail_attachment()
	set category = null
	set name = "Toggle Underrail Attachment (Weapon)"
	set desc = "Uses the underrail attachement currently attached to the gun."

	if(activate_attachment(ATTACHMENT_SLOT_UNDER, usr))
		return
	balloon_alert(usr, "No usable underrail attachments")

///Toggles weapons ejecting their magazines when they're empty. This one is one a gun level and is used via right clicking the gun.
/obj/item/weapon/gun/verb/toggle_auto_eject()
	set category = null
	set name = "Toggle Automatic Magazine Ejection (Weapon)"
	set desc = "Toggles the automatic unloading of the gun's magazine upon depletion."

	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_AUTO_EJECT_LOCKED))
		balloon_alert(usr, "Cannot toggle ejection")
		return

	TOGGLE_BITFIELD(reciever_flags, AMMO_RECIEVER_AUTO_EJECT)
	balloon_alert(usr, "Automatic unloading [CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_AUTO_EJECT) ? "enabled" : "disabled"].")

/obj/item/weapon/gun/item_action_slot_check(mob/user, slot)
	if(slot != SLOT_L_HAND && slot != SLOT_R_HAND && !CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		return FALSE
	return TRUE


/obj/item/weapon/gun/proc/modify_fire_delay(value, mob/user)
	fire_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)

/obj/item/weapon/gun/proc/modify_burst_delay(value, mob/user)
	burst_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, burst_delay)

/obj/item/weapon/gun/proc/modify_auto_burst_delay(value, mob/user)
	autoburst_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_AUTO_BURST_SHOT_DELAY_MODIFIED, autoburst_delay)

/obj/item/weapon/gun/proc/modify_burst_amount(value, mob/user)
	burst_amount += value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)

	if(burst_amount < 2)
		if(GUN_FIREMODE_BURSTFIRE in gun_firemode_list)
			remove_firemode(GUN_FIREMODE_BURSTFIRE, user)
		if(GUN_FIREMODE_AUTOBURST in gun_firemode_list)
			remove_firemode(GUN_FIREMODE_AUTOBURST, user)
	else
		if(!(GUN_FIREMODE_BURSTFIRE in gun_firemode_list))
			add_firemode(GUN_FIREMODE_BURSTFIRE, user)
		if((GUN_FIREMODE_AUTOMATIC in gun_firemode_list) && !(GUN_FIREMODE_AUTOBURST in gun_firemode_list))
			add_firemode(GUN_FIREMODE_AUTOBURST, user)

///Calculates aim_fire_delay, can't be below 0
/obj/item/weapon/gun/proc/recalculate_aim_mode_fire_delay()
	var/modification_value = 0
	for(var/key in aim_fire_delay_mods)
		modification_value += aim_fire_delay_mods[key]
	var/old_delay = aim_fire_delay
	aim_fire_delay = max(initial(aim_fire_delay) + modification_value, 0)
	if(HAS_TRAIT(src, TRAIT_GUN_IS_AIMING))
		modify_fire_delay(aim_fire_delay - old_delay)
		modify_auto_burst_delay(aim_fire_delay - old_delay)

///Adds an aim_fire_delay modificatio value
/obj/item/weapon/gun/proc/add_aim_mode_fire_delay(source, value)
	aim_fire_delay_mods[source] = value
	recalculate_aim_mode_fire_delay()

///Removes an aim_fire_delay modificatio value
/obj/item/weapon/gun/proc/remove_aim_mode_fire_delay(source)
	if(!(source in aim_fire_delay_mods))
		return
	aim_fire_delay_mods -= source
	recalculate_aim_mode_fire_delay()

/obj/item/weapon/gun/proc/toggle_auto_aim_mode(mob/living/carbon/human/user) //determines whether toggle_aim_mode activates at the end of gun/wield proc

	if((flags_item & FULLY_WIELDED) || (flags_item & IS_DEPLOYED)) //if gun is wielded it toggles aim mode directly instead
		toggle_aim_mode(user)
		return

	if(!HAS_TRAIT(src, TRAIT_GUN_AUTO_AIM_MODE))
		to_chat(user, span_notice("You will immediately aim upon wielding your weapon.</b>"))
		ADD_TRAIT(src, TRAIT_GUN_AUTO_AIM_MODE, GUN_TRAIT)
	else
		to_chat(user, span_notice("You will wield your weapon without aiming with precision.</b>"))
		REMOVE_TRAIT(src, TRAIT_GUN_AUTO_AIM_MODE, GUN_TRAIT)

/obj/item/weapon/gun/proc/toggle_aim_mode(mob/living/carbon/human/user)
	var/static/image/aim_mode_visual = image('icons/mob/hud.dmi', null, "aim_mode")

	if(HAS_TRAIT(src, TRAIT_GUN_IS_AIMING))
		user.overlays -= aim_mode_visual
		REMOVE_TRAIT(src, TRAIT_GUN_IS_AIMING, GUN_TRAIT)
		user.remove_movespeed_modifier(MOVESPEED_ID_AIM_MODE_SLOWDOWN)
		modify_fire_delay(-aim_fire_delay)
		modify_auto_burst_delay(-aim_fire_delay)
		///if your attached weapon has aim mode, stops it from aimming
		if( (gunattachment) && (/datum/action/item_action/aim_mode in gunattachment.actions_types) )
			REMOVE_TRAIT(gunattachment, TRAIT_GUN_IS_AIMING, GUN_TRAIT)
			gunattachment.modify_fire_delay(-aim_fire_delay)
			gunattachment.modify_auto_burst_delay(-aim_fire_delay)
		to_chat(user, span_notice("You cease aiming."))
		return
	if(!(flags_item & WIELDED) && !(flags_item & IS_DEPLOYED))
		to_chat(user, span_notice("You need to wield your gun before aiming."))
		return
	if(!user.wear_id)
		to_chat(user, span_notice("You don't have distinguished allies you want to avoid shooting.</b>"))
		return
	to_chat(user, span_notice("You steady your breathing..."))

	if(user.do_actions)
		return
	if(!user.marksman_aura)
		if(!do_after(user, aim_time, (flags_item & IS_DEPLOYED) ? NONE : IGNORE_USER_LOC_CHANGE, (flags_item & IS_DEPLOYED) ? loc : src, BUSY_ICON_BAR))
			to_chat(user, span_warning("<b>Your concentration is interrupted!</b>"))
			return
	if(!(flags_item & WIELDED) && !(flags_item & IS_DEPLOYED))
		to_chat(user, span_notice("You need to wield your gun before aiming."))
		return
	user.overlays += aim_mode_visual
	ADD_TRAIT(src, TRAIT_GUN_IS_AIMING, GUN_TRAIT)
	user.add_movespeed_modifier(MOVESPEED_ID_AIM_MODE_SLOWDOWN, TRUE, 0, NONE, TRUE, aim_speed_modifier)
	modify_fire_delay(aim_fire_delay)
	modify_auto_burst_delay(aim_fire_delay)
	///if your attached weapon has aim mode, makes it aim
	if( (gunattachment) && (/datum/action/item_action/aim_mode in gunattachment.actions_types) )
		ADD_TRAIT(gunattachment, TRAIT_GUN_IS_AIMING, GUN_TRAIT)
		gunattachment.modify_fire_delay(aim_fire_delay)
		gunattachment.modify_auto_burst_delay(aim_fire_delay)
	to_chat(user, span_notice("You line up your aim, allowing you to shoot past allies.</b>"))

/// Signal handler to activate the rail attachement of that gun if it's in our active hand
/obj/item/weapon/gun/proc/activate_rail_attachment()
	SIGNAL_HANDLER
	if(gun_user?.get_active_held_item() != src && !(flags_item & IS_DEPLOYED))
		return
	activate_attachment(ATTACHMENT_SLOT_RAIL, gun_user)
	return COMSIG_KB_ACTIVATED

/// Signal handler to activate the underrail attachement of that gun if it's in our active hand
/obj/item/weapon/gun/proc/activate_underrail_attachment()
	SIGNAL_HANDLER
	if(gun_user?.get_active_held_item() != src && !(flags_item & IS_DEPLOYED))
		return
	activate_attachment(ATTACHMENT_SLOT_UNDER, gun_user)
	return COMSIG_KB_ACTIVATED

/// Signal handler to unload that gun if it's in our active hand
/obj/item/weapon/gun/proc/unload_gun()
	SIGNAL_HANDLER
	unload(gun_user)
	return COMSIG_KB_ACTIVATED

/// Signal handler to toggle the safety of the gun
/obj/item/weapon/gun/proc/toggle_gun_safety_keybind()
	SIGNAL_HANDLER
	toggle_gun_safety()
	return COMSIG_KB_ACTIVATED

/// Signal handler to toggle automatic magazine ejection
/obj/item/weapon/gun/proc/toggle_auto_eject_keybind()
	SIGNAL_HANDLER
	toggle_auto_eject()
	return COMSIG_KB_ACTIVATED

/obj/item/weapon/gun/toggle_deployment_flag(deployed)
	. = ..()
	setup_bullet_accuracy()
