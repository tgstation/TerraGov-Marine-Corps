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

/obj/structure/closet/secure_closet/guncabinet/New()
	..()
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




/obj/structure/closet/secure_closet/guncabinet/mp_armory
	req_access = list(ACCESS_MARINE_BRIG)

/obj/structure/closet/secure_closet/guncabinet/mp_armory/New()
	..()
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

/obj/structure/closet/secure_closet/guncabinet/riot_control/New()
	..()
	new /obj/item/weapon/gun/shotgun/pump(src, TRUE)
	new /obj/item/weapon/gun/shotgun/pump(src, TRUE)
	new /obj/item/weapon/gun/shotgun/pump(src, TRUE)
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
