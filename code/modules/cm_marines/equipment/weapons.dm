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
				user << "<span class='notice'>You don't have enough cable for that.</span>"
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

/obj/item/weapon/butterfly/katana
	name = "katana"
	desc = "A ancient weapon from Japan."
	icon_state = "samurai"
	force = 50

/obj/item/weapon/claymore/mercsword
	name = "Combat Sword"
	desc = "A dusty sword commonly seen in historical museums. Where you got this is a mystery, for sure. Only a mercenary would be nuts enough to carry one of these. Sharpened to deal massive damage."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "sword"
	force = 39

/obj/item/weapon/claymore/mercsword/machete
	name = "M2132 Machete"
	desc = "Latest issue of the USCM Machete. Great for clearing out jungle or brush on outlying colonies. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "machete"
	item_state = "machete"
	item_color = "machete"
	force = 35
	slot_flags = SLOT_BACK
	w_class = 4.0

/obj/item/weapon/storage/box/m56_system
	name = "M56 smartgun system"
	desc = "A large case containing the full M56 Smartgun System. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = 5
	storage_slots = 5
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	open(var/mob/user as mob)
		if(!opened)
			if(istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/glasses/night/m56_goggles(src)
				new /obj/item/smartgun_powerpack(src)
				new /obj/item/clothing/suit/storage/smartgunner/snow(src)
				new /obj/item/weapon/gun/smartgun(src)
			else
				new /obj/item/clothing/glasses/night/m56_goggles(src)
				new /obj/item/smartgun_powerpack(src)
				new /obj/item/clothing/suit/storage/smartgunner(src)
				new /obj/item/weapon/gun/smartgun(src)
			opened = 1
		..()

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
		if(do_after(user,50))
			pcell.charge -= 50
			if(!mygun.current_mag) //This shouldn't happen, since the mag can't be ejected. Good safety, I guess.
				var/obj/item/ammo_magazine/internal/smartgun/A = new(mygun)
				mygun.current_mag = A

			var/rounds_to_reload = min(rounds_remaining, (mygun.current_mag.max_rounds - mygun.current_mag.current_rounds)) //Get the smaller value.

			mygun.current_mag.current_rounds += rounds_to_reload
			rounds_remaining -= rounds_to_reload

			user << "You finish loading [rounds_to_reload] shells into the M56 Smartgun. Ready to rumble!"
			playsound(user, 'sound/weapons/unload.ogg', 50, 1)

			reloading = 0
			return 1
		else
			user << "Your reloading was interrupted!"
			reloading = 0
			return
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
				usr << "A small gauge in the corner reads: Ammo: [rounds_remaining] / 250."

/obj/item/smartgun_powerpack/fancy
	icon = 'icons/mob/back.dmi'
	item_state = "powerpackw"
	icon_state = "powerpackw"

/obj/item/smartgun_powerpack/merc
	icon = 'icons/mob/back.dmi'
	item_state = "powerpackp"
	icon_state = "powerpackp"

/obj/item/weapon/storage/box/heavy_armor
	name = "B-Series Defensive Armor crate"
	desc = "A large case containing an experiemental suit of B18 armor for the discerning specialist."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "armor_case"
	w_class = 5
	storage_slots = 2
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	open(var/mob/user as mob)
		if(!opened)
			new /obj/item/clothing/gloves/marine/specialist(src)
			if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/suit/storage/marine/specialist/snow(src)
				new /obj/item/clothing/head/helmet/marine/specialist/snow(src)
			else
				new /obj/item/clothing/suit/storage/marine/specialist(src)
				new /obj/item/clothing/head/helmet/marine/specialist(src)
			opened = 1
		..()

/obj/item/weapon/storage/box/m42c_system
	name = "M42C Scoped Rifle system (Recon Set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 10
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rifle/sniper/M42A(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/device/binoculars(src)
			new /obj/item/weapon/storage/backpack/marine/smock(src)

	open(var/mob/user as mob) //A ton of runtimes were caused by ticker being null, so now we do the special items when its first opened
		if(!opened) //First time opening it, so add the round-specific items
			opened = 1
			if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/suit/storage/marine/sniper/snow(src)
				new /obj/item/clothing/head/helmet/marine/snow(src)
			else
				new /obj/item/clothing/suit/storage/marine/sniper(src)
				new /obj/item/clothing/head/helmet/durag(src)
		..()

/obj/item/weapon/storage/box/m42c_system_Jungle
	name = "M42C Scoped Rifle system (Marksman Set)"
	desc = "A large case containing your very own long-range sniper rifle. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sniper_case"
	w_class = 5
	storage_slots = 10
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rifle/sniper/M42A/jungle(src)
			new /obj/item/clothing/glasses/m42_goggles(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/incendiary(src)
			new /obj/item/ammo_magazine/sniper/flak(src)
			new /obj/item/weapon/facepaint/sniper(src)
			new /obj/item/weapon/storage/backpack/marine/smock(src)

	open(var/mob/user as mob)
		if(!opened)
			opened = 1
			if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony))
				new /obj/item/clothing/suit/storage/marine/sniper/snow(src)
				new /obj/item/clothing/head/helmet/marine/snow(src)
			else
				new /obj/item/clothing/suit/storage/marine/sniper/jungle(src)
				new /obj/item/clothing/head/helmet/durag/jungle(src)
		..()

/obj/item/weapon/storage/box/grenade_system
	name = "M92 Grenade Launcher case"
	desc = "A large case containing a heavy-duty multi-shot grenade launcher, the Armat Systems M92. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade_case"
	w_class = 5
	storage_slots = 2
	slowdown = 1
	can_hold = list() //Nada. Once you take the stuff out it doesn't fit back in.
	foldable = null

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
	foldable = null

	New()
		..()
		spawn(1)
			new /obj/item/weapon/gun/rocketlauncher(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/ap(src)
			new /obj/item/ammo_magazine/rocket/wp(src)

/obj/item/weapon/tank/phoron/m240
	name = "M240 Fuel tank"
	desc = "A fuel tank of powerful sticky-fire chemicals for use in the M240 Incinerator unit. Handle with care."
	icon_state = "flametank"


///***GRENADES***///
/obj/item/weapon/grenade/explosive
	desc = "It is set to detonate in 4 seconds."
	name = "frag grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_ex"
	det_time = 40
	item_state = "grenade_ex"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	dangerous = 1

	prime()
		spawn(0)
			explosion(src.loc,-1,-1,2)
			del(src)
		return

/obj/item/weapon/grenade/explosive/PMC
	desc = "A fragmentation grenade produced for private security firms. It explodes 3 seconds after the pin has been pulled."
	icon = 'icons/obj/grenade2.dmi'
	icon_state = "grenade_ex"
	item_state = "grenade_ex"


	prime()
		spawn(0)
			explosion(src.loc,-1,-1,3)
			del(src)
		return

/obj/item/weapon/grenade/incendiary
	desc = "It is set to detonate in 4 seconds."
	name = "incendiary grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "large_grenade"
	det_time = 40
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	dangerous = 1

	prime()
		spawn(0)
			flame_radius(1,get_turf(src))
			del(src)
		return

proc/flame_radius(var/radius = 1, var/turf/turf)
	if(!turf || !isturf(turf)) return
	if(radius < 0) radius = 0
	if(radius > 5) radius = 5

	for(var/turf/T in range(radius,turf))
		if(T.density) continue
		if(istype(T,/turf/space)) continue
		if(locate(/obj/flamer_fire) in T) continue //No stacking

		var/obj/flamer_fire/F = new(T)
		processing_objects.Add(F)
		F.firelevel = 5 + rand(0,11)
		if(F.firelevel < 1) F.firelevel = 1
		if(F.firelevel > 16) F.firelevel = 16


/obj/item/weapon/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/smoke_spread/bad/smoke

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/bad
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		src.smoke.set_up(10, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
		sleep(20)
		del(src)
		return

/obj/item/weapon/grenade/phosphorus
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/smoke_spread/phosphorus/smoke
	dangerous = 1

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/phosphorus
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		src.smoke.set_up(10, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()

		sleep(20)
		del(src)
		return


///***MINES***///
/obj/item/device/mine
	name = "Proximity Mine"
	desc = "An anti-personnel mine. Useful for setting traps or for area denial. "
	icon = 'icons/obj/grenade.dmi'
	icon_state = "mine"
	force = 5.0
	w_class = 2.0
	layer = 3
	throwforce = 5.0
	throw_range = 6
	throw_speed = 3
	unacidable = 1
	flags = FPRINT | TABLEPASS

	var/triggered = 0
	var/triggertype = "explosive" //Calls that proc
	/*
		"explosive"
		//"incendiary" //New bay//
	*/


//Arming
/obj/item/device/mine/attack_self(mob/living/user as mob)
	if(locate(/obj/item/device/mine) in get_turf(src))
		src << "There's already a mine at this position!"
		return

	if(user.z == 3 || user.z == 4) // On the Sulaco.
		src << "Are you crazy? You can't plant a landmine on a spaceship!"
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

	if(istype(M, /mob/living/carbon/Xenomorph) && !istype(M, /mob/living/carbon/Xenomorph/Larva) && M.stat != DEAD) //Only humanoid aliens can trigger it.
		var/mob/living/carbon/Xenomorph/X = M
		if(X.is_robotic) return //NOPE.jpg
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]!</font>"
		triggered = 1
		explosion(src.loc,-1,-1,2)
		spawn(0)
			if(src)
				del(src)

//TYPES//
//Explosive
/obj/item/device/mine/proc/explosive(obj)
	explosion(src.loc,-1,-1,3)
	spawn(0)
		del(src)
