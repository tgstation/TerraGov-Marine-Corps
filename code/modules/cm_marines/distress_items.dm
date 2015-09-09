/obj/item/clothing/under/pizza
	name = "pizza delivery uniform"
	desc = "An ill-fitting, slightly stained uniform for a pizza delivery pilot. Smells of cheese."
	icon_state = "redshirt2"
	item_state = "r_suit"
	item_color = "redshirt2"

/obj/item/weapon/storage/box/pizza
	name = "Food Delivery Box"
	desc = "A space-age food storage device, capable of keeping food extra fresh. Actually, it's just a box."

	New()
		..()
		pixel_y = rand(-3,3)
		pixel_x = rand(-3,3)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		var/randsnack
		for(var/i = 1 to 3)
			randsnack = rand(0,5)
			switch(randsnack)
				if(0)
					new /obj/item/weapon/reagent_containers/food/snacks/fries(src)
				if(1)
					new /obj/item/weapon/reagent_containers/food/snacks/cheesyfries(src)
				if(2)
					new /obj/item/weapon/reagent_containers/food/snacks/bigbiteburger(src)
				if(4)
					new /obj/item/weapon/reagent_containers/food/snacks/taco(src)
				if(5)
					new /obj/item/weapon/reagent_containers/food/snacks/hotdog(src)

//IRON BEARS


/obj/item/clothing/under/marine_jumpsuit/PMC/Bear
	name = "Iron Bear Uniform"
	desc = "A uniform worn by Iron Bears mercenaries"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "bear_jumpsuit"
	item_state = "bear_jumpsuit"
	item_color = "bear_jumpsuit"

/obj/item/clothing/suit/storage/marine/PMCarmor/Bear
	name = "H1 Iron Bears Vest"
	desc = "A protective vest worn by Iron Bears mercenaries."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "bear_armor"
	icon_state = "bear_armor"
	armor = list(melee = 70, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

/obj/item/clothing/mask/gas/Bear
	name = "Tactical Balaclava"
	desc = "A superior balaclava worn by the Iron Bears."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "bear_head"
	icon_state = "bear_head"
	icon_override = 'icons/PMC/PMC.dmi'
	anti_hug = 2

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS
	anti_hug = 4
	armor = list(melee = 70, bullet = 70, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	flags = FPRINT | TABLEPASS | BLOCKHAIR
	siemens_coefficient = 2.0
	anti_hug = 5
	armor = list(melee = 90, bullet = 70, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)


/obj/item/weapon/gun/projectile/automatic/mar20
	name = "\improper MAR-40"
	desc = "A cheaply-produced, yet tough assault rifle found far and wide across the United Systems. Uses 12mm rounds in a simple magazine."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "rsprifle"
	item_state = "c20r"
	w_class = 4
	max_shells = 40
	caliber = "12mm"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	fire_sound = 'sound/weapons/Gunshot_m39.ogg'
	load_method = 2
	twohanded = 1
	fire_delay = 4
	recoil = 0
	muzzle_pixel_x = 31
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 19
	under_pixel_x = 21
	under_pixel_y = 15

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/a12mm/empty(src)
		update_icon()
		return

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			update_icon()
		return

	update_icon()
		..()
		if(empty_mag)
			icon_state = "rsprifle"
		else
			icon_state = "rsprifle0"
		return

/obj/item/weapon/gun/projectile/shotgun/pump/merc
	name = "custom-built shotgun"
	desc = "A four-barrel pump action shotgun capable of firing in rapid succession. Dangerous."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "rspshotgun"
	max_shells = 4
	w_class = 4
	ammo_type = "/obj/item/ammo_casing/shotgun"
	fire_delay = 4
	recoil = 1
	force = 10.0
	twohanded = 1
	muzzle_pixel_x = 30
	muzzle_pixel_y = 18
	rail_pixel_x = 13
	rail_pixel_y = 19
	under_pixel_x = 22
	under_pixel_y = 15

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		update_icon()

	update_icon()
		..()
		if(loaded.len)
			icon_state = "rspshotgun"
		else
			icon_state = "rspshotgun0"
