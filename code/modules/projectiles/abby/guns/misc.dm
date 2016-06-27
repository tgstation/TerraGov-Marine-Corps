//-------------------------------------------------------
//ENERGY GUNS/ETC
/obj/item/weapon/gun/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	icon_empty = "taser0"
	item_state = null	//so the human update icon uses the icon_state instead.
	muzzle_flash = null //TO DO.
	can_pointblank = 0
	energy_based = 1
	fire_sound = 'sound/weapons/Taser.ogg'
	origin_tech = "combat=1;materials=1"
	matter = list("metal" = 40000)
	var/obj/item/weapon/cell/cell //1000 power, so you don't need to wait an hour to charge.
	var/charge_cost = 100 //10 shots.
	fire_delay = 10
	recoil = 0

	New()
		..()
		cell = new /obj/item/weapon/cell(src) //Initialize our junk.
		ammo = new /datum/ammo/energy/taser()

	update_icon()
		if(!cell || cell.charge - charge_cost < 0)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		return

	emp_act(severity)
		cell.use(round(cell.maxcharge / severity))
		update_icon()
		..()

	load_into_chamber()
		if(!cell || cell.charge - charge_cost < 0)
			return

		cell.charge -= charge_cost
		in_chamber = create_bullet(ammo)
		return in_chamber

	reload_into_chamber()
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
		del(projectile_to_fire)
		if(refund)
			cell.charge += charge_cost
		return 1

	reload()
		return

	unload()
		return

	make_casing()
		return

//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = "CHIMP70 Magazine (.70M)"
	default_ammo = "/datum/ammo/bullet/pistol/mankey"
	caliber = ".70M"
	icon_state = "monkey1"
	icon_empty = "monkey1"
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	matter = list("metal" = 100000)
	max_rounds = 300
	gun_type = "/obj/item/weapon/gun/pistol/chimp"
	handful_type = "Bullets (.70M)"

/obj/item/weapon/gun/pistol/chimp
	name = "\improper CHIMP70 Pistol"
	desc = "A powerful sidearm issed mainly to highly trained elite assassin necro-cyber-agents."
	icon_state = "chimp70"
	item_state = "chimp70"
	icon_empty = "chimp70_empty"
	can_pointblank = 0
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	mag_type = "/obj/item/ammo_magazine/pistol/chimp"
	fire_sound = 'sound/weapons/chimp70.ogg'
	eject_casings = 0
	fire_delay = 3
	burst_delay = 2
	burst_amount = 6
	recoil = 0
	w_class = 3
	force = 8

//-------------------------------------------------------

/obj/item/weapon/gun/flare
	name = "flare gun"
	desc = "A gun that fires flares. Replace with flares. Simple!"
	icon_state = "flaregun" //REPLACE THIS
	icon_empty = "flaregun"
	item_state = "gun" //YUCK
	fire_sound = 'sound/weapons/flaregun.ogg'
	can_pointblank = 0
	origin_tech = "combat=1;materials=2"
	default_ammo = ""
	var/num_flares = 1
	var/max_flares = 1
	fire_delay = 30
	recoil = 0

	New()
		..()
		ammo = new /datum/ammo/flare()

	update_icon()
		if(!num_flares && icon_empty)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		return

	load_into_chamber()
		if(num_flares)
			in_chamber = create_bullet(ammo)
			in_chamber.SetLuminosity(4)
			num_flares--
			return in_chamber
		return

	reload_into_chamber()
		update_icon()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
		del(projectile_to_fire)
		if(refund)
			num_flares++
		return 1

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/device/flashlight/flare))
			var/obj/item/device/flashlight/flare/flare = I
			if(num_flares >= max_flares)
				user << "It's already full."
				return

			if(flare.on)
				user << "\The [flare] is already active. Can't load it now."
				return

			num_flares++
			user.drop_from_inventory(flare)
			sleep(-1)
			del(flare)
			user << "\blue You insert the flare."
			return

		return ..()

	reload()
		return

	unload()
		return

	make_casing()
		return

//-------------------------------------------------------
//This gun is very powerful, but also has a kick.

/obj/item/ammo_magazine/minigun
	name = "Rotating Ammo Drum (7.62×51mm)"
	desc = "A huge ammo drum for a huge gun."
	caliber = "7.62×51mm"
	icon_state = "a762"
	icon_empty = "a762-0"
	origin_tech = "combat=3;materials=3"
	matter = list("metal" = 100000)
	default_ammo = "/datum/ammo/bullet/minigun"
	max_rounds = 300
	reload_delay = 24 //Hard to reload.
	gun_type = "/obj/item/weapon/gun/minigun"
	handful_type = "Bullets (.37.62×51mm)"

/obj/item/weapon/gun/minigun
	name = "\improper Ol' Painless"
	desc = "An enormous multi-barreled rotating gatling gun. This thing will no doubt pack a punch."
	icon_state = "painless"
	icon_empty = "painless0"
	item_state = "painless"
	icon_wielded = "painless-w"
	origin_tech = "combat=7;materials=5"
	mag_type = "/obj/item/ammo_magazine/minigun"
	fire_sound = 'sound/weapons/minigun.ogg'
	cocked_sound = 'sound/weapons/gun_cocked.ogg'
	eject_casings = 1
	autoejector = 0 // Harder to reload.
	twohanded = 1
	w_class = 5
	force = 20
	burst_amount = 6
	burst_delay = 1
	fire_delay = 5
	recoil = 2 //Good amount of recoil.
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 11
	rail_pixel_y = 19
	under_pixel_x = 20
	under_pixel_y = 15
	burst_amount = 5
	accuracy = -20 //It's not very accurate.
	//Not found on mercs or russians.

	New()
		..()
		load_into_chamber()

//-------------------------------------------------------