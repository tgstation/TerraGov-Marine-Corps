//-------------------------------------------------------
//ENERGY GUNS/ETC
/obj/item/weapon/gun/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	icon_empty = "taser0"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'
	var/obj/item/weapon/cell/cell
	var/charge_cost = 20
	fire_delay = 10
	recoil = 0

	emp_act(severity)
		cell.use(round(cell.maxcharge / severity))
		update_icon()
		..()

	New()
		..()
		cell = new /obj/item/weapon/cell/high(src) //Initialize our junk.
		ammo = new /datum/ammo/energy/taser()

	load_into_chamber()
		if(!cell || cell.charge - charge_cost < 0)
			return 0

		if(in_chamber) return 1 //Already set!

		cell.charge -= charge_cost
		var/obj/item/projectile/P = new(src) //New bullet!
		P.ammo = src.ammo //Share the ammo type. This does all the heavy lifting.
		P.name = P.ammo.name
		P.icon_state = P.ammo.icon_state //Make it look fancy.
		in_chamber = P
		P.damage = P.ammo.damage //For reverse lookups.
		P.damage_type = P.damage_type
		return 1

	update_icon()
		if(!cell || cell.charge - charge_cost < 0)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		return

//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = "CHIMP70 Magazine (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/mankey"
	icon_state = "45"
	icon_empty = "45-0"
	max_rounds = 300
	gun_type = "/obj/item/weapon/gun/pistol/chimp"

/obj/item/weapon/gun/pistol/chimp
	name = "\improper CHIMP70 Pistol"
	desc = "A powerful sidearm issed mainly to highly trained elite assassin necro-cyber-agents."
	icon_state = "chimp70"
	item_state = "chimp70"
	mag_type = "/obj/item/ammo_magazine/pistol/chimp"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
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
	fire_sound = 'sound/weapons/Taser.ogg' //REPLACE
	default_ammo = ""
	var/num_flares = 1
	var/max_flares = 1
	fire_delay = 30
	recoil = 0

	New()
		..()
		ammo = new /datum/ammo/flare()

	load_into_chamber()
		if(num_flares <= 0)
			return 0

		if(in_chamber) return 1

		var/obj/item/projectile/P = new(src) //New bullet!
		P.ammo = src.ammo
		P.name = P.ammo.name
		P.icon_state = P.ammo.icon_state
		in_chamber = P
		P.damage = P.ammo.damage
		P.damage_type = P.damage_type
		P.SetLuminosity(4)
		return 1

	update_icon()
		if(num_flares <= 0 && icon_empty)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)
		return

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/device/flashlight/flare))
			if(num_flares >= max_flares)
				user << "It's already full."
				return

			if(I:on)
				I:turn_off()
				processing_objects -= I

			num_flares++
			user.drop_from_inventory(I)
			sleep(-1)
			del(I)
			user << "\blue You insert the flare."
			return

		return ..()

//-------------------------------------------------------

/obj/item/ammo_magazine/minigun
	name = "Rotating Ammo Drum (8mm)"
	desc = "A huge ammo drum for a huge gun."
	icon_state = "a762"
	icon_empty = "a762-0"
	default_ammo = "/datum/ammo/bullet"
	max_rounds = 300
	gun_type = "/obj/item/weapon/gun/minigun"

/obj/item/weapon/gun/minigun
	name = "\improper Ol' Painless"
	desc = "An enormous multi-barreled rotating gatling gun. Chambered in 8mm shells. Seems like it's waiting."
	icon_state = "painless"
	icon_empty = "painless0"
	item_state = "painless"
	icon_wielded = "painless-w"
	mag_type = "/obj/item/ammo_magazine/minigun"
	fire_sound = 'sound/weapons/gunshot_glock.ogg' //Change
	twohanded = 1
	w_class = 5
	force = 20
	burst_amount = 6
	burst_delay = 2
	fire_delay = 12
	recoil = 0
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 11
	rail_pixel_y = 19
	under_pixel_x = 20
	under_pixel_y = 15
	burst_amount = 5
	accuracy = -20
	//Not found on mercs or russians.

//-------------------------------------------------------