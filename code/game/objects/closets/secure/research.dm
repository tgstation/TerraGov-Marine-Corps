/obj/structure/closet/secure_closet/scientist
	name = "Scientist's Locker"
	req_access = list(ACCESS_RESEARCH)
	icon_state = "secureres1"
	icon_closed = "secureres"
	icon_locked = "secureres1"
	icon_opened = "secureresopen"
	icon_broken = "secureresbroken"
	icon_off = "secureresoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/scientist(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/device/pda/science(src)
		new /obj/item/tank/oxygen(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/device/radio/headset/headset_sci(src)



/obj/structure/closet/secure_closet/rd
	name = "Research Director's Locker"
	req_access = list(ACCESS_RD)
	icon_state = "rdsecure1"
	icon_closed = "rdsecure"
	icon_locked = "rdsecure1"
	icon_opened = "rdsecureopen"
	icon_broken = "rdsecurebroken"
	icon_off = "rdsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/rd(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/clipboard(src)
		new /obj/item/tank/air(src)
		new /obj/item/clothing/mask/gas(src)
		new /obj/item/device/flash(src)
		new /obj/item/device/radio/headset/heads/rd(src)
		//