
//Gun attachable items code. Lets you add various effects to firearms.
//Some attachables are hardcoded in the projectile firing system, like grenade launchers, flamethrowers.
/obj/item/attachable
	name = "attachable item"
	desc = "Its an attachment. You should never see this."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = ""
	item_state = ""
	var/pixel_shift_x = 16 //Determines the amount of pixels to move the icon state for the overlay.
	var/pixel_shift_y = 16 //Uses the bottom left corner of the item.

	flags =  FPRINT | TABLEPASS | CONDUCT
	matter = list("metal" = 2000)
	w_class = 2.0
	force = 1.0
	var/slot = null //"muzzle", "rail", "under"
	var/list/guns_allowed = list() //what weapons can it be attached to? Note that it must be the FULL path, not parents.
	var/accuracy_mod = 0 //Modifier to firing accuracy % - FLAT
	var/ranged_dmg_mod = 100 //Modifier to ranged damage - PERCENTAGE / 100
	var/melee_mod = 100 //Modifier to melee damage - PERCENTAGE / 100
	var/w_class_mod = 0 //Modifier to weapon's weight class -- FLAT
	var/capacity_mod = 100 //Modifier to a weapon's magazine capacity - PERCENTAGE / 100
	var/list/contains = new/list() //Stores an attachable's internal contents, ie. grenades
	var/ammo_type = 0 //Which type of casing it stores, if reloadable
	var/ammo_capacity = 0 //How much ammo it can store
	var/twohanded_mod = 0 //If 1, removes two handed, if 2, adds two-handed.
	var/recoil_mod = 0 //If positive, adds recoil, if negative, lowers it. Recoil can't go below 0.
	var/silence_mod = 0 //Adds silenced to weapon
	var/light_mod = 0 //Adds an x-brightness flashlight to the weapon, which can be toggled on and off.
	var/tank_size = 0 //Determines amount of flamethrower tiles it can spray, total.
	var/spew_range = 0 //Determines # of tiles distance the flamethrower can exhale.

	New()
		if(ammo_type)
			spawn(0)
				for(var/i = 1, i <= ammo_capacity, i++)
					var/A = new ammo_type(src)
					contains += A


	proc/Attach(var/obj/item/weapon/gun/G)
		if(!istype(G)) return //Guns only
		if(slot == "rail") G.rail = src
		if(slot == "muzzle") G.muzzle = src
		if(slot == "under") G.under = src

		//Now deal with static, non-coded modifiers.
		if(melee_mod != 100)
			G.force = (G.force * melee_mod / 100)
			if(melee_mod > 100) G.attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		if(w_class_mod != 0) G.w_class += w_class_mod
		if(istype(G,/obj/item/weapon/gun/projectile))
			if(capacity_mod != 100) G:max_shells = (G:max_shells * capacity_mod / 100)
		if(recoil_mod)
			G.recoil += recoil_mod
			if(G.recoil < 0) G.recoil = 0
		if(twohanded_mod == 1) G.twohanded = 1
		if(twohanded_mod == 2) G.twohanded = 0
		if(silence_mod) G.silenced = 1
		if(light_mod)
			G.flash_lum = light_mod

	proc/Detach(var/obj/item/weapon/gun/G)
		if(!istype(G)) return //Guns only
		if(slot == "rail") G.rail = null
		if(slot == "muzzle") G.muzzle = null
		if(slot == "under") G.under = null

		//Now deal with static, non-coded modifiers.
		if(melee_mod != 100)
			G.force = initial(G.force)
			G.attack_verb = initial(G.attack_verb)
		if(w_class_mod != 0) G.w_class -= w_class_mod
		if(istype(G,/obj/item/weapon/gun/projectile))
			if(capacity_mod != 100)
				var/obj/item/weapon/gun/projectile/P = G
				P.max_shells = initial(P.max_shells)
		if(recoil_mod) G.recoil = initial(G.recoil)
		if(twohanded_mod) G.twohanded = initial(G.twohanded)
		if(silence_mod) G.silenced = initial(G.silenced)
		if(light_mod)  //Remember to turn the lights off
			if(G.flashlight_on && G.flash_lum)
				if(!ismob(G.loc))
					G.SetLuminosity(0)
				else
					var/mob/M = G.loc
					M.SetLuminosity(-light_mod) //Lights are on and we removed the flashlight, so turn it off
			G.flash_lum = initial(G.flash_lum)
			G.flashlight_on = 0


/obj/item/attachable/suppressor
	name = "suppressor"
	desc = "A small tube with exhaust ports to expel noise and gas.\nDoes not completely silence a weapon, but does make it much quieter."
	icon_state = "suppressor"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
						/obj/item/weapon/gun/projectile/M42C,
						/obj/item/weapon/gun/projectile/automatic/m39,
						/obj/item/weapon/gun/projectile/m4a3
						)
	accuracy_mod = -5
	slot = "muzzle"
	silence_mod = 1

/obj/item/attachable/bayonet
	name = "bayonet"
	desc = "A sharp blade for mounting on a weapon. It can be used to stab manually."
	icon_state = "bayonet"
	force = 18
	throwforce = 10
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37)
	melee_mod = 300 //30 brute for those 3 guns, normally do 10
	accuracy_mod = -10
	slot = "muzzle"

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does greatly increase weapon accuracy."
	icon_state = "reddot"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
						/obj/item/weapon/gun/projectile/automatic/m39,
						/obj/item/weapon/gun/projectile/shotgun/pump/m37,
						/obj/item/weapon/gun/projectile/m4a3
						)
	accuracy_mod = 20 //20% accuracy bonus
	slot = "rail"

/obj/item/attachable/foregrip
	name = "forward grip"
	desc = "A custom-built improved foregrip for maximum accuracy. However, it also changes the weapon to two-handed and increases weapon size."
	icon_state = "sparemag"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/M42C)
	accuracy_mod = 25
	twohanded_mod = 1
	w_class_mod = 1
	recoil_mod = -1
	slot = "under"

/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to allow a two handed weapon to be fired with one hand. Greatly reduces accuracy, however."
	icon_state = "gyro"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37)
	twohanded_mod = 2
	recoil_mod = 1
	accuracy_mod = -5
//	capacity_mod = 50 //50% ammo capacity.
	slot = "under"

/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. Has no drawbacks."
	icon_state = "flashlight"
	guns_allowed = list(/obj/item/weapon/gun,
					/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39
					)
	light_mod = 5
	slot = "rail"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/weapon/screwdriver))
			user << "You modify the rail flashlight back into a normal flashlight."
			var/obj/item/device/flashlight/F = new(src.loc)
			if(src.loc == user)
				user.drop_from_inventory(src)
			user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
			if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
				F.loc = src.loc
			del(src) //Delete da old flashlight
		else
			..()

/obj/item/attachable/grenade
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, two-shot grenade launcher. When empty, it must be detached before being reloaded."
	icon_state = "grenade"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41)
	ammo_capacity = 2
	ammo_type = /obj/item/weapon/grenade
	slot = "under"


	New() //Make these spawn with real grenades instead of the fake ones determined by ammo_type
		spawn(0)
			for(var/i = 1, i <= ammo_capacity, i++)
				var/A = new /obj/item/weapon/grenade/explosive(src)
				contains += A

	attackby(obj/item/I as obj, mob/user as mob)
		if(contains.len >= ammo_capacity)
			user << "It's full already."
			return

		if(istype(I,ammo_type))
			user << "You insert \the [I] into the [src]."
			playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)

/obj/item/attachable/shotgun
	name = "masterkey shotgun"
	icon_state = "masterkey"
	desc = "A weapon-mounted, four-shot shotgun. Mostly used in emergencies. To reload it, it must first be detached.\nTakes only M37 shells."
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41)
	ammo_capacity = 4
	ammo_type = /obj/item/ammo_casing/m37
	slot = "under"

	attackby(obj/item/I as obj, mob/user as mob)
		if(contains.len >= ammo_capacity)
			user << "It's full already."
			return

		if(istype(I,ammo_type))
			user << "You insert \the [I] into the [src]."
			playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)

/obj/item/attachable/flamer
	name = "mini flamethrower"
	icon_state = "grenade" //Placeholder
	desc = "A weapon-mounted flamethrower attachment.\nIt is designed for short bursts and must be discarded after it is empty."
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41)
	spew_range = 2 //Max range of fire
	tank_size = 10 //Total # of tiles
	slot = "under"

/obj/item/attachable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. Greatly increases accuracy and reduces recoil, but also increases weapon size."
	icon_state = "bipod"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/M42C)
	recoil_mod = -1
	accuracy_mod = 30
	slot = "under"
	w_class_mod = 2
	melee_mod = 50 //50% melee damage. Can't swing it around as easily.
