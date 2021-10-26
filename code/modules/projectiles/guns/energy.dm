
//-------------------------------------------------------
//ENERGY GUNS/ETC

/obj/item/weapon/gun/energy
	attachable_allowed = list()
	rounds_to_draw = 10 //100 shots.
	flags_gun_features = GUN_AMMO_COUNTER
	general_codex_key = "energy weapons"

	placed_overlay_iconstate = "laser"
	reciever_flags = RECIEVER_MAGAZINES
	allowed_ammo_type = /obj/item/cell
	current_rounds_var = "charge"
	max_rounds_var = "maxcharge"
	ammo_type_var = null
	gun_type_var = null

/obj/item/weapon/gun/energy/muzzle_flash()
	return

// energy guns, however, do not use gun rattles.
/obj/item/weapon/gun/energy/play_fire_sound(mob/user)
	if(HAS_TRAIT(src, TRAIT_GUN_SILENCED))
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
	rounds_to_draw = 500
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER|GUN_ALLOW_SYNTHETIC
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 0


	fire_delay = 10
	accuracy_mult = 1.15
	scatter = 10
	scatter_unwielded = 15



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

	gun_type_var = "gun_type"
	reload_delay_var = "reload_delay"

/obj/item/weapon/gun/energy/lasgun/tesla
	name = "\improper M43-T tesla shock rifle"
	desc = "A prototype TGMC energy rifle that fires balls of elecricity that shock all those near them, it is meant to drain the plasma of unidentified creatures from within, limiting their abilities. Handle only with insulated clothing. Reloaded with power cells."
	icon_state = "m43"
	item_state = "m43"
	fire_sound = 'sound/weapons/guns/fire/tesla.ogg'
	ammo = /datum/ammo/energy/tesla
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_ENERGY|GUN_AMMO_COUNTER
	muzzle_flash_color = COLOR_TESLA_BLUE

	rounds_to_draw = 500
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
	rounds_to_draw = ENERGY_STANDARD_AMMO_COST
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
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	starting_attachment_types = list(/obj/item/attachable/stock/lasgun)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

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
	ammo = /datum/ammo/energy/lasgun/pulsebolt
	muzzleflash_iconstate = "muzzle_flash_pulse"
	rounds_to_draw = ENERGY_STANDARD_AMMO_COST
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
	attachable_allowed = list()
	starting_attachment_types = list(/obj/item/attachable/stock/lasgun/practice)
	muzzle_flash_color = COLOR_DISABLER_BLUE

	damage_falloff_mult = 1
	fire_delay = 0.33 SECONDS
	aim_slowdown = 0.35

/obj/item/weapon/gun/energy/lasgun/M43/practice/do_unique_action(mob/user)
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
	rounds_to_draw = 10
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
	var/rounds_to_draw = 0
	///the ammo datum this mode is.
	var/datum/ammo/ammo = null
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

/obj/item/weapon/gun/energy/lasgun/lasrifle/do_unique_action(mob/user)
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


	rounds_to_draw = initial(choice.rounds_to_draw)
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
	user.hud_used.update_ammo_hud(user, src)

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
	rounds_to_draw = 12
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

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
	rounds_to_draw = 12
	ammo = /datum/ammo/energy/lasgun/marine
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Rifle Standard.ogg'
	message_to_user = "You set the laser rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "ter"


/datum/lasrifle/base/energy_rifle_mode/overcharge
	rounds_to_draw = 30
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
	rounds_to_draw = 20
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
	rounds_to_draw = 20
	ammo = /datum/ammo/energy/lasgun/marine/pistol
	fire_delay = 0.25 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Pistol Standard.ogg'
	message_to_user = "You set the laser pistol's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tep"

/datum/lasrifle/base/energy_pistol_mode/disabler
	rounds_to_draw = 80
	ammo = /datum/ammo/energy/lasgun/marine/pistol/disabler
	fire_delay = 10
	fire_sound = 'sound/weapons/guns/fire/disabler.ogg'
	message_to_user = "You set the laser pistol's charge mode to disabler fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tep"
	radial_icon_state = "laser_disabler"

/datum/lasrifle/base/energy_pistol_mode/heat
	rounds_to_draw = 110
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
	rounds_to_draw = 15
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

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
	rounds_to_draw = 15
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
	rounds_to_draw = 60
	ammo = /datum/ammo/energy/lasgun/marine/blast
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
	force = 20
	icon_state = "tes"
	item_state = "tes"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 12 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine/sniper
	ammo_diff = null
	rounds_to_draw = 50
	damage_falloff_mult = 0
	gun_firemode = GUN_FIREMODE_SEMIAUTO
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/unremovable/laser_sniper_scope,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 18,"rail_x" = 19, "rail_y" = 19, "under_x" = 28, "under_y" = 8, "stock_x" = 22, "stock_y" = 12)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/laser_sniper_scope)

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
	rounds_to_draw = 50
	fire_delay = 1 SECONDS
	ammo = /datum/ammo/energy/lasgun/marine/sniper
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the sniper rifle's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_SEMIAUTO
	icon_state = "tes"

/datum/lasrifle/base/energy_sniper_mode/heat
	rounds_to_draw = 150
	fire_delay = 1 SECONDS
	ammo = /datum/ammo/energy/lasgun/marine/sniper_heat
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
	force = 20
	icon_state = "tem"
	item_state = "tem"
	icon = 'icons/Marine/gun64.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_shots = 150 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/marine/autolaser
	ammo_diff = null
	rounds_to_draw = 4
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

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
	rounds_to_draw = 4
	ammo = /datum/ammo/energy/lasgun/marine/autolaser
	fire_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/Laser Sniper Standard.ogg'
	message_to_user = "You set the machine laser's charge mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	icon_state = "tem"

/datum/lasrifle/base/energy_mg_mode/standard/efficiency
	ammo = /datum/ammo/energy/lasgun/marine/autolaser/efficiency
	fire_delay = 0.15 SECONDS
	rounds_to_draw = 3
	message_to_user = "You set the machine laser's charge mode to efficiency mode."
