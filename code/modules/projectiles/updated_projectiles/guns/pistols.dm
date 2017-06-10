//Base pistol and revolver for inheritance/
//--------------------------------------------------

/obj/item/weapon/gun/pistol
	icon_state = "" //Defaults to revolver pistol when there's no sprite.
	reload_sound = 'sound/weapons/flipblade.ogg'
	cocked_sound = 'sound/weapons/gun_pistol_cocked.ogg'
	origin_tech = "combat=3;materials=2"
	matter = list("metal" = 65000)
	flags_equip_slot = SLOT_WAIST
	w_class = 3
	force = 6
	fire_sound = 'sound/weapons/gun_servicepistol.ogg'
	type_of_casings = "bullet"
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK //For easy reference.

	New()
		..()
		if(current_mag && current_mag.current_rounds > 0) load_into_chamber()

	unique_action(mob/user)
		cock(user)

//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol
	name = "\improper M4A3 magazine (9mm)"
	caliber = "9mm"
	icon_state = "m4a3"
	max_rounds = 12
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/m4a3

/obj/item/ammo_magazine/pistol/hp
	name = "\improper M4A3 hollowpoint magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/hollow

/obj/item/ammo_magazine/pistol/ap
	name = "\improper M4A3 AP magazine (9mm)"
	icon_state = "m4a3_AP"
	default_ammo = /datum/ammo/bullet/pistol/ap

/obj/item/ammo_magazine/pistol/incendiary
	name = "\improper M4A3 incendiary magazine (9mm)"
	icon_state = "m4a3_incendiary"
	default_ammo = /datum/ammo/bullet/pistol/incendiary

/obj/item/ammo_magazine/pistol/extended
	name = "\improper M4A3 extended magazine (9mm)"
	max_rounds = 22
	icon_state = "m4a3" //PLACEHOLDER
	bonus_overlay = "m4a3_ex"

/obj/item/weapon/gun/pistol/m4a3
	name = "\improper M4A3 service pistol"
	desc = "An M4A3 Colt Service Pistol, the standard issue sidearm of the Colonial Marines. Uses 9mm pistol rounds."
	icon_state = "m4a3"
	item_state = "m4a3"
	current_mag = /obj/item/ammo_magazine/pistol

	New()
		select_gamemode_skin(/obj/item/weapon/gun/pistol/m4a3)
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

/obj/item/weapon/gun/pistol/m4a3/custom
	name = "\improper M4A3 custom pistol"
	desc = "An M4A3 Service Pistol, the standard issue sidearm of the Colonial Marines. Uses 9mm pistol rounds. This one is crested with an elephant-tusk ivory grip and has a slide carefully polished by a team of orphan children. Looks important."
	icon_state = "m4a3c"
	item_state = "m4a3c"

	New()
		..()
		damage += config.low_hit_damage_mult
		fire_delay = config.high_fire_delay

//-------------------------------------------------------
//M4A3 45 //Inspired by the 1911

/obj/item/ammo_magazine/pistol/m1911
	name = "\improper M4A3 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".45"
	icon_state = "m4a345"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/m1911

/obj/item/weapon/gun/pistol/m1911
	name = "\improper M4A3 service pistol (.45)"
	desc = "A standard M4A3 chambered in .45. Has a smaller magazine capacity, but packs a better punch."
	icon_state = "m4a345"
	item_state = "m4a3"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gun_glock.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/m1911
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS|GUN_ON_RUSSIANS

	New()
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

//-------------------------------------------------------
//Beretta 92FS, the gun McClane carries around in Die Hard. Very similar to the service pistol, all around.

/obj/item/ammo_magazine/pistol/b92fs
	name = "\improper Beretta 92FS magazine (9mm)"
	caliber = "9mm"
	icon_state = "m4a3"
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/b92fs

/obj/item/weapon/gun/pistol/b92fs
	name = "\improper Beretta 92FS pistol"
	desc = "A popular police firearm in the 20th century, often employed by hardboiled cops while confronting terrorists. A classic of its time, chambered in 9mm."
	icon_state = "b92fs"
	item_state = "b92fs"
	current_mag = /obj/item/ammo_magazine/pistol/b92fs


	New()
		..()
		fire_delay = config.high_fire_delay
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17, "stock_x" = 21, "stock_y" = 17)

//-------------------------------------------------------
//DEAGLE //This one is obvious.

/obj/item/ammo_magazine/pistol/heavy
	name = "\improper Desert Eagle magazine (.50)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".50"
	icon_state = "m4a345" //PLACEHOLDER
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/heavy

//Captain's vintage pistol.
/obj/item/weapon/gun/pistol/heavy
	name = "\improper vintage Desert Eagle"
	desc = "A bulky 50 caliber pistol with a serious kick, probably taken from some museum somewhere. This one is engraved, 'Peace through superior firepower.'"
	icon_state = "deagle"
	item_state = "deagle"
	fire_sound = 'sound/weapons/gun_44mag.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/heavy
	force = 13

	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/compensator)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS

	New()
		..() //Pick some variant sprites.
		damage += config.med_hit_damage_mult
		recoil = config.low_recoil_value
		fire_delay = config.low_fire_delay*3
		var/skin = pick("","g_","c_")
		icon_state = skin + icon_state
		item_state = skin + item_state
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 23, "under_x" = 20, "under_y" = 17, "stock_x" = 20, "stock_y" = 17)

//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/ammo_magazine/pistol/c99t
	name = "\improper PK-9 magazine (.22 tranq)"
	default_ammo = /datum/ammo/bullet/pistol/tranq
	caliber = ".22"
	icon_state = "pk-9_tranq"
	max_rounds = 8
	gun_type = /obj/item/weapon/gun/pistol/c99

/obj/item/ammo_magazine/pistol/c99
	name = "\improper PK-9 magazine (.22 hollowpoint)"
	default_ammo = /datum/ammo/bullet/pistol/hollow
	caliber = ".22"
	icon_state = "pk-9"
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/pistol/c99



/obj/item/weapon/gun/pistol/c99
	name = "\improper Korovin PK-9 pistol"
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Commonly found among mercenary companies due to its reliability, but also issued to UPP armed forces. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is usually loaded with the more common .22 hollowpoint rounds and appears to be a mercenary version.."
	icon_state = "pk9"
	item_state = "pk9"
	origin_tech = "combat=3;materials=1;syndicate=3"
	fire_sound = 'sound/weapons/gun_c99.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/c99
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS

	New()//Making the gun have an invisible silencer since it's supposed to have one.
		..()
		fire_delay = config.high_fire_delay
		accuracy += config.high_hit_accuracy_mult
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18, "stock_x" = 21, "stock_y" = 18)
		var/obj/item/attachable/suppressor/S = new(src)
		S.icon_state = ""
		S.flags_attach_features &= ~ATTACH_REMOVABLE
		S.Attach(src)
		update_attachable(S.slot)

/obj/item/weapon/gun/pistol/c99/russian
	icon_state = "pk9r"
	item_state = "pk9r"
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS

/obj/item/weapon/gun/pistol/c99/upp
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Commonly found among mercenary companies due to its reliability, but also issued to UPP armed forces. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is usually loaded with the more common .22 hollowpoint rounds and appears to be a UPP model."
	icon_state = "pk9u"
	item_state = "pk9u"
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

/obj/item/weapon/gun/pistol/c99/upp/tranq
	desc = "An updated variant of an old eastern design, dating back to from the 20th century. Commonly found among mercenary companies due to its reliability, but also issued to UPP armed forces. Features an integrated silencer, and chambered in the razor small .22 rounds. This one is usually loaded with special low-recoil .22 dart rounds, which act as a dangerous tranquilizer."
	desc = "This one is usually loaded with special low-recoil .22 dart rounds, which act as a dangerous tranquilizer."
	current_mag = /obj/item/ammo_magazine/pistol/c99t

//-------------------------------------------------------
//KT-42 //Inspired by the .44 Auto Mag pistol

/obj/item/ammo_magazine/pistol/automatic
	name = "\improper KT-42 magazine (.44)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".32"
	icon_state = "kt42"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/kt42

/obj/item/weapon/gun/pistol/kt42
	name = "\improper KT-42 automag"
	desc = "The KT-42 Automag is an archaic but reliable design, going back many decades. There have been many versions and variations, but the 42 is by far the most common. You can't go wrong with this handcannon."
	icon_state = "kt42"
	item_state = "kt42"
	fire_sound = 'sound/weapons/gun_kt42.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/automatic
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS

	New()
		..()
		recoil = config.min_recoil_value
		fire_delay = config.high_fire_delay*2
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 17)

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "tiny pistol magazine (.22)"
	desc = "A surprisingly small magazine, holding .22 bullets. No Kolibri, but it's getting there."
	default_ammo = /datum/ammo/bullet/pistol/tiny
	caliber = ".22"
	icon_state = "m4a3" //PLACEHOLDER
	max_rounds = 5
	gun_type = /obj/item/weapon/gun/pistol/holdout

/obj/item/weapon/gun/pistol/holdout
	name = "holdout pistol"
	desc = "A tiny pistol meant for hiding in hard-to-reach areas. Best not ask where it came from."
	icon_state = "holdout"
	item_state = "holdout"
	origin_tech = "combat=2;materials=1"
	fire_sound = 'sound/weapons/gun_pistol_holdout.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/holdout
	w_class = 1
	force = 2
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/quickfire,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS

	New()
		..()
		fire_delay = config.mlow_fire_delay
		attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 17, "under_y" = 15, "stock_x" = 22, "stock_y" = 17)

//-------------------------------------------------------
//.45 MARSHALS PISTOL //Inspired by the Browning Hipower

/obj/item/ammo_magazine/pistol/highpower
	name = "\improper Highpower magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = "9mm"
	icon_state = "m4a3" //PLACEHOLDER
	max_rounds = 13
	gun_type = /obj/item/weapon/gun/pistol/highpower

/obj/item/weapon/gun/pistol/highpower
	name = "\improper Highpower automag"
	desc = "A Colonial Marshals issued, powerful semi-automatic pistol chambered in armor piercing 9mm caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	icon_state = "highpower"
	item_state = "highpower"
	fire_sound = 'sound/weapons/gun_kt42.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/highpower
	force = 10
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ON_MERCS

	New()
		..()
		damage += config.low_hit_damage_mult
		recoil = config.min_recoil_value
		attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 16, "under_y" = 15, "stock_x" = 16, "stock_y" = 15)

//-------------------------------------------------------
//VP70 //Not actually the VP70, but it's more or less the same thing. VP70 was the standard sidearm in Aliens though.

/obj/item/ammo_magazine/pistol/vp70
	name = "\improper 88M4 AP magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = "9mm"
	icon_state = "88m4"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp70

/obj/item/weapon/gun/pistol/vp70
	name = "\improper 88 Mod 4 combat pistol"
	desc = "A powerful sidearm issed mainly to Weyland Yutani response teams, but issued to the USCM in small numbers, based on the original vp70 more than a century ago. Fires 9mm armor piercing rounds and is capable of 3-round burst."
	icon_state = "88m4"
	item_state = "88m4"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/vp70.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/vp70
	force = 8

	New()
		..()
		damage += config.high_hit_damage_mult
		burst_amount = config.med_burst_value
		burst_delay = config.low_fire_delay
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 21, "stock_y" = 16)

//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = "\improper VP78 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = "9mm"
	icon_state = "88m4" //PLACEHOLDER
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp78

/obj/item/weapon/gun/pistol/vp78
	name = "\improper VP78 pistol"
	desc = "A massive, formidable automatic handgun chambered in 9mm squash-head rounds. Commonly seen in the hands of wealthy Weyland Yutani members."
	icon_state = "vp78"
	item_state = "vp78"
	origin_tech = "combat=4;materials=4"
	fire_sound = 'sound/weapons/gun_pistol_large.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/vp78
	force = 8

	New()
		..()
		fire_delay = config.low_fire_delay*3
		burst_amount = config.med_burst_value
		burst_delay = config.low_fire_delay
		recoil = config.min_recoil_value
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 24, "under_x" = 23, "under_y" = 13, "stock_x" = 23, "stock_y" = 13)

//-------------------------------------------------------
/*
Auto 9 The gun RoboCop uses. A better version of the VP78, with more rounds per magazine. Probably the best pistol around, but takes no attachments.
It is a modified Beretta 93R, and can fire three round burst or single fire. Whether or not anyone else aside RoboCop can use it is not established.
*/

/obj/item/ammo_magazine/pistol/auto9
	name = "\improper Auto-9 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = "9mm"
	icon_state = "88m4" //PLACEHOLDER
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/pistol/auto9

/obj/item/weapon/gun/pistol/auto9
	name = "\improper Auto-9 pistol"
	desc = "An advanced, select-fire machine pistol capable of three round burst. Last seen cleaning up the mean streets of Detroit."
	icon_state = "auto9"
	item_state = "auto9"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/gun_pistol_large.ogg'
	current_mag = /obj/item/ammo_magazine/pistol/auto9
	force = 15
	attachable_allowed = list()

	New()
		..()
		fire_delay = config.med_fire_delay
		burst_amount = config.med_burst_value
		burst_delay = config.min_fire_delay
		recoil = config.min_recoil_value
