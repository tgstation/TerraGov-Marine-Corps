
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
	var/list/loaded = new/list() //Stores an attachable's internal contents, ie. grenades
	var/ammo_type = null //Which type of casing it stores, if reloadable
	var/ammo_capacity = 0 //How much ammo it can store
	var/shoot_sound = null //Sound to play when firing it alternately
	var/twohanded_mod = 0 //If 1, removes two handed, if 2, adds two-handed.
	var/recoil_mod = 0 //If positive, adds recoil, if negative, lowers it. Recoil can't go below 0.
	var/silence_mod = 0 //Adds silenced to weapon
	var/light_mod = 0 //Adds an x-brightness flashlight to the weapon, which can be toggled on and off.
	var/tank_size = 0 //Determines amount of flamethrower tiles it can spray, total.
	var/spew_range = 0 //Determines # of tiles distance the flamethrower can exhale.
	var/delay_mod = 0 //Changes firing delay. Cannot go below 0.
	var/burst_mod = 0 //Changes burst rate. 1 == 0.

	New()
		if(ammo_type)
			spawn(0)
				for(var/i = 1, i <= ammo_capacity, i++)
					var/A = new ammo_type(src)
					loaded += A


	proc/Attach(var/obj/item/weapon/gun/G)
		if(!istype(G)) return //Guns only
		if(slot == "rail") G.rail = src
		if(slot == "muzzle") G.muzzle = src
		if(slot == "under") G.under = src

		//Now deal with static, non-coded modifiers.
		if(melee_mod != 100)
			G.force = (G.force * melee_mod / 100)
			if(melee_mod > 100)
				G.attack_verb = null
				G.attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
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
		if(delay_mod)
			G.fire_delay += delay_mod
			if(G.fire_delay < 0)
				G.fire_delay = 1
				G.burst_amount++

		if(burst_mod)
			G.burst_amount += burst_mod
			if(G.burst_amount < 2) G.burst_amount = 0

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
		if(delay_mod)
			G.fire_delay = initial(G.fire_delay)
			G.burst_amount = initial(G.burst_amount)
		if(light_mod)  //Remember to turn the lights off
			if(G.flashlight_on && G.flash_lum)
				if(!ismob(G.loc))
					G.SetLuminosity(0)
				else
					var/mob/M = G.loc
					M.SetLuminosity(-light_mod) //Lights are on and we removed the flashlight, so turn it off
			G.flash_lum = initial(G.flash_lum)
			G.flashlight_on = 0
		if(burst_mod) G.burst_amount = initial(G.burst_amount)


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
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/m44m)
	melee_mod = 300 //30 brute for those 3 guns, normally do 10
	accuracy_mod = -10
	slot = "muzzle"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/weapon/screwdriver))
			user << "You modify the bayonet back into a combat knife."
			if(src.loc == user)
				user.drop_from_inventory(src)
			var/obj/item/weapon/combat_knife/F = new(src.loc)
			user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
			if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
				F.loc = src.loc
			del(src) //Delete da old bayonet
		else
			..()

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does greatly increase weapon accuracy."
	icon_state = "reddot"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
						/obj/item/weapon/gun/projectile/automatic/m39,
						/obj/item/weapon/gun/projectile/shotgun/pump/m37,
						/obj/item/weapon/gun/projectile/m4a3,
						/obj/item/weapon/gun/projectile/m44m
						)
	accuracy_mod = 20 //20% accuracy bonus
	slot = "rail"

/obj/item/attachable/foregrip
	name = "forward grip"
	desc = "A custom-built improved foregrip for maximum accuracy. However, it also changes the weapon to two-handed and increases weapon size."
	icon_state = "sparemag"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37)
	accuracy_mod = 15
	ranged_dmg_mod = 105
	twohanded_mod = 1
	w_class_mod = 1
	recoil_mod = -1
	slot = "under"

/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to allow a two handed weapon to be fired with one hand. Greatly reduces accuracy, however."
	icon_state = "gyro"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/M42C)
	twohanded_mod = 2
	recoil_mod = 1
	accuracy_mod = -15
	slot = "under"

/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. Has no drawbacks."
	icon_state = "flashlight"
	guns_allowed = list(/obj/item/weapon/gun,
					/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/m44m
					)
	light_mod = 5
	slot = "rail"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/weapon/screwdriver))
			user << "You modify the rail flashlight back into a normal flashlight."
			if(src.loc == user)
				user.drop_from_inventory(src)
			var/obj/item/device/flashlight/F = new(src.loc)
			user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
			if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
				F.loc = src.loc
			del(src) //Delete da old flashlight
		else
			..()

/obj/item/attachable/altfire
	name = "alternating fire attachable"

	attackby(obj/item/I as obj, mob/user as mob)
		if(loaded.len >= ammo_capacity)
			user << "It's full already."
			return

		if(ammo_type && istype(I,ammo_type))
			user << "You insert \the [I] into the [src]."
			playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
			user.drop_from_inventory(I)
			I.loc = src
			loaded += I

/obj/item/attachable/altfire/grenade
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, two-shot grenade launcher. When empty, it must be detached before being reloaded."
	icon_state = "grenade"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41)
	ammo_capacity = 2
	ammo_type = /obj/item/weapon/grenade
	slot = "under"
	shoot_sound = 'sound/weapons/grenadelaunch.ogg'

	New() //Make these spawn with real grenades instead of the fake ones determined by ammo_type
		spawn(0)
			for(var/i = 1, i <= ammo_capacity, i++)
				var/A = new /obj/item/weapon/grenade/explosive(src)
				loaded += A

/obj/item/attachable/altfire/shotgun
	name = "masterkey shotgun"
	icon_state = "masterkey"
	desc = "A weapon-mounted, four-shot shotgun. Mostly used in emergencies. To reload it, it must first be detached.\nTakes only M37 shells."
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41)
	ammo_capacity = 4
	ammo_type = /obj/item/ammo_casing/m37
	slot = "under"
	shoot_sound = 'sound/weapons/shotgun.ogg'

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
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. Greatly increases accuracy and reduces recoil, but also increases weapon size and slows firing speed."
	icon_state = "bipod"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/M42C)
	recoil_mod = -1
	accuracy_mod = 30
	slot = "under"
	w_class_mod = 2
	melee_mod = 50 //50% melee damage. Can't swing it around as easily.
	delay_mod = 1

/obj/item/attachable/extended_barrel
	name = "extended barrel"
	desc = "A lengthened barrel allows for greater accuracy, particularly at long range.\nHowever, natural resistance also slows the bullet, leading to reduced damage."
	slot = "muzzle"
	icon_state = "ebarrel"
	accuracy_mod = 20
	ranged_dmg_mod = 95
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/m44m
					)

/obj/item/attachable/heavy_barrel
	name = "barrel charger"
	desc = "A fitted barrel extender that goes on the muzzle, with a small shaped charge that propels a bullet much faster.\nGreatly increases projectile damage at the cost of accuracy and firing speed."
	slot = "muzzle"
	icon_state = "hbarrel"
	accuracy_mod = -40
	ranged_dmg_mod = 140
	delay_mod = 4
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/m44m,
					/obj/item/weapon/gun/projectile/M56_Smartgun
					)

/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. However, greatly reduces accuracy and increases weapon recoil."
	slot = "rail"
	icon_state = "autoloader"
	accuracy_mod = -25
	delay_mod = -3
	recoil_mod = 1
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/m44m,
					/obj/item/weapon/gun/projectile/M42C
					)

/obj/item/attachable/compensator
	name = "recoil compensator"
	desc = "A muzzle attachment that reduces recoil by diverting expelled gasses upwards. Increases accuracy and reduces recoil, at the cost of a small amount of weapon damage."
	slot = "muzzle"
	icon_state = "comp"
	accuracy_mod = 20
	ranged_dmg_mod = 90
	recoil_mod = -3
	guns_allowed = list(/obj/item/weapon/gun/projectile/shotgun/pump/m37,
					/obj/item/weapon/gun/projectile/M42C
					)

/obj/item/attachable/burstfire_assembly
	name = "burst fire assembly"
	desc = "A mechanism re-assembly kit that allows for automatic fire, or more shots per burst if the weapon already has the ability."
	icon_state = "rapidfire"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/M42C
						)
	accuracy_mod = -40
	slot = "under"
	burst_mod = 2

/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a USCM armor."
	icon_state = "magnetic"
	guns_allowed = list(/obj/item/weapon/gun/projectile/automatic/m41,
					/obj/item/weapon/gun/projectile/m4a3,
					/obj/item/weapon/gun/projectile/automatic/m39,
					/obj/item/weapon/gun/projectile/M42C,
					/obj/item/weapon/gun/projectile
						)
	accuracy_mod = -15
	slot = "rail"