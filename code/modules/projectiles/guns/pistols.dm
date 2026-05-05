//Base pistol for inheritance/
//--------------------------------------------------

/obj/item/weapon/gun/pistol
	icon = 'icons/obj/items/guns/pistols.dmi'
	icon_state = "" //Defaults to revolver pistol when there's no sprite.
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/guns/pistols_left_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/guns/pistols_right_1.dmi',
	)
	fire_sound = 'sound/weapons/guns/fire/pistol.ogg'
	unload_sound = 'sound/weapons/guns/interact/pistol_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/pistol_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/pistol_cocked.ogg'
	load_method = MAGAZINE //codex
	equip_slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	force = 6
	movement_acc_penalty_mult = 2
	wield_delay = 0.4 SECONDS
	type_of_casings = "bullet"
	gun_skill_category = SKILL_PISTOLS
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/gyro,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	actions_types = list(/datum/action/item_action/aim_mode) // all pistols can aim mode
	aim_speed_modifier = 0.65
	scatter = -2
	scatter_unwielded = 4
	akimbo_additional_delay = 0.9
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	placed_overlay_iconstate = "pistol"

//-------------------------------------------------------
//P-14 PISTOL

/obj/item/weapon/gun/pistol/standard_pistol
	name = "\improper P-14 pistol"
	desc = "The P-14, produced by Terran Armories. A reliable sidearm that loads 9x19mm Parabellum Auto munitions. Capable of mounting a limited amount of attachments, and firing at a respectable rate of fire, often as fast as you can pull the trigger. Takes 21-round 9mm magazines."
	icon_state = "tp14"
	worn_icon_state = "tp14"
	caliber = CALIBER_9X19 //codex
	max_shells = 21 //codex
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_p14.ogg'
	reload_sound = 'sound/weapons/guns/interact/tp14_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/standard_pistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/standard_pistol)

	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 25, "under_y" = 14, "stock_x" = 21, "stock_y" = 17)

	fire_delay = 0.15 SECONDS
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.95
	scatter_unwielded = 4
	recoil = -2
	recoil_unwielded = -2
	akimbo_scatter_mod = 8

/obj/item/weapon/gun/pistol/standard_pistol/standard
	starting_attachment_types = list(/obj/item/attachable/lace, /obj/item/attachable/reddot, /obj/item/attachable/lasersight)

//-------------------------------------------------------
//PP-7 Plasma Pistol
/obj/item/weapon/gun/pistol/plasma_pistol
	name = "\improper PP-7 plasma pistol"
	desc = "An experimental weapon designed to set the terrain and targets on fire. It hums with power as magnetic fields coil round each other."
	icon_state = "tx7"
	worn_icon_state = "tx7"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/guns/energy_left_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/guns/energy_right_1.dmi',
	)
	caliber = CALIBER_PLASMA
	max_shots = 10
	icon = 'icons/obj/items/guns/energy.dmi'
	reload_sound = 'sound/weapons/guns/interact/tp14_reload.ogg'
	fire_sound = 'sound/weapons/guns/fire/laser3.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/plasma_pistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/plasma_pistol)
	type_of_casings = null
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 13, "rail_y" = 21, "under_x" = 19, "under_y" = 13, "stock_x" = 21, "stock_y" = 17)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/scope/marine,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
	)

	muzzleflash_iconstate = "muzzle_flash_laser"
	gun_features_flags = GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER|GUN_IS_ATTACHMENT|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	actions_types = list()
	wield_delay = 0.7 SECONDS
	muzzle_flash_color = COLOR_GREEN

	fire_delay = 1.5 SECONDS
	scatter_unwielded = 2
	recoil = -2
	recoil_unwielded = -2

	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	pixel_shift_x = 10
	pixel_shift_y = 19

	wield_delay_mod = 0.2 SECONDS

	placed_overlay_iconstate = "tx7"

/obj/item/weapon/gun/pistol/plasma_pistol/beginner
	starting_attachment_types = list(/obj/item/weapon/gun/shotgun/combat/masterkey, /obj/item/attachable/reddot, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/pistol/plasma_pistol/can_attach(obj/item/attaching_to, mob/attacher)
	if(!attachments_by_slot[ATTACHMENT_SLOT_RAIL])
		return TRUE
	to_chat(attacher, span_warning("You cannot attach [src] to [attaching_to] while [attachments_by_slot[ATTACHMENT_SLOT_RAIL]] occupies [src]'s rail slot."))
	return FALSE

/obj/item/weapon/gun/pistol/plasma_pistol/on_attach(obj/item/attached_to, mob/user)
	gun_features_flags |= (GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY)
	return ..()

/obj/item/weapon/gun/pistol/plasma_pistol/on_detach(obj/item/attached_to, mob/user)
	gun_features_flags &= ~(GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY)
	return ..()

/obj/item/weapon/gun/pistol/plasma_pistol/guardsman_pistol
	name = "\improper Guardsman\'s plasma pistol"
	desc = "FOR THE EMPEROR!"
	icon_state = "tx7w"
	worn_icon_state = "tx7"

//-------------------------------------------------------
//RT-3 pistol

/obj/item/weapon/gun/pistol/rt3
	name = "\improper RT-3 target pistol"
	desc = "An RT-3 target pistol, a common sight throughout the bubble. Fires 9mm in magazines."
	icon_state = "rt3"
	worn_icon_state = "rt3"
	caliber = CALIBER_9X19 //codex
	max_shells = 14 //codex
	fire_sound = 'sound/weapons/guns/fire/pistol_service.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/pistol/hp,
		/obj/item/ammo_magazine/pistol/ap,
		/obj/item/ammo_magazine/pistol/incendiary,
		/obj/item/ammo_magazine/pistol/extended,
	)

	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 19,"rail_x" = 19, "rail_y" = 21, "under_x" = 21, "under_y" = 15, "stock_x" = 21, "stock_y" = 17)

	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.15

//-------------------------------------------------------
// P-23 service pistol

/obj/item/weapon/gun/pistol/standard_heavypistol
	name = "\improper P-23 service pistol"
	desc = "A standard P-23 chambered in .45 ACP. Has a smaller magazine capacity, but packs a better punch. Has an irremovable laser sight. Uses .45 magazines."
	icon_state = "tp23"
	worn_icon_state = "tp23"
	caliber = CALIBER_45ACP //codex
	max_shells = 14 //codex
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_p23.ogg'
	unload_sound = 'sound/weapons/guns/interact/colt_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/colt_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/colt_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/standard_heavypistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/standard_heavypistol)
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 22,"rail_x" = 13, "rail_y" = 24, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.20 //Has a forced laser sight.
	accuracy_mult_unwielded = 0.95
	recoil = -2
	recoil_unwielded = -2

/obj/item/weapon/gun/pistol/standard_heavypistol/suppressed
	starting_attachment_types = list(/obj/item/attachable/suppressor, /obj/item/attachable/flashlight) //Tacticool

/obj/item/weapon/gun/pistol/standard_heavypistol/tacticool
	starting_attachment_types = list(/obj/item/attachable/lace, /obj/item/attachable/flashlight) //Tacticool

/obj/item/weapon/gun/pistol/standard_heavypistol/tactical
	starting_attachment_types = list(/obj/item/attachable/reddot)

/obj/item/weapon/gun/pistol/standard_heavypistol/beginner
	starting_attachment_types = list(/obj/item/attachable/lace, /obj/item/attachable/reddot)

//-------------------------------------------------------
//P-1911

/obj/item/weapon/gun/pistol/m1911
	name = "\improper P-1911 service pistol"
	desc = "A P-1911 chambered in .45 ACP. An archaic weapon, yet its popular and extremely reliable mechanism provided a template for many semi-automatic pistols to come."
	icon_state = "m1911"
	worn_icon_state = "m1911"
	caliber = CALIBER_45ACP //codex
	max_shells = 10 //codex
	fire_sound = 'sound/weapons/guns/fire/colt.ogg'
	unload_sound = 'sound/weapons/guns/interact/colt_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/colt_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/colt_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/m1911
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/m1911)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 17, "rail_y" = 22, "under_x" = 21, "under_y" = 15, "stock_x" = 21, "stock_y" = 17)
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT_LOCKED
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.05
	accuracy_mult_unwielded = 0.85
	damage_mult = 1.15
	recoil = -2

/obj/item/weapon/gun/pistol/m1911/custom
	name = "\improper P-1911A1 custom pistol"
	desc = "A handgun that has received several modifications. It seems to have been lovingly taken care of and passed down for generations. Lacks an auto magazine eject feature."
	icon_state = "m1911c"
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
	)
	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	fire_delay = 0.15 SECONDS
	damage_mult = 1.3

//-------------------------------------------------------
//P-22. Blocc

/obj/item/weapon/gun/pistol/g22
	name = "\improper P-22 pistol"
	desc = "A popular police firearm in the modern day. Chambered in 9x19mm."
	icon_state = "g22"
	worn_icon_state = "g22"
	caliber = CALIBER_9X19 //codex
	max_shells = 15 //codex
	fire_sound = 'sound/weapons/guns/fire/beretta.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/beretta_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/beretta_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/beretta_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/beretta_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/g22
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/g22, /obj/item/ammo_magazine/pistol/g22tranq)
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)
	burst_amount = 3
	accuracy_mult = 1.15
	scatter_unwielded = 0
	aim_slowdown = 0.2
	fire_delay = 0.2 SECONDS

/obj/item/weapon/gun/pistol/g22/tranq
	name = "\improper P-22 custom pistol"
	desc = "A 20th century military firearm customized for special forces use, fires tranq darts to take down enemies nonlethally. It does not seem to accept any other attachments."
	icon_state = "g22"
	worn_icon_state = "g22"
	caliber = CALIBER_9X19_TRANQUILIZER //codex
	max_shells = 12 //codex
	default_ammo_type = /obj/item/ammo_magazine/pistol/g22tranq
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 21, "under_x" = 21, "under_y" = 15, "stock_x" = 21, "stock_y" = 17)
	starting_attachment_types = list(
		/obj/item/attachable/lasersight,
		/obj/item/attachable/suppressor,
	)

	fire_delay = 0.6 SECONDS
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 1.15
	damage_mult = 0.5


//-------------------------------------------------------
//DEAGLE //Deagle Brand Deagle

/obj/item/weapon/gun/pistol/heavy
	name = "\improper Desert Eagle pistol"
	desc = "A magnum chambered in .50AE that comes with a serious kick. This one is engraved, <i>\"Peace through superior firepower\"</i>."
	icon_state = "deagle"
	worn_icon_state = "deagle"
	caliber = CALIBER_50AE //codex
	max_shells = 7 //codex
	fire_sound = 'sound/weapons/guns/fire/deagle.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/deagle_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/deagle_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/deagle_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/deagle_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/heavy
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/heavy)
	force = 13
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 19,"rail_x" = 9, "rail_y" = 23, "under_x" = 22, "under_y" = 14, "stock_x" = 20, "stock_y" = 17)

	fire_delay = 0.45 SECONDS
	scatter_unwielded = 25
	recoil = 1
	recoil_unwielded = 2
	scatter = 2
	scatter_unwielded = 7
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.7
	damage_mult = 1.15

/obj/item/weapon/gun/pistol/heavy/gold
	name = "\improper Desert Eagle custom pistol"
	desc = "A magnum chambered in .50AE that comes with a serious kick. This one is in a gold finish, with lots of stylistic engravings."
	icon_state = "g_deagle"
	worn_icon_state = "g_deagle"
	damage_mult = 1.25

//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/weapon/gun/pistol/c99
	name = "\improper Korovin PK-9 pistol"
	desc = "An updated variant of an old handgun design, Features an integrated silencer, and chambered in the razor small .22 rounds. This one is loaded with the more common .22 hollowpoint rounds and appears to be a mercenary version."
	icon_state = "pk9"
	worn_icon_state = "pk9"
	caliber = CALIBER_22LR //codex
	max_shells = 12 //codex
	fire_sound = 'sound/weapons/guns/fire/pistol_holdout.ogg' // Never heard in-game sadly.
	unload_sound = 'sound/weapons/guns/interact/c99_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/c99_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/c99_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/c99
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/c99, /obj/item/ammo_magazine/pistol/c99t)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/suppressor/unremovable/invisible,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18)
	//Making the gun have an invisible silencer since it's supposed to have one.
	starting_attachment_types = list(/obj/item/attachable/suppressor/unremovable/invisible)

	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.3
	scatter_unwielded = 2
	damage_mult = 1.3
	aim_slowdown = 0.1

/obj/item/weapon/gun/pistol/c99/tranq
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is usually loaded with special low-recoil .22 dart rounds, which act as a dangerous tranquilizer."
	default_ammo_type = /obj/item/ammo_magazine/pistol/c99t

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/weapon/gun/pistol/holdout
	name = "holdout pistol"
	desc = "A tiny pistol meant for hiding in hard-to-reach areas. Best not ask where it came from."
	icon_state = "holdout"
	worn_icon_state = "holdout"
	caliber = CALIBER_22LR //codex
	max_shells = 5 //codex
	fire_sound = 'sound/weapons/guns/fire/pistol_holdout.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/holdout
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/holdout)
	w_class = WEIGHT_CLASS_TINY
	force = 2
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lace,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 17, "under_y" = 15, "stock_x" = 22, "stock_y" = 17)

	fire_delay = 0.15 SECONDS

//-------------------------------------------------------
//P-17 Pocket pistol. Based on a PMM.

/obj/item/weapon/gun/pistol/standard_pocketpistol
	name = "\improper P-17 pocket pistol"
	desc = "A tiny pistol used by the TGMC as an emergency handgun meant to be stored about anywhere. Fits in boots. Uses .380 ACP stored in an eight round magazine."
	icon_state = "tp17"
	worn_icon_state = "tp17"
	fire_animation = "tp17_fire"
	caliber = CALIBER_380ACP //codex
	max_shells = 8 //codex
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_p17.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/standard_pocketpistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/standard_pocketpistol)
	w_class = WEIGHT_CLASS_TINY
	force = 5
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/lace,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 17, "under_y" = 15, "stock_x" = 22, "stock_y" = 17)

	fire_delay = 0.15 SECONDS
	recoil = -2
	recoil_unwielded = -2
	scatter_unwielded = 0
	aim_speed_modifier = 0


//-------------------------------------------------------
// Browning Hipower

/obj/item/weapon/gun/pistol/highpower
	name = "\improper Highpower automag"
	desc = "A powerful semi-automatic pistol chambered in the devastating .50 AE caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	icon_state = "highpower"
	worn_icon_state = "highpower"
	caliber = CALIBER_50AE //codex
	max_shells = 13 //codex
	fire_sound = 'sound/weapons/guns/fire/hp.ogg'
	unload_sound = 'sound/weapons/guns/interact/hp_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/hp_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/hp_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/highpower
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/highpower)
	force = 10

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 18, "under_y" = 15, "stock_x" = 16, "stock_y" = 15)

	fire_delay = 0.45 SECONDS
	burst_delay = 0.5 SECONDS
	damage_mult = 1.1
	recoil = 1
	recoil_unwielded = 2
	accuracy_mult_unwielded = 0.6
	scatter = 3
	scatter_unwielded = 7

/obj/item/weapon/gun/pistol/highpower/standard
	starting_attachment_types = list(/obj/item/attachable/lace, /obj/item/attachable/reddot, /obj/item/attachable/gyro)

//-------------------------------------------------------
//VP70

/obj/item/weapon/gun/pistol/vp70
	name = "\improper MK88 Mod 4 combat pistol"
	desc = "An uncommon automatic handgun used for self defense, based on the original VP70 more than a century ago. Fires 9mm armor piercing rounds and is capable of 3-round burst or automatic fire."
	icon_state = "88m4"
	worn_icon_state = "88m4"
	caliber = CALIBER_9X19 //codex
	max_shells = 18 //codex
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_88mod4.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/vp70_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/vp70_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/vp70_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/vp70
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/vp70)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lace,
	)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 19, "rail_y" = 24, "under_x" = 24, "under_y" = 16, "stock_x" = 11, "stock_y" = 10)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.1 SECONDS
	burst_amount = 3
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.95
	recoil = 0
	aim_slowdown = 0.2
	scatter = 0
	scatter_unwielded = 6
	akimbo_additional_delay = 2

/obj/item/weapon/gun/pistol/vp70/tactical
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight, /obj/item/attachable/compensator)

/obj/item/weapon/gun/pistol/vp70/beginner
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight, /obj/item/attachable/lace)

//-------------------------------------------------------
//VP78

/obj/item/weapon/gun/pistol/vp78
	name = "\improper VP78 combat pistol"
	desc = "A massive, formidable automatic handgun chambered in 9mm squash-head rounds. Commonly seen in the hands of wealthy Nanotrasen members."
	icon_state = "vp78"
	worn_icon_state = "vp78"
	caliber = CALIBER_9X19 //codex
	max_shells = 18 //codex
	fire_sound = 'sound/weapons/guns/fire/pistol_large.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/vp70_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/vp70_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/vp70_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/vp78
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/vp78)
	force = 8
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 23, "under_x" = 23, "under_y" = 13, "stock_x" = 23, "stock_y" = 13)

	fire_delay = 0.3 SECONDS
	burst_amount = 3
	burst_delay = 0.2 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.85
	recoil_unwielded = 3

/obj/item/weapon/gun/pistol/vp78/pmc
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/gyro, /obj/item/attachable/compensator)

//-------------------------------------------------------
//MK90M4, standard PMC pistol

/obj/item/weapon/gun/pistol/mk90
	name = "\improper MK90 Mod 4 combat pistol"
	desc = "Standard issue pistol for Nanotrasen Contractors, based on MK88. Has inbuilt barrel charger. Lost it's inbuilt burst fire mode, but in exchange got much heavier punch. Fires 9mm armor piercing rounds."
	icon_state = "90m4"
	worn_icon_state = "90m4"
	caliber = CALIBER_9X19 //codex
	max_shells = 20 //codex
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_88mod4.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/vp70_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/vp70_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/vp70_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/mk90
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/mk90, /obj/item/ammo_magazine/pistol/mk90/extended)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/gyro,
		/obj/item/attachable/lace,
	)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 22,"rail_x" = 10, "rail_y" = 23, "under_x" = 21, "under_y" = 16, "stock_x" = 11, "stock_y" = 10)

	fire_delay = 0.2 SECONDS
	burst_amount = 1
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.95
	recoil = 0
	aim_slowdown = 0.2
	scatter = 0
	scatter_unwielded = 5
	akimbo_additional_delay = 2
	damage_mult = 1.25
	shell_speed_mod = 2
	damage_falloff_mult = 0.8

/obj/item/weapon/gun/pistol/mk90/pmc_standard
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight)

/obj/item/weapon/gun/pistol/mk90/pmc_sniper
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/burstfire_assembly, /obj/item/attachable/lace)
	default_ammo_type = /obj/item/ammo_magazine/pistol/mk90/extended

//-------------------------------------------------------
//MK100M5, PMC heavy gyrojet pistol

/obj/item/weapon/gun/pistol/mk100_gyrojet
	name = "\improper MK100 mod 5 'Suppresor' gyrojet pistol"
	desc = "A massive, formidable automatic handgun chambered with 15x50mm rocket propelled rounds. Commonly seen in the hands of wealthy Nanotrasen members, not because this weapon is expensive, but because you better have a power armor on, to not break your arm while firing this thing. Due to shell's rupture in target's body, high chance of causing shrapnel."
	icon_state = "100m5"
	worn_icon_state = "100m5"
	caliber = CALIBER_15X50 //codex
	max_shells = 10 //codex
	fire_sound = 'sound/weapons/guns/fire/svd.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/deagle_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m4ra_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m4ra_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/mk100_gyrojet
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/mk100_gyrojet)
	force = 12
	attachable_allowed = list(,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 23, "under_x" = 23, "under_y" = 13, "stock_x" = 23, "stock_y" = 13)

	fire_delay = 0.45 SECONDS
	burst_amount = 3
	burst_delay = 0.2 SECONDS
	extra_delay = 0.25 SECONDS
	accuracy_mult = 1.15
	accuracy_mult_unwielded = 0.75
	recoil = 2
	recoil_unwielded = 4

/obj/item/weapon/gun/pistol/mk100_gyrojet/pmc_leader

	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/lasersight)

//-------------------------------------------------------
//SOM pistol

/obj/item/weapon/gun/pistol/som
	name = "\improper V-11 pistol"
	desc = "The standard sidearm used by the Sons of Mars. A reliable and simple weapon that is often seen on the export market on the outer colonies. Typically chambered in 9mm armor piercing rounds."
	icon_state = "v11"
	worn_icon_state = "v11"
	caliber = CALIBER_9X19
	max_shells = 18
	fire_sound = 'sound/weapons/guns/fire/vp70.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/vp70_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/vp70_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/vp70_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/som
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/som, /obj/item/ammo_magazine/pistol/som/incendiary, /obj/item/ammo_magazine/pistol/som/extended)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lace,
	)

	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 6, "rail_y" = 23, "under_x" = 24, "under_y" = 15, "stock_x" = 11, "stock_y" = 10)

	fire_delay = 0.15 SECONDS
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.95
	recoil = -2
	aim_slowdown = 0.1
	scatter = -1
	scatter_unwielded = 4

/obj/item/weapon/gun/pistol/som/standard
	starting_attachment_types = list(
		/obj/item/attachable/lasersight,
		/obj/item/attachable/reddot,
	)

/obj/item/weapon/gun/pistol/som/burst
	default_ammo_type = /obj/item/ammo_magazine/pistol/som/extended
	starting_attachment_types = list(
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/reddot,
		/obj/item/attachable/lace,
	)
//-------------------------------------------------------
//C96 based on P96

/obj/item/weapon/gun/pistol/vsd_pistol
	name = "\improper C96 pistol"
	desc = "A 'riot control' weapon used by the protectors of colonies. Now adopted by the V.S.D, it is the standard side arm for all members. Firing armor piercing 9x19mm parabellum with a capacity of 15 rounds."
	icon_state = "c96"
	worn_icon_state = "c96"
	caliber = CALIBER_9X19
	max_shells = 15
	fire_sound = 'sound/weapons/guns/fire/tp23.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/vp70_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/uzi_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/uzi_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/vp70_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/vsd_pistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/vsd_pistol)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/compensator,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 21,"rail_x" = 2, "rail_y" = 23, "under_x" = 22, "under_y" = 15, "stock_x" = 23, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.0
	accuracy_mult_unwielded = 0.75
	recoil = -2
	aim_slowdown = 0.1
	scatter = -1
	scatter_unwielded = 4

/obj/item/weapon/gun/pistol/vsd_pistol/standard
	starting_attachment_types = list(/obj/item/attachable/reddot,/obj/item/attachable/compensator,/obj/item/attachable/lasersight,)

/obj/item/weapon/gun/pistol/xmdivider
	name = "\improper CC/104 'Divider' Revolver"
	desc = "Intertech's one of a kind revolver. Fires custom incendiary .357 rounds, has firemode switch of single action and burst fire. Kicks like a fucking mule. You remember High Command saying: 'Don't let this get into enemy hands'."
	icon = 'icons/obj/items/guns/pistols.dmi'
	icon_state = "c104"
	worn_icon_state = "c104"
	caliber = CALIBER_357 //codex
	max_shells = 6
	default_ammo_type = /obj/item/ammo_magazine/pistol/xmdivider
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/xmdivider)
	force = 8
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20, "rail_x" = 17, "rail_y" = 22, "under_x" = 29, "under_y" = 15, "stock_x" = 10, "stock_y" = 18)
	windup_delay = 0.5 SECONDS
	aim_slowdown = 0.1
	burst_amount = 3
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE)
	windup_sound = 'sound/weapons/guns/fire/t76_start.ogg'
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_r76.ogg'
	fire_delay = 0.75 SECONDS
	akimbo_additional_delay = 0.6
	accuracy_mult_unwielded = 0.85
	accuracy_mult = 1
	scatter_unwielded = 5
	scatter = 2
	recoil = 4
	recoil_unwielded = 3

/obj/item/weapon/gun/pistol/xmdivider/gunslinger
	starting_attachment_types = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
	)

//-------------------------------------------------------
/*
Auto 9 The gun RoboCop uses. A better version of the VP78, with more rounds per magazine. Probably the best pistol around, but takes no attachments.
It is a modified Beretta 93R, and can fire three round burst or single fire. Whether or not anyone else aside RoboCop can use it is not established.
*/

/obj/item/weapon/gun/pistol/auto9
	name = "\improper Auto-9 pistol"
	desc = "An advanced, select-fire machine pistol capable of three round burst. Last seen cleaning up the mean streets of Detroit."
	icon_state = "auto9"
	worn_icon_state = "auto9"
	caliber = CALIBER_9X19 //codex
	max_shells = 50 //codex
	fire_sound = 'sound/weapons/guns/fire/beretta.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/auto9
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/auto9)
	force = 15
	attachable_allowed = list()
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST)


	fire_delay = 0.1 SECONDS
	burst_amount = 3
	recoil_unwielded = 3

//-------------------------------------------------------
// PL-5 ICC Duty Pistol

/obj/item/weapon/gun/pistol/icc_dpistol
	name = "\improper PL-5B2 duty pistol"
	desc = "The PL-5 is a true and tested ICCAF handgun, used for a very long time with minimal changes to the core design, best used at close quarters with its higher than usual magazine size for its caliber. It is chambered in .45 ACP."
	icon_state = "pl5"
	worn_icon_state = "pl5"
	icon = 'icons/obj/items/guns/pistols64.dmi'
	caliber = CALIBER_45ACP //codex
	max_shells = 18 //codex
	fire_sound = 'sound/weapons/guns/fire/colt.ogg'
	unload_sound = 'sound/weapons/guns/interact/colt_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/colt_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/colt_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/icc_dpistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/icc_dpistol)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 17, "rail_y" = 22, "under_x" = 21, "under_y" = 15, "stock_x" = 21, "stock_y" = 17)
	reciever_flags = AMMO_RECIEVER_MAGAZINES
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.1
	accuracy_mult_unwielded = 0.75
	damage_falloff_mult = 1.25
	recoil = -2
	recoil_unwielded = -1

//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.

/obj/item/weapon/gun/pistol/chimp
	name = "\improper CHIMP70 pistol"
	desc = "A powerful sidearm issued mainly to highly trained elite assassin necro-cyber-agents."
	icon_state = "c70"
	worn_icon_state = "c70"

	caliber = CALIBER_70MANKEY //codex
	max_shells = 300 //codex
	default_ammo_type = /obj/item/ammo_magazine/pistol/chimp
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/chimp)
	fire_sound = 'sound/weapons/guns/fire/chimp70.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	force = 8
	type_of_casings = null
	gun_skill_category = SKILL_PISTOLS
	attachable_allowed = list()
	gun_features_flags = GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES

	fire_delay = 0.3 SECONDS
	burst_delay = 0.2 SECONDS
	burst_amount = 2


/obj/item/weapon/gun/pistol/knife
	name = "\improper M6 'Eclipse Raider' ballistic knife"
	desc = "The back issue survival knife issued to a few TerraGov Marine Corps marines. There are a surprisingly large amount of attachment points on this... knife."
	icon = 'icons/obj/items/weapons/knives.dmi'
	icon_state = "elite_knife"
	reload_sound = 'sound/weapons/flipblade.ogg'
	cocked_sound = 'sound/weapons/guns/interact/pistol_cocked.ogg'
	caliber = CALIBER_ALIEN
	equip_slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	force = 30
	movement_acc_penalty_mult = 3
	aim_slowdown = -0.2
	wield_delay = 1 SECONDS // This is how long a knife takes to pull out in CS.
	fire_sound = 'sound/weapons/guns/fire/pistol_service.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/knife
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/knife)
	type_of_casings = "bullet"
	gun_skill_category = SKILL_PISTOLS
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 14,"rail_x" = 9, "rail_y" = 17, "under_x" = 23, "under_y" = 11, "stock_x" = 23, "stock_y" = 10)
	attachable_allowed = list(
		/obj/item/attachable/quickfire,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)

// Smart pistol, based on the MP-9.
/obj/item/weapon/gun/pistol/smart_pistol
	name = "\improper SP-13 smart machinepistol"
	desc = "The SP-13 is a IFF-capable sidearm used by the TerraGov Marine Corps. Cutting edge advancements in cost cutting allows for anyone to use this pistol without training due to the simplified KTLD system used at the cost of the barrel muzzle device. Uses 9mm."
	icon_state = "sp13"
	worn_icon_state = "sp13"
	caliber = CALIBER_9X19 //codex
	max_shells = 40 //codex
	fire_sound = 'sound/weapons/guns/fire/tp14.ogg'
	reload_sound = 'sound/weapons/guns/interact/tp14_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight,
	)

	gun_features_flags = GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	actions_types = list() // Inherits aimmode, but has IFF so..
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_SEMIAUTO)

	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 20,"rail_x" = 13, "rail_y" = 23, "under_x" = 19, "under_y" = 13, "stock_x" = 21, "stock_y" = 17)

	aim_slowdown = 0.35
	wield_delay = 0.65 SECONDS
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.2
	accuracy_mult_unwielded = 0.85
	damage_falloff_mult = 0.75
	scatter = 0
	scatter_unwielded = 8
	recoil_unwielded = 2

/obj/item/weapon/gun/pistol/smart_pistol/pmc
	starting_attachment_types = list(
		/obj/item/attachable/reddot,
	)
