//-------------------------------------------------------

/obj/item/weapon/gun/rifle
	reload_sound = 'sound/weapons/rifle_reload.ogg'
	cocked_sound = 'sound/weapons/rifle_cocked.ogg'
	origin_tech = "combat=4;materials=3"
	flags_equip_slot = SLOT_BACK
	w_class = 4
	force = 15
	flags_atom = FPRINT|CONDUCT|TWOHANDED
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	aim_slowdown = SLOWDOWN_ADS_SHOTGUN

	New()
		..()
		burst_amount = config.med_burst_value
		burst_delay = config.mlow_fire_delay
		if(current_mag && current_mag.current_rounds > 0) load_into_chamber()

	unique_action(mob/user)
		cock(user)

//-------------------------------------------------------
//M41A PULSE RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle
	name = "\improper M41A magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = "10×24mm"
	icon_state = "m41a"
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/m41a

/obj/item/ammo_magazine/rifle/extended
	name = "\improper M41A extended magazine (10x24mm)"
	desc = "A 10mm assault extended rifle magazine."
	max_rounds = 60
	bonus_overlay = "m41a_ex"

/obj/item/ammo_magazine/rifle/incendiary
	name = "\improper M41A incendiary magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	default_ammo = /datum/ammo/bullet/rifle/incendiary

/obj/item/ammo_magazine/rifle/ap
	name = "\improper M41A AP magazine (10x24mm)"
	desc = "A 10mm armor piercing magazine."
	default_ammo = /datum/ammo/bullet/rifle/ap

//-------------------------------------------------------
//M41A PULSE RIFLE

/obj/item/weapon/gun/rifle/m41a
	name = "\improper M41A pulse rifle MK2"
	desc = "The standard issue rifle of the Colonial Marines. Commonly carried by most combat personnel. Uses 10x24mm caseless ammunition."
	icon_state = "m41a"
	item_state = "m41a"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	current_mag = /obj/item/ammo_magazine/rifle
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/foregrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/stock/rifle,
						/obj/item/attachable/grenade,
						/obj/item/attachable/flamer,
						/obj/item/attachable/shotgun,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

	New()
		select_gamemode_skin(/obj/item/weapon/gun/rifle/m41a)
		..()
		fire_delay = config.med_fire_delay
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
		var/obj/item/attachable/grenade/G = new(src)
		G.Attach(src)
		update_attachable(G.slot)

//-------------------------------------------------------
//M41A MARKSMAN VARIANT

/obj/item/ammo_magazine/rifle/marksman
	name = "\improper M41A marksman magazine (10x24mm)"
	desc = "This special magazine is designed for use with the M41A/M and will not fit the standard M41A MK2 rifle."
	default_ammo = /datum/ammo/bullet/rifle/marksman
	gun_type = /obj/item/weapon/gun/rifle/m41a/scoped

/obj/item/weapon/gun/rifle/m41a/scoped
	name = "\improper M41A/M marksman rifle"
	desc = "An advanced prototype pulse rifle based on the tried and true M41A Pulse Rifle MK2.\nIt is equipped with rail scope and can take the 10x24mm marksman magazine in addition to regular MK2 magazines."
	icon_state = "m41b"
	item_state = "m41a" //PLACEHOLDER
	origin_tech = "combat=5;materials=4"
	current_mag = /obj/item/ammo_magazine/rifle/marksman
	force = 16
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/foregrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/bipod,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly)

	New()
		..()
		accuracy += config.med_hit_accuracy_mult
		recoil = config.min_recoil_value
		fire_delay = config.high_fire_delay
		burst_amount = config.min_burst_value
		var/obj/item/attachable/scope/S = new(src)
		S.icon_state = null //Rifle already has a nice looking scope sprite.
		S.flags_attach_features &= ~ATTACH_REMOVABLE //Don't want it coming off.
		S.Attach(src)
		var/obj/item/attachable/stock/rifle/marksman/Q = new(src)
		Q.Attach(src)
		var/obj/item/attachable/G = under //We'll need this in a sec.
		G.Detach(src) //This will null the attachment slot.
		cdel(G) //So without a temp variable, this wouldn't work.
		update_attachables()

//-------------------------------------------------------
//M41A PMC VARIANT

/obj/item/weapon/gun/rifle/m41a/elite
	name = "\improper M41A/2 battle rifle"
	desc = "A reinforced and remachined version of the tried and tested M41A Pulse Rifle MK2. Given only to elite units."
	icon_state = "m41a2"
	item_state = "m41a2"
	origin_tech = "combat=7;materials=5"
	current_mag = /obj/item/ammo_magazine/rifle/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED

	New()
		..()
		accuracy += config.max_hit_accuracy_mult
		damage += config.max_hit_damage_mult

//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/ammo_magazine/rifle/m41aMK1
	name = "\improper M41AMK1 magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the original M41A Pulse Rifle."
	max_rounds = 95
	gun_type = /obj/item/weapon/gun/rifle/m41aMK1

/obj/item/weapon/gun/rifle/m41aMK1
	name = "\improper M41A pulse rifle"
	desc = "An older design of the Pulse Rifle commonly used by Colonial Marines. Uses 10x24mm caseless ammunition."
	icon_state = "m41amk1" //Placeholder.
	item_state = "m41amk1" //Placeholder.
	fire_sound = 'sound/weapons/m41a_2.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/grenade,
						/obj/item/attachable/flamer,
						/obj/item/attachable/shotgun)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

	New()
		..()
		accuracy -= config.min_hit_accuracy_mult
		damage += config.min_hit_damage_mult
		burst_amount = config.high_burst_value
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

//-------------------------------------------------------
//MAR-40 AK CLONE //AK47 and FN FAL together as one.

/obj/item/ammo_magazine/rifle/mar40
	name = "\improper MAR magazine (7.62x39mm)"
	desc = "A 7.62×39mm magazine for the MAR series of firearms."
	caliber = "7.62×39mm"
	icon_state = "mar40"
	default_ammo = /datum/ammo/bullet/rifle/mar40
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/mar40

/obj/item/ammo_magazine/rifle/mar40/extended
	name = "\improper MAR extended magazine (7.62x39mm)"
	desc = "A 7.62×39mm MAR magazine, this one carries more rounds than the average magazine."
	max_rounds = 60
	bonus_overlay = "mar40_ex"

/obj/item/weapon/gun/rifle/mar40
	name = "\improper MAR-40 battle rifle"
	desc = "A cheap, reliable assault rifle chambered in 7.62×39mm. Commonly found in the hands of criminals or mercenaries, or in the hands of the UPP or Iron Bears."
	icon_state = "mar40"
	item_state = "mar40"
	origin_tech = "combat=4;materials=2;syndicate=4"
	fire_sound = 'sound/weapons/heavyrifle.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/mar40
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/stock/slavic,
						/obj/item/attachable/grenade,
						/obj/item/attachable/flamer,
						/obj/item/attachable/shotgun,
						/obj/item/attachable/scope/slavic)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS|GUN_ON_RUSSIANS

	New()
		..()
		accuracy -= config.low_hit_accuracy_mult
		burst_amount = config.high_burst_value
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)

/obj/item/weapon/gun/rifle/mar40/carbine
	name = "\improper MAR-30 battle carbine"
	desc = "A cheap, reliable assault rifle chambered in 7.62×39mm. Commonly found in the hands of criminals or mercenaries. This is the carbine variant."
	icon_state = "mar30"
	item_state = "mar30"
	fire_sound = 'sound/weapons/gunshot_ak47.ogg' //Change

	New()
		..()
		accuracy += config.min_hit_accuracy_mult
		fire_delay = config.high_fire_delay

//-------------------------------------------------------
//M16 RIFLE

/obj/item/ammo_magazine/rifle/m16
	name = "\improper M16 magazine (5.56x45mm)"
	desc = "A 5.56×45mm magazine for the M16 assault rifle."
	caliber = "5.56×45mm"
	icon_state = "mar40" //PLACEHOLDER
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 20 //Also comes in 30 and 100 round Beta-C mag.
	gun_type = /obj/item/weapon/gun/rifle/m16

/obj/item/weapon/gun/rifle/m16
	name = "\improper M16 rifle"
	desc = "An old, reliable design first adopted by the U.S. military in the 1960s. Something like this belongs in a museum of war history. It is chambered in 5.56×45mm."
	icon_state = "m16"
	item_state = "m16"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/heavyrifle.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m16
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/foregrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/grenade,
						/obj/item/attachable/flamer,
						/obj/item/attachable/shotgun
						)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ON_MERCS|GUN_ON_RUSSIANS

	New()
		..()
		accuracy += config.min_hit_accuracy_mult
		damage += config.min_hit_damage_mult
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 22, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 13)

//-------------------------------------------------------
//M41AE2 HEAVY PULSE RIFLE

/obj/item/ammo_magazine/rifle/lmg
	name = "\improper M41AE2 ammo box (10x24mm)"
	desc = "A semi-rectangular box of rounds for the M41AE2 Heavy Pulse Rifle."
	icon_state = "m41ae2"
	max_rounds = 100 //Should be a 300 box.
	gun_type = /obj/item/weapon/gun/rifle/lmg

/obj/item/weapon/gun/rifle/lmg
	name = "\improper M41AE2 heavy pulse rifle"
	desc = "A large weapon capable of laying down supressing fire. Currently undergoing field testing among USCM scout platoons and in mercenary companies. Like it's smaller brother, the M41A MK2, the M41AE2 is chambered in 10mm."
	icon_state = "m41ae2"
	item_state = "m41ae2"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gunshot_rifle.ogg' //Change
	current_mag = /obj/item/ammo_magazine/rifle/lmg
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/foregrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/compensator,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ON_MERCS

	New()
		..()
		accuracy -= config.low_hit_accuracy_mult
		fire_delay = config.high_fire_delay
		burst_amount = config.high_burst_value
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 24, "under_x" = 24, "under_y" = 12, "stock_x" = 24, "stock_y" = 12)

//-------------------------------------------------------

