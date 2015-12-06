#define SPEEDLOADER 0
#define FROM_BOX 1
#define MAGAZINE 2

/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses 357 ammo"
	name = "revolver"
	icon_state = "revolver"
	caliber = "357"
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	matter = list("metal" = 1000)
	recoil = 1
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/list/loaded = list()
	var/max_shells = 7
	var/load_method = SPEEDLOADER //0 = Single shells or quick loader, 1 = box, 2 = magazine
	var/obj/item/ammo_magazine/empty_mag = null
	var/using_alt = 0 //1: using underslung, 2: using rail, 3: using muzzle attachment to shoot.

/obj/item/weapon/gun/projectile/New()
	..()
	for(var/i = 1, i <= max_shells, i++)
		loaded += new ammo_type(src)
	update_icon()
	return

/obj/item/weapon/gun/projectile/proc/unload(var/mob/user)
	if (loaded.len)
		if (load_method == SPEEDLOADER)
			var/obj/item/ammo_casing/AC = loaded[1]
			loaded -= AC
			AC.loc = get_turf(src) //Eject casing onto ground.
			playsound(usr, 'sound/weapons/flipblade.ogg', 20, 1)
			user << "\blue You unload shell from \the [src]!"
		if (load_method == MAGAZINE)
			if(empty_mag)
				var/obj/item/ammo_magazine/AM = empty_mag
				for (var/obj/item/ammo_casing/AC in loaded)
					AM.stored_ammo += AC
					loaded -= AC
				AM.loc = get_turf(src)
				empty_mag = null
				update_icon()
				AM.update_icon()
				user << "\blue You unload magazine from \the [src]!"
				playsound(usr, 'sound/weapons/unload.ogg', 20, 1)
			else
				user << "\red Nothing loaded in \the [src]!"
	else
		user << "\red Nothing loaded in \the [src]!"

/obj/item/weapon/gun/projectile/load_into_chamber()
	if(in_chamber)
		return 1 //{R}

	if(!loaded.len)
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	if(isnull(AC) || !istype(AC))
		return 0
	if(ejectshell)
		AC.loc = get_turf(src) //Eject casing onto ground.
	if(AC.BB)
		AC.desc += " This one is spent."	//descriptions are magic - only when there's a projectile in the casing
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		if(!ejectshell) //Hopefully this will get rid of ghost shells floating around in our guns
			del(AC)
		return 1
	if(!isnull(AC) && !ejectshell)
		del(AC)
	return 0


/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A,/obj/item/attachable))
		return ..()

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_magazine))
		if((load_method == MAGAZINE) && loaded.len)
			user << "There's a magazine in there already."
			return
		var/obj/item/ammo_magazine/AM = A
		if(AM.stored_ammo.len <= 0)
			user << "<span class='warning'>The new magazine is empty!</span>"
			return
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(loaded.len >= max_shells)
				break
			if(AC.caliber == caliber && loaded.len < max_shells)
				AC.loc = src
				AM.stored_ammo -= AC
				loaded += AC
				num_loaded++
//				empty_mag = AM	//a temporary solution to get rid of magazines from mob hand
//				user.remove_from_mob(AM)

		if(load_method == MAGAZINE && !isnull(AM))
			user.remove_from_mob(AM)
			empty_mag = AM
			empty_mag.loc = src

	else if(istype(A, /obj/item/ammo_casing) && load_method == SPEEDLOADER)
		var/obj/item/ammo_casing/AC = A
		if(AC.caliber == caliber && loaded.len < max_shells)
			user.drop_item()
			AC.loc = src
			loaded += AC
			num_loaded++
		else
			if(!check_attach_reload()) //Check if we're trying to reload an altfiring attachment
				return ..()
	else
		if(!check_attach_reload()) //Check if we're trying to reload an altfiring attachment
			return ..() //Just do generic shit.

	if(num_loaded)
		user << "\blue You load [num_loaded] shell\s into \the [src]!"
		playsound(user, 'sound/weapons/reload.ogg', 20, 1)
		A.update_icon()
		update_icon()
	return

/obj/item/weapon/gun/projectile/proc/check_attach_reload(var/obj/item/A as obj, mob/user as mob)
	if(!user || !A) return

	if(muzzle) //First lets check muzzle attachments
		if(istype(muzzle,/obj/item/attachable/altfire))
			if(istype(A,muzzle.ammo_type))
				muzzle.attackby(A,user)
				return 1
	if(rail)
		if(istype(rail,/obj/item/attachable/altfire))
			if(istype(A,rail.ammo_type))
				rail.attackby(A,user)
				return 1
	if(under)
		if(istype(under,/obj/item/attachable/altfire))
			if(istype(A,under.ammo_type))
				under.attackby(A,user)
				return 1
	return 0


/obj/item/weapon/gun/projectile/examine()
	..()
	usr << "Has [getAmmo()] round\s remaining."
//		if(in_chamber && !loaded.len)
//			usr << "However, it has a chambered round."
//		if(in_chamber && loaded.len)
//			usr << "It also has a chambered round." {R}
	return

/obj/item/weapon/gun/projectile/proc/getAmmo()
	var/bullets = 0
	for(var/obj/item/ammo_casing/AC in loaded)
		if(istype(AC))
			bullets += 1
	return bullets

