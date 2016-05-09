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
	accuracy = 10
	slot_flags = SLOT_BACK

//MERC SHOTGUN - DOES NOT REQUIRE PUMPING
/obj/item/weapon/gun/shotgun/merc
	name = "\improper Custom Built Shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon_state = "rspshotgun"
	icon_empty = "rspshotgun0"
	item_state = "rspshotgun"
	fire_delay = 10
	w_class = 4
	autoejector = 1
	muzzle_pixel_x = 31
	muzzle_pixel_y = 19
	rail_pixel_x = 10
	rail_pixel_y = 21
	under_pixel_x = 17
	under_pixel_y = 14
	burst_amount = 4
	burst_delay = 2
	accuracy = -10
	found_on_mercs = 1
	twohanded = 0

//-------------------------------------------------------

/obj/item/weapon/gun/shotgun/combat
	name = "\improper MK221 Tactical Shotgun"
	desc = "The Weyland-Yutani MK221 Shotgun, a semi-automatic shotgun with a quick fire rate."
	icon_state = "cshotgun"
	icon_empty = "cshotgun"
	item_state = "cshotgun"
	icon_wielded = "cshotgun-w"
	fire_delay = 12
	muzzle_pixel_x = 33
	muzzle_pixel_y = 19
	rail_pixel_x = 10
	rail_pixel_y = 21
	under_pixel_x = 14
	under_pixel_y = 16

	New()
		..()
		var/obj/item/attachable/grenade/G = new(src)
		G.can_be_removed = 0
		G.icon_state = "" //Gun already has a better one
		G.Attach(src)
		update_attachables()

//-------------------------------------------------------

/obj/item/ammo_magazine/shotgun/double
	name = "12 Gauge Slugs"
	desc = "2 heavy shotgun shells designed for the double barrel shotgun. Just click to load them in."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "twoshells"
	icon_empty = "twoshells0"
	default_ammo = "/datum/ammo/bullet/shotgun"
	max_rounds = 2
	gun_type = "/obj/item/weapon/gun/shotgun/double"
	reload_delay = 6

//-------------------------------------------------------

/obj/item/weapon/gun/shotgun/double
	name = "\improper Double Barrel Shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design. Uses 12 Gauge Special slugs, but can only hold 2 at a time."
	icon_state = "dshotgun"
	icon_empty = "dshotgun"
	item_state = "dshotgun"
	icon_wielded = "dshotgun-w"
	mag_type = "/obj/item/ammo_magazine/shotgun/double"
	fire_delay = 6
	muzzle_pixel_x = 33
	muzzle_pixel_y = 21
	rail_pixel_x = 15
	rail_pixel_y = 22
	under_pixel_x = 21
	under_pixel_y = 16
	found_on_mercs = 1

/obj/item/weapon/gun/shotgun/double/sawn
	name = "\improper Sawn-Off Shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sawnshotgun"
	icon_empty = "sawnshotgun"
	item_state = "sawnshotgun"
	fire_delay = 3
	muzzle_pixel_x = 30
	muzzle_pixel_y = 20
	rail_pixel_x = 11
	rail_pixel_y = 22
	under_pixel_x = 18
	under_pixel_y = 16
	accuracy = -20
	twohanded = 0
	slot_flags = SLOT_BELT

	load_into_chamber()
		..()
		if(in_chamber) in_chamber.damage += 15

//-------------------------------------------------------
//Shotguns not in this category will not need to be pumped on each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "\improper M37A2 Pump Shotgun"
	desc = "An Armat Battlefield Systems classic design, the M37A2 combines close-range firepower with long term reliability. Alt click or use the weapon tab to pump it."
	icon_state = "m37"
	icon_empty = "m37_empty"
	icon_wielded = "m37-w"
	item_state = "m37"
	fire_delay = 26
	muzzle_pixel_x = 33
	muzzle_pixel_y = 19
	rail_pixel_x = 10
	rail_pixel_y = 21
	under_pixel_x = 14
	under_pixel_y = 15
	w_class = 4
	var/recentpump = 0
	autoejector = 0 //Does not automatically eject "magazines".
	var/is_pumped = 0
	var/is_reloading = 0

	load_into_chamber()
		if(is_pumped == 0)
			return 0
		..()
		is_pumped = 0
		return 1

	AltClick(var/mob/user)
		if(!user.canmove || user.stat || user.restrained())
			user << "Not right now."
			return

		if(is_pumped)
			usr << "There's already a shell in the chamber, just shoot it."
			return

		if(recentpump)	return
		var/mob/living/carbon/human/M = user
		if(!istype(M)) return //wat

		if(M.get_active_hand() != src && !M.get_inactive_hand() != src)
			M << "You have to be holding a shotgun!"
			return //not holding it

		src.pump(M)
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

		playsound(M, 'sound/weapons/shotgunpump.ogg', 70, 1)
		var/casingtype = text2path(ammo.casing_type)
		if(casingtype)
			new casingtype(get_turf(src)) //Drop a spent casing.

		//ready_bullet()
		is_pumped = 1
		if(M && current_mag.current_rounds <= 0)
			M << "\blue The last of \the [src]'s casings hit the ground. <B>Reload</b>!"
			current_mag.loc = get_turf(src) //Eject the mag.
			current_mag = null

		update_icon()
		return 1
/*
	proc/ready_bullet()	//Clone of load_into_chamber, only does it at a different time.
		var/obj/item/projectile/P = new(src) //New bullet!
		P.ammo = src.ammo
		P.name = P.ammo.name
		P.icon_state = P.ammo.icon_state //Make it look fancy.
		in_chamber = P
		P.damage = P.ammo.damage //For reverse lookups.
		P.damage_type = P.damage_type
		return 1
*/
	verb/pump_shotgun()
		set category = "Weapons"
		set name = "Pump Shotgun"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			usr << "Not right now."
			return

		if(is_pumped)
			usr << "There's already a shell in the chamber, just shoot it."
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

	snowflake_reload(var/obj/item/ammo_magazine/A)
		if(!istype(A) || !istype(current_mag) || !istype(A,current_mag.type) || A.default_ammo != current_mag.default_ammo)
			if(usr) usr << "The ammo types must be the same."
			return 0
		if(A.current_rounds == 0)
			if(usr) usr << "That [A] is empty."
			return 0

		if(current_mag.current_rounds >= current_mag.max_rounds)
			if(usr) usr << "It's already full."
			return 0

		if(is_reloading) return

		var/shells_to_load = A.current_rounds + current_mag.current_rounds
		if(shells_to_load > current_mag.max_rounds) shells_to_load = current_mag.max_rounds
		var/turf/start_turf = get_turf(src.loc)

		if(usr && istype(usr,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			H.visible_message("\blue [H] begins hand-reloading reloading \the [src].","\blue You begin hand-reloading the [src].")
			for(var/i = 1 to shells_to_load)
				is_reloading = 1
				if(get_turf(src.loc) != start_turf) break//We moved
				if(!A || !current_mag || current_mag.loc != src || A.loc != H) break	 //We ejected the mag
				if(H.get_active_hand() != A) break //We put it in backpacks
				if(!H || H.stat || H.lying || H.buckled) break //We died
				playsound(H, 'sound/weapons/shotgun_shell_insert.ogg', 50, 1)
				A.current_rounds--
				current_mag.current_rounds++
				if(A.current_rounds == 0)
					A.update_icon()
					src.update_icon()
					if(usr) usr << "\blue The [A] is empty!"
					is_reloading = 0
					break
				sleep(4)

			spawn(4 * shells_to_load)
				is_reloading = 0


		return 1

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
	item_state = "CMBshotgun"
	icon_wielded = "CMBshotgun-w"
	mag_type = "/obj/item/ammo_magazine/shotgun/cmb"
	fire_delay = 16
	muzzle_pixel_x = 33
	muzzle_pixel_y = 20
	rail_pixel_x = 10
	rail_pixel_y = 23
	under_pixel_x = 19
	under_pixel_y = 17

//-------------------------------------------------------