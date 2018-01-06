/obj/structure/closet/secure_closet/captains
	name = "Captain's Locker"
	req_access = list(ACCESS_MARINE_COMMANDER)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/storage/backpack/captain(src)
		else
			new /obj/item/storage/backpack/satchel/cap(src)
		new /obj/item/clothing/suit/captunic(src)
		new /obj/item/clothing/suit/captunic/capjacket(src)
		new /obj/item/clothing/head/helmet/cap(src)
		new /obj/item/clothing/under/rank/captain(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/cartridge/captain(src)
		new /obj/item/clothing/head/helmet/swat(src)
		new /obj/item/clothing/shoes/brown(src)
//		new /obj/item/device/radio/headset/heads/captain(src)
		new /obj/item/clothing/gloves/captain(src)
//		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/clothing/suit/armor/captain(src)
		new /obj/item/weapon/telebaton(src)
		new /obj/item/clothing/under/dress/dress_cap(src)
		new /obj/item/clothing/head/helmet/formalcaptain(src)
		new /obj/item/clothing/under/captainformal(src)
		return



/obj/structure/closet/secure_closet/hop
	name = "Head of Personnel's Locker"
	req_access = list(ACCESS_MARINE_BRIDGE)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet(src)
		new /obj/item/cartridge/hop(src)
//		new /obj/item/device/radio/headset/heads/hop(src)
		new /obj/item/storage/box/ids(src)
		new /obj/item/storage/box/ids( src )
//		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash(src)
		return

/obj/structure/closet/secure_closet/hop2
	name = "Head of Personnel's Attire"
	req_access = list(ACCESS_MARINE_BRIDGE)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/head_of_personnel(src)
		new /obj/item/clothing/under/dress/dress_hop(src)
		new /obj/item/clothing/under/dress/dress_hr(src)
		new /obj/item/clothing/under/lawyer/female(src)
		new /obj/item/clothing/under/lawyer/black(src)
		new /obj/item/clothing/under/lawyer/red(src)
		new /obj/item/clothing/under/lawyer/oldman(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/shoes/leather(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/under/rank/head_of_personnel_whimsy(src)
		new /obj/item/clothing/head/helmet/hop(src)
		return



/obj/structure/closet/secure_closet/hos
	name = "Head of Security's Locker"
	req_access = list(ACCESS_MARINE_BRIDGE)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/storage/backpack/security(src)
		else
			new /obj/item/storage/backpack/satchel/sec(src)
		new /obj/item/clothing/head/helmet/HoS(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/under/rank/head_of_security/jensen(src)
		new /obj/item/clothing/under/rank/head_of_security/corp(src)
		new /obj/item/clothing/suit/armor/hos/jensen(src)
		new /obj/item/clothing/suit/armor/hos(src)
		new /obj/item/clothing/head/helmet/HoS/dermal(src)
		new /obj/item/cartridge/hos(src)
//		new /obj/item/device/radio/headset/heads/hos(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/tool/taperoll/police(src)
		new /obj/item/weapon/shield/riot(src)
		new /obj/item/storage/box/flashbangs(src)
		new /obj/item/storage/belt/security(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/baton/loaded(src)
//		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/clothing/tie/holster/waist(src)
		new /obj/item/weapon/telebaton(src)
		new /obj/item/clothing/head/beret/sec/hos(src)
		return



/obj/structure/closet/secure_closet/warden
	name = "Warden's Locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"


	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/storage/backpack/security(src)
		else
			new /obj/item/storage/backpack/satchel/sec(src)
		new /obj/item/clothing/suit/armor/vest/security(src)
		new /obj/item/clothing/under/rank/warden(src)
		new /obj/item/clothing/under/rank/warden/corp(src)
		new /obj/item/clothing/suit/armor/vest/warden(src)
		new /obj/item/clothing/head/helmet/warden(src)
//		new /obj/item/cartridge/security(src)
//		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/tool/taperoll/police(src)
		new /obj/item/storage/box/flashbangs(src)
		new /obj/item/storage/belt/security(src)
		new /obj/item/reagent_container/spray/pepper(src)
		new /obj/item/weapon/baton/loaded(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/storage/box/holobadge(src)
		new /obj/item/clothing/head/beret/sec/warden(src)
		return

/obj/structure/closet/secure_closet/marshal
	name = "Marshal's Locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_warrant"
	icon_closed = "secure_unlocked_warrant"
	icon_locked = "secure_locked_warrant"
	icon_opened = "secure_open_warrant"
	icon_broken = "secure_locked_warrant"
	icon_off = "secure_closed_warrant"


	New()
		..()
		new /obj/item/clothing/suit/storage/CMB(src)
		new /obj/item/clothing/under/CM_uniform(src)
		new /obj/item/storage/backpack/security(src)
		new /obj/item/storage/belt/security(src)
		new /obj/item/clothing/shoes/jackboots(src)
		return

/obj/structure/closet/secure_closet/security
	name = "Security Officer's Locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_police"
	icon_closed = "secure_closed_police"
	icon_locked = "secure_locked_police"
	icon_opened = "secure_open_police"
	icon_broken = "secure_broken_police"
	icon_off = "secure_closed_police"

	New()
		..()
		sleep(2)
		if(prob(50))
			new /obj/item/storage/backpack/security(src)
		else
			new /obj/item/storage/backpack/satchel/sec(src)
		new /obj/item/clothing/suit/armor/vest/security(src)
		new /obj/item/clothing/head/helmet(src)
//		new /obj/item/cartridge/security(src)
//		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/storage/belt/security(src)
		new /obj/item/device/flash(src)
		new /obj/item/reagent_container/spray/pepper(src)
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/weapon/baton/loaded(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/clothing/glasses/sunglasses/sechud(src)
		new /obj/item/tool/taperoll/police(src)
		new /obj/item/device/hailer(src)
		new /obj/item/clothing/tie/storage/black_vest(src)
		new /obj/item/clothing/head/soft/sec/corp(src)
		new /obj/item/clothing/under/rank/security/corp(src)
		return


/obj/structure/closet/secure_closet/security/cargo

	New()
		..()
		new /obj/item/clothing/tie/armband/cargo(src)
//		new /obj/item/device/encryptionkey/req(src)
		return

/obj/structure/closet/secure_closet/security/engine

	New()
		..()
		new /obj/item/clothing/tie/armband/engine(src)
		new /obj/item/device/encryptionkey/engi(src)
		return

/obj/structure/closet/secure_closet/security/science

	New()
		..()
		new /obj/item/clothing/tie/armband/science(src)
//		new /obj/item/device/encryptionkey/headset_sci(src)
		return

/obj/structure/closet/secure_closet/security/med

	New()
		..()
		new /obj/item/clothing/tie/armband/medgreen(src)
		new /obj/item/device/encryptionkey/med(src)
		return

/obj/structure/closet/secure_closet/security_empty
	name = "Security Officer's Locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_open_police"
	icon_closed = "secure_closed_police"
	icon_locked = "secure_locked_police"
	icon_opened = "secure_open_police"
	icon_broken = "secure_broken_police"
	icon_off = "secoff"

	opened = 1
	locked = 0
	density = 0


/obj/structure/closet/secure_closet/detective
	name = "Detective's Cabinet"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/det(src)
		new /obj/item/clothing/under/det/black(src)
		new /obj/item/clothing/under/det/slob(src)
		new /obj/item/clothing/suit/storage/det_suit(src)
		new /obj/item/clothing/suit/storage/det_suit/black(src)
		new /obj/item/clothing/suit/storage/forensics/blue(src)
		new /obj/item/clothing/suit/storage/forensics/red(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/clothing/head/det_hat(src)
		new /obj/item/clothing/head/det_hat/black(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/storage/box/evidence(src)
//		new /obj/item/device/radio/headset/headset_sec(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/clothing/suit/armor/det_suit(src)
//		new /obj/item/ammo_magazine/c45r(src)
//		new /obj/item/ammo_magazine/c45r(src)
		new /obj/item/tool/taperoll/police(src)
//		new /obj/item/weapon/gun/projectile/detective/semiauto(src)
		new /obj/item/clothing/tie/holster/armpit(src)
		return

/obj/structure/closet/secure_closet/detective/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/injection
	name = "Lethal Injections"
	req_access = list(ACCESS_MARINE_COMMANDER)


	New()
		..()
		sleep(2)
		new /obj/item/reagent_container/ld50_syringe/choral(src)
		new /obj/item/reagent_container/ld50_syringe/choral(src)
		return



/obj/structure/closet/secure_closet/brig
	name = "Brig Locker"
	req_access = list(ACCESS_MARINE_BRIG)
	anchored = 1
	var/id = null

	New()
		..()
		new /obj/item/clothing/under/color/orange(src)
		new /obj/item/clothing/shoes/orange(src)
		new /obj/item/device/radio/headset(src)
		return



/obj/structure/closet/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(ACCESS_MARINE_BRIG)

	New()
		..()
		sleep(2)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/paper/Court (src)
		new /obj/item/paper/Court (src)
		new /obj/item/paper/Court (src)
		new /obj/item/tool/pen (src)
		new /obj/item/clothing/suit/judgerobe (src)
		new /obj/item/clothing/head/powdered_wig (src)
		new /obj/item/storage/briefcase(src)
		return

/obj/structure/closet/secure_closet/wall
	name = "wall locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0

/obj/structure/closet/secure_closet/wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened
