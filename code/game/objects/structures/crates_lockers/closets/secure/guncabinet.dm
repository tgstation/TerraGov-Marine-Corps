/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access_txt = "0"
	icon = 'icons/obj/structures/misc.dmi'
	icon_state = "base"
	icon_off ="base"
	icon_broken ="base"
	icon_locked ="base"
	icon_closed ="base"
	icon_opened = "base"

/obj/structure/closet/secure_closet/guncabinet/Initialize()
	. = ..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/toggle()
	..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/update_icon()
	overlays.Cut()
	if(opened)
		overlays += icon(icon,"door_open")
	else
		overlays += icon(src.icon,"door")

		if(broken)
			overlays += icon(src.icon,"broken")
		else if (locked)
			overlays += icon(src.icon,"locked")
		else
			overlays += icon(src.icon,"open")


/obj/structure/closet/secure_closet/guncabinet/canterbury
	req_access = list(ACCESS_MARINE_BRIDGE)


/obj/structure/closet/secure_closet/guncabinet/canterbury/PopulateContents()
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/clothing/suit/storage/marine/smartgunner/fancy(src)
	new /obj/item/weapon/gun/smartgun(src)
	new /obj/item/smartgun_powerpack/fancy(src)
	new /obj/item/weapon/gun/flamer(src)
	new /obj/item/ammo_magazine/flamer_tank(src)
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/weapon/gun/smg/standard_smg(src)
	new /obj/item/weapon/gun/pistol/m4a3(src)

	var/list/to_spawn = list(
		/obj/item/ammo_magazine/shotgun/buckshot = 3,
		/obj/item/clothing/suit/armor/bulletproof = 4,
		/obj/item/ammo_magazine/pistol/ap = 2,
	)
	for(var/typepath in to_spawn)
		for(var/i in 1 to to_spawn[typepath])
			new typepath(src)


/obj/structure/closet/secure_closet/guncabinet/nt_lab/PopulateContents()
	new /obj/item/weapon/gun/smg/m39/elite(src)


/obj/structure/closet/secure_closet/guncabinet/pmc_m39/PopulateContents()
	new /obj/item/storage/pouch/magazine/large/pmc_m39(src)
	new /obj/item/weapon/gun/smg/standard_smg(src)


/obj/structure/closet/secure_closet/guncabinet/lmg/PopulateContents()
	new /obj/item/weapon/gun/rifle/standard_lmg(src)
	new /obj/item/ammo_magazine/standard_lmg(src)
	new /obj/item/weapon/gun/rifle/standard_lmg(src)
	new /obj/item/ammo_magazine/standard_lmg(src)


/obj/structure/closet/secure_closet/guncabinet/m57a4/PopulateContents()
	new /obj/item/weapon/gun/launcher/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/weapon/gun/launcher/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)


/obj/structure/closet/secure_closet/guncabinet/explosives/PopulateContents()
	new /obj/item/storage/box/nade_box/HIDP(src)
	new /obj/item/storage/box/nade_box/M15(src)
	new /obj/item/storage/box/nade_box/impact(src)
	new /obj/item/storage/box/explosive_mines(src)


/obj/structure/closet/secure_closet/guncabinet/spec_boxes/PopulateContents()
	new /obj/item/storage/box/spec/demolitionist(src)
	new /obj/item/storage/box/spec/heavy_grenadier(src)
	new /obj/item/storage/box/spec/heavy_gunner(src)
	new /obj/item/storage/box/spec/pyro(src)
	new /obj/item/storage/box/spec/scout(src)
	new /obj/item/storage/box/spec/scoutshotgun(src)
	new /obj/item/storage/box/spec/sniper(src)
	new /obj/item/storage/box/spec/tracker(src)


/obj/structure/closet/secure_closet/guncabinet/highpower/PopulateContents()
	new /obj/item/weapon/gun/pistol/highpower(src)
	new /obj/item/ammo_magazine/pistol/highpower(src)


/obj/structure/closet/secure_closet/guncabinet/incendiary
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/structure/closet/secure_closet/guncabinet/incendiary/PopulateContents()
	new /obj/item/weapon/gun/flamer(src)
	new /obj/item/explosive/grenade/incendiary(src)


/obj/structure/closet/secure_closet/guncabinet/m41aMK1/PopulateContents()
	new /obj/item/weapon/gun/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/weapon/gun/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)
	new /obj/item/ammo_magazine/rifle/standard_assaultrifle(src)


/obj/structure/closet/secure_closet/guncabinet/mp_armory
	req_access = list(ACCESS_MARINE_BRIG)

/obj/structure/closet/secure_closet/guncabinet/mp_armory/PopulateContents()
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/weapon/gun/shotgun/combat(src)
	new /obj/item/ammo_magazine/shotgun(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)
	new /obj/item/ammo_magazine/shotgun/buckshot(src)



/obj/structure/closet/secure_closet/guncabinet/riot_control
	name = "riot control equipment closet"
	req_access = list(ACCESS_MARINE_BRIG)
	storage_capacity = 55 //lots of stuff to fit in

/obj/structure/closet/secure_closet/guncabinet/riot_control/PopulateContents()
	new /obj/item/weapon/gun/shotgun/pump(src, TRUE)
	new /obj/item/weapon/gun/shotgun/pump(src, TRUE)
	new /obj/item/weapon/gun/shotgun/pump(src, TRUE)
	new /obj/item/weapon/shield/riot(src)
	new /obj/item/weapon/shield/riot(src)
	new /obj/item/weapon/shield/riot(src)
	new /obj/item/weapon/shield/riot(src)
	new /obj/item/ammo_magazine/shotgun/beanbag(src)
	new /obj/item/ammo_magazine/shotgun/beanbag(src)
	new /obj/item/ammo_magazine/shotgun/beanbag(src)
	new /obj/item/ammo_magazine/shotgun/beanbag(src)
	new /obj/item/weapon/gun/launcher/m81/riot(src, TRUE)
	new /obj/item/storage/box/nade_box/tear_gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/head/helmet/riot(src)
	new /obj/item/clothing/head/helmet/riot(src)
	new /obj/item/clothing/head/helmet/riot(src)
	new /obj/item/clothing/suit/armor/riot/marine(src)
	new /obj/item/clothing/suit/armor/riot/marine(src)
	new /obj/item/clothing/suit/armor/riot/marine(src)
	new /obj/item/storage/box/flashbangs(src)
