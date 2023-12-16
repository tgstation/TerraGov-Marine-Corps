/obj/item/weapon/gun/shotgun
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	caliber = CALIBER_12G //codex
	max_chamber_items = 8 //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_shell_insert.ogg'
	hand_reload_sound = 'sound/weapons/guns/interact/shotgun_shell_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/shotgun_reload.ogg'
	opened_sound = 'sound/weapons/guns/interact/shotgun_open.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_HANDFULS
	type_of_casings = "shell"
	allowed_ammo_types = list()
	aim_slowdown = 0.35
	wield_delay = 0.6 SECONDS //Shotguns are really easy to put up to fire, since they are designed for CQC (at least compared to a rifle)
	gun_skill_category = SKILL_SHOTGUNS
	flags_item_map_variant = NONE

	fire_delay = 6
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.75
	scatter = 4
	scatter_unwielded = 10
	recoil = 2
	recoil_unwielded = 4
	movement_acc_penalty_mult = 2
	lower_akimbo_accuracy = 3
	upper_akimbo_accuracy = 5

	placed_overlay_iconstate = "shotgun"


//-------------------------------------------------------
//TACTICAL SHOTGUN

/obj/item/weapon/gun/shotgun/combat
	name = "\improper SH-221 tactical shotgun"
	desc = "The Nanotrasen SH-221 Shotgun, a quick-firing semi-automatic shotgun based on the centuries old Benelli M4 shotgun. Only issued to the TGMC in small numbers."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "mk221"
	item_state = "mk221"
	fire_sound = 'sound/weapons/guns/fire/shotgun_automatic.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	max_chamber_items = 9
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/weapon/gun/grenade_launcher/underslung/invisible,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 14, "stock_y" = 16)
	starting_attachment_types = list(/obj/item/weapon/gun/grenade_launcher/underslung/invisible)

	fire_delay = 15 //one shot every 1.5 seconds.
	accuracy_mult_unwielded = 0.5 //you need to wield this gun for any kind of accuracy
	scatter_unwielded = 10
	damage_mult = 0.75  //normalizing gun for vendors; damage reduced by 25% to compensate for faster fire rate; still higher DPS than T-32.
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.4


//-------------------------------------------------------
//SH-39 semi automatic shotgun. Used by marines.

/obj/item/weapon/gun/shotgun/combat/standardmarine
	name = "\improper SH-39 combat shotgun"
	desc = "The Terran Armories SH-39 combat shotgun is a semi automatic shotgun used by breachers and pointmen within the TGMC squads. Uses 12 gauge shells."
	force = 20 //Has a stock already
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t39"
	item_state = "t39"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sh39.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/stock/t39stock,
	)

	attachable_offset = list("muzzle_x" = 41, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 20, "under_x" = 23, "under_y" = 12, "stock_x" = 13, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/stock/t39stock)

	fire_delay = 14 //one shot every 1.4 seconds.
	accuracy_mult = 1.05
	accuracy_mult_unwielded = 0.65
	scatter = 3
	scatter_unwielded = 12
	damage_mult = 0.7  //30% less damage. Faster firerate.
	recoil = 2
	recoil_unwielded = 4
	wield_delay = 0.8 SECONDS
	akimbo_additional_delay = 0.9

/obj/item/weapon/gun/shotgun/combat/masterkey
	name = "masterkey shotgun"
	desc = "A weapon-mounted, three-shot shotgun. Reloadable with any normal 12 gauge shell. The short barrel reduces the ammo's effectiveness drastically in exchange for fitting as a attachment.."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "masterkey"
	max_chamber_items = 2
	attachable_allowed = list()
	starting_attachment_types = list()
	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	flags_gun_features = GUN_IS_ATTACHMENT|GUN_AMMO_COUNTER|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_CAN_POINTBLANK|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	damage_mult = 0.6 // 40% less damage, but MUCH higher falloff.
	scatter = 3
	fire_delay = 20 // Base shotgun fire delay.
	pixel_shift_x = 14
	pixel_shift_y = 18

	wield_delay_mod = 0.2 SECONDS

//-------------------------------------------------------
//DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double
	name = "double barrel shotgun"
	desc = "A double barreled over and under shotgun of archaic, but sturdy design. Uses 12 gauge shells, but can only hold 2 at a time."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "dshotgun"
	item_state = "dshotgun"
	max_chamber_items = 2 //codex
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sh34.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_db_insert.ogg'
	cocked_sound = null //We don't want this.
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight/under,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_TOGGLES_OPEN|AMMO_RECIEVER_TOGGLES_OPEN_EJECTS|AMMO_RECIEVER_HANDFULS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 21,"rail_x" = 15, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 21, "stock_y" = 16)

	fire_delay = 2
	burst_delay = 2
	scatter = 4
	scatter_unwielded = 8
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.6

/obj/item/weapon/gun/shotgun/double/sawn
	name = "sawn-off shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range for further CQC potiential."
	icon_state = "sshotgun"
	item_state = "sshotgun"
	flags_equip_slot = ITEM_SLOT_BELT
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES|GUN_WIELDED_FIRING_ONLY
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 18, "under_y" = 16, "stock_x" = 18, "stock_y" = 16)

	fire_delay = 2
	accuracy_mult = 0.9
	scatter = 4
	scatter_unwielded = 10
	recoil = 3
	recoil_unwielded = 5

//-------------------------------------------------------
//MARINE DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double/marine
	name = "\improper SH-34 double barrel shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design used by the TGMC. Due to reports of barrel bursting, the abiility to fire both barrels has been disabled. Uses 12 gauge shells, but can only hold 2 at a time."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "ts34"
	item_state = "ts34"
	max_chamber_items = 2 //codex
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sh34.ogg'
	hand_reload_sound = 'sound/weapons/guns/interact/shotgun_db_insert.ogg'
	cocked_sound = null //We don't want this.
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 21, "under_y" = 13, "stock_x" = 13, "stock_y" = 16)

	fire_delay = 0.65 SECONDS
	burst_amount = 1
	scatter = 3
	scatter_unwielded = 10
	recoil = 1
	recoil_unwielded = 4


//-------------------------------------------------------
//PUMP SHOTGUN
//Shotguns in this category will need to be pumped each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper V10 pump shotgun"
	desc = "A classic design, using the outdated shotgun frame. The V10 combines close-range firepower with long term reliability.\n<b>Requires a pump, which is the Unique Action key.</b>"
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "v10"
	item_state = "v10"
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	cocked_sound = 'sound/weapons/guns/interact/shotgun_pump.ogg'
	max_chamber_items = 8
	cock_delay = 1.4 SECONDS

	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_HANDFULS|AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS
	cocked_message = "You rack the pump."
	cock_locked_message = "The pump is locked! Fire it first!"
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 10, "rail_y" = 21, "under_x" = 20, "under_y" = 14, "stock_x" = 20, "stock_y" = 14)

	fire_delay = 20
	scatter_unwielded = 10
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.45

/obj/item/weapon/gun/shotgun/pump/standard
	starting_attachment_types = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet,
	)

//-------------------------------------------------------
//A shotgun, how quaint.
/obj/item/weapon/gun/shotgun/pump/cmb
	name = "\improper SH-12 Paladin pump shotgun"
	desc = "A nine-round pump action shotgun. A shotgun used for hunting, home defence and police work, many versions of it exist and are used by just about anyone."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "pal12"
	item_state = "pal12"
	fire_sound = 'sound/weapons/guns/fire/shotgun_cmb.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_cmb_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/shotgun_cmb_pump.ogg'
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/stock/pal12,
	)
	flags_item_map_variant = NONE
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 19,"rail_x" = 14, "rail_y" = 19, "under_x" = 37, "under_y" = 16, "stock_x" = 15, "stock_y" = 14)
	starting_attachment_types = list(
		/obj/item/attachable/stock/pal12,
	)

	fire_delay = 15
	damage_mult = 0.75
	accuracy_mult = 1.25
	accuracy_mult_unwielded = 1
	scatter_unwielded = 10
	recoil = 0 // It has a stock. It's on the sprite.
	recoil_unwielded = 0
	cock_delay = 12
	aim_slowdown = 0.4

/obj/item/weapon/gun/shotgun/pump/cmb/mag_harness
	starting_attachment_types = list(
		/obj/item/attachable/stock/pal12,
		/obj/item/attachable/magnetic_harness,
	)

//-------------------------------------------------------
//A shotgun, how quaint.
/obj/item/weapon/gun/shotgun/pump/trenchgun
	name = "\improper L-4034 trenchgun"
	desc = "A six-round pump action shotgun. A shotgun used for hunting, home defence and police work, many versions of it exist and are used by just about anyone."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "trenchgun"
	item_state = "trenchgun"
	fire_sound = 'sound/weapons/guns/fire/trenchgun.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_cmb_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/trenchgun_pump.ogg'
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/stock/trenchgun,
	)
	flags_item_map_variant = NONE
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 37, "under_y" = 16, "stock_x" = 0, "stock_y" = 12)
	starting_attachment_types = list(
		/obj/item/attachable/stock/trenchgun,
	)

	fire_delay = 1.2 SECONDS
	max_chamber_items = 5
	damage_mult = 0.75
	accuracy_mult_unwielded = 1

	scatter = 4
	min_scatter = 4
	scatter_increase = 8
	scatter_decay = 3
	scatter_decay_unwielded = 1

	scatter_unwielded = 10
	recoil = 0 // It has a stock. It's on the sprite.
	recoil_unwielded = 0
	cock_delay = 1.2 SECONDS
	aim_slowdown = 0.55

/obj/item/weapon/gun/shotgun/pump/trenchgun/icc_leader
	starting_attachment_types = list(
		/obj/item/attachable/stock/trenchgun,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/compensator,
	)

//------------------------------------------------------
//A hacky bolt action rifle. in here for the "pump" or bolt working action.

/obj/item/weapon/gun/shotgun/pump/bolt
	name = "\improper Mosin Nagant rifle"
	desc = "A mosin nagant rifle, even just looking at it you can feel the cosmoline already. Commonly known by its slang, \"Moist Nugget\", by downbrained colonists and outlaws."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "mosin"
	item_state = "mosin"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mosin.ogg'
	fire_rattle = 'sound/weapons/guns/fire/tgmc/kinetic/gun_mosin_low.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_762X54 //codex
	load_method = SINGLE_CASING //codex
	max_chamber_items = 4 //codex
	default_ammo_type = /datum/ammo/bullet/sniper/svd
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/boltclip)
	gun_skill_category = SKILL_RIFLES
	cocked_sound = 'sound/weapons/guns/interact/working_the_bolt.ogg'
	cocked_message = "You work the bolt."
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mosin,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/mosin,
		/obj/item/attachable/shoulder_mount,
	)
	flags_item_map_variant = NONE
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 37, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 15, "stock_y" = 12)
	starting_attachment_types = list(
		/obj/item/attachable/scope/mosin,
		/obj/item/attachable/stock/mosin,
	)
	actions_types = list(/datum/action/item_action/aim_mode)
	force = 20
	aim_fire_delay = 0.75 SECONDS
	aim_speed_modifier = 0.8

	fire_delay = 1.75 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.7
	scatter = -1
	scatter_unwielded = 12
	recoil = -3
	recoil_unwielded = 4
	cock_delay = 12
	aim_slowdown = 1
	wield_delay = 1.2 SECONDS
	movement_acc_penalty_mult = 4.5

	placed_overlay_iconstate = "wood"

/obj/item/weapon/gun/shotgun/pump/bolt/unscoped
	starting_attachment_types = list(/obj/item/attachable/stock/mosin)

//***********************************************************
// Martini Henry

/obj/item/weapon/gun/shotgun/double/martini
	name = "\improper Martini Henry lever action rifle"
	desc = "A lever action with room for a single round of .557/440 ball. Perfect for any kind of hunt, be it elephant or xeno with how quick to the draw it is."
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "martini"
	item_state = "martini"
	shell_eject_animation = "martini_flick"
	caliber = CALIBER_557 //codex
	muzzle_flash_lum = 7
	max_chamber_items = 1 //codex
	ammo_datum_type = /datum/ammo/bullet/sniper/martini
	default_ammo_type = /datum/ammo/bullet/sniper/martini
	gun_skill_category = SKILL_RIFLES
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_martinihenry.ogg'
	reload_sound = 'sound/weapons/guns/interact/martini_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/martini_cocked.ogg'
	opened_sound = 'sound/weapons/guns/interact/martini_open.ogg'
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 23,"rail_x" = 17, "rail_y" = 25, "under_x" = 19, "under_y" = 14, "stock_x" = 15, "stock_y" = 12)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_slowdown = 0.35
	aim_time = 0.5 SECONDS


	fire_delay = 1 SECONDS

	scatter = -25
	scatter_unwielded = 20

	recoil = 2
	recoil_unwielded = 4

	aim_slowdown = 1
	wield_delay = 1 SECONDS
	movement_acc_penalty_mult = 5

	placed_overlay_iconstate = "wood"

//***********************************************************
// Derringer

/obj/item/weapon/gun/shotgun/double/derringer
	name = "\improper R-2395 Derringer"
	desc = "The R-2395 Derringer has been a classic for centuries. This latest iteration combines plasma propulsion powder with the classic design to make an assasination weapon that will leave little to chance."
	icon_state = "derringer"
	item_state = "tp17"
	gun_skill_category = SKILL_PISTOLS
	w_class = WEIGHT_CLASS_TINY
	caliber = CALIBER_41RIM //codex
	muzzle_flash_lum = 5
	max_chamber_items = 2 //codex
	ammo_datum_type = /datum/ammo/bullet/pistol/superheavy/derringer
	default_ammo_type = /datum/ammo/bullet/pistol/superheavy/derringer
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	reload_sound = 'sound/weapons/guns/interact/shotgun_db_insert.ogg'
	cocked_sound = 'sound/weapons/guns/interact/martini_cocked.ogg'
	opened_sound = 'sound/weapons/guns/interact/martini_open.ogg'
	attachable_allowed = list()
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES

	fire_delay = 0.2 SECONDS
	scatter = 0
	scatter_unwielded = 0
	recoil = 0
	recoil_unwielded = 0
	aim_slowdown = 0
	wield_delay = 0.1 SECONDS

/obj/item/weapon/gun/shotgun/double/derringer/Initialize(mapload)
	. = ..()
	if(round(rand(1, 10), 1) != 1)
		return
	base_gun_icon = "derringerw"
	update_icon()

//***********************************************************
// Yee Haw it's a cowboy lever action gun!

/obj/item/weapon/gun/shotgun/pump/lever
	name = "lever action rifle"
	desc = "A .44 magnum lever action rifle with side loading port. It has a low fire rate, but it packs quite a punch in hunting."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "mares_leg"
	item_state = "mares_leg"
	fire_sound = 'sound/weapons/guns/fire/leveraction.ogg'//I like how this one sounds.
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_44 //codex
	load_method = SINGLE_CASING //codex
	max_chamber_items = 9 //codex
	default_ammo_type = /datum/ammo/bullet/revolver/tp44
	gun_skill_category = SKILL_RIFLES
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'//good enough for now.
	cocked_message = "You work the lever."
	flags_item_map_variant = NONE
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/bayonet,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 21,"rail_x" = 8, "rail_y" = 21, "under_x" = 37, "under_y" = 16, "stock_x" = 20, "stock_y" = 14)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES

	fire_delay = 8
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.7
	scatter = 2
	scatter_unwielded = 7
	recoil = 2
	recoil_unwielded = 4
	cock_delay = 6


// ***********************************************
// Leicester Rifle. The gun that won the west.

/obj/item/weapon/gun/shotgun/pump/lever/repeater
	name = "\improper Leicester Repeater"
	desc = "The gun that won the west or so they say. But space is a very different kind of frontier all together, chambered for .45-70 Governemnt."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "leicrepeater"
	item_state = "leicrepeater"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_repeater.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_4570 //codex
	load_method = SINGLE_CASING //codex
	max_chamber_items = 13 //codex
	default_ammo_type = /datum/ammo/bullet/rifle/repeater
	gun_skill_category = SKILL_RIFLES
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'//good enough for now.
	flags_item_map_variant = NONE
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
	)
	attachable_offset = list ("muzzle_x" = 45, "muzzle_y" = 23,"rail_x" = 21, "rail_y" = 23, "under_x" = 19, "under_y" = 14, "stock_x" = 15, "stock_y" = 12)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.3 SECONDS
	aim_speed_modifier = 2

	fire_delay = 10
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.8
	damage_falloff_mult = 0.5
	scatter = -5
	scatter_unwielded = 7
	recoil = 0
	recoil_unwielded = 2
	cock_delay = 2
	aim_slowdown = 0.6
	movement_acc_penalty_mult = 5

//------------------------------------------------------
//MBX900 Lever Action Shotgun
/obj/item/weapon/gun/shotgun/pump/lever/mbx900
	name = "\improper MBX lever action shotgun"
	desc = "A .410 bore lever action shotgun that fires nearly as fast as you can operate the lever. Renowed due to its devastating and extremely reliable design."
	icon_state = "mbx900"
	item_state = "mbx900"
	fire_sound = 'sound/weapons/guns/fire/shotgun_light.ogg'//I like how this one sounds.
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/mosin_reload.ogg'
	caliber = CALIBER_410
	load_method = SINGLE_CASING
	max_chamber_items = 9
	default_ammo_type = /datum/ammo/bullet/shotgun/mbx900_buckshot
	gun_skill_category = SKILL_SHOTGUNS
	cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'

	attachable_allowed = list(
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/gyro,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/reddot,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/verticalgrip,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 19, "under_x" = 27, "under_y" = 16, "stock_x" = 0, "stock_y" = 0)

	flags_item_map_variant = NONE

	fire_delay = 0.6 SECONDS
	accuracy_mult = 1.2
	cock_delay = 0.2 SECONDS

//------------------------------------------------------
//SH-35 Pump shotgun
/obj/item/weapon/gun/shotgun/pump/t35
	name = "\improper SH-35 pump shotgun"
	desc = "The Terran Armories SH-35 is the shotgun used by the TerraGov Marine Corps. It's used as a close quarters tool when someone wants something more suited for close range than most people, or as an odd sidearm on your back for emergencies. Uses 12 gauge shells.\n<b>Requires a pump, which is the Unique Action key.</b>"
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/gun64.dmi'
	icon_state = GUN_ICONSTATE_LOADED
	item_state = GUN_ICONSTATE_LOADED
	cock_animation = GUN_ICONSTATE_PUMP
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_sh35.ogg'
	max_chamber_items = 8
	greyscale_config = /datum/greyscale_config/gun/gun64/shotgun
	colorable_allowed = PRESET_COLORS_ALLOWED
	item_icons = list(
		slot_l_hand_str = /datum/greyscale_config/gun_inhand/t35,
		slot_r_hand_str = /datum/greyscale_config/gun_inhand/r_hand/t35,
		slot_back_str = /datum/greyscale_config/worn_gun/t35,
		slot_s_store_str = /datum/greyscale_config/worn_gun/suit/t35,
	)
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/foldable/t35stock,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	starting_attachment_types = list(/obj/item/attachable/foldable/t35stock)

	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 9, "rail_y" = 21, "under_x" = 18, "under_y" = 12, "stock_x" = -3, "stock_y" = 16)
	flags_item_map_variant = NONE

	fire_delay = 20
	scatter_unwielded = 10
	recoil = 2
	recoil_unwielded = 4
	aim_slowdown = 0.45
	cock_delay = 14

	placed_overlay_iconstate = "t35"

//buckshot variants
/obj/item/weapon/gun/shotgun/pump/t35/pointman
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	starting_attachment_types = list(/obj/item/attachable/foldable/t35stock, /obj/item/attachable/motiondetector, /obj/item/attachable/angledgrip, /obj/item/attachable/bayonet)

/obj/item/weapon/gun/shotgun/pump/t35/standard
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	starting_attachment_types = list(/obj/item/attachable/foldable/t35stock, /obj/item/attachable/angledgrip, /obj/item/attachable/magnetic_harness, /obj/item/attachable/bayonet)

/obj/item/weapon/gun/shotgun/pump/t35/nonstandard
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	starting_attachment_types = list(/obj/item/attachable/foldable/t35stock, /obj/item/attachable/angledgrip, /obj/item/attachable/magnetic_harness)

//-------------------------------------------------------
//THE MYTH, THE GUN, THE LEGEND, THE DEATH, THE ZX

/obj/item/weapon/gun/shotgun/zx76
	name = "\improper ZX-76 assault shotgun"
	desc = "The ZX-76 Assault Shotgun, a incredibly rare, double barreled semi-automatic combat shotgun with a twin shot mode. Possibly the unrivaled master of CQC. Has a 9 round internal magazine."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "zx-76"
	item_state = "zx-76"
	flags_equip_slot = ITEM_SLOT_BACK
	max_chamber_items = 9 //codex
	caliber = CALIBER_12G //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/shotgun_light.ogg'
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	aim_slowdown = 0.45
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/lasersight,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/grenade_launcher/underslung,
	)

	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 23, "under_x" = 29, "under_y" = 12, "stock_x" = 13, "stock_y" = 15)

	fire_delay = 1.75 SECONDS
	damage_mult = 0.9
	wield_delay = 0.75 SECONDS
	burst_amount = 2
	burst_delay = 0.01 SECONDS //basically instantaneous two shots
	extra_delay = 0.5 SECONDS
	scatter = 1
	burst_scatter_mult = 2 // 2x4=8
	accuracy_mult = 1

/obj/item/weapon/gun/shotgun/zx76/standard
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/magnetic_harness, /obj/item/attachable/verticalgrip)

//-------------------------------------------------------
//V-51 SOM shotgun


/obj/item/weapon/gun/shotgun/som
	name = "\improper V-51 combat shotgun"
	desc = "The V-51 is the main shotgun utilised by the Sons of Mars. Slower firing than some other semi automatic shotguns, but packs more of a kick."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "v51"
	icon = 'icons/Marine/gun64.dmi'
	item_state = "v51"
	fire_sound = "shotgun_som"
	dry_fire_sound = 'sound/weapons/guns/fire/v51_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/v51_load.ogg'
	hand_reload_sound = 'sound/weapons/guns/interact/v51_load.ogg'
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	default_ammo_type = /datum/ammo/bullet/shotgun/buckshot
	max_chamber_items = 9
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight/under,
	)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 18,"rail_x" = 26, "rail_y" = 22, "under_x" = 38, "under_y" = 12, "stock_x" = 14, "stock_y" = 16)

	fire_delay = 1.8 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.6
	scatter = 4
	scatter_unwielded = 16
	damage_mult = 0.85
	recoil = 1
	recoil_unwielded = 4
	aim_slowdown = 0.35
	wield_delay = 0.65 SECONDS

/obj/item/weapon/gun/shotgun/som/pointman
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/motiondetector)

/obj/item/weapon/gun/shotgun/som/standard
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/magnetic_harness, /obj/item/attachable/flashlight/under)

/obj/item/weapon/gun/shotgun/som/support
	default_ammo_type = /datum/ammo/bullet/shotgun/flechette
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/shotgun/som/burst
	name = "\improper V-51B assault shotgun"
	desc = "V-51B custom. An upgraded version of the standard SOM shotgun with a burst fire mode and a snazzy paintjob. Rare as it is deadly."
	icon_state = "v51b"
	burst_amount = 2
	burst_delay = 0.5 SECONDS
	extra_delay = -0.2 SECONDS
	damage_mult = 1
	default_ammo_type = /datum/ammo/bullet/shotgun/flechette

/obj/item/weapon/gun/shotgun/som/burst/pointman
	default_ammo_type = /datum/ammo/bullet/shotgun/flechette
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/motiondetector)

/obj/item/weapon/gun/shotgun/som/burst/ert
	default_ammo_type = /datum/ammo/bullet/shotgun/flechette
	starting_attachment_types = list(/obj/item/attachable/bayonet, /obj/item/attachable/magnetic_harness, /obj/item/attachable/flashlight/under)

//-------------------------------------------------------
//Inbuilt launcher for the V-31
/obj/item/weapon/gun/shotgun/micro_grenade
	name = "\improper VA-61 micro rail launcher"
	desc = "An in-built railgun designed to fire so called 'micro grenades'. By using railgun technology, the projectile does not need any propellant, helping greatly increase usable space for the payload."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "va61"
	fire_sound = 'sound/weapons/guns/fire/pred_plasma_shot.ogg'
	max_chamber_items = 2
	flags_gun_features = GUN_IS_ATTACHMENT|GUN_AMMO_COUNTER|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY
	flags_attach_features = NONE
	slot = ATTACHMENT_SLOT_STOCK
	default_ammo_type = /datum/ammo/bullet/micro_rail/airburst
	caliber = CALIBER_10G_RAIL
	type_of_casings = null

	fire_delay = 1.5 SECONDS
	accuracy_mult = 1.1
	scatter = 0
	recoil = 1
