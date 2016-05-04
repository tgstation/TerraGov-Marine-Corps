///**************COLONIAL MARINES WEAPON/VENDING/FLASHLIGHT LAST EDIT: 06FEB2015 BY APOPHIS7755**************///


/obj/item/weapon/combat_knife
	name = "\improper Marine Combat Knife"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "combat_knife"
	item_state = "knife"
	desc = "The standard issue combat knife issued to Colonial Marines soldiers. You can slide this knife into your boots."
	flags = FPRINT | TABLEPASS | CONDUCT
	sharp = 1
	force = 25
	w_class = 1.0
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/CC = I
			if (CC.use(5))
				user << "You wrap some cable around the bayonet. It can now be attached to a gun."
				var/obj/item/attachable/bayonet/F = new(src.loc)
				if(src.loc == user)
					user.drop_from_inventory(src)
				user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
				if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
					F.loc = get_turf(src)
				del(src) //Delete da old knife
			else
				user << "<span class='notice'>This cable coil appears to be empty.</span>"
				return
		else
			..()

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>")
		return (BRUTELOSS)

/obj/item/weapon/throwing_knife
	name ="Throwing Knife"
	icon='icons/obj/weapons.dmi'
	icon_state = "throwing_knife"
	desc="A military knife designed to be thrown at the enemy. Much quieter than a firearm, but requires a steady hand to be used effectively."
	flags = FPRINT | TABLEPASS | CONDUCT
	sharp = 1
	force = 10
	w_class = 1.0
	throwforce = 35
	throw_speed = 4
	throw_range = 7
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	slot_flags = SLOT_POCKET

/obj/item/clothing/glasses/night/m56_goggles
	name = "M56 head mounted sight"
	desc = "A headset and goggles system for the M56 Smartgun. Has a low-res short range imager, allowing for view of terrain."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "m56_goggles"
	item_state = "glasses"
	darkness_view = 5
	toggleable = 1
	icon_action_button = "action_meson"
	vision_flags = SEE_TURFS

	mob_can_equip(mob/user, slot)
		if(slot == slot_glasses)
			if(!ishuman(user)) return ..() //Doesn't matter, just pass it to the main proc
			var/mob/living/carbon/human/H = user
			if(istype(H))
				var/obj/item/smartgun_powerpack/P = H.back
				if(!P || !istype(P))
					user << "You must be wearing an M56 Powerpack on your back to wear these."
					return 0
		return ..(user, slot)


/obj/item/clothing/glasses/night/m56_goggles/New()
	..()
	overlay = global_hud.thermal


/obj/item/weapon/storage/box/m56_system
	name = "M56 smartgun system"
	desc = "A large case containing the full M56 Smartgun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			if(istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/glasses/night/m56_goggles(src)
				new /obj/item/smartgun_powerpack(src)
				new /obj/item/clothing/suit/storage/marine_smartgun_armor/snow(src)
				new /obj/item/weapon/gun/smartgun(src)
			else
				new /obj/item/clothing/glasses/night/m56_goggles(src)
				new /obj/item/smartgun_powerpack(src)
				new /obj/item/clothing/suit/storage/marine_smartgun_armor(src)
				new /obj/item/weapon/gun/smartgun(src)

/obj/item/clothing/suit/storage/marine_smartgun_armor
	name = "M56 combat harness"
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "8"
	item_state = "armor"
	slowdown = 1
	icon_override = 'icons/Marine/marine_armor.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories."
	blood_overlay_type = "armor"
	armor = list(melee = 55, bullet = 75, laser = 30, energy = 0, bomb = 35, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/device/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/device/mine,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/gun/smartgun)

/obj/item/smartgun_powerpack
	name = "M56 powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the M56 Smartgun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "powerpack"
	item_state = "armor"
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BACK
	w_class = 5.0
	var/obj/item/weapon/cell/pcell = null
	var/rounds_remaining = 250
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list
	var/reloading = 0

	New()
		spawn(1)
			pcell = new /obj/item/weapon/cell(src)

	attack_self(mob/user)
		if(!ishuman(user) || user.stat) return 0

		var/obj/item/weapon/gun/smartgun/mygun = user.get_active_hand()

		if(isnull(mygun) || !mygun || !istype(mygun))
			user << "You must be holding an M56 Smartgun to begin the reload process."
			return 0
		if(rounds_remaining < 1)
			user << "Your powerpack is completely devoid of spare ammo belts! Looks like you're up shit creek, maggot!"
			return 0
		if(!pcell)
			user << "Your powerpack doesn't have a battery! Slap one in there!"
			return 0
		if(reloading) return 0
		if(pcell.charge <= 50)
			user << "Your powerpack's battery is too drained! Get a new one!"
			return 0

		reloading = 1
		user.visible_message("[user.name] begin feeding an ammo belt into the M56 Smartgun.","You begin feeding a fresh ammo belt into the M56 Smartgun. Don't move or you'll be interrupted.")
		if(do_after(user,50))
			pcell.charge -= 50
			var/existing_rounds = 0
			if(!mygun.current_mag)
				var/obj/item/ammo_magazine/smartgun_integrated/A = new(mygun)
				mygun.current_mag = A
			else
				existing_rounds = mygun.current_mag.current_rounds

			user << "You finish loading [mygun.current_mag.max_rounds - existing_rounds] shells into the M56 Smartgun. Ready to rumble!"
			reloading = 0
			playsound(user, 'sound/weapons/unload.ogg', 50, 1)
			mygun.current_mag.current_rounds = mygun.current_mag.max_rounds //Refill that shit.
			rounds_remaining -= (mygun.current_mag.max_rounds - existing_rounds)
			return 1
		else
			user << "Your reloading was interrupted!"
			reloading = 0
			return 0
		return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(istype(A,/obj/item/weapon/cell))
			var/obj/item/weapon/cell/C = A
			visible_message("[user.name] swaps out the power cell in the [src.name].","You swap out the power cell in the [src] and drop the old one.")
			user << "The new cell contains: [C.charge] power."
			pcell.loc = get_turf(user)
			pcell = C
			C.loc = src
			playsound(src,'sound/machines/click.ogg', 20, 1)
		else
			..()

	examine()
		set src in oview(1)
		..()

		if (get_dist(usr, src) <= 1)
			if(pcell)
				usr << "A small gauge in the corner reads: Ammo: [rounds_remaining] / 200."

/obj/item/clothing/glasses/m42_goggles
	name = "M42 Scout Sight"
	desc = "A headset and goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "m56_goggles"
	item_state = "m56_goggles"
	vision_flags = SEE_TURFS
	toggleable = 1
	icon_action_button = "action_meson"

	New()
		..()
		overlay = null  //Stops the overlay.

/obj/item/weapon/storage/box/m42c_system
	name = "M42C Scoped Rifle system"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 10
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/sniper(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/weapon/facepaint/sniper(src)
			new /obj/item/weapon/storage/backpack/smock(src)

			if(istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/suit/storage/marine/sniper/snow(src)
				new /obj/item/clothing/head/helmet/marine/snow(src)
			else
				new /obj/item/clothing/suit/storage/marine/sniper(src)
				new /obj/item/clothing/head/helmet/durag(src)

/obj/item/weapon/gun/m92
	name = "M92 grenade launcher"
	desc = "A heavy, 5-shot grenade launcher used by the Colonial Marines for area denial and big explosions."
	icon_state = "m92"
	icon_wielded = "riotgun"
	item_state = "riotgun" //Ugh replace this plz
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 6
	twohanded = 1
	mag_type = null //Does not use magazines.

	New()
		..()
		spawn(1) //Load er up!
			grenades += new /obj/item/weapon/grenade/explosive(src)
			grenades += new /obj/item/weapon/grenade/explosive(src)
			grenades += new /obj/item/weapon/grenade/incendiary(src)
			grenades += new /obj/item/weapon/grenade/explosive(src)
			grenades += new /obj/item/weapon/grenade/explosive(src)

	examine()
		set src in view()
		..()
		if(grenades.len)
			if (!(usr in view(2)) && usr!=src.loc) return
			usr << "\icon[src] Grenade launcher:"
			usr << "\blue [grenades.len] / [max_grenades] Grenades."

	attackby(obj/item/I as obj, mob/user as mob)
		if((istype(I, /obj/item/weapon/grenade)))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "\blue You put the [I] in the grenade launcher."
				user << "\blue Now storing: [grenades.len] / [max_grenades] grenades."
			else
				usr << "\red The grenade launcher cannot hold more grenades."

	afterattack(atom/target, mob/user , flag)
		if(get_dist(target,user) <= 2)
			usr << "\red The grenade launcher beeps a warning noise. You are too close!"
			return

		if(!wielded)
			user << "\red You need two hands to fire this!"
			return

		if(grenades.len)
			spawn(0) fire_grenade(target,user)
			playsound(user.loc, 'sound/weapons/grenadelaunch.ogg', 50, 1)
		else
			usr << "\red The grenade launcher is empty."

	proc/fire_grenade(atom/target, mob/user)
		for(var/mob/O in viewers(world.view, user))
			O.show_message(text("\red [] fired a grenade!", user), 1)
		user << "\red You fire the grenade launcher!"
		var/obj/item/weapon/grenade/F = grenades[1]
		grenades -= F
		F.loc = user.loc
		F.throw_range = 20
		F.throw_at(target, 20, 2, user)
		message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([src.name]).")
		log_game("[key_name_admin(user)] used a grenade ([src.name]).")
		F.active = 1
		F.icon_state = initial(icon_state) + "_active"
		playsound(F.loc, 'sound/weapons/armbomb.ogg', 50, 1)
		spawn(10)
			if(F) //If somehow got deleted since then
				F.prime()

/obj/item/weapon/storage/box/grenade_system
	name = "M92 Grenade Launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 2
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/m92(src)
			new /obj/item/weapon/storage/belt/grenade(src)
			new /obj/item/weapon/storage/belt/grenade(src)
			new /obj/item/weapon/storage/belt/grenade(src)


/obj/item/weapon/storage/box/rocket_system
	name = "M83 Rocket Launcher crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = 5
	storage_slots = 7
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rocketlauncher(src)
			new /obj/item/ammo_magazine/rocket_tube(src)
			new /obj/item/ammo_magazine/rocket_tube(src)
			new /obj/item/ammo_magazine/rocket_tube/ap(src)
			new /obj/item/ammo_magazine/rocket_tube/ap(src)
			new /obj/item/ammo_magazine/rocket_tube/wp(src)

/obj/item/weapon/tank/phoron/m240
	name = "M240 Fuel tank"
	desc = "A fuel tank of powerful sticky-fire chemicals for use in the M240 Incinerator unit. Handle with care."
	icon_state = "flametank"


/*
/obj/item/projectile/bullet/m4a3 //Colt 45 Pistol
	damage = 22  //OLD:  30
	name = "pistol bullet"

/obj/item/projectile/bullet/m44m //44 Magnum Peacemaker
	damage = 45  //OLD:  70
	name = "revolver bullet"

/obj/item/projectile/bullet/m39 // M39 SMG
	damage = 28  //OLD:  35
	name = "smg bullet"

/obj/item/projectile/bullet/m41 //M41 Assault Rifle
	damage = 36  //OLD:  50
	name = "rifle bullet"

/obj/item/projectile/bullet/m37 //M37 Pump Shotgun
	damage = 65  //OLD:  80
	range_falloff_at = 4 //4 turfs
	name = "shotgun slug"

///***Ammo***///

/obj/item/ammo_casing/m4a3 //45 Pistol
	desc = "A .45 special bullet casing."
	caliber = "45s"
	projectile_type = "/obj/item/projectile/bullet/m4a3"

/obj/item/ammo_casing/m44m //44 Magnum Peacemaker
	desc = "A 44 Magnum bullet casing."
	caliber = "38s"
	projectile_type = "/obj/item/projectile/bullet/m44m"

/obj/item/ammo_casing/m39 // M39 SMG
	desc = "A .9mm special bullet casing."
	caliber = "9mms"
	projectile_type = "/obj/item/projectile/bullet/m39"

/obj/item/ammo_casing/m41 //M41Assault Rifle
	desc = "A 10mm special bullet casing."
	caliber = "10mms"
	projectile_type = "/obj/item/projectile/bullet/m41"

/obj/item/ammo_casing/m37 //M37 Pump Shotgun
	name = "Shotgun shell"
	desc = "A 12 gauge shell."
	icon_state = "gshell"
	caliber = "shotgun"
	projectile_type = "/obj/item/projectile/bullet/m37"
	w_class = 1

///***Ammo Boxes***///

/obj/item/ammo_magazine/m4a3 //45 Pistol
	name = "M4A3 Magazine (.45)"
	desc = "A magazine with .45 ammo"
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = ".45a"
	ammo_type = "/obj/item/ammo_casing/m4a3"
	max_ammo = 12
	w_class = 1

/obj/item/ammo_magazine/m4a3/empty //45 Pistol
	icon_state = ".45a0"
	max_ammo = 0

/obj/item/ammo_magazine/m44m // 44 Magnum Peacemaker
	name = "44 Magnum Speed Loader (.44)"
	desc = "A 44 Magnum speed loader"
	icon_state = "38"
	ammo_type = "/obj/item/ammo_casing/m44m"
	max_ammo = 6
	multiple_sprites = 1
	w_class = 1

/obj/item/ammo_magazine/m39 // M39 SMG
	name = "M39 SMG Mag (9mm)"
	desc = "A 9mm special magazine"
	icon_state = "9x19p-8"
	ammo_type = "/obj/item/ammo_casing/m39"
	max_ammo = 35
	w_class = 1

/obj/item/ammo_magazine/m39/empty // M39 SMG
	icon_state = "9x19p-0"
	max_ammo = 0

/obj/item/ammo_magazine/m41 //M41 Assault Rifle
	name = "M41A Magazine (10mm)"
	desc = "A 10mm special magazine"
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "m309a"
	ammo_type = "/obj/item/ammo_casing/m41"
	max_ammo = 30
	w_class = 1

/obj/item/ammo_magazine/m41/empty //Assault Rifle
	max_ammo = 0
	icon_state = "m309a0"

/obj/item/weapon/storage/box/m37 //M37 Shotgun
	name = "M37 Shotgun shells (box)"
	desc = "A box of standard issue high-powered 12 gauge buckshot rounds. Manufactured by Armat Systems for military and civilian use."
	icon_state = "shells"
	w_class = 2 //Can fit in belts
	storage_slots = 14
	foldable = /obj/item/weapon/paper/crumpled
	can_hold = list("/obj/item/ammo_casing/m37")
	New()
		..()
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)


///***Pistols***///

/obj/item/weapon/gun/projectile/m4a3 //45 Pistol
	name = "\improper M4A3 Service Pistol"
	desc = "M4A3 Service Pistol, the standard issue sidearm of the Colonial Marines. Uses .45 special rounds."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "colt"
	item_state = "m4a3"
	max_shells = 12
	caliber = "45s"
	ammo_type = "/obj/item/ammo_casing/m4a3"
	recoil = 0
	w_class = 2
	silenced = 0
	load_method = 2
	fire_sound = 'sound/weapons/servicepistol.ogg'
	muzzle_pixel_x = 28
	muzzle_pixel_y = 19
	rail_pixel_x = 20
	rail_pixel_y = 21
	under_pixel_x = 20
	under_pixel_y = 17
	w_class = 3
	fire_delay = 3

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/m4a3/empty(src)
//		update_icon()
		return


/obj/item/weapon/gun/projectile/m4a3/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!loaded.len && empty_mag)
		empty_mag.loc = get_turf(src.loc)
		empty_mag = null
	return

/obj/item/weapon/gun/projectile/m44m //mm44 Magnum Peacemaker
	name = "\improper 44 Magnum"
	desc = "A bulky 44 Magnum revolver, occasionally carried by assault troops and officers in the Colonial Marines. Uses 44 Magnum rounds"
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "44"
	item_state = "44"
	caliber = "38s"
	ammo_type = "/obj/item/ammo_casing/m44m"
	fire_sound = 'sound/weapons/44mag.ogg'
	max_shells = 6
	muzzle_pixel_x = 30
	muzzle_pixel_y = 19
	rail_pixel_x = 17
	rail_pixel_y = 21
	under_pixel_x = 23
	under_pixel_y = 17
	w_class = 3
	fire_delay = 7

///***SMGS***///

/obj/item/weapon/gun/projectile/automatic/m39 // M39 SMG
	name = "\improper M39 SMG"
	desc = " Armat Battlefield Systems M39 SMG. Occasionally carried by light-infantry, scouts or non-combat personnel. Uses 9mm rounds."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smg"
	item_state = "m39"
	max_shells = 35
	caliber = "9mms"
	ammo_type = "/obj/item/ammo_casing/m39"
	fire_delay = 3
	force = 9.0
	fire_sound = 'sound/weapons/Gunshot_m39.ogg'
	ejectshell = 0 //Caseless
	load_method = 2
	recoil = 0
	muzzle_pixel_x = 33
	muzzle_pixel_y = 19
	rail_pixel_x = 20
	rail_pixel_y = 22
	under_pixel_x = 24
	under_pixel_y = 16
	w_class = 4
	burst_amount = 3

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag.update_icon()
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 30, 1)
		return

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/m39/empty(src)
		update_icon()
		return


///***RIFLES***///

/obj/item/weapon/gun/projectile/automatic/m41 //M41 Assault Rifle
	name = "\improper M41A Rifle"
	desc = "M41A Pulse Rifle. The standard issue rifle of the Colonial Marines. Commonly carried by most combat personnel. Uses 10mm special ammunition."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "m41a0"
	item_state = "m41a"
	w_class = 4.0
	max_shells = 30
	caliber = "10mms"
	ammo_type = "/obj/item/ammo_casing/m41"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	force = 10.0
	ejectshell = 0 //Caseless
	fire_delay = 2
	slot_flags = SLOT_BACK
	recoil = 0
	twohanded = 1
	muzzle_pixel_y = 15
	muzzle_pixel_x = 33
	rail_pixel_y = 19
	rail_pixel_x = 26
	under_pixel_y = 12
	under_pixel_x = 21
	burst_amount = 2

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/m41/empty(src)
		update_icon()
		return

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag.update_icon()
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			update_icon()
		return

	update_icon()
		..()
		if(empty_mag)
			icon_state = "m41a"
		else
			icon_state = "m41a0"
		return


	verb/eject_magazine()
		set category = "Weapons"
		set name = "Eject current magazine"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			usr << "Not right now."
			return

		if(!src || usr.get_active_hand() != src)
			return

		var/obj/item/ammo_magazine/AM = empty_mag
		if (loaded.len && AM)
			for (var/obj/item/ammo_casing/AC in loaded)
				AM.stored_ammo += AC
				loaded -= AC
			AM.loc = get_turf(src)
			AM.update_icon()
			empty_mag = null
			update_icon()
			if(AM.stored_ammo.len)
				AM.icon_state = "m309a"
			usr << "\blue You unload the magazine from \the [src]!"
			playsound(usr, 'sound/weapons/unload.ogg', 20, 1)
		else
			usr << "\red Nothing loaded in \the [src]!"

		return


///***SHOTGUNS***///

/obj/item/weapon/gun/projectile/shotgun/pump/m37 //M37 Pump Shotgun
	name = "\improper M37 Pump Shotgun"
	desc = "An M37 Pump Shotgun, a weapon commonly carried by Colonial Marines pointmen, law enforcement, and civilians. Alt click to pump it or use the verb.\nGood to keep handy for close encounters."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "m37"
	item_state = "m37"
	fire_sound = 'sound/weapons/shotgun.ogg'
	max_shells = 8
	caliber = "shotgun"
	ammo_type = "/obj/item/ammo_casing/m37"
	recoil = 1
	force = 10.0
	twohanded = 1
	fire_delay = 30
	muzzle_pixel_x = 31
	muzzle_pixel_y = 18
	rail_pixel_x = 16
	rail_pixel_y = 19
	under_pixel_x = 22
	under_pixel_y = 15
	w_class = 4

*/
///***MELEE/THROWABLES***///

/*

/obj/item/weapon/gun/projectile/M42C
	name = "M42C Scoped Rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 7-round magazine.\n'Peace Through Superior Firepower'"
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "M42c"
	item_state = "l6closednomag"  //placeholder
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	ammo_type = "/obj/item/ammo_casing/m42c"
	fire_delay = 60
	w_class = 4.0
	max_shells = 7
	caliber = ".50"
	load_method = 2
	force = 10.0
	recoil = 2
	twohanded = 1
	zoomdevicename = "scope"
	slot_flags = SLOT_BACK
	muzzle_pixel_x = 33
	muzzle_pixel_y = 17
	rail_pixel_x = 22
	rail_pixel_y = 20
	under_pixel_x = 25
	under_pixel_y = 12

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/m42c/empty(src)
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

/obj/item/weapon/gun/projectile/M42C/verb/scope()
	set category = "Weapons"
	set name = "Use Scope"
	set popup_menu = 1

	zoom()


/obj/item/projectile/bullet/m42c //M42C Sniper Rifle
	damage = 70
	armor_pierce = 100
	accuracy = 60
	incendiary = 1
	name = "sniper round"

/obj/item/ammo_casing/m42c
	desc = "A .50 special bullet casing."
	caliber = ".50"
	projectile_type = "/obj/item/projectile/bullet/m42c"

/obj/item/ammo_magazine/m42c
	name = "scoped rifle magazine"
	desc = "A .50 cal sniper rifle magazine"
	icon_state = "75"
	ammo_type = "/obj/item/ammo_casing/m42c"
	max_ammo = 7

/obj/item/ammo_magazine/m42c/empty
	icon_state = "75-0"
	max_ammo = 0
	*/


/*
/obj/item/weapon/gun/projectile/M56_Smartgun
	name = "M56 smartgun"
	desc = "The actual firearm in the 4-piece M56 Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a Powerpack. Click the powerpack icon in the top left to reload."
//	icon = 'icons/Marine/marine-weapons64.dmi'
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "m56"
	item_state = "m56"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	ammo_type = "/obj/item/ammo_casing/m56"
	w_class = 5.0
	max_shells = 50
	caliber = "28mm"
	force = 12.0
	twohanded = 1
	ejectshell = 0
	recoil = 0
	fire_delay = 1
	muzzle_pixel_x = 33
	muzzle_pixel_y = 17
	rail_pixel_x = 18
	rail_pixel_y = 18
	under_pixel_x = 23
	under_pixel_y = 14
	burst_amount = 3

	special_check(user)
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(!H.back || !istype(H.back,/obj/item/smartgun_powerpack))
				user << "The [src] makes a sad beeping noise. It cannot be fired without a powerpack and Combat Harness."
				return 0
			if(!H.wear_suit || !istype(H.wear_suit,/obj/item/clothing/suit/storage/marine_smartgun_armor))
				user << "The [src] makes a sad beeping noise. It cannot be fired without a powerpack and Combat Harness."
				return 0
			return 1
		return 0

	attack_hand(mob/user as mob)
		if(istype(user,/mob/living/carbon/human) && src.loc != user )
			var/mob/living/carbon/human/H = user
			if(!H.wear_suit || !istype(H.wear_suit,/obj/item/clothing/suit/storage/marine_smartgun_armor))
				user << "\red The [src] is much too heavy to pick up without a matching combat harness."
				return
		return ..(user)

	dropped(var/mob/living/carbon/human/H)
		if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/storage/marine_smartgun_armor))
			var/obj/item/clothing/suit/storage/marine_smartgun_armor/I = H.wear_suit
			if(isnull(H.s_store))
				if(wielded)	unwield()
				spawn(0)
					H.equip_to_slot_if_possible(src,slot_s_store)
					if(H.s_store == src) H << "\red The [src] snaps into place on [I]."
					H.update_inv_s_store()
		..()
*/

/*
/obj/item/projectile/bullet/m56 //M56 Smartgun bullet, 28mm
	damage = 35
	iff = 1
	armor_pierce = 10
	accuracy = 30
	name = "smartgun bullet"

/obj/item/ammo_casing/m56
	desc = "A 28mm bullet casing, somehow. Since the rounds are caseless..."
	caliber = "28mm"
	projectile_type = "/obj/item/projectile/bullet/m56"
*/
