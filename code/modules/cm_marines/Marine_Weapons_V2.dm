///**************COLONIAL MARINES WEAPON/VENDING/FLASHLIGHT LAST EDIT: 06FEB2015 BY APOPHIS7755**************///


///***Bullets***///
/obj/item/projectile/bullet/m4a3 //Colt 45 Pistol
	damage = 25

/obj/item/projectile/bullet/m44m //44 Magnum Peacemaker
	damage = 45

/obj/item/projectile/bullet/m39 // M39 SMG
	damage = 20

/obj/item/projectile/bullet/m41 //M41 Assault Rifle
	damage = 30

/obj/item/projectile/bullet/m37 //M37 Pump Shotgun
	damage = 80

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
	caliber = "12gs"
	projectile_type = "/obj/item/projectile/bullet/m37"

///***Ammo Boxes***///

/obj/item/ammo_magazine/m4a3 //45 Pistol
	name = "M4A3 Magazine (.45)"
	desc = "A magazine with .45 ammo"
	icon_state = ".45a"
	ammo_type = "/obj/item/ammo_casing/m4a3"
	max_ammo = 12

/obj/item/ammo_magazine/m4a3e/empty //45 Pistol
	icon_state = ".45a0"
	max_ammo = 0

/obj/item/weapon/gun/projectile/pistol/m4a3/New() //45 Pistol
	..()
	empty_mag = new /obj/item/ammo_magazine/m4a3e/empty(src) //45 Pistol
	return

/obj/item/ammo_magazine/m44m // 44 Magnum Peacemaker
	name = "44 Magnum Speed Loader (.44)"
	desc = "A 44 Magnum speed loader"
	icon_state = "38"
	ammo_type = "/obj/item/ammo_casing/m44m"
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_magazine/m39 // M39 SMG
	name = "M39 SMG Mag (9mm)"
	desc = "A 9mm special magazine"
	icon_state = "9x19p-8"
	ammo_type = "/obj/item/ammo_casing/m39"
	max_ammo = 30

/obj/item/ammo_magazine/m39/empty // M39 SMG
	icon_state = "9x19p-0"
	max_ammo = 0

/obj/item/ammo_magazine/m41 //M41 Assault Rifle
	name = "M41A Magazine (10mm)"
	desc = "A 10mm special magazine"
	icon_state = "m309a"
	ammo_type = "/obj/item/ammo_casing/m41"
	max_ammo = 30

/obj/item/ammo_magazine/m41/empty //Assault Rifle
	max_ammo = 0
	icon_state = "m309a0"


/obj/item/weapon/storage/box/m37 //M37 Shotgun
	name = "M37 Shotgun shells (box)"
	desc = "It has a picture of a M37 shotgun on the side."
	icon_state = "shells"
	w_class = 2 //Can fit in belts
	New()
		..()
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)
		new /obj/item/ammo_casing/m37(src)


///***Pistols***///

/obj/item/weapon/gun/projectile/pistol/m4a3 //45 Pistol
	name = "\improper M4A3 Service Pistol"
	desc = "M4A3 Service Pistol. Uses .45 special rounds."
	icon_state = "colt"
	max_shells = 12
	caliber = "45s"
	ammo_type = "/obj/item/ammo_casing/m4a3"
	recoil = 0

/obj/item/weapon/gun/projectile/pistol/m4a3/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!loaded.len && empty_mag)
		empty_mag.loc = get_turf(src.loc)
		empty_mag = null
	return

/obj/item/weapon/gun/projectile/m44m //mm44 Magnum Peacemaker
	name = "\improper 44 Magnum"
	desc = "A 44 Magnum revolver. Uses 44 Magnum rounds"
	icon_state = "mateba"
	caliber = "38s"
	ammo_type = "/obj/item/ammo_casing/m44m"


///***SMGS***///

/obj/item/weapon/gun/projectile/automatic/Assault/m39 // M39 SMG
	name = "\improper M39 SMG"
	desc = " Armat Battlefield Systems M39 SMG. Uses 9mm rounds."
	icon_state = "smg"
	item_state = "c20r"
	max_shells = 30
	caliber = "9mms"
	ammo_type = "/obj/item/ammo_casing/m39"
	fire_delay = 0
	force = 9.0
	ejectshell = 0 //Caseless

	isHandgun()
		return 0


///***RIFLES***///

/obj/item/weapon/gun/projectile/Assault/m41 //M41 Assault Rifle
	name = "\improper M41A Rifle"
	desc = "M41A Pulse Rifle. Uses 10mm special ammunition."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "m41a0"
	item_state = "m41a"
	w_class = 3.0
	max_shells = 30
	caliber = "10mms"
	ammo_type = "/obj/item/ammo_casing/m41"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	force = 10.0
	ejectshell = 0 //Caseless
	fire_delay = 4
	slot_flags = SLOT_BACK

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/m41/empty(src)
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
			icon_state = "m41a"
		else
			icon_state = "m41a0"
		return


///***SHOTGUNS***///

/obj/item/weapon/gun/projectile/shotgun/pump/m37 //M37 Pump Shotgun
	name = "\improper M37 Pump Shotgun"
	desc = "Colonial Marine M37 Pump Shotgun"
	icon_state = "cshotgun"
	max_shells = 8
	caliber = "12gs"
	ammo_type = "/obj/item/ammo_casing/m37"
	recoil = 1
	force = 10.0


///***MELEE/THROWABLES***///

/obj/item/weapon/combat_knife
	name = "\improper Marine Combat Knife"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "combat_knife"
	item_state = "knife"
	desc = "When shits gets serious! You can slide this knife into your boots."
	flags = FPRINT | TABLEPASS | CONDUCT
	sharp = 1
	force = 25
	w_class = 1.0
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>")
		return (BRUTELOSS)


///***GRENADES***///
/obj/item/weapon/grenade/explosive
	desc = "It is set to detonate in 3 seconds."
	name = "frag grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_ex"
	det_time = 30
	item_state = "grenade_ex"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	dangerous = 1

	prime()
		spawn(0)
			explosion(src.loc,0,0,3)
			del(src)
		return

/obj/item/weapon/grenade/incendiary
	desc = "It is set to detonate in 3 seconds."
	name = "incendiary grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_ex"
	det_time = 30
	item_state = "grenade_ex"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	dangerous = 1

	prime()
		spawn(0)
			explosion(src.loc,0,0,0, flame_range = 4)
			del(src)
		return


///***MINES***///
/obj/item/device/mine
	name = "explosive mine"
	desc = "Anti-personnel mine."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "mine"
	force = 5.0
	w_class = 2.0
	layer = 3
	throwforce = 5.0
	throw_range = 6
	throw_speed = 3
	flags = FPRINT | TABLEPASS

	var/triggered = 0
	var/triggertype = "explosive"
	/*
		"explosive"
		"incendiary"
	*/
/obj/item/device/mine/incendiary
	name = "incendiary mine"
	triggertype = "incendiary" //Calls that proc

//Arming
/obj/item/device/mine/attack_self(mob/living/user as mob)
	if(locate(/obj/item/device/mine) in get_turf(src))
		src << "There's already a mine at this position!"
		return
	if(!anchored)
		user.visible_message("\blue \The [user] is deploying \the [src]")
		if(!do_after(user,40))
			user.visible_message("\blue \The [user] decides not to deploy \the [src].")
			return
		user.visible_message("\blue \The [user] deployed \the [src].")
		anchored = 1
		icon_state = "mine_armed"
		user.drop_item()
		return

//Disarming
/obj/item/device/mine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/multitool))
		if(anchored)
			user.visible_message("\blue \The [user] starts to disarm \the [src].")
			if(!do_after(user,80))
				user.visible_message("\blue \The [user] decides not to disarm \the [src].")
				return
			user.visible_message("\blue \The [user] finishes disarming \the [src]!")
			anchored = 0
			icon_state = "mine"
			return

//Triggering
/obj/item/device/mine/Crossed(AM as mob|obj)
	Bumped(AM)

/obj/item/device/mine/Bumped(mob/M as mob|obj)
	if(!anchored) return //If armed
	if(triggered) return

	if(istype(M, /mob/living/carbon/alien) && !istype(M, /mob/living/carbon/alien/larva)) //Only humanoid aliens can trigger it.
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]!</font>"
		triggered = 1
		call(src,triggertype)(M)

//TYPES//
//Explosive
/obj/item/device/mine/proc/explosive(obj)
	explosion(src.loc,0,0,2)
	spawn(0)
		del(src)

/obj/item/device/mine/proc/incendiary(obj)
	explosion(src.loc,0,0,0, flame_range = 3)
	spawn(0)
		del(src)
//Incendiary
//**//TODO



//EXTRA CODE TO MAKE THINGS WORK  Just... Leave it for now...

/obj/item/weapon/gun/projectile/Assault
	name = "\improper C-20r SMG"
	desc = "A standard issue assault rifle. Uses 12mm ammunition."
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	caliber = "12mm"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	fire_delay = 2
	var/gun_light = 7 // Defines how bright the light on the flashlight will be
	var/haslight = 0  // Checks if there is a light on the rifle
	var/islighton = 0 // Checks if the Light is on


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
			icon_state = "c20r-[round(loaded.len,4)]"
		else
			icon_state = "c20r"
		return

///////NEW FANCY FLASHLIGHT CODE MADE OF HOPES AND DREAMS./





/obj/item/weapon/gun/projectile/Assault/verb/toggle_light()
	set name = "Toggle Flashlight"
	set category = "Weapon"

	if(haslight && !islighton) //Turns the light on
		usr << "\blue You turn the flashlight on."
		usr.SetLuminosity(gun_light)
		islighton = 1
	else if(haslight && islighton) //Turns the light off
		usr << "\blue You turn the flashlight off."
		usr.SetLuminosity(0)
		islighton = 0
	else if(!haslight) //Points out how stupid you are
		usr << "\red You foolishly look at where the flashlight would be, if it was attached..."

/obj/item/weapon/gun/projectile/Assault/pickup(mob/user)//Transfers the lum to the user when picked up
	if(islighton)
		SetLuminosity(0)
		usr.SetLuminosity(gun_light)

/obj/item/weapon/gun/projectile/Assault/dropped(mob/user)//Transfers the Lum back to the gun when dropped
	if(islighton)
		SetLuminosity(gun_light)
		usr.SetLuminosity(0)


