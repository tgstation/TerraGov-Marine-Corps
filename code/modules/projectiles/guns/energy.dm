
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
	ammo_datum_type = /datum/ammo/energy/taser
	default_ammo_type = /obj/item/cell/lasgun/lasrifle
	allowed_ammo_types = list(/obj/item/cell/lasgun/lasrifle)
	rounds_per_shot = 500
	flags_gun_features = GUN_AMMO_COUNTER|GUN_ALLOW_SYNTHETIC|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	gun_skill_category = SKILL_PISTOLS
	movement_acc_penalty_mult = 0


	fire_delay = 10
	accuracy_mult = 1.15
	scatter = 2
	scatter_unwielded = 1

/obj/item/weapon/gun/energy/taser/able_to_fire(mob/living/user)
	. = ..()
	if (!.)
		return
	if(user.skills.getRating(SKILL_POLICE) < SKILL_POLICE_MP)
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
	ammo_datum_type = /datum/ammo/energy/lasgun
	flags_equip_slot = ITEM_SLOT_BACK
	muzzleflash_iconstate = "muzzle_flash_laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	overcharge = FALSE
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_SHOWS_AMMO_REMAINING
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	aim_slowdown = 0.75
	wield_delay = 1 SECONDS
	gun_skill_category = SKILL_RIFLES
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

	user?.hud_used.update_ammo_hud(src, get_ammo_list(), get_display_ammo_count())

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
	rounds_per_shot = ENERGY_STANDARD_AMMO_COST
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
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

	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)
	ammo_level_icon = "m19c4"
	fire_delay = 4
	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.95
	scatter_unwielded = 25
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_firemode = GUN_FIREMODE_AUTOMATIC

/obj/item/weapon/gun/energy/lasgun/pulse/Initialize(mapload, spawn_empty)
	. = ..()
	AddComponent(/datum/component/reequip, list(SLOT_BELT)) //Innate mag harness, no more free pulse rifles for you >:(

//-------------------------------------------------------
//A practice version of M43, only for memes

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
	rounds_per_shot = 12
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
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
	allowed_ammo_types = list(/obj/item/cell/lasgun/lasrifle, /obj/item/cell/lasgun/volkite/powerpack/marine, /obj/item/cell/lasgun/lasrifle/recharger)
	/// A list of available modes this gun can switch to
	var/list/datum/lasrifle/mode_list = list()
	/// The index of the current mode selected, used for non radial mode switches
	var/mode_index = 1

/datum/lasrifle
	///how much power the gun uses on this mode when shot.
	var/rounds_per_shot = 0
	///the ammo datum this mode is.
	var/datum/ammo/ammo_datum_type = null
	///how long it takes between each shot of that mode, same as gun fire delay.
	var/fire_delay = 0
	///Gives guns a burst amount, editable.
	var/burst_amount = 0
	///heat amount per shot
	var/heat_per_fire = 0
	///The gun firing sound of this mode
	var/fire_sound = null
	///What message it sends to the user when you switch to this mode.
	var/message_to_user = "" // todo delete me I'm useless
	///Used to change the gun firemode, like automatic, semi-automatic and burst.
	var/fire_mode = GUN_FIREMODE_SEMIAUTO
	///what to change the gun icon_state to when switching to this mode.
	var/icon_state = "tx73"
	///Which icon file the radial menu will use.
	var/radial_icon = 'icons/mob/radial.dmi'
	///The icon state the radial menu will use.
	var/radial_icon_state = "laser"
	///windup before firing
	var/windup_delay = 0
	///codex description
	var/description = ""

//TODO this proc should be generic so that you dont have to manually copy paste the default mode onto the item
/obj/item/weapon/gun/energy/lasgun/lasrifle/unique_action(mob/user)
	if(!user)
		CRASH("switch_modes called with no user.")

	var/datum/lasrifle/choice
	var/list/available_modes = list()
	if(user?.client?.prefs.toggles_gameplay & RADIAL_LASERGUNS)
		for(var/mode in mode_list)
			available_modes += list("[mode]" = image(icon = initial(mode_list[mode].radial_icon), icon_state = initial(mode_list[mode].radial_icon_state)))

		choice = mode_list[show_radial_menu(user, user, available_modes, null, 64, tooltips = TRUE)]
		mode_index = 0
	else
		for(var/mode_key AS in mode_list)
			available_modes += mode_key

		mode_index = WRAP(mode_index + 1, 1, length(mode_list)+1)
		choice = mode_list[available_modes[mode_index]]

	if(!choice)
		return

	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return

	playsound(user, 'sound/weapons/emitter.ogg', 5, FALSE, 2)

	shots_fired = 0
	gun_firemode = initial(choice.fire_mode)
	gun_firemode_list = list(gun_firemode)
	ammo_datum_type = initial(choice.ammo_datum_type)
	fire_delay = initial(choice.fire_delay)
	burst_amount = initial(choice.burst_amount)
	fire_sound = initial(choice.fire_sound)
	rounds_per_shot = initial(choice.rounds_per_shot)
	windup_delay = initial(choice.windup_delay)
	heat_per_fire = initial(choice.heat_per_fire)
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)
	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, initial(choice.fire_mode), user.client)

	base_gun_icon = initial(choice.icon_state)
	update_icon()
	to_chat(user, initial(choice.message_to_user))
	user?.hud_used.update_ammo_hud(src, get_ammo_list(), get_display_ammo_count())

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
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	ammo_datum_type = /datum/ammo/energy/tesla
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	default_ammo_type = /obj/item/cell/lasgun/lasrifle
	allowed_ammo_types = list(/obj/item/cell/lasgun/lasrifle, /obj/item/cell/lasgun/volkite/powerpack/marine)
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
		"Standard" = /datum/lasrifle/tesla_mode/standard,
		"Focused" = /datum/lasrifle/tesla_mode/focused,
	)

/datum/lasrifle/tesla_mode/standard
	rounds_per_shot = 100
	ammo_datum_type = /datum/ammo/energy/tesla
	fire_delay = 4 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	message_to_user = "You set the tesla shock rifle's power mode mode to standard."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tesla"
	description = "Fires a slow moving ball of energy that shocks any living thing nearby. Minimal damage, but drains plasma rapidly from xenomorphs."

/datum/lasrifle/tesla_mode/focused
	rounds_per_shot = 100
	ammo_datum_type = /datum/ammo/energy/tesla/focused
	fire_delay = 4 SECONDS
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	message_to_user = "You set the tesla shock rifle's power mode mode to focused."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tesla"
	radial_icon_state = "laser_overcharge"
	description = "Fires an sophisticated IFF tesla ball, but with reduces shock range."

//TE Tier 1 Series//

//TE Standard Laser rifle

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle
	name = "\improper Terra Experimental laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	max_shots = 60
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
	rounds_per_shot = 10
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	turret_flags = TURRET_INACCURATE
	ammo_level_icon = "te"
	greyscale_config = /datum/greyscale_config/gun/gun64/lasgun
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/ter,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/ter,
		slot_back_str = /datum/greyscale_config/worn_gun/ter,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/ter,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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
		/obj/item/attachable/gyro,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
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
		"Standard" = /datum/lasrifle/energy_rifle_mode/standard,
		"Overcharge" = /datum/lasrifle/energy_rifle_mode/overcharge,
		"Weakening" = /datum/lasrifle/energy_rifle_mode/weakening,
		"Microwave" = /datum/lasrifle/energy_rifle_mode/microwave,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/reddot, /obj/item/weapon/gun/flamer/mini_flamer)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/magnetic_harness, /obj/item/weapon/gun/flamer/mini_flamer)

/datum/lasrifle/energy_rifle_mode/standard
	rounds_per_shot = 10
	ammo_datum_type = /datum/ammo/energy/lasgun/marine
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the laser rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	description = "Fire a standard automatic laser pulse. Better armour penetration and sunder than common projectiles."


/datum/lasrifle/energy_rifle_mode/overcharge
	rounds_per_shot = 24
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/overcharge
	fire_delay = 0.45 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser overcharge standard.ogg'
	message_to_user = "You set the laser rifle's charge mode to overcharge."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_overcharge"
	description = "Fires a powerful overcharged laser pulse. Deals heavy damage with superior penetration at the cost of slower fire rate."

/datum/lasrifle/energy_rifle_mode/weakening
	rounds_per_shot = 24
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/weakening
	fire_delay = 0.4 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser.ogg'
	message_to_user = "You set the laser rifle's charge mode to weakening."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_disabler"
	description = "Fires a pulse of energy that inflicts slowdown, and deals stamina damage to humans, or drains plasma from xenomorphs."


/datum/lasrifle/energy_rifle_mode/microwave
	rounds_per_shot = 30
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/microwave
	fire_delay = 0.45 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser_rifle_2.ogg'
	message_to_user = "You set the laser rifle's charge mode to microwave."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_microwave"
	description = "Fires a deadly pulse of microwave radiation, dealing moderate damage but applying a 'microwave' effect that deals strong damage over time."

///TE Standard Laser Pistol

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol
	name = "\improper Terra Experimental laser pistol"
	desc = "A TerraGov standard issue laser pistol abbreviated as TE-P. It has an integrated charge selector for normal, heat and taser settings. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_pistol_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Pistol Standard.ogg'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	w_class = WEIGHT_CLASS_NORMAL
	flags_equip_slot = ITEM_SLOT_BELT
	max_shots = 30 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol
	ammo_level_icon = null
	rounds_per_shot = 20
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	greyscale_config = /datum/greyscale_config/gun/pistol/tep
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tep,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tep,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight/under,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 23, "muzzle_y" = 22,"rail_x" = 12, "rail_y" = 22, "under_x" = 16, "under_y" = 14, "stock_x" = 22, "stock_y" = 12)

	akimbo_additional_delay = 0.9
	wield_delay = 0.2 SECONDS
	scatter = 2
	scatter_unwielded = 4
	fire_delay = 0.15 SECONDS
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.9
	damage_falloff_mult = 0.2
	aim_slowdown = 0
	mode_list = list(
		"Standard" = /datum/lasrifle/energy_pistol_mode/standard,
		"Heat" = /datum/lasrifle/energy_pistol_mode/heat,
		"Disabler" = /datum/lasrifle/energy_pistol_mode/disabler,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight)

/datum/lasrifle/energy_pistol_mode/standard
	rounds_per_shot = 20
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol
	fire_delay = 0.15 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Pistol Standard.ogg'
	message_to_user = "You set the laser pistol's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	description = "Fires a standard laser pulse. Moderate damage."

/datum/lasrifle/energy_pistol_mode/disabler
	rounds_per_shot = 80
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol/disabler
	fire_delay = 10
	fire_sound = 'sound/weapons/guns/fire/disabler.ogg'
	message_to_user = "You set the laser pistol's charge mode to disabler fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_disabler"
	description = "Fires a disabling pulse that drains stamina. Ineffective against xenomorphs."

/datum/lasrifle/energy_pistol_mode/heat
	rounds_per_shot = 100
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/pistol/heat
	fire_delay = 0.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the laser pistol's charge mode to wave heat."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_heat"
	description = "Fires an incendiary laser pulse that ignites living targets."

//TE Standard Laser Carbine

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine
	name = "\improper Terra Experimental laser carbine"
	desc = "A TerraGov standard issue laser carbine, otherwise known as TE-C for short. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Carbine Scatter.ogg'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	max_shots = 12
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/blast
	rounds_per_shot = 50
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	ammo_level_icon = "te"
	greyscale_config = /datum/greyscale_config/gun/gun64/lasgun/tec
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tec,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tec,
		slot_back_str = /datum/greyscale_config/worn_gun/tec,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/tec,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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
		/obj/item/attachable/gyro,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 17, "rail_y" = 21, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.2
	wield_delay = 0.3 SECONDS
	scatter = 1
	scatter_unwielded = 10
	fire_delay = 1.5 SECONDS
	burst_delay = 0.1 SECONDS
	extra_delay = 0.15 SECONDS
	autoburst_delay = 0.35 SECONDS
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.65
	damage_falloff_mult = 0.5
	movement_acc_penalty_mult = 4
	mode_list = list(
		"Auto burst standard" = /datum/lasrifle/energy_carbine_mode/auto_burst,
		"Spread" = /datum/lasrifle/energy_carbine_mode/base/spread,
		"Impact" = /datum/lasrifle/energy_carbine_mode/base/impact,
		"Cripple" = /datum/lasrifle/energy_carbine_mode/base/cripple,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	starting_attachment_types = list(
		/obj/item/attachable/reddot,
		/obj/item/weapon/gun/grenade_launcher/underslung,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/mag_harness
	starting_attachment_types = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/bayonet,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/gyro
	starting_attachment_types = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
	)

/datum/lasrifle/energy_carbine_mode/auto_burst
	rounds_per_shot = 12
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/carbine
	fire_delay = 0.2 SECONDS
	burst_amount = 4
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the laser carbine's charge mode to standard auto burst fire."
	fire_mode = GUN_FIREMODE_AUTOBURST
	icon_state = GUN_ICONSTATE_LOADED
	description = "Fires a rapid pulse laser, dealing good damage per second, but suffers from increased scatter and poorer falloff."

/datum/lasrifle/energy_carbine_mode/base/spread
	rounds_per_shot = 50
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/blast
	fire_delay = 1.5 SECONDS
	burst_amount = 1
	fire_sound = 'sound/weapons/guns/fire/Laser Carbine Scatter.ogg'
	message_to_user = "You set the laser carbine's charge mode to spread."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_spread"
	description = "Fire a 3 strong laser pulse dealing heavy damage with good penetration, but with a very slow rate of fire."

/datum/lasrifle/energy_carbine_mode/base/impact
	rounds_per_shot = 50
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/impact
	fire_delay = 1 SECONDS
	burst_amount = 1
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the laser carbine's charge mode to impact."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_impact"
	description = "Fires an experimental laser pulse designed to apply significant kinetic force on a target, applying strong knockback, but modest direct damage."

/datum/lasrifle/energy_carbine_mode/base/cripple
	rounds_per_shot = 15
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/cripple
	fire_delay = 0.3 SECONDS
	burst_amount = 1
	fire_sound = 'sound/weapons/guns/fire/laser.ogg'
	message_to_user = "You set the laser carbine's charge mode to cripple."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_disabler"
	description = "Fires a laser pulse dealing moderate damage and slowdown."

//TE Standard Sniper

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper
	name = "\improper Terra Experimental laser sniper rifle"
	desc = "The T-ES, a Terra Experimental standard issue laser sniper rifle, has multiple powerful firemodes, although the lack of aim mode can limit its tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_laser_sniper_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 20
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/sniper
	rounds_per_shot = 30
	damage_falloff_mult = 0
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	ammo_level_icon = "te"
	icon_overlay_x_offset = -1
	icon_overlay_y_offset = -3
	greyscale_config = /datum/greyscale_config/gun/gun64/lasgun/tes
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tes,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tes,
		slot_back_str = /datum/greyscale_config/worn_gun/tes,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/tes,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/unremovable/laser_sniper_scope,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/gyro,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 18,"rail_x" = 19, "rail_y" = 19, "under_x" = 28, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/laser_sniper_scope)

	aim_slowdown = 0.7
	wield_delay = 0.7 SECONDS
	scatter = -4
	scatter_unwielded = 10
	fire_delay = 0.8 SECONDS
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.5
	movement_acc_penalty_mult = 6
	mode_list = list(
		"Standard" = /datum/lasrifle/energy_sniper_mode/standard,
		"Heat" = /datum/lasrifle/energy_sniper_mode/heat,
		"Shatter" = /datum/lasrifle/energy_sniper_mode/shatter,
		"Ricochet" = /datum/lasrifle/energy_sniper_mode/ricochet,
	)

/datum/lasrifle/energy_sniper_mode/standard
	rounds_per_shot = 30
	fire_delay = 0.8 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/sniper
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the sniper rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	description = "Fires a single strong laser pulse, with good damage and penetration, and no falloff."

/datum/lasrifle/energy_sniper_mode/heat
	rounds_per_shot = 100
	fire_delay = 1 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/sniper_heat
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the sniper rifle's charge mode to wave heat."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_heat"
	description = "Fires an incendiary laser pulse, designed to ignite victims at range."

/datum/lasrifle/energy_sniper_mode/shatter
	rounds_per_shot = 100
	fire_delay = 1 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/shatter
	fire_sound = 'sound/weapons/guns/fire/laser_rifle_2.ogg'
	message_to_user = "You set the sniper rifle's charge mode to shatter."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_charge"
	description = "Fires a devestating laser pulse that significantly degrades the victims armor, at the cost of lower direct damage."

/datum/lasrifle/energy_sniper_mode/ricochet
	rounds_per_shot = 45
	fire_delay = 0.8 SECONDS
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/ricochet/four
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the sniper rifle's charge mode to ricochet."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_ricochet"
	description = "Fires an experiment laser pulse capable of bouncing off many wall surfaces. The laser increases in potency when bouncing, before collapsing entirely after exceeding its threshold."

// TE Standard MG

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser
	name = "\improper Terra Experimental laser machine gun"
	desc = "A Terra Experimental standard issue machine laser gun, often called as the TE-M by marines. High efficiency modulators ensure the TE-M has an extremely high fire count, and multiple firemodes makes it a flexible infantry support gun. Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	reload_sound = 'sound/weapons/guns/interact/standard_machine_laser_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 150 //codex stuff
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser
	rounds_per_shot = 4
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	ammo_level_icon = "te"
	greyscale_config = /datum/greyscale_config/gun/gun64/lasgun/tem
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/tem,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/tem,
		slot_back_str = /datum/greyscale_config/worn_gun/tem,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/tem,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
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
		/obj/item/attachable/gyro,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 15,"rail_x" = 22, "rail_y" = 24, "under_x" = 30, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)

	aim_slowdown = 0.7
	wield_delay = 0.8 SECONDS
	scatter = 1
	fire_delay = 0.2 SECONDS
	burst_delay = 0.25 SECONDS
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.3
	scatter_unwielded = 30
	movement_acc_penalty_mult = 6
	damage_falloff_mult = 0.3
	windup_sound = 'sound/weapons/guns/fire/laser_charge_up.ogg'
	mode_list = list(
		"Standard" = /datum/lasrifle/energy_mg_mode/standard,
		"Burst" = /datum/lasrifle/energy_mg_mode/standard/burst,
		"Charge" = /datum/lasrifle/energy_mg_mode/standard/charge,
		"Melting" = /datum/lasrifle/energy_mg_mode/standard/melting,
	)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/apply_gun_modifiers(obj/projectile/projectile_to_fire, atom/target, firer)
	. = ..()
	if((gun_firemode == GUN_FIREMODE_BURSTFIRE) && shots_fired) //this specifically boosts the burst fire mode
		projectile_to_fire.damage *= (1 + shots_fired)

/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/weapon/gun/grenade_launcher/underslung, /obj/item/attachable/bayonet)

/datum/lasrifle/energy_mg_mode/standard
	rounds_per_shot = 4
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the machine laser's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = GUN_ICONSTATE_LOADED
	description = "Fires a rapid laser pulse with slightly reduced damage, but improved penetration and vastly improved energy efficiency."

/datum/lasrifle/energy_mg_mode/standard/burst
	rounds_per_shot = 8
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser/burst
	fire_delay = 0.45 SECONDS
	burst_amount = 4
	fire_sound = 'sound/weapons/guns/fire/Laser Carbine Scatter.ogg'
	message_to_user = "You set the machine laser's charge mode to burst."
	fire_mode = GUN_FIREMODE_BURSTFIRE
	icon_state = GUN_ICONSTATE_LOADED
	radial_icon_state = "laser_spread"
	description = "Fires a series of laser pulses in quick succession. Each pulse in a burst is more powerful than the last."


/datum/lasrifle/energy_mg_mode/standard/charge
	rounds_per_shot = 15
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser/charge
	fire_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser overcharge standard.ogg'
	windup_delay = 0.5 SECONDS
	fire_mode = GUN_FIREMODE_AUTOMATIC
	message_to_user = "You set the machine laser's charge mode to charge."
	radial_icon_state = "laser_charge"
	description = "Fires a powerful laser pulse after a brief charge up."

/datum/lasrifle/energy_mg_mode/standard/melting
	rounds_per_shot = 18
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/autolaser/melting
	fire_delay = 0.3 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser_rifle_2.ogg'
	message_to_user = "You set the machine laser's charge mode to melting."
	radial_icon_state = "laser_heat"
	description = "Fires an unusual laser pulse that applies a melting effect which severely sunders xenomorph armor over time, as well as applying further damage."

// TE X-Ray

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
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/gyro,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
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
		"Standard" = /datum/lasrifle/energy_rifle_mode/xray,
		"Piercing" = /datum/lasrifle/energy_rifle_mode/xray/piercing,
	)

/datum/lasrifle/energy_rifle_mode/xray
	rounds_per_shot = 15
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/xray
	fire_delay = 0.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	message_to_user = "You set the xray rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tex"
	radial_icon_state = "laser_heat"
	description = "Fires an incendiary laser pulse designed to ignite a victim."

/datum/lasrifle/energy_rifle_mode/xray/piercing
	rounds_per_shot = 30
	ammo_datum_type = /datum/ammo/energy/lasgun/marine/xray/piercing
	fire_delay = 0.6 SECONDS
	fire_sound = 'sound/weapons/guns/fire/laser.ogg'
	message_to_user = "You set the xray rifle's charge mode to piercing mode."
	radial_icon_state = "laser"
	description = "Fires a powerful xray laser pulse. Completely penetrates a victims armour, as well as any solid substance in the way."

//Martian death rays
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite
	name = "volkite gun"
	desc = "you shouldn't see this gun."
	icon_state = "charger"
	item_state = "charger"
	ammo_level_icon = ""
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
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_SHOWS_LOADED
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

	damage_falloff_mult = 0.9
	fire_delay = 0.2 SECONDS
	mode_list = list()
	light_range = 0.1
	light_power = 0.1
	light_color = LIGHT_COLOR_ORANGE

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/update_icon(mob/user)
	. = ..()
	if(rounds)
		turn_light(user, TRUE)
	else
		turn_light(user, FALSE)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	set_light_on(toggle_on)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/apply_custom(mutable_appearance/standing, inhands, icon_used, state_used)
	. = ..()
	var/mutable_appearance/emissive_overlay = emissive_appearance(icon_used, "[item_state]_emissive")
	standing.overlays.Add(emissive_overlay)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta
	name = "\improper VX-12 Serpenta"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. The 'serpenta' is pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size."
	icon_state = "vx12"
	item_state = "vx12"
	w_class = WEIGHT_CLASS_NORMAL
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
	movement_acc_penalty_mult = 2
	aim_slowdown = 0.1
	wield_delay = 0.2 SECONDS

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom
	name = "\improper VX-12c Serpenta"
	desc = "The 'serpenta' is pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size. This particular weapon appears to be a custom model with improved performance."
	icon_state = "vx12c"
	item_state = "vx12"
	ammo_datum_type = /datum/ammo/energy/volkite/medium/custom
	max_shots = 27
	rounds_per_shot = 20
	scatter = -2
	scatter_unwielded = 4
	accuracy_mult = 1.25
	accuracy_mult_unwielded = 0.95

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger
	name = "\improper VX-32 Charger"
	desc = "Volkite weapons are the pride of Martian weapons manufacturing, their construction being a tightly guarded secret. Infamous for its ability to deflagrate organic targets with its tremendous thermal energy, explosively burning flesh in a fiery blast that can be deadly to anyone unfortunate enough to be nearby. The charger is a light weight weapon with a high rate of fire, designed for high mobility and easy handling. Ineffective at longer ranges."
	icon_state = "charger"
	item_state = "charger"
	max_shots = 45
	rounds_per_shot = 32
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
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 13,"rail_x" = 9, "rail_y" = 23, "under_x" = 30, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)
	scatter = 3
	accuracy_mult = 1.05
	accuracy_mult_unwielded = 0.9
	scatter_unwielded = 8
	recoil_unwielded = 1
	movement_acc_penalty_mult = 3
	damage_falloff_mult = 0.5

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
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "caliver"
	item_state = "caliver"
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)
	fire_sound = 'sound/weapons/guns/fire/volkite_3.ogg'
	max_shots = 40
	ammo_datum_type = /datum/ammo/energy/volkite/medium
	rounds_per_shot = 36
	default_ammo_type = /obj/item/cell/lasgun/volkite
	allowed_ammo_types = list(
		/obj/item/cell/lasgun/volkite,
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
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 13,"rail_x" = 9, "rail_y" = 24, "under_x" = 45, "under_y" = 11, "stock_x" = 22, "stock_y" = 12)
	accuracy_mult = 1.1
	aim_slowdown = 0.65
	damage_falloff_mult = 0.4
	wield_delay = 0.7 SECONDS
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
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)
	ammo_level_icon = null
	max_shots = 120
	ammo_datum_type = /datum/ammo/energy/volkite/heavy
	rounds_per_shot = 30
	default_ammo_type = null
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite/powerpack)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
	)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_WIELDED_FIRING_ONLY|GUN_SHOWS_LOADED
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 14,"rail_x" = 11, "rail_y" = 29, "under_x" = 23, "under_y" = 10, "stock_x" = 22, "stock_y" = 12)
	aim_slowdown = 1
	wield_delay = 1.2 SECONDS
	fire_delay = 0.15 SECONDS
	scatter = 3
	accuracy_mult_unwielded = 0.4
	scatter_unwielded = 35
	recoil_unwielded = 5
	damage_falloff_mult = 0.4
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)
