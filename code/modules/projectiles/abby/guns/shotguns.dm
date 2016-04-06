//Generic shotgun magazines

/obj/item/ammo_magazine/shotgun
	name = "Box of Shotgun Slugs"
	desc = "A box filled with heavy shotgun shells. A timeless classic."
	icon_state = "shells"
	default_ammo = "/datum/ammo/bullet/shotgun"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/shotgun"
	reload_delay = 30 //3 second reload.

/obj/item/ammo_magazine/shotgun/buckshot
	name = "Box of Buckshot Shells"
	desc = "A box filled with buckshot spread shotgun shells."
	icon_state = "beanbag"
	default_ammo = "/datum/ammo/bullet/shotgun/buckshot"
	max_rounds = 8

/obj/item/ammo_magazine/shotgun/incendiary
	name = "Box of Incendiary Slugs"
	desc = "A box filled with self-detonating incendiary shotgun rounds."
	icon_state = "incendiary"
	default_ammo = "/datum/ammo/bullet/shotgun/incendiary"
	max_rounds = 8

//-------------------------------------------------------

/obj/item/weapon/gun/shotgun
	mag_type = "/obj/item/ammo_magazine/shotgun"
	recoil = 2
	force = 14.0
	twohanded = 1
	fire_sound = 'sound/weapons/shotgun.ogg'

//MERC SHOTGUN - DOES NOT REQUIRE PUMPING
/obj/item/weapon/gun/shotgun/merc
	name = "\improper Custom Built Shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon_state = "rspshotgun"
	icon_empty = "rspshotgun0"
	fire_delay = 30
	w_class = 4
	autoejector = 1
	muzzle_pixel_x = 31
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 20
	under_pixel_x = 18
	under_pixel_y = 14
	burst_amount = 4
	accuracy = -35
	found_on_mercs = 1
	twohanded = 0

//-------------------------------------------------------
//Shotguns not in this category will not need to be pumped on each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper M37A2 Pump Shotgun"
	desc = "An Armat Battlefield Systems classic design, the M37A2 combines close-range firepower with long term reliability. Alt click or use the weapon tab to pump it."
	icon_state = "m37"
	icon_empty = "m37_empty"
	icon_wielded = "m37-w"
	item_state = "m37"
	fire_delay = 32
	muzzle_pixel_x = 32
	muzzle_pixel_y = 18
	rail_pixel_x = 8
	rail_pixel_y = 19
	under_pixel_x = 10
	under_pixel_y = 15
	w_class = 4
	var/recentpump = 0
	autoejector = 0 //Does not automatically eject "magazines".

	load_into_chamber()
		if(in_chamber) return 1
		return 0

	AltClick(var/mob/user)
		if(recentpump)	return
		var/mob/living/carbon/human/M = user
		if(!istype(M)) return //wat
		if(M.get_active_hand() != src && !M.get_inactive_hand() != src) return //not holding it

		pump(M)
		recentpump = 1
		spawn(20)
			recentpump = 0
		return

	proc/pump(mob/M as mob)
		if(in_chamber)     //We have a shell in the chamber
			return 0

		if(!current_mag || !ammo)
			M << "There's nothing loaded!"
			recentpump = 0
			return 0

		playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
		var/casingtype = text2path(ammo.casing_type)
		if(casingtype)
			new casingtype(get_turf(src)) //Drop a spent casing.

		ready_bullet()

		if(M && current_mag.current_rounds <= 0)
			M << "\blue The last of \the [src]'s casings hit the ground. Reload!"
			current_mag.loc = get_turf(src) //Eject the mag.
			current_mag = null

		update_icon()
		return 1

	proc/ready_bullet()	//Clone of load_into_chamber, only does it at a different time.
		var/obj/item/projectile/P = new(src) //New bullet!
		P.ammo = src.ammo
		P.name = P.ammo.name
		P.icon_state = P.ammo.icon_state //Make it look fancy.
		in_chamber = P
		P.damage = P.ammo.damage //For reverse lookups.
		P.damage_type = P.damage_type
		return 1

	verb/pump_shotgun()
		set category = "Weapons"
		set name = "Pump Shotgun"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			usr << "Not right now."
			return

		if(recentpump)	return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return //wat

		if(M.get_active_hand() != src && !M.get_inactive_hand() != src)
			M << "You have to be holding a shotgun!"
			return //not holding it

		src.pump(M)
		recentpump = 1
		spawn(20)
			recentpump = 0

		return

//-------------------------------------------------------

/obj/item/weapon/gun/shotgun/pump/combat
	name = "\improper MK221 Tactical Shotgun"
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate."
	icon_state = "cshotgun"
	icon_empty = "cshotgun0"
	item_state = "m37"
	fire_delay = 4
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 12
	rail_pixel_y = 20
	under_pixel_x = 18
	under_pixel_y = 14
	found_on_mercs = 1

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/double
	name = "12 Gauge Slugs"
	desc = "2 heavy shotgun shells designed for the double barrel shotgun. Just click to load them in."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "twoshells"
	icon_empty = "twoshells0"
	default_ammo = "/datum/ammo/bullet/shotgun"
	max_rounds = 2
	gun_type = "/obj/item/weapon/gun/shotgun/pump/double"
	reload_delay = 6

//-------------------------------------------------------

/obj/item/weapon/gun/shotgun/pump/double
	name = "\improper Double Barrel Shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design. Uses 12 Gauge Special slugs, but can only hold 2 at a time."
	icon_state = "dshotgun"
	icon_empty = "dshotgun"
	item_state = "m37-w"
	mag_type = "/obj/item/ammo_magazine/shotgun/double"
	fire_delay = 6
	muzzle_pixel_x = 32
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 20
	under_pixel_x = 24
	under_pixel_y = 16
	//found_on_mercs = 1 //Is this worth giving to them?

/obj/item/weapon/gun/shotgun/pump/double/sawn
	name = "\improper Sawn-Off Shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sawnshotgun"
	icon_empty = "sawnshotgun"
	item_state = "sawed"
	fire_delay = 1
	muzzle_pixel_x = 27
	muzzle_pixel_y = 19
	rail_pixel_x = 12
	rail_pixel_y = 20
	under_pixel_x = 24
	under_pixel_y = 17
	accuracy = -20
	twohanded = 0

	ready_bullet()
		..()
		if(in_chamber) in_chamber.damage += 15

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/cmb
	gun_type = "/obj/item/weapon/gun/shotgun/pump/cmb"
	reload_delay = 10
	max_rounds = 4

/obj/item/ammo_magazine/shotgun/buckshot/cmb
	gun_type = "/obj/item/weapon/gun/shotgun/pump/cmb"
	max_rounds = 4
	reload_delay = 10

/obj/item/ammo_magazine/shotgun/incendiary/cmb
	gun_type = "/obj/item/weapon/gun/shotgun/pump/cmb"
	max_rounds = 4
	reload_delay = 15

/obj/item/weapon/gun/shotgun/pump/cmb
	name = "\improper HG 37-12 Pump Shotgun"
	desc = "A four-round pump action shotgun with internal tube magazine allowing for quick reloading and highly accurate fire. Used exclusively by Colonial Marshals."
	icon_state = "CMBshotgun"
	icon_empty = "CMBshotgun"
	item_state = "m37"
	mag_type = "/obj/item/ammo_magazine/shotgun/cmb"
	fire_delay = 16
	muzzle_pixel_x = 32
	muzzle_pixel_y = 20
	rail_pixel_x = 10
	rail_pixel_y = 23
	under_pixel_x = 17
	under_pixel_y = 17

//-------------------------------------------------------