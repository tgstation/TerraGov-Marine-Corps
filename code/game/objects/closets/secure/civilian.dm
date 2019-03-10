
/obj/structure/closet/secure_closet/chef_personal
	name = "Chef's Locker"
	req_access = list(ACCESS_KITCHEN)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chef(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/device/radio/headset(src)

/obj/structure/closet/secure_closet/bar
	name = "Booze"
	req_access = list(ACCESS_BAR)


	New()
		..()
		sleep(2)
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		new /obj/item/reagent_container/food/drinks/beer( src )
		return

/obj/structure/closet/secure_closet/barman_personal
	name = "Barman's Locker"
	req_access = list(ACCESS_BAR)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/bartender(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/device/radio/headset(src)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)
		new /obj/item/ammo_casing/shotgun/beanbag(BPK)

/obj/structure/closet/secure_closet/hydro_personal
	name = "Botanist's Locker"
	req_access = list(ACCESS_HYDROPONICS)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/hydro
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/device/analyzer/plant_analyzer(src)
		new /obj/item/device/radio/headset(src)

/obj/structure/closet/secure_closet/janitor_personal
	name = "Janitor's Locker"
	req_access = list(access_sulaco_engineering)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/janitor(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/device/pda/janitor(src)

/obj/structure/closet/secure_closet/lawyer_personal
	name = "Lawyer's Locker"
	req_access = list(ACCESS_LAWYER)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/lawyer(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/device/pda/lawyer(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/storage/briefcase(src)

/obj/structure/closet/secure_closet/librarian_personal
	name = "Librarian's Locker"
	req_access = list(ACCESS_LIBRARY)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/librarian(src)
		//
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/weapon/barcodescanner(src)

/obj/structure/closet/secure_closet/counselor_personal
	name = "Counselor's Locker"
	req_access = list(ACCESS_CHAPEL_OFFICE)

	New()
		..()
		sleep(2)
		new /obj/item/wardrobe/chaplain(src)
		//
		new /obj/item/storage/backpack/cultpack (src)
		var/obj/item/storage/backpack/BPK = new /obj/item/storage/backpack(src)
		var/obj/item/storage/box/B = new(BPK)
		new /obj/item/tool/pen(B)
		new /obj/item/storage/box/bible(src)
		new /obj/item/device/pda/chaplain(src)
		new /obj/item/device/radio/headset(src)
		new /obj/item/weapon/candlepack(src)
		new /obj/item/weapon/candlepack(src)
