
//-------------------------------------------------------
//ENERGY GUNS/ETC

/obj/item/weapon/gun/energy
	attachable_allowed = list()
	var/obj/item/cell/cell //1000 power.
	charge_cost = 10 //100 shots.
	var/cell_type = /obj/item/cell
	flags_gun_features = GUN_AMMO_COUNTER
	general_codex_key = "energy weapons"

/obj/item/weapon/gun/energy/examine_ammo_count(mob/user)
	var/list/dat = list()
	if(!(flags_gun_features & (GUN_INTERNAL_MAG|GUN_UNUSUAL_DESIGN))) //Internal mags and unusual guns have their own stuff set.
		var/current_shots = get_ammo_count()
		if(cell && current_shots > 0)
			if(flags_gun_features & GUN_AMMO_COUNTER)

				dat += "Ammo counter shows [current_shots] round\s remaining.<br>"
			else
				dat += "It's loaded[in_chamber?" and has a round chambered":""].<br>"
		else
			dat += "It's unloaded[in_chamber?" but has a round chambered":""].<br>"
	if(dat)
		to_chat(user, "[dat.Join(" ")]")

/obj/item/weapon/gun/energy/Initialize()
	. = ..()
	if(cell_type)
		cell = new cell_type(src)

/obj/item/weapon/gun/energy/able_to_fire(mob/living/user)
	. = ..()
	if(!cell || cell.charge - charge_cost < 0)
		return

/obj/item/weapon/gun/energy/load_into_chamber()
	if(!cell || cell.charge - charge_cost < 0)
		return

	cell.charge -= charge_cost
	in_chamber = create_bullet(ammo)
	return in_chamber

/obj/item/weapon/gun/energy/update_icon()
	return

/obj/item/weapon/gun/energy/reload_into_chamber()
	update_icon()
	return TRUE

/obj/item/weapon/gun/energy/delete_bullet(obj/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund)
		cell.charge = min(cell.charge + charge_cost, cell.maxcharge) //Safeguard against 'overcharging' the cell.
	return TRUE

/obj/item/weapon/gun/energy/emp_act(severity)
	cell.use(round(cell.maxcharge / severity))
	update_icon()
	return ..()

/obj/item/weapon/gun/energy/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/energy/get_ammo_count()
	if(!cell)
		return 0
	else
		return FLOOR(cell.charge / max(charge_cost, 1),1)

// energy guns, however, do not use gun rattles.
/obj/item/weapon/gun/energy/play_fire_sound(mob/user)
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		if(active_attachable.fire_sound) //If we're firing from an attachment, use that noise instead.
			playsound(user, active_attachable.fire_sound, 50)
		return
	if(flags_gun_features & GUN_SILENCED)
		playsound(user, fire_sound, 25)
		return
	playsound(user, fire_sound, 60)


/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	item_state = "taser"
	muzzle_flash = null //TO DO.
	fire_sound = 'sound/weapons/guns/fire/taser.ogg'
	ammo = /datum/ammo/energy/taser
	charge_cost = 500
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER|GUN_ALLOW_SYNTHETIC
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 0
	cell_type = /obj/item/cell/high

	fire_delay = 10
	accuracy_mult = 1.15
	scatter = 10
	scatter_unwielded = 15


/obj/item/weapon/gun/energy/taser/update_icon()
	if(!cell || cell.charge - charge_cost < 0)
		icon_state = base_gun_icon + "_e"
	else
		icon_state = base_gun_icon

/obj/item/weapon/gun/energy/taser/able_to_fire(mob/living/user)
	. = ..()
	if (.) //Let's check all that other stuff first.
		if(user.skills.getRating("police") < SKILL_POLICE_MP)
			to_chat(user, span_warning("You don't seem to know how to use [src]..."))
			return FALSE


//-------------------------------------------------------
//Lasguns

/obj/item/weapon/gun/energy/lasgun
	name = "\improper Lasgun"
	desc = "A laser based firearm. Uses power cells."
	reload_sound = 'sound/weapons/guns/interact/rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/laser.ogg'
	load_method = CELL //codex
	ammo = /datum/ammo/energy/lasgun
	flags_equip_slot = ITEM_SLOT_BACK
	muzzleflash_iconstate = "muzzle_flash_laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	overcharge = FALSE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER
	aim_slowdown = 0.75
	wield_delay = 1 SECONDS
	gun_skill_category = GUN_SKILL_RIFLES
	muzzle_flash_color = COLOR_LASER_RED

	fire_delay = 3
	accuracy_mult = 1.5
	accuracy_mult_unwielded = 0.6
	scatter_unwielded = 80 //Heavy and unwieldy
	damage_falloff_mult = 0.5
	upper_akimbo_accuracy = 5
	lower_akimbo_accuracy = 3

/obj/item/weapon/gun/energy/lasgun/unique_action(mob/user)
	. = ..()
	if(!.)
		return
	return cock(user)

/obj/item/weapon/gun/energy/lasgun/tesla
	name = "\improper M43-T tesla shock rifle"
	desc = "A prototype TGMC energy rifle that fires balls of elecricity that shock all those near them, it is meant to drain the plasma of unidentified creatures from within, limiting their abilities. Handle only with insulated clothing. Reloaded with power cells."
	icon_state = "m43"
	item_state = "m43"
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	ammo = /datum/ammo/energy/tesla
	cell_type = /obj/item/cell/lasgun/tesla
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_ENERGY|GUN_AMMO_COUNTER
	muzzle_flash_color = COLOR_TESLA_BLUE

	charge_cost = 500
	fire_delay = 4 SECONDS

//-------------------------------------------------------
//M43 Sunfury Lasgun MK1

/obj/item/weapon/gun/energy/lasgun/M43
	name = "\improper M43 Sunfury Lasgun MK1"
	desc = "An accurate, recoilless laser based battle rifle with an integrated charge selector. Ideal for longer range engagements. It was the standard lasrifle for TGMC soldiers until it was replaced by the TX-73, due to its extremely modular lens system."
	force = 20 //Large and hefty! Includes stock bonus.
	icon_state = "m43"
	item_state = "m43"
	max_shots = 50 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/M43
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/M43
	charge_cost = ENERGY_STANDARD_AMMO_COST
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/scope,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/shotgun,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/focuslens,
		/obj/item/attachable/widelens,
		/obj/item/attachable/heatlens,
		/obj/item/attachable/efflens,
		/obj/item/attachable/pulselens,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade, /obj/item/attachable/stock/lasgun)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

	accuracy_mult_unwielded = 0.5 //Heavy and unwieldy; you don't one hand this.
	scatter_unwielded = 100 //Heavy and unwieldy; you don't one hand this.
	damage_falloff_mult = 0.25
	fire_delay = 3

//variant without ugl attachment
/obj/item/weapon/gun/energy/lasgun/M43/stripped
	starting_attachment_types = list()

/obj/item/weapon/gun/energy/lasgun/Initialize(mapload, ...)
	. = ..()
	update_icon()


//Toggles Overcharge mode. Overcharge mode significantly increases damage and AP in exchange for doubled ammo usage and increased fire delay.
/obj/item/weapon/gun/energy/lasgun/cock(mob/user)
	//if(in_chamber)
	//	delete_bullet(in_chamber, TRUE)
	if(ammo_diff == null)
		to_chat(user, "[icon2html(src, user)] You need an appropriate lens to enable overcharge mode.")
		return
	if(overcharge == FALSE)
		if(!cell)
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 0, 2)
			to_chat(user, span_warning("You attempt to toggle on [src]'s overcharge mode but you have no battery loaded."))
			return
		if(cell.charge < ENERGY_OVERCHARGE_AMMO_COST)
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 0, 2)
			to_chat(user, span_warning("You attempt to toggle on [src]'s overcharge mode but your battery pack lacks adequate charge to do so."))
			return
		//While overcharge is active, double ammo consumption, and
		playsound(user, 'sound/weapons/emitter.ogg', 5, 0, 2)
		charge_cost = ENERGY_OVERCHARGE_AMMO_COST
		ammo = GLOB.ammo_list[ammo_diff]
		fire_delay += 7 // 1 shot per second fire rate
		fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
		to_chat(user, "[icon2html(src, user)] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = TRUE
	else
		playsound(user, 'sound/weapons/emitter2.ogg', 5, 0, 2)
		charge_cost = ENERGY_STANDARD_AMMO_COST
		ammo = GLOB.ammo_list[/datum/ammo/energy/lasgun/M43]
		fire_delay -= 7
		fire_sound = 'sound/weapons/guns/fire/laser.ogg'
		to_chat(user, "[icon2html(src, user)] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = FALSE

	//load_into_chamber()

	if(user)
		var/obj/screen/ammo/A = user.hud_used.ammo //The ammo HUD
		A.update_hud(user)

	return TRUE

/obj/item/weapon/gun/energy/lasgun/load_into_chamber(mob/user)
		//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			return create_bullet(active_attachable.ammo)
		else
			to_chat(user, span_warning("[active_attachable] is empty!"))
			to_chat(user, span_notice("You disable [active_attachable]."))
			playsound(user, active_attachable.activation_sound, 15, 1)
			active_attachable.activate_attachment(null, TRUE)

	if(!cell?.use(charge_cost))
		return
	in_chamber = create_bullet(ammo)
	update_icon(user)
	return in_chamber

/obj/item/weapon/gun/energy/lasgun/reload_into_chamber(mob/user)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		make_casing(active_attachable.type_of_casings) // Attachables can drop their own casings.

	if(!active_attachable && cell) //We don't need to check for the mag if an attachment was used to shoot.
		if(cell) //If there is no mag, we can't reload.
			if(overcharge && cell.charge < ENERGY_OVERCHARGE_AMMO_COST && cell.charge >= ENERGY_STANDARD_AMMO_COST) //Revert to standard shot if we don't have enough juice for overcharge, but enough for the standard mode
				cock(user)
				return
			if(cell.charge <= 0 && flags_gun_features & GUN_AUTO_EJECTOR) // This is where the magazine is auto-ejected.
				unload(user,1,1) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
				playsound(src, empty_sound, 25, 1)

	return TRUE


//Ammo/Charge functions
/obj/item/weapon/gun/energy/lasgun/update_icon(mob/user)
	var/cell_charge = (!cell || cell.charge <= 0) ? 0 : CEILING((cell.charge / max(cell.maxcharge, 1)) * 100, 25)
	icon_state = "[base_gun_icon]_[cell_charge]"
	update_mag_overlay(user)
	update_item_state(user)


/obj/item/weapon/gun/energy/lasgun/update_item_state(mob/user)
	. = item_state
	var/cell_charge = (!cell || cell.charge <= 0) ? 0 : CEILING((cell.charge / max(cell.maxcharge, 1)) * 100, 25)
	item_state = "[initial(icon_state)]_[cell_charge][flags_item & WIELDED ? "_w" : ""]"
	if(. != item_state && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(src == human_user.l_hand)
			human_user.update_inv_l_hand()
		else if (src == human_user.r_hand)
			human_user.update_inv_r_hand()


/obj/item/weapon/gun/energy/lasgun/reload(mob/user, obj/item/cell/lasgun/new_cell)
	if(flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG))
		return

	if(!new_cell || !istype(new_cell))
		to_chat(user, span_warning("That's not a power cell!"))
		return

	if(new_cell.charge <= 0)
		to_chat(user, span_warning("[cell] is depleted!"))
		return

	if(!istype(src, new_cell.gun_type))
		to_chat(user, span_warning("That power cell doesn't fit in there!"))
		return

	if(cell)
		to_chat(user, span_warning("It's still got something loaded."))
		return

	if(user)
		if(new_cell.reload_delay > 1)
			to_chat(user, span_notice("You begin reloading [src]. Hold still..."))
			if(do_after(user,new_cell.reload_delay, TRUE, src, BUSY_ICON_GENERIC))
				replace_magazine(user, new_cell)
			else
				to_chat(user, span_warning("Your reload was interrupted!"))
				return
		else
			replace_magazine(user, new_cell)
	else
		replace_magazine(null, new_cell)
	return TRUE

/obj/item/weapon/gun/energy/lasgun/replace_magazine(mob/user, obj/item/cell/lasgun/new_cell)
	cell = new_cell
	if(user)
		user.transferItemToLoc(new_cell, src) //Click!
		user.visible_message(span_notice("[user] loads [new_cell] into [src]!"),
		span_notice("You load [new_cell] into [src]!"), null, 3)
		if(reload_sound)
			playsound(user, reload_sound, 25, 1, 5)
		update_icon(user)
	else
		cell.loc = src
		update_icon()

//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
//This can be passed with a null user, so we need to check for that as well.
/obj/item/weapon/gun/energy/lasgun/unload(mob/user, reload_override = 0, drop_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst. Drop is for dropping the magazine on the ground.
	if(!reload_override && (flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG)))
		return FALSE

	if(!cell || cell.loc != src)
		return FALSE

	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		cell.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(cell)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message(span_notice("[user] unloads [cell] from [src]."),
	span_notice("You unload [cell] from [src]."), null, 4)
	cell.update_icon()
	cell = null

	update_icon(user)

	return TRUE

//-------------------------------------------------------
//Deathsquad-only gun -- Model 2419 pulse rifle, the M19C4.

/obj/item/weapon/gun/energy/lasgun/pulse
	name = "\improper M19C4 pulse energy rifle"
	desc = "A heavy-duty, multifaceted energy weapon that uses pulse-based beam generation technology to emit powerful laser blasts. Because of its complexity and cost, it is rarely seen in use except by specialists and front-line combat personnel. This is a testing model issued only for Asset Protection units and offshore elite Nanotrasen squads."
	force = 23 //Slightly more heftier than the M43, but without the stock.
	icon_state = "m19c4"
	item_state = "m19c4"
	fire_sound = 'sound/weapons/guns/fire/pulseenergy.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	max_shots = 100//codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/pulsebolt
	muzzleflash_iconstate = "muzzle_flash_pulse"
	cell_type = /obj/item/cell/lasgun/pulse
	charge_cost = ENERGY_STANDARD_AMMO_COST
	muzzle_flash_color = COLOR_PULSE_BLUE

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

	fire_delay = 8
	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.95
	scatter_unwielded = 25

//-------------------------------------------------------
//A practice version of M43, only for the marine hq map.

/obj/item/weapon/gun/energy/lasgun/M43/practice
	name = "\improper M43-P Sunfury Lasgun MK1"
	desc = "An accurate, recoilless laser based battle rifle, based on the outdated M43 design. Only accepts practice power cells and it doesn't have a charge selector. Uses power cells instead of ballistic magazines."
	force = 8 //Well, it's not complicted compared to the original.
	ammo = /datum/ammo/energy/lasgun/M43/practice
	cell_type = /obj/item/cell/lasgun/M43/practice
	attachable_allowed = list()
	starting_attachment_types = list(/obj/item/attachable/stock/lasgun/practice)
	muzzle_flash_color = COLOR_DISABLER_BLUE

	damage_falloff_mult = 1
	fire_delay = 0.33 SECONDS
	aim_slowdown = 0.35

/obj/item/weapon/gun/energy/lasgun/M43/practice/cock(mob/user)
	return

/obj/item/weapon/gun/energy/lasgun/lasrifle
	name = "\improper TX-73 lasrifle MK2"
	desc = "A multifunctional laser based rifle with an integrated mode selector. Ideal for any situation. Uses power cells instead of ballistic magazines."
	force = 20 //Large and hefty! Includes stock bonus.
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "tx73"
	item_state = "tx73"
	max_shots = 50 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/M43
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/lasrifle
	charge_cost = 10
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)//Lasrifle has special behavior for fire mode, be carefull
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/shotgun,
		/obj/item/attachable/scope/mini,
	)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 14,"rail_x" = 18, "rail_y" = 18, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	accuracy_mult_unwielded = 0.5 //Heavy and unwieldy; you don't one hand this.
	scatter_unwielded = 100 //Heavy and unwieldy; you don't one hand this.
	damage_falloff_mult = 0.25
	fire_delay = 2
	var/list/datum/lasrifle/base/mode_list = list(
	)

/datum/lasrifle/base
	///how much power the gun uses on this mode when shot.
	var/charge_cost = 0
	///the ammo datum this mode is.
	var/datum/ammo/ammo = null
	///how long it takes between each shot of that mode, same as gun fire delay.
	var/fire_delay = 0
	///Gives guns a burst amount, editable.
	var/burst_amount = 0
	///gives firemode selections for guns.
	var/gun_firemode_list
	///The gun firing sound of this mode.
	var/fire_sound = null
	///What message it sends to the user when you switch to this mode.
	var/message_to_user = ""
	///Used to change the gun firemode, like automatic, semi-automatic and burst.
	var/fire_mode = GUN_FIREMODE_SEMIAUTO
	///what to change the gun icon_state to when switching to this mode.
	var/icon_state = "tx73"
	///Which icon file the radial menu will use.
	var/radial_icon = 'icons/mob/radial.dmi'
	///The icon state the radial menu will use.
	var/radial_icon_state = "laser"

/obj/item/weapon/gun/energy/lasgun/lasrifle/cock(mob/user)
	if(!user)
		CRASH("switch_modes called with no user.")

	var/list/available_modes = list()
	for(var/mode in mode_list)
		available_modes += list("[mode]" = image(icon = initial(mode_list[mode].radial_icon), icon_state = initial(mode_list[mode].radial_icon_state)))

	var/datum/lasrifle/base/choice = mode_list[show_radial_menu(user, user, available_modes, null, 64, tooltips = TRUE)]
	if(!choice)
		return


	playsound(user, 'sound/weapons/emitter.ogg', 5, FALSE, 2)


	gun_firemode = initial(choice.fire_mode)


	charge_cost = initial(choice.charge_cost)
	ammo = GLOB.ammo_list[initial(choice.ammo)]
	fire_delay = initial(choice.fire_delay)
	burst_amount = initial(choice.burst_amount)
	fire_sound = initial(choice.fire_sound)
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)
	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, initial(choice.fire_mode), user.client)

	base_gun_icon = initial(choice.icon_state)
	update_icon()

	to_chat(user, initial(choice.message_to_user))

	var/obj/screen/ammo/A = user.hud_used.ammo //The ammo HUD
	A.update_hud(user)

/obj/item/weapon/gun/energy/lasgun/lasrifle/update_item_state(mob/user) //Without this override icon states for wielded guns won't show. because lasgun overrides and this has no charge icons
	item_state = "[initial(icon_state)][flags_item & WIELDED ? "_w" : ""]"


//TE Tier 1 Series//

//TE Standard Laser rifle

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle
	name = "\improper Terra Experimental laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. It has an integrated charge selector for normal and high settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	force = 20
	icon_state = "ter"
	item_state = "ter"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 50 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/lasrifle/marine
	charge_cost = 12
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 21, "under_x" = 29, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.4
	wield_delay = 0.5 SECONDS
	scatter = 0
	scatter_unwielded = 10
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.55
	scatter_unwielded = 10
	damage_falloff_mult = 0.2
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_rifle_mode/standard,
		"Overcharge" = /datum/lasrifle/base/energy_rifle_mode/overcharge,
	)

/datum/lasrifle/base/energy_rifle_mode/standard
	charge_cost = 12
	ammo = /datum/ammo/energy/lasgun/marine
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the laser rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "ter"

/datum/lasrifle/base/energy_rifle_mode/overcharge
	charge_cost = 30
	ammo = /datum/ammo/energy/lasgun/marine/overcharge
	fire_delay = 0.45 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser overcharge standard.ogg'
	message_to_user = "You set the laser rifle's charge mode to overcharge."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "ter"
	radial_icon_state = "laser_overcharge"

///TE Standard Laser Pistol

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol
	name = "\improper Terra Experimental laser pistol"
	desc = "A TerraGov standard issue laser pistol abbreviated as TE-P. It has an integrated charge selector for normal, heat and taser settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_pistol_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Pistol Standard.ogg'
	force = 20
	icon_state = "tep"
	item_state = "tep"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	flags_equip_slot = ITEM_SLOT_BELT
	max_shots = 30 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/lasrifle/marine
	charge_cost = 20
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 23, "muzzle_y" = 22,"rail_x" = 12, "rail_y" = 22, "under_x" = 16, "under_y" = 14, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.2
	wield_delay = 0.6 SECONDS
	scatter = 0
	scatter_unwielded = 0
	fire_delay = 0.25 SECONDS
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.9
	scatter_unwielded = 0
	damage_falloff_mult = 0.2
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_pistol_mode/standard,
		"Heat" = /datum/lasrifle/base/energy_pistol_mode/heat,
		"Disabler" = /datum/lasrifle/base/energy_pistol_mode/disabler,
	)

/datum/lasrifle/base/energy_pistol_mode/standard
	charge_cost = 20
	ammo = /datum/ammo/energy/lasgun/marine/pistol
	fire_delay = 0.25 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Pistol Standard.ogg'
	message_to_user = "You set the laser pistol's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tep"

/datum/lasrifle/base/energy_pistol_mode/disabler
	charge_cost = 80
	ammo = /datum/ammo/energy/lasgun/marine/pistol/disabler
	fire_delay = 10
	fire_sound = 'sound/weapons/guns/fire/disabler.ogg'
	message_to_user = "You set the laser pistol's charge mode to disabler fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tep"
	radial_icon_state = "laser_disabler"

/datum/lasrifle/base/energy_pistol_mode/heat
	charge_cost = 110
	ammo = /datum/ammo/energy/lasgun/marine/pistol/heat
	fire_delay = 0.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the laser pistol's charge mode to wave heat."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tep"
	radial_icon_state = "laser_heat"

//TE Standard Laser Carbine

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine
	name = "\improper Terra Experimental laser carbine"
	desc = "A TerraGov standard issue laser carbine, otherwise known as TE-C for short. It has an integrated charge selector for burst and scatter settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	force = 20
	icon_state = "tec"
	item_state = "tec"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 40 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/lasrifle/marine
	charge_cost = 15
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 17, "rail_y" = 21, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.2
	wield_delay = 0.3 SECONDS
	scatter = 0
	scatter_unwielded = 15
	fire_delay = 0.2 SECONDS
	burst_amount = 1
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.65
	scatter_unwielded = 15
	damage_falloff_mult = 0.5
	mode_list = list(

		"Auto burst standard" = /datum/lasrifle/base/energy_carbine_mode/auto_burst_standard,
		"Automatic standard" = /datum/lasrifle/base/energy_carbine_mode/auto_burst_standard/automatic,
		"Spread" = /datum/lasrifle/base/energy_carbine_mode/base/spread,
	)

/datum/lasrifle/base/energy_carbine_mode/auto_burst_standard ///I know this seems tacky, but if I make auto burst a standard firemode it somehow buffs spread's fire delay.
	charge_cost = 15
	ammo = /datum/ammo/energy/lasgun/marine
	fire_delay = 0.2 SECONDS
	burst_amount = 4
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the laser carbine's charge mode to standard auto burst fire."
	fire_mode = GUN_FIREMODE_AUTOBURST
	icon_state = "tec"

/datum/lasrifle/base/energy_carbine_mode/auto_burst_standard/automatic
	message_to_user = "You set the laser carbine's charge mode to standard automatic fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC

/datum/lasrifle/base/energy_carbine_mode/base/spread
	charge_cost = 60
	ammo = /datum/ammo/energy/lasgun/marine/blast
	fire_delay = 1.5 SECONDS
	burst_amount = 1
	fire_sound = 'sound/weapons/guns/fire/Laser Carbine Scatter.ogg'
	message_to_user = "You set the laser carbine's charge mode to spread."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tec"
	radial_icon_state = "laser_spread"

//TE Standard Sniper

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper
	name = "\improper Terra Experimental laser sniper rifle"
	desc = "The T-ES, a Terra Experimental standard issue laser sniper rifle, it has an integrated charge selector for normal and heat settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_sniper_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	force = 20
	icon_state = "tes"
	item_state = "tes"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 12 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine/sniper
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/lasrifle/marine
	charge_cost = 50
	damage_falloff_mult = 0
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/unremovable/laser_sniper_scope,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 18,"rail_x" = 19, "rail_y" = 19, "under_x" = 28, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/laser_sniper_scope)
	aim_fire_delay = 0.5 SECONDS
	aim_speed_modifier = 2

	actions_types = list(/datum/action/item_action/aim_mode)
	aim_slowdown = 0.7
	wield_delay = 0.7 SECONDS
	scatter = 0
	scatter_unwielded = 10
	fire_delay = 1 SECONDS
	accuracy_mult = 1.35
	accuracy_mult_unwielded = 0.5
	scatter_unwielded = 10
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_sniper_mode/standard,
		"Heat" = /datum/lasrifle/base/energy_sniper_mode/heat,
	)

/datum/lasrifle/base/energy_sniper_mode/standard
	charge_cost = 50
	fire_delay = 1 SECONDS
	ammo = /datum/ammo/energy/lasgun/marine/sniper
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the sniper rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tes"

/datum/lasrifle/base/energy_sniper_mode/heat
	charge_cost = 150
	fire_delay = 1 SECONDS
	ammo = /datum/ammo/energy/lasgun/marine/sniper_heat
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the sniper rifle's charge mode to wave heat."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tes"
	radial_icon_state = "laser_heat"

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser
	name = "\improper Terra Experimental laser machine gun"
	desc = "A Terra Experimental standard issue machine laser gun, often called as the TE-M by marines. It has a fire switch for normal and efficiency modes. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_machine_laser_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	force = 20
	icon_state = "tem"
	item_state = "tem"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 150 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine/autolaser
	ammo_diff = null
	cell_type = /obj/item/cell/lasgun/lasrifle/marine
	charge_cost = 4
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/attached_gun/grenade,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 15,"rail_x" = 22, "rail_y" = 24, "under_x" = 30, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 1
	wield_delay = 1.5 SECONDS
	scatter = 0
	fire_delay = 0.2 SECONDS
	accuracy_mult = 0.95
	accuracy_mult_unwielded = 0.3
	scatter_unwielded = 80
	damage_falloff_mult = 0.3
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_mg_mode/standard,
		"Efficiency mode" = /datum/lasrifle/base/energy_mg_mode/standard/efficiency,
	)

/datum/lasrifle/base/energy_mg_mode/standard
	charge_cost = 4
	ammo = /datum/ammo/energy/lasgun/marine/autolaser
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the machine laser's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tem"

/datum/lasrifle/base/energy_mg_mode/standard/efficiency
	ammo = /datum/ammo/energy/lasgun/marine/autolaser/efficiency
	fire_delay = 0.15 SECONDS
	charge_cost = 3
	message_to_user = "You set the machine laser's charge mode to efficiency mode."
