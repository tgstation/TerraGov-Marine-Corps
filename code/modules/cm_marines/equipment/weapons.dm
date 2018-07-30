

/obj/item/storage/box/m56_system
	name = "\improper M56 smartgun system"
	desc = "A large case containing the full M56 Smartgun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = 5
	storage_slots = 4
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	open(var/mob/user as mob)
		if(!opened)
			new /obj/item/clothing/glasses/night/m56_goggles(src)
			new /obj/item/weapon/gun/smartgun(src)
			new /obj/item/smartgun_powerpack(src)
			new /obj/item/clothing/suit/storage/marine/smartgunner(src)
		..()

/obj/item/smartgun_powerpack
	name = "\improper M56 powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the M56 Smartgun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "powerpack"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_BACK
	w_class = 5.0
	var/obj/item/cell/pcell = null
	var/rounds_remaining = 250
	actions_types = list(/datum/action/item_action/toggle)
	var/reloading = 0

	New()
		select_gamemode_skin(/obj/item/smartgun_powerpack)
		..()
		pcell = new /obj/item/cell(src)

	attack_self(mob/user)
		if(!ishuman(user) || user.stat) return 0

		var/obj/item/weapon/gun/smartgun/mygun = user.get_active_hand()

		if(isnull(mygun) || !mygun || !istype(mygun))
			user << "You must be holding an M56 Smartgun to begin the reload process."
			return
		if(rounds_remaining < 1)
			user << "Your powerpack is completely devoid of spare ammo belts! Looks like you're up shit creek, maggot!"
			return
		if(!pcell)
			user << "Your powerpack doesn't have a battery! Slap one in there!"
			return

		mygun.shells_fired_now = 0 //If you attempt a reload, the shells reset. Also prevents double reload if you fire off another 20 bullets while it's loading.

		if(reloading)
			return
		if(pcell.charge <= 50)
			user << "Your powerpack's battery is too drained! Get a new battery and install it!"
			return

		reloading = 1
		user.visible_message("[user.name] begin feeding an ammo belt into the M56 Smartgun.","You begin feeding a fresh ammo belt into the M56 Smartgun. Don't move or you'll be interrupted.")
		var/reload_duration = 50
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.smartgun>0)
			reload_duration = max(reload_duration - 10*user.mind.cm_skills.smartgun,30)
		if(do_after(user,reload_duration, TRUE, 5, BUSY_ICON_FRIENDLY))
			pcell.charge -= 50
			if(!mygun.current_mag) //This shouldn't happen, since the mag can't be ejected. Good safety, I guess.
				var/obj/item/ammo_magazine/internal/smartgun/A = new(mygun)
				mygun.current_mag = A

			var/rounds_to_reload = min(rounds_remaining, (mygun.current_mag.max_rounds - mygun.current_mag.current_rounds)) //Get the smaller value.

			mygun.current_mag.current_rounds += rounds_to_reload
			rounds_remaining -= rounds_to_reload

			user << "You finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!"
			playsound(user, 'sound/weapons/unload.ogg', 25, 1)

			reloading = 0
			return 1
		else
			user << "Your reloading was interrupted!"
			reloading = 0
			return
		return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(istype(A,/obj/item/cell))
			var/obj/item/cell/C = A
			visible_message("[user.name] swaps out the power cell in the [src.name].","You swap out the power cell in the [src] and drop the old one.")
			user << "The new cell contains: [C.charge] power."
			pcell.loc = get_turf(user)
			pcell = C
			C.loc = src
			playsound(src,'sound/machines/click.ogg', 25, 1)
		else
			..()

	examine(mob/user)
		..()
		if (get_dist(user, src) <= 1)
			if(pcell)
				user << "A small gauge in the corner reads: Ammo: [rounds_remaining] / 250."

/obj/item/smartgun_powerpack/snow
	icon_state = "s_powerpack"

/obj/item/smartgun_powerpack/fancy
	icon_state = "powerpackw"

/obj/item/smartgun_powerpack/merc
	icon_state = "powerpackp"

/obj/item/storage/box/heavy_armor
	name = "\improper B-Series defensive armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
	storage_slots = 3
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	open(var/mob/user as mob)
		if(!opened)
			new /obj/item/clothing/gloves/marine/specialist(src)
			new /obj/item/clothing/suit/storage/marine/specialist(src)
			new /obj/item/clothing/head/helmet/marine/specialist(src)
		..()

/obj/item/storage/box/m42c_system
	name = "\improper M42A scoped rifle system (recon set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 12
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/sniper(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/device/binoculars(src)
			new /obj/item/storage/backpack/marine/smock(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A(src)


	open(var/mob/user as mob) //A ton of runtimes were caused by ticker being null, so now we do the special items when its first opened
		if(!opened) //First time opening it, so add the round-specific items
			if(map_tag)
				switch(map_tag)
					if(MAP_ICE_COLONY)
						new /obj/item/clothing/head/helmet/marine(src)
					else
						new /obj/item/clothing/head/helmet/durag(src)
						new /obj/item/facepaint/sniper(src)
		..()


/obj/item/storage/box/m42c_system_Jungle
	name = "\improper M42A scoped rifle system (marksman set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 9
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/sniper/jungle(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/clothing/head/helmet/durag/jungle(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A/jungle(src)

	open(var/mob/user as mob)
		if(!opened)
			if(map_tag)
				switch(map_tag)
					if(MAP_ICE_COLONY)
						new /obj/item/clothing/under/marine/sniper(src)
						new /obj/item/storage/backpack/marine/satchel(src)
						new /obj/item/bodybag/tarp/snow(src)
					else
						new /obj/item/facepaint/sniper(src)
						new /obj/item/storage/backpack/marine/smock(src)
						new /obj/item/bodybag/tarp(src)
		..()

/obj/item/storage/box/grenade_system
	name = "\improper M92 grenade launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 3
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/launcher/m92(src)
			new /obj/item/storage/belt/grenade(src)
			new /obj/item/storage/belt/grenade(src)


/obj/item/storage/box/rocket_system
	name = "\improper M5 RPG crate"
	desc = "A large case containing a heavy-caliber antitank missile launcher and missiles. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	w_class = 5
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/launcher/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/wp(src)





////////////////// new specialist systems ///////////////////////////:


/obj/item/storage/box/spec
	var/spec_set

/obj/item/storage/box/spec/demolitionist
	name = "\improper Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, and claymore mines. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "rocket_case"
	spec_set = "demolitionist"
	w_class = 5
	storage_slots = 12
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new	/obj/item/clothing/suit/storage/marine/M3T(src)
			new /obj/item/clothing/head/helmet/marine(src)
			new /obj/item/weapon/gun/launcher/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/wp(src)
			new /obj/item/explosive/mine(src)
			new /obj/item/explosive/mine(src)
			new /obj/item/explosive/plastique(src)
			new /obj/item/explosive/plastique(src)



/obj/item/storage/box/spec/sniper
	name = "\improper Sniper equipment"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 11
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "sniper"

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/sniper(src)
			new /obj/item/clothing/glasses/night/m42_night_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/device/binoculars(src)
			new /obj/item/storage/backpack/marine/smock(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A(src)

	open(mob/user) //A ton of runtimes were caused by ticker being null, so now we do the special items when its first opened
		if(!opened) //First time opening it, so add the round-specific items
			if(map_tag)
				switch(map_tag)
					if(MAP_ICE_COLONY)
						new /obj/item/clothing/head/helmet/marine(src)
					else
						new /obj/item/clothing/head/helmet/durag(src)
						new /obj/item/facepaint/sniper(src)
		..()

/obj/item/storage/box/spec/scout
	name = "\improper Scout equipment"
	desc = "A large case containing Scout equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 15
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "scout"

	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/M3S(src)
			new /obj/item/clothing/head/helmet/marine/scout(src)
			new /obj/item/clothing/glasses/night/M4RA(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra(src)
			new /obj/item/ammo_magazine/rifle/m4ra/incendiary(src)
			new /obj/item/ammo_magazine/rifle/m4ra/incendiary(src)
			new /obj/item/ammo_magazine/rifle/m4ra/impact(src)
			new /obj/item/ammo_magazine/rifle/m4ra/impact(src)
			new /obj/item/device/binoculars/tactical/scout(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/weapon/gun/rifle/m4ra(src)
			new /obj/item/storage/backpack/marine/satchel/scout_cloak(src)
			new /obj/item/explosive/plastique(src)
			new /obj/item/explosive/plastique(src)



/obj/item/storage/box/spec/pyro
	name = "\improper Pyrotechnician equipment"
	desc = "A large case containing Pyrotechnician equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
	storage_slots = 8
	slowdown = 1
	can_hold = list()
	foldable = null
	spec_set = "pyro"


	New()
		..()
		spawn(1)
			new /obj/item/clothing/suit/storage/marine/M35(src)
			new /obj/item/clothing/head/helmet/marine/pyro(src)
			new /obj/item/storage/backpack/marine/engineerpack/flamethrower(src)
			new /obj/item/weapon/gun/flamer/M240T(src)
			new /obj/item/ammo_magazine/flamer_tank/large(src)
			new /obj/item/ammo_magazine/flamer_tank/large(src)
			new /obj/item/ammo_magazine/flamer_tank/large/B(src)
			new /obj/item/ammo_magazine/flamer_tank/large/X(src)



/obj/item/storage/box/spec/heavy_grenadier
	name = "\improper Heavy Grenadier case"
	desc = "A large case containing M50 Heavy Armor and a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 6
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null
	spec_set = "heavy grenadier"

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/launcher/m92(src)
			new /obj/item/storage/belt/grenade(src)
			new /obj/item/storage/belt/grenade(src)
			new /obj/item/clothing/gloves/marine/specialist(src)
			new /obj/item/clothing/suit/storage/marine/specialist(src)
			new /obj/item/clothing/head/helmet/marine/specialist(src)


/obj/item/spec_kit //For events/WO, allowing the user to choose a specalist kit
	name = "specialist kit"
	desc = "A paper box. Open it and get a specialist kit."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycrate"

/obj/item/spec_kit/attack_self(mob/user as mob)
	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED)
		user << "<span class='notice'>This box is not for you, give it to a specialist!</span>"
		return
	var/choice = input(user, "Please pick a specalist kit!","Selection") in list("Pyro","Grenadier","Sniper","Scout","Demo")
	var/obj/item/storage/box/spec/S = null
	switch(choice)
		if("Pyro")
			S = /obj/item/storage/box/spec/pyro
		if("Grenadier")
			S = /obj/item/storage/box/spec/heavy_grenadier
		if("Sniper")
			S = /obj/item/storage/box/spec/sniper
		if("Scout")
			S = /obj/item/storage/box/spec/scout
		if("Demo")
			S = /obj/item/storage/box/spec/demolitionist
	new S(loc)
	user.put_in_hands(S)
	cdel()

/obj/item/spec_kit/attack_self(mob/user)
	var/selection = input(user, "Pick your equipment", "Specialist Kit Selection") as null|anything in list("Pyro","Grenadier","Sniper","Scout","Demo")
	if(!selection)
		return
	var/turf/T = get_turf(loc)
	switch(selection)
		if("Pyro")
			new /obj/item/storage/box/spec/pyro (T)
		if("Grenadier")
			new /obj/item/storage/box/spec/heavy_grenadier (T)
		if("Sniper")
			new /obj/item/storage/box/spec/sniper (T)
		if("Scout")
			new /obj/item/storage/box/spec/scout (T)
		if("Demo")
			new /obj/item/storage/box/spec/demolitionist (T)
	cdel(src)