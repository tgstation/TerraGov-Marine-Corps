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
	item_state = "bear_mask"
	icon_state = "bear_mask"
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


/obj/item/weapon/gun/projectile/automatic/mar40
	name = "\improper MAR-40 Pulse Rifle"
	desc = "A cheaply-produced, yet tough pulse rifle found far and wide across the universe. Uses 12mm rounds in a simple magazine."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "rsprifle"
	item_state = "mar40"
	w_class = 4
	max_shells = 40
	caliber = "12mm"
	ammo_type = "/obj/item/ammo_casing/mar40"
	fire_sound = 'sound/weapons/Gunshot_m39.ogg'
	load_method = 2
	twohanded = 1
	fire_delay = 3
	recoil = 0
	muzzle_pixel_x = 31
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 19
	under_pixel_x = 21
	under_pixel_y = 15
	burst_amount = 4

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/mar40/empty(src)
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

/obj/item/projectile/bullet/mar40
	damage = 28
	name = "autorifle bullet"
	accuracy = -15

/obj/item/ammo_casing/mar40
	desc = "A 12mm bullet casing."
	caliber = "12mm"
	projectile_type = "/obj/item/projectile/bullet/mar40"

/obj/item/ammo_magazine/mar40
	name = "MAR-40 12mm magazine"
	desc = "A magazine with MAR-40 12mm ammo."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = ".45a"
	ammo_type = "/obj/item/ammo_casing/mar40"
	max_ammo = 40
	w_class = 1

/obj/item/ammo_magazine/mar40/empty
	max_ammo = 0
	icon_state = ".45a0"

/obj/item/weapon/gun/projectile/merc
	name = "sawn-off shotgun"
	desc = "A short-barreled shotgun which can fire two 12 gauge shells in rapid succession. Commonly found in the hands of criminals, mercenaries and in museums. Dangerous."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "rspshotgun"
	item_state = "sawed"
	max_shells = 2
	w_class = 6
	caliber = "shotgun"
	ammo_type = "/obj/item/ammo_casing/shotgun"
	fire_sound = 'sound/weapons/shotgun.ogg'
	fire_delay = 20
	burst_amount = 2
	recoil = 2.5
	force = 20.0
	twohanded = 0
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


/obj/item/clothing/under/marine_jumpsuit/PMC/green
	name = "Uniform"
	desc = "A uniform"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "arg_jumpsuit"
	item_state = "arg_jumpsuit"
	item_color = "arg_jumpsuit"

/obj/item/clothing/suit/storage/marine/PMCarmor/green
	name = "Armored Vest"
	desc = "A protective vest"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "arg_armor"
	icon_state = "arg_armor"
	armor = list(melee = 70, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

/obj/item/clothing/head/helmet/marine/PMC/green
	name = "Helmet"
	desc = "A protective helmet"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "arg_helmet"
	icon_state = "arg_helmet"
	armor = list(melee = 30, bullet = 30, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/marine_jumpsuit/PMC/dutch
	name = "Dutch's Dozen Uniform"
	desc = "A uniform worn by the mercenaries"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "dutch_jumpsuit"
	item_state = "dutch_jumpsuit"
	item_color = "dutch_jumpsuit"

/obj/item/clothing/under/marine_jumpsuit/PMC/dutch2
	name = "Dutch's Dozen Uniform"
	desc = "A uniform worn by the mercenaries"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "dutch_jumpsuit2"
	item_state = "dutch_jumpsuit2"
	item_color = "dutch_jumpsuit2"

/obj/item/clothing/head/helmet/marine/PMC/dutch
	name = "Dutch's Dozen Helmet"
	desc = "A protective helmet"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_helmet"
	icon_state = "dutch_helmet"
	armor = list(melee = 30, bullet = 30, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/marine/PMC/bearmask
	name = "Iron Bear Mask"
	desc = "A protective mask"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_helmet"
	icon_state = "dutch_helmet"
	armor = list(melee = 30, bullet = 30, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/marine/PMC/dutch/cap
	item_state = "dutch_cap"
	icon_state = "dutch_cap"

/obj/item/clothing/head/helmet/marine/PMC/dutch/band
	item_state = "dutch_band"
	icon_state = "dutch_band"


/obj/item/clothing/suit/storage/marine/PMCarmor/dutch
	name = "Armored Vest"
	desc = "A protective vest"
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "dutch_armor"
	icon_state = "dutch_armor"
	armor = list(melee = 70, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

/obj/item/weapon/gun/projectile/vp70
	name = "VP70 Combat Pistol"
	desc = "A semi-automatic combat pistol produced by Weyland-Yutani. Commonly found in the hands of mercenaries and soldiers around the galaxy."
	icon_state = "vp70"
	w_class = 2
	max_shells = 18
	caliber = "9mm"
	silenced = 0
	ammo_type = "/obj/item/ammo_casing/c9mm"
	fire_sound = 'sound/weapons/vp70.ogg'
	load_method = 2
	recoil = 0
	fire_delay = 2
	burst_amount = 2


/obj/item/clothing/suit/storage/marine/PMCarmor/sniper
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "pmc_sniper"
	icon_state = "pmc_sniper"
	armor = list(melee = 60, bullet = 70, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

/obj/item/clothing/head/helmet/marine/PMC/sniper
	name = "PMC Sniper Helmet"
	desc = "A helmet worn by PMC Marksmen"
	item_state = "pmc_sniper_hat"
	icon_state = "pmc_sniper_hat"

/obj/item/weapon/gun/projectile/automatic/m41/commando
	name = "\improper M41C Rifle"
	desc = "A modified M41A Pulse Rifle, the M41C. A modification of the standard Armat systems model adjusted to be fired with one hand, and at quicker firing rates. Painted in a brown color scheme and carried by corporate Black Ops kill-teams.."
	icon = 'icons/PMC/PMC.dmi'
	twohanded = 0
	fire_delay = 2
	item_state = "m41c"

/obj/item/weapon/claymore/mercsword
	name = "Combat Sword"
	desc = "A dusty sword commonly seen in historical museums. Where you got this is a mystery, for sure. Only a mercenary would be nuts enough to carry one of these. Sharped to deal massive damage."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "sword"
	force = 32

