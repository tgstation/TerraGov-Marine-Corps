
/obj/item/weapon/gun/smg
	reload_sound = 'sound/weapons/gun_rifle_reload.ogg' //Could use a unique sound.
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_m39.ogg'
	type_of_casings = "bullet"
	force = 8
	w_class = 4
	movement_acc_penalty_mult = 4
	wield_delay = WIELD_DELAY_FAST
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	gun_skill_category = GUN_SKILL_SMGS

	New()
		..()
		if(current_mag && current_mag.current_rounds > 0) load_into_chamber()

	unique_action(mob/user)
		cock(user)


//-------------------------------------------------------
//M39 SMG

/obj/item/weapon/gun/smg/m39
	name = "\improper M39 submachinegun"
	desc = "Armat Battlefield Systems M-39 submachinegun. Occasionally carried by light-infantry, scouts, engineers or medics. Uses 10x20mm rounds in a 48 round magazine."
	icon_state = "m39"
	item_state = "m39"
	current_mag = /obj/item/ammo_magazine/smg/m39
	type_of_casings = null
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/stock/smg,
						/obj/item/attachable/compensator,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/scope/mini,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER

/obj/item/weapon/gun/smg/m39/New()
	select_gamemode_skin(/obj/item/weapon/gun/smg/m39, list(MAP_ICE_COLONY = "m39b2") )
	..()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 14, "rail_y" = 22, "under_x" = 24, "under_y" = 16, "stock_x" = 24, "stock_y" = 16)

/obj/item/weapon/gun/smg/m39/set_gun_config_values()
	fire_delay = config.low_fire_delay
	burst_delay = config.mlow_fire_delay
	burst_amount = config.med_burst_value
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil_unwielded = config.min_recoil_value





//-------------------------------------------------------

/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B/2 submachinegun"
	desc = "Armat Battlefield Systems M-39 submachinegun, version B2. This reliable weapon fires armor piercing 10x20mm rounds and is used by elite troops."
	icon_state = "m39b2"
	item_state = "m39b2"
	origin_tech = "combat=6;materials=5"
	current_mag = /obj/item/ammo_magazine/smg/m39/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED

/obj/item/weapon/gun/smg/m39/elite/set_gun_config_values()
	fire_delay = config.low_fire_delay
	burst_delay = config.min_fire_delay
	burst_amount = config.high_burst_value
	accuracy_mult = config.base_hit_accuracy_mult + config.med_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.min_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult + config.max_hit_damage_mult
	recoil_unwielded = config.min_recoil_value



//-------------------------------------------------------
//M5, a classic SMG used in a lot of action movies.

/obj/item/weapon/gun/smg/mp5
	name = "\improper MP5 submachinegun"
	desc = "A German design, this was one of the most widely used submachine guns in the world. It's still possible to find this firearm in the hands of collectors or gun fanatics."
	icon_state = "mp5"
	item_state = "mp5"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/smg_light.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp5
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_CAN_POINTBLANK

	New()
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17, "stock_x" = 28, "stock_y" = 17)


/obj/item/weapon/gun/smg/mp5/set_gun_config_values()
	fire_delay = config.mlow_fire_delay
	burst_delay = config.mlow_fire_delay
	burst_amount = config.high_burst_value

	accuracy_mult = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.high_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult + config.med_hit_damage_mult
	recoil_unwielded = config.min_recoil_value


//-------------------------------------------------------
//MP27, based on the MP27, based on the M7.

/obj/item/weapon/gun/smg/mp7
	name = "\improper MP27 submachinegun"
	desc = "An archaic design going back hundreds of years, the MP27 was common in its day. Today it sees limited use as cheap computer-printed replicas or family heirlooms."
	icon_state = "mp7"
	item_state = "mp7"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/smg_light.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp7
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17, "stock_x" = 28, "stock_y" = 17)


/obj/item/weapon/gun/smg/mp7/set_gun_config_values()
	fire_delay = config.med_fire_delay
	burst_delay = config.mlow_fire_delay
	burst_amount = config.high_burst_value

	accuracy_mult = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value + config.low_scatter_value
	scatter_unwielded = config.med_scatter_value + config.high_scatter_value
	damage_mult = config.base_hit_damage_mult + config.high_hit_damage_mult
	recoil_unwielded = config.min_recoil_value

//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/weapon/gun/smg/skorpion
	name = "\improper CZ-81 submachinegun"
	desc = "A robust, 20th century firearm that's a combination of pistol and submachinegun. Fires .32ACP caliber rounds from a 20 round magazine."
	icon_state = "skorpion"
	item_state = "skorpion"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gun_skorpion.ogg'
	current_mag = /obj/item/ammo_magazine/smg/skorpion
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

	New()
		..()
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 22, "under_x" = 23, "under_y" = 15, "stock_x" = 23, "stock_y" = 15)

/obj/item/weapon/gun/smg/skorpion/set_gun_config_values()
	fire_delay = config.low_fire_delay
	burst_delay = config.mlow_fire_delay
	burst_amount = config.med_burst_value

	accuracy_mult = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.max_scatter_value
	damage_mult = config.base_hit_damage_mult + config.hmed_hit_damage_mult
	recoil_unwielded = config.min_recoil_value


/obj/item/weapon/gun/smg/skorpion/upp
	icon_state = "skorpion_u"
	item_state = "skorpion_u"

//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b submachinegun"
	desc = "An unauthorized copy of a replica of a prototype submachinegun developed in a third world shit hole somewhere."
	icon_state = "ppsh17b"
	item_state = "ppsh17b"
	origin_tech = "combat=3;materials=2;syndicate=4"
	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/ppsh
	flags_gun_features = GUN_CAN_POINTBLANK

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 26, "under_y" = 15, "stock_x" = 26, "stock_y" = 15)


/obj/item/weapon/gun/smg/ppsh/set_gun_config_values()
	fire_delay = config.mhigh_fire_delay
	burst_delay = config.min_fire_delay
	burst_amount = config.med_burst_value

	accuracy_mult = config.base_hit_accuracy_mult - config.min_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.min_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value + config.low_scatter_value
	scatter_unwielded = config.max_scatter_value + config.low_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil_unwielded = config.min_recoil_value



//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/weapon/gun/smg/uzi
	name = "\improper MAC-15 submachinegun"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age. Turn on burst mode for maximum firepower."
	icon_state = "mac15"
	item_state = "mac15"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/uzi.ogg'
	current_mag = /obj/item/ammo_magazine/smg/uzi
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

	New()
		..()
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 22, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)


/obj/item/weapon/gun/smg/uzi/set_gun_config_values()
	fire_delay = config.med_fire_delay
	burst_delay = config.min_fire_delay
	burst_amount = config.high_burst_value

	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value + config.med_scatter_value
	scatter_unwielded = config.med_scatter_value + config.med_scatter_value + config.max_scatter_value
	damage_mult = config.base_hit_damage_mult - config.min_hit_damage_mult
	recoil_unwielded = config.min_recoil_value


//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/weapon/gun/smg/p90
	name = "\improper FN FP9000 Submachinegun"
	desc = "An archaic design, but one that's stood the test of time. Fires fast armor piercing rounds."
	icon_state = "FP9000"
	item_state = "FP9000"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_p90.ogg'
	current_mag = /obj/item/ammo_magazine/smg/p90

	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/scope)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 20, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16)


/obj/item/weapon/gun/smg/p90/set_gun_config_values()
	fire_delay = config.high_fire_delay
	burst_delay = config.mlow_fire_delay
	burst_amount = config.med_burst_value

	accuracy_mult = config.base_hit_accuracy_mult + config.high_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult + config.high_hit_accuracy_mult - config.hmed_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value + config.max_scatter_value
	damage_mult = config.base_hit_damage_mult + config.low_hit_damage_mult
	recoil_unwielded = config.min_recoil_value

//-------------------------------------------------------
