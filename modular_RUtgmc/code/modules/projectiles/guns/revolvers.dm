///////////////////////////////////////////////////////////////////////
//////// Сoltrifle, based on Colt Model 1855 Revolving Rifle. /////////
///////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/revolver/standard_revolver/coltrifle
	name = "\improper M1855 Revolving Rifle"
	desc = "A revolver and carbine hybrid, designed and manufactured a long time ago by Crowford Armory Union. Popular back then, but completely obsolete today. Still used by some antiquity lovers."
	icon = 'modular_RUtgmc/icons/Marine/gun64.dmi'
	icon_state = "coltrifle"
	item_state = "coltrifle"
	fire_animation = "coltrifle_fire"
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	gun_skill_category = SKILL_RIFLES
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	caliber = CALIBER_44LS
	max_chamber_items = 8
	default_ammo_type = /obj/item/ammo_magazine/revolver/rifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/rifle)
	force = 20

	scatter = 3
	recoil = 3
	scatter_unwielded = 10
	recoil_unwielded = 6
	recoil_backtime_multiplier = 2
	recoil_deviation = 360 //real party

	fire_delay = 0.25 SECONDS
	aim_fire_delay = 0.25 SECONDS
	upper_akimbo_accuracy = 6
	lower_akimbo_accuracy = 3
	akimbo_additional_delay = 1
	aim_slowdown = 0.3

	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/reddot,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 21,"rail_x" = 24, "rail_y" = 22)

//////////////////////////////////////////////////////////////////////////
/////////////////////////// t500 revolver ////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/revolver/t500
	name = "\improper R-500 BF revolver"
	desc = "The R-500 BF revolver, chambered in .500 Nigro Express. Hard to use, but hits as hard as it’s kicks your hand. This handgun made by BMSS, designed to be deadly, unholy force to stop everything what moves, so in exchange for it, revolver lacking recoil control and have tight cocking system. Because of its specific, handcanon niche, was produced in small numbers. Black & Metzer special attachments system can turn extremely powerful handgun to fullscale rifle, making it a weapon to surpass Metal Gear."
	icon = 'modular_RUtgmc/icons/Marine/gun64.dmi'
	icon_state = "t500"
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/items_righthand_1.dmi',)
	item_state = "t500"
	caliber =  CALIBER_500 //codex
	max_chamber_items = 5 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/t500
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/t500, /datum/ammo/bullet/revolver/t500/qk)
	force = 20
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/t500stock,
		/obj/item/attachable/t500barrelshort,
		/obj/item/attachable/t500barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lace/t500,
	)
	attachable_offset = list("muzzle_x" = 0, "muzzle_y" = 0,"rail_x" = 0, "rail_y" = 0, "under_x" = 19, "under_y" = 13, "stock_x" = -19, "stock_y" = 0)
	windup_delay = 0.8 SECONDS
	windup_sound = 'modular_RUtgmc/sound/weapons/guns/fire/t500_start.ogg'
	fire_sound = 'modular_RUtgmc/sound/weapons/guns/fire/t500.ogg'
	dry_fire_sound = 'modular_RUtgmc/sound/weapons/guns/fire/t500_empty.ogg'
	fire_animation = "t500_fire"
	fire_delay = 0.8 SECONDS
	akimbo_additional_delay = 0.6
	accuracy_mult_unwielded = 0.9
	accuracy_mult = 1
	scatter_unwielded = 5
	scatter = -1
	recoil = 2
	recoil_unwielded = 3
