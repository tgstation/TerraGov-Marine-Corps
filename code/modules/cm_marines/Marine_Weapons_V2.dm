///**************COLONIAL MARINES WEAPON/VENDING/FLASHLIGHT LAST EDIT: 06FEB2015 BY APOPHIS7755**************///


///***Bullets***///
/obj/item/projectile/bullet/m4a3 //Colt 45 Pistol
	damage = 25

/obj/item/projectile/bullet/m44m //44 Magnum Peacemaker
	damage = 35

/obj/item/projectile/bullet/m39 // M39 SMG
	damage = 22

/obj/item/projectile/bullet/m41 //M41 Assault Rifle
	damage = 32

/obj/item/projectile/bullet/m37 //M37 Pump Shotgun
	damage = 50

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
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = ".45a"
	ammo_type = "/obj/item/ammo_casing/m4a3"
	max_ammo = 12

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
	icon = 'icons/Marine/marine-weapons.dmi'
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

/obj/item/weapon/gun/projectile/m4a3 //45 Pistol
	name = "\improper M4A3 Service Pistol"
	desc = "M4A3 standard issue USCM pistol. It is composed of a lightweight steel alloy and fires .45 calibre rounds."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "colt"
	max_shells = 12
	caliber = "45s"
	ammo_type = "/obj/item/ammo_casing/m4a3"
	recoil = 0
	w_class = 2
	silenced = 0
	load_method = 2
	fire_sound = 'sound/weapons/servicepistol.ogg'

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
	desc = "A classic .44 calibre Magnum revolver from Earth's wilder days. Not standard issue."
	icon_state = "mateba"
	caliber = "38s"
	ammo_type = "/obj/item/ammo_casing/m44m"
	max_shells = 6



///***SMGS***///

/obj/item/weapon/gun/projectile/automatic/m39 // M39 SMG
	name = "\improper M39 SMG"
	desc = " Armat Battlefield Systems M39 SMG. Uses 9mm rounds. Often used by PMCs or in civilian zones due to its lack of stopping power."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smg"
	item_state = "c20r"
	max_shells = 35
	caliber = "9mms"
	ammo_type = "/obj/item/ammo_casing/m39"
//	fire_delay = 1
	force = 9.0
	fire_sound = 'sound/weapons/Gunshot_m39.ogg'
	ejectshell = 0 //Caseless
	load_method = 2
	recoil = 0

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 30, 1)
		return

	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/m39/empty(src)
		update_icon()
		return

	isHandgun()
		return 0

///***RIFLES***///

/obj/item/weapon/gun/projectile/automatic/m41 //M41 Assault Rifle
	name = "\improper M41A Rifle"
	desc = "M41A Pulse Rifle produced by Armat Battlefield Systems. Uses 10mm caseless ammunition. Peace Through Superior Firepower (tm)."
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
	fire_delay = 4
	slot_flags = SLOT_BACK
	recoil = 0
	twohanded = 1

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


	verb/eject_magazine(mob/user)
		set category = "Object"
		set name = "Eject current magazine"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			user << "Not right now."
			return

		var/obj/item/ammo_magazine/AM = empty_mag
		if (loaded.len && AM)
			for (var/obj/item/ammo_casing/AC in loaded)
				AM.stored_ammo += AC
				loaded -= AC
			AM.loc = get_turf(src)
			empty_mag = null
			update_icon()
			if(AM.stored_ammo.len)
				AM.icon_state = "m309a"
			user << "\blue You unload the magazine from \the [src]!"
			playsound(user, 'sound/weapons/unload.ogg', 20, 1)
		else
			user << "\red Nothing loaded in \the [src]!"

		return


///***SHOTGUNS***///

/obj/item/weapon/gun/projectile/shotgun/pump/m37 //M37 Pump Shotgun
	name = "\improper M37 Pump Shotgun"
	desc = "A Colonial Marines M37 Pump Shotgun. It fires heavily damaging quasi-explosive 12-gauge slugs. Shift click to pump it or use the verb."
	icon_state = "cshotgun"
	max_shells = 8
	caliber = "12gs"
	ammo_type = "/obj/item/ammo_casing/m37"
	recoil = 1
	force = 10.0
	twohanded = 1
	fire_delay = 30


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


/obj/item/weapon/gun/projectile/M42C
	name = "M42C Scoped Rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 6-round magazine."
	icon = 'icons/obj/gun.dmi'
	icon_state = "sniper"
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	ammo_type = "/obj/item/ammo_casing/m42c"
	fire_delay = 80
	w_class = 4.0
	max_shells = 6
	caliber = ".50"
	load_method = 2
	force = 10.0
	recoil = 2
	twohanded = 1
	zoomdevicename = "scope"

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
	set category = "Object"
	set name = "Use Scope"
	set popup_menu = 1

	zoom()


/obj/item/projectile/bullet/m42c //M42C Sniper Rifle
	damage = 70

/obj/item/ammo_casing/m42c
	desc = "A .50 special bullet casing."
	caliber = ".50"
	projectile_type = "/obj/item/projectile/bullet/m42c"

/obj/item/ammo_magazine/m42c
	name = "M42C Scoped Rifle Magazine"
	desc = "A .50 cal sniper rifle magazine"
	icon_state = "75"
	ammo_type = "/obj/item/ammo_casing/m42c"
	max_ammo = 6

/obj/item/ammo_magazine/m42c/empty
	icon_state = "75-0"
	max_ammo = 0


/* I'll get to this soonish.
/obj/item/weapon/gun/projectile/M56_Smartgun
	name = "M56 Smartgun"
	desc = "The actual firearm in the 4-piece M56 Smartgun System. Essentially a heavy, mobile machinegun."
	icon = 'icons/obj/gun.dmi'
	icon_state = "sniper"
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	ammo_type = "/obj/item/ammo_casing/m42c"
	fire_delay = 80
	w_class = 4.0
	max_shells = 6
	caliber = ".50"
	load_method = 2
	force = 10.0
	recoil = 2
	twohanded = 1
*/





//EXTRA CODE TO MAKE THINGS WORK  Just... Leave it for now...
/*
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
*/



/*
/obj/item/weapon/gun/projectile/Assault/verb/toggle_light()
	set name = "Toggle Flashlight"
	set category = "Object"

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


*/

