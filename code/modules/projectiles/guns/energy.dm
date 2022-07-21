
//-------------------------------------------------------
//ENERGY GUNS/ETC

/obj/item/weapon/gun/energy
	attachable_allowed = list()
	rounds_per_shot = 10 //100 shots.
	flags_gun_features = GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	general_codex_key = "energy weapons"

	placed_overlay_iconstate = "laser"
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	default_ammo_type = /obj/item/cell/lasgun
	allowed_ammo_types = list(/obj/item/cell/lasgun)
	muzzle_flash = null

/obj/item/weapon/gun/energy/get_current_rounds(obj/item/mag)
	var/obj/item/cell/lasgun/cell = mag
	return cell?.charge

/obj/item/weapon/gun/energy/adjust_current_rounds(obj/item/mag, new_rounds)
	var/obj/item/cell/lasgun/cell = mag
	cell?.charge += new_rounds

/obj/item/weapon/gun/energy/get_max_rounds(obj/item/mag)
	var/obj/item/cell/lasgun/cell = mag
	return cell?.maxcharge

/obj/item/weapon/gun/energy/get_magazine_default_ammo(obj/item/mag)
	return null

/obj/item/weapon/gun/energy/get_flags_magazine_features(obj/item/mag)
	var/obj/item/cell/lasgun/cell = mag
	return cell ? cell.flags_magazine_features : NONE
//based off of basegun proc, should work.
/obj/item/weapon/gun/energy/get_magazine_overlay(obj/item/mag)
	var/obj/item/cell/lasgun/cell = mag
	return cell?.bonus_overlay
//based off of basegun proc, should work.
/obj/item/weapon/gun/energy/get_magazine_reload_delay(obj/item/mag)
	var/obj/item/cell/lasgun/cell = mag
	return cell?.reload_delay

/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	item_state = "taser"
	muzzle_flash = null //TO DO.
	fire_sound = 'sound/weapons/guns/fire/taser.ogg'
	ammo_datum_type  = /datum/ammo/energy/taser
	default_ammo_type = /obj/item/cell/lasgun/lasrifle
	allowed_ammo_types = list(/obj/item/cell/lasgun/lasrifle)
	rounds_per_shot = 500
	flags_gun_features = GUN_AMMO_COUNTER|GUN_ALLOW_SYNTHETIC|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 0


	fire_delay = 10
	accuracy_mult = 1.15
	scatter = 2
	scatter_unwielded = 1

/obj/item/weapon/gun/energy/taser/able_to_fire(mob/living/user)
	. = ..()
	if (!.)
		return
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
	ammo_datum_type  = /datum/ammo/energy/lasgun
	flags_equip_slot = ITEM_SLOT_BACK
	muzzleflash_iconstate = "muzzle_flash_laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	overcharge = FALSE
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_SHOWS_AMMO_REMAINING
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	aim_slowdown = 0.75
	wield_delay = 1 SECONDS
	gun_skill_category = GUN_SKILL_RIFLES
	muzzle_flash_color = COLOR_LASER_RED

	fire_delay = 3
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.6
	scatter_unwielded = 80 //Heavy and unwieldy
	damage_falloff_mult = 0.5
	upper_akimbo_accuracy = 5
	lower_akimbo_accuracy = 3

/obj/item/weapon/gun/energy/lasgun/unique_action(mob/user, dont_operate = FALSE)
	QDEL_NULL(in_chamber)
	if(ammo_diff == null)
		to_chat(user, "[icon2html(src, user)] You need an appropriate lens to enable overcharge mode.")
		return
	if(overcharge == FALSE)
		if(!length(chamber_items))
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 0, 2)
			to_chat(user, span_warning("You attempt to toggle on [src]'s overcharge mode but you have no battery loaded."))
			return
		if(rounds < ENERGY_OVERCHARGE_AMMO_COST)
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 0, 2)
			to_chat(user, span_warning("You attempt to toggle on [src]'s overcharge mode but your battery pack lacks adequate charge to do so."))
			return
		//While overcharge is active, double ammo consumption, and
		playsound(user, 'sound/weapons/emitter.ogg', 5, 0, 2)
		charge_cost = ENERGY_OVERCHARGE_AMMO_COST
		ammo_datum_type = ammo_diff
		fire_delay += 7 // 1 shot per second fire rate
		fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
		to_chat(user, "[icon2html(src, user)] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = TRUE
	else
		playsound(user, 'sound/weapons/emitter2.ogg', 5, 0, 2)
		charge_cost = ENERGY_STANDARD_AMMO_COST
		ammo_datum_type = /datum/ammo/energy/lasgun/M43
		fire_delay -= 7
		fire_sound = 'sound/weapons/guns/fire/laser.ogg'
		to_chat(user, "[icon2html(src, user)] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = FALSE

	//load_into_chamber()

	user?.hud_used.update_ammo_hud(user, src)

	return TRUE

//-------------------------------------------------------
//M43 Sunfury Lasgun MK1

/obj/item/weapon/gun/energy/lasgun/M43
	name = "\improper M43 Sunfury Lasgun MK1"
	desc = "An accurate, recoilless laser based battle rifle with an integrated charge selector. Ideal for longer range engagements. It was the standard lasrifle for TGMC soldiers until it was replaced by the LR-73, due to its extremely modular lens system."
	force = 20 //Large and hefty! Includes stock bonus.
	icon_state = "m43"
	item_state = "m43"
	max_shots = 50 //codex stuff
	load_method = CELL //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/M43
	ammo_diff = null
	rounds_per_shot = ENERGY_STANDARD_AMMO_COST
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
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/focuslens,
		/obj/item/attachable/widelens,
		/obj/item/attachable/heatlens,
		/obj/item/attachable/efflens,
		/obj/item/attachable/pulselens,
		/obj/item/attachable/stock/lasgun,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_SHOWS_AMMO_REMAINING
	starting_attachment_types = list(/obj/item/attachable/stock/lasgun)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)
	ammo_level_icon = "m43"
	accuracy_mult_unwielded = 0.5 //Heavy and unwieldy; you don't one hand this.
	scatter_unwielded = 100 //Heavy and unwieldy; you don't one hand this.
	damage_falloff_mult = 0.25
	fire_delay = 3

//variant without ugl attachment
/obj/item/weapon/gun/energy/lasgun/M43/stripped
	starting_attachment_types = list()


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
	ammo_datum_type = /datum/ammo/energy/lasgun/pulsebolt
	muzzleflash_iconstate = "muzzle_flash_pulse"
	rounds_per_shot = ENERGY_STANDARD_AMMO_COST
	muzzle_flash_color = COLOR_PULSE_BLUE
	default_ammo_type = /obj/item/cell/lasgun/pulse
	allowed_ammo_types = list(/obj/item/cell/lasgun/pulse)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)
	ammo_level_icon = "m19c4"
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
	ammo_datum_type = /datum/ammo/energy/lasgun/M43/practice
	attachable_allowed = list(/obj/item/attachable/stock/lasgun/practice)
	starting_attachment_types = list(/obj/item/attachable/stock/lasgun/practice)
	muzzle_flash_color = COLOR_DISABLER_BLUE

	damage_falloff_mult = 1
	fire_delay = 0.35 SECONDS
	aim_slowdown = 0.35

/obj/item/weapon/gun/energy/lasgun/M43/practice/unique_action(mob/user)
	return

/obj/item/weapon/gun/energy/lasgun/lasrifle
	name = "\improper LR-73 lasrifle MK2"
	desc = "A multifunctional laser based rifle with an integrated mode selector. Ideal for any situation. Uses power cells instead of ballistic magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "tx73"
	item_state = "tx73"
	max_shots = 50 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
	ammo_diff = null
	rounds_per_shot = 12
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
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
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
	)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 14,"rail_x" = 18, "rail_y" = 18, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)
	ammo_level_icon = "tx73"
	accuracy_mult_unwielded = 0.5 //Heavy and unwieldy; you don't one hand this.
	scatter_unwielded = 100 //Heavy and unwieldy; you don't one hand this.
	damage_falloff_mult = 0.25
	fire_delay = 2
	default_ammo_type = /obj/item/cell/lasgun/lasrifle
	allowed_ammo_types = list(/obj/item/cell/lasgun/lasrifle)
	var/list/datum/lasrifle/base/mode_list = list(
	)

/datum/lasrifle/base
	///how much power the gun uses on this mode when shot.
	var/rounds_per_shot = 0
	///the ammo datum this mode is.
	var/datum/ammo/ammo_datum_type = null
	///how long it takes between each shot of that mode, same as gun fire delay.
	var/fire_delay = 0
	///Gives guns a burst amount, editable.
	var/burst_amount = 0
	///The gun firing sound of this mode
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

/obj/item/weapon/gun/energy/lasgun/lasrifle/unique_action(mob/user)
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
	ammo_datum_type = initial(choice.ammo_datum_type)
	fire_delay = initial(choice.fire_delay)
	burst_amount = initial(choice.burst_amount)
	fire_sound = initial(choice.fire_sound)
	rounds_per_shot = initial(choice.rounds_per_shot)
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)
	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, initial(choice.fire_mode), user.client)

	base_gun_icon = initial(choice.icon_state)
	update_icon()
	to_chat(user, initial(choice.message_to_user))
	user?.hud_used.update_ammo_hud(user, src)

	if(!in_chamber || !length(chamber_items))
		return
	QDEL_NULL(in_chamber)

	in_chamber = get_ammo_object(chamber_items[current_chamber_position])

//Tesla gun
/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla
	name = "\improper Terra Experimental tesla shock rifle"
	desc = "A Terra Experimental energy rifle that fires balls of elecricity that shock all those near them, it is meant to drain the plasma of unidentified creatures from within, limiting their abilities. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts. Uses standard Terra Experimental (TE) power cells."
	icon_state = "tesla"
	item_state = "tesla"
	icon = 'icons/Marine/gun64.dmi'
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	ammo_datum_type  = /datum/ammo/energy/tesla
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	default_ammo_type = /obj/item/cell/lasgun/lasrifle
	allowed_ammo_types = list(/obj/item/cell/lasgun/lasrifle)
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_SHOWS_AMMO_REMAINING
	muzzle_flash_color = COLOR_TESLA_BLUE
	ammo_level_icon = "tesla"
	max_shots = 6 //codex stuff
	rounds_per_shot = 100
	fire_delay = 4 SECONDS
	turret_flags = TURRET_INACCURATE
	attachable_allowed = list(
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	mode_list = list(
		"Standard" = /datum/lasrifle/base/tesla_mode/standard,
		"Focused" = /datum/lasrifle/base/tesla_mode/focused,
	)

/datum/lasrifle/base/tesla_mode/standard
	rounds_per_shot = 100
	ammo_datum_type = /datum/ammo/energy/tesla
	fire_delay = 4 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	message_to_user = "You set the tesla shock rifle's power mode mode to standard."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tesla"

/datum/lasrifle/base/tesla_mode/focused
	rounds_per_shot = 100
	ammo_datum_type = /datum/ammo/energy/tesla/focused
	fire_delay = 4 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	message_to_user = "You set the tesla shock rifle's power mode mode to focused."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tesla"
	radial_icon_state = "laser_overcharge"

//TE Tier 1 Series//

//TE Standard Laser rifle

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle
	name = "\improper Terra Experimental laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. It has an integrated charge selector for normal and high settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	icon_state = "ter"
	item_state = "ter"
	max_shots = 50 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
	ammo_diff = null
	rounds_per_shot = 12
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	turret_flags = TURRET_INACCURATE
	ammo_level_icon = "te"
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 21, "under_x" = 29, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.4
	wield_delay = 0.5 SECONDS
	scatter = 0
	scatter_unwielded = 10
	fire_delay = 0.2 SECONDS
	accuracy_mult_unwielded = 0.55
	damage_falloff_mult = 0.2
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_rifle_mode/standard,
		"Overcharge" = /datum/lasrifle/base/energy_rifle_mode/overcharge,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/reddot, /obj/item/weapon/gun/flamer/mini_flamer)

/datum/lasrifle/base/energy_rifle_mode/standard
	rounds_per_shot = 12
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the laser rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "ter"


/datum/lasrifle/base/energy_rifle_mode/overcharge
	rounds_per_shot = 30
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/overcharge
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
	icon_state = "tep"
	item_state = "tep"
	w_class = WEIGHT_CLASS_NORMAL
	flags_equip_slot = ITEM_SLOT_BELT
	max_shots = 30 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol
	ammo_diff = null
	rounds_per_shot = 20
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 23, "muzzle_y" = 22,"rail_x" = 12, "rail_y" = 22, "under_x" = 16, "under_y" = 14, "stock_x" = 22, "stock_y" = 12)

	akimbo_additional_delay = 0.9
	wield_delay = 0.6 SECONDS
	scatter = 2
	scatter_unwielded = 4
	fire_delay = 0.15 SECONDS
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.9
	damage_falloff_mult = 0.2
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_pistol_mode/standard,
		"Heat" = /datum/lasrifle/base/energy_pistol_mode/heat,
		"Disabler" = /datum/lasrifle/base/energy_pistol_mode/disabler,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight)

/datum/lasrifle/base/energy_pistol_mode/standard
	rounds_per_shot = 20
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol
	fire_delay = 0.15 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Pistol Standard.ogg'
	message_to_user = "You set the laser pistol's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tep"

/datum/lasrifle/base/energy_pistol_mode/disabler
	rounds_per_shot = 80
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol/disabler
	fire_delay = 10
	fire_sound = 'sound/weapons/guns/fire/disabler.ogg'
	message_to_user = "You set the laser pistol's charge mode to disabler fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tep"
	radial_icon_state = "laser_disabler"

/datum/lasrifle/base/energy_pistol_mode/heat
	rounds_per_shot = 110
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol/heat
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
	icon_state = "tec"
	item_state = "tec"
	max_shots = 40 //codex stuff
	load_method = CELL //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
	ammo_diff = null
	rounds_per_shot = 15
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	ammo_level_icon = "te"
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 17, "rail_y" = 21, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.2
	wield_delay = 0.3 SECONDS
	scatter = 1
	scatter_unwielded = 10
	fire_delay = 0.2 SECONDS
	burst_amount = 1
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.65
	damage_falloff_mult = 0.5
	movement_acc_penalty_mult = 4
	mode_list = list(
		"Auto burst standard" = /datum/lasrifle/base/energy_carbine_mode/auto_burst_standard,
		"Automatic standard" = /datum/lasrifle/base/energy_carbine_mode/auto_burst_standard/automatic,
		"Spread" = /datum/lasrifle/base/energy_carbine_mode/base/spread,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/weapon/gun/grenade_launcher/underslung,)

/datum/lasrifle/base/energy_carbine_mode/auto_burst_standard ///I know this seems tacky, but if I make auto burst a standard firemode it somehow buffs spread's fire delay.
	rounds_per_shot = 15
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
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
	rounds_per_shot = 60
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/blast
	fire_delay = 1.5 SECONDS
	burst_amount = 1
	fire_sound = 'sound/weapons/guns/fire/Laser Carbine Scatter.ogg'
	message_to_user = "You set the laser carbine's charge mode to spread."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tec"
	radial_icon_state = "laser_spread"

//TE Standard Sniper

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper
	name = "\improper Terra Experimental laser sniper rifle"
	desc = "The T-ES, a Terra Experimental standard issue laser sniper rifle, it has an integrated charge selector for normal and heat settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_sniper_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	icon_state = "tes"
	item_state = "tes"
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 12 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/sniper
	ammo_diff = null
	rounds_per_shot = 50
	damage_falloff_mult = 0
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	ammo_level_icon = "te"
	icon_overlay_x_offset = -1
	icon_overlay_y_offset = -3

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/unremovable/laser_sniper_scope,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 18,"rail_x" = 19, "rail_y" = 19, "under_x" = 28, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/laser_sniper_scope)

	aim_slowdown = 0.7
	wield_delay = 0.7 SECONDS
	scatter = 0
	scatter_unwielded = 10
	fire_delay = 1 SECONDS
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.5
	movement_acc_penalty_mult = 6
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_sniper_mode/standard,
		"Heat" = /datum/lasrifle/base/energy_sniper_mode/heat,
	)

/datum/lasrifle/base/energy_sniper_mode/standard
	rounds_per_shot = 50
	fire_delay = 1 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/sniper
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the sniper rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tes"

/datum/lasrifle/base/energy_sniper_mode/heat
	rounds_per_shot = 150
	fire_delay = 1 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/sniper_heat
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the sniper rifle's charge mode to wave heat."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tes"
	radial_icon_state = "laser_heat"

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser
	name = "\improper Terra Experimental laser machine gun"
	desc = "A Terra Experimental standard issue machine laser gun, often called as the TE-M by marines. It has a fire switch for normal and efficiency modes. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_machine_laser_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	icon_state = "tem"
	item_state = "tem"
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 150 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser
	ammo_diff = null
	rounds_per_shot = 4
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	ammo_level_icon = "te"

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 15,"rail_x" = 22, "rail_y" = 24, "under_x" = 30, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 1
	wield_delay = 1.5 SECONDS
	scatter = 1
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.3
	scatter_unwielded = 30
	damage_falloff_mult = 0.3
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_mg_mode/standard,
		"Efficiency mode" = /datum/lasrifle/base/energy_mg_mode/standard/efficiency,
	)

/datum/lasrifle/base/energy_mg_mode/standard
	rounds_per_shot = 4
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the machine laser's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tem"

/datum/lasrifle/base/energy_mg_mode/standard/efficiency
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser/efficiency
	fire_delay = 0.15 SECONDS
	rounds_per_shot = 3
	message_to_user = "You set the machine laser's charge mode to efficiency mode."

/obj/item/weapon/gun/energy/lasgun/lasrifle/xray
	name = "\improper Terra Experimental X-Ray laser rifle"
	desc = "A Terra Experimental X-Ray laser rifle, abbreviated as the TE-X. It has an integrated charge selector for normal and high settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	icon_state = "tex"
	item_state = "tex"
	max_shots = 40 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/xray
	rounds_per_shot = 15
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 19,"rail_x" = 20, "rail_y" = 21, "under_x" = 30, "under_y" = 13, "stock_x" = 22, "stock_y" = 14)
	ammo_level_icon = "tex"
	aim_slowdown = 0.4
	wield_delay = 0.5 SECONDS
	scatter = 0
	scatter_unwielded = 10
	fire_delay = 0.5 SECONDS
	accuracy_mult_unwielded = 0.55
	damage_falloff_mult = 0.3
	mode_list = list(
		"Standard" = /datum/lasrifle/base/energy_rifle_mode/xray,
		"Piercing" = /datum/lasrifle/base/energy_rifle_mode/xray/piercing,
	)

/datum/lasrifle/base/energy_rifle_mode/xray
	rounds_per_shot = 15
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/xray
	fire_delay = 0.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the xray rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tex"
	radial_icon_state = "laser_heat"

/datum/lasrifle/base/energy_rifle_mode/xray/piercing
	rounds_per_shot = 30
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/xray/piercing
	fire_delay = 0.6 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser.ogg'
	message_to_user = "You set the xray rifle's charge mode to piercing mode."
	radial_icon_state = "laser"

//Martian death rays
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite
	name = "volkite gun"
	desc = "you shouldn't see this gun."
	icon_state = "charger"
	item_state = "charger"
	fire_sound = 'sound/weapons/guns/fire/volkite_1.ogg'
	dry_fire_sound = 'sound/weapons/guns/misc/error.ogg'
	unload_sound = 'sound/weapons/guns/interact/volkite_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/volkite_reload.ogg'
	max_shots = 50
	ammo_datum_type = /datum/ammo/energy/volkite
	rounds_per_shot = 24
	default_ammo_type = /obj/item/cell/lasgun/volkite
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite)
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 14,"rail_x" = 18, "rail_y" = 18, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	accuracy_mult = 1
	scatter = -2
	recoil = 0
	accuracy_mult_unwielded = 0.5
	scatter_unwielded = 25
	recoil_unwielded = 3

	aim_slowdown = 0.35
	wield_delay = 0.4 SECONDS
	wield_penalty = 0.2 SECONDS

	damage_falloff_mult = 0.25
	fire_delay = 0.2 SECONDS
	mode_list = list()

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta
	name = "\improper VX-12 Serpenta"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. The 'serpenta' is pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size."
	icon_state = "vx12"
	item_state = "vx12"
	w_class = WEIGHT_CLASS_NORMAL
	ammo_level_icon = ""
	max_shots = 15
	rounds_per_shot = 36
	ammo_datum_type = /datum/ammo/energy/volkite/medium
	default_ammo_type = /obj/item/cell/lasgun/volkite/small
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite/small)
	fire_sound = 'sound/weapons/guns/fire/volkite_3.ogg'
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	fire_delay = 0.35 SECONDS
	scatter = -1
	scatter_unwielded = 5
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.9
	recoil_unwielded = 0
	damage_falloff_mult = 0.5
	movement_acc_penalty_mult = 2
	aim_slowdown = 0.1

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger
	name = "\improper VX-32 Charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges."
	icon_state = "charger"
	item_state = "charger"
	ammo_level_icon = "charger"
	max_shots = 40
	rounds_per_shot = 24
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 13,"rail_x" = 6, "rail_y" = 20, "under_x" = 26, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)
	scatter = 3
	accuracy_mult_unwielded = 0.9
	scatter_unwielded = 10
	recoil_unwielded = 1
	damage_falloff_mult = 0.9
	movement_acc_penalty_mult = 4

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/gyro)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/standard
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout
	starting_attachment_types = list(/obj/item/attachable/motiondetector, /obj/item/attachable/gyro)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver
	name = "\improper VX-33 Caliver"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. The caliver is the primary rifle of the volkite family, and effective at most ranges and situations. Drag click the powerpack to the gun to use that instead of magazines."
	icon_state = "caliver"
	item_state = "caliver"
	ammo_level_icon = "caliver"
	fire_sound = 'sound/weapons/guns/fire/volkite_3.ogg'
	max_shots = 50
	ammo_datum_type = /datum/ammo/energy/volkite/medium
	rounds_per_shot = 36
	default_ammo_type = /obj/item/cell/lasgun/volkite/highcap
	allowed_ammo_types = list(
		/obj/item/cell/lasgun/volkite/highcap,
		/obj/item/cell/lasgun/volkite/powerpack,
	)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 13,"rail_x" = 6, "rail_y" = 20, "under_x" = 33, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)
	accuracy_mult = 1.1
	aim_slowdown = 0.65
	wield_delay	= 0.7 SECONDS
	fire_delay = 0.25 SECONDS

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/magharness
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	starting_attachment_types = list(/obj/item/attachable/motiondetector, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/standard
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin
	name = "\improper VX-42 Culverin"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. The culverin is the largest man portable example of volkite weaponry, and can lay down a staggering torrent of fire due to its linked back-mounted powerpack. Drag click the powerpack to the gun to load."
	icon_state = "culverin"
	item_state = "culverin"
	ammo_level_icon = null
	max_shots = 120
	ammo_datum_type = /datum/ammo/energy/volkite/heavy
	rounds_per_shot = 30
	default_ammo_type = null
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite/powerpack)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
	)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_WIELDED_FIRING_ONLY
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 14,"rail_x" = 17, "rail_y" = 22, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)
	aim_slowdown = 1
	wield_delay	= 1.2 SECONDS
	fire_delay = 0.15 SECONDS
	scatter = 3
	accuracy_mult_unwielded = 0.4
	scatter_unwielded = 35
	recoil_unwielded = 5
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)
