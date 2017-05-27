/obj/item/weapon/combat_knife
	name = "\improper M11 combat bayonet"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "combat_knife"
	item_state = "knife"
	desc = "The standard issue combat bayonet issued to Colonial Marines soldiers. You can slide this knife into your boots, and can be field-modified to attach to the end of a rifle."
	flags_atom = FPRINT|CONDUCT
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
				if(loc == user)
					user.temp_drop_inv_item(src)
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
	name ="\improper M11 throwing knife"
	icon='icons/obj/weapons.dmi'
	icon_state = "throwing_knife"
	desc="A military knife designed to be thrown at the enemy. Much quieter than a firearm, but requires a steady hand to be used effectively."
	flags_atom = FPRINT|CONDUCT
	sharp = 1
	force = 10
	w_class = 1.0
	throwforce = 35
	throw_speed = 4
	throw_range = 7
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	flags_equip_slot = SLOT_STORE

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</b>"
		return(BRUTELOSS)

/obj/item/weapon/claymore/mercsword
	name = "combat sword"
	desc = "A dusty sword commonly seen in historical museums. Where you got this is a mystery, for sure. Only a mercenary would be nuts enough to carry one of these. Sharpened to deal massive damage."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "sword"
	force = 39

/obj/item/weapon/claymore/mercsword/machete
	name = "\improper M2132 machete"
	desc = "Latest issue of the USCM Machete. Great for clearing out jungle or brush on outlying colonies. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "machete"
	item_state = "machete"
	item_color = "machete"
	force = 35
	//flags_equip_slot = SLOT_BACK
	w_class = 4.0

/obj/item/weapon/claymore/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, -1)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "A finely made Japanese sword, expertly crafted by a dedicated weaponsmith. It has some foreign letters carved into the hilt."
	icon_state = "katana"
	item_state = "katana"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST|SLOT_BACK
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>"
		return(BRUTELOSS)

//To do: replace the toys.
/obj/item/weapon/katana/replica
	name = "replica katana"
	desc = "A cheap knock-off commonly found in regular knife stores. Can still do some damage."
	force = 27
	throwforce = 7

/obj/item/weapon/katana/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, -1)
	return ..()

/obj/item/weapon/butterfly/katana
	name = "katana"
	desc = "A ancient weapon from Japan."
	icon_state = "samurai"
	force = 50

/obj/item/weapon/storage/box/m56_system
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
			opened = 1
		..()

/obj/item/smartgun_powerpack
	name = "\improper M56 powerpack"
	desc = "A heavy reinforced backpack with support equipment, power cells, and spare rounds for the M56 Smartgun System.\nClick the icon in the top left to reload your M56."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "powerpack"
	item_state = "powerpack"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_BACK
	w_class = 5.0
	var/obj/item/weapon/cell/pcell = null
	var/rounds_remaining = 250
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list
	var/reloading = 0

	New()
		select_gamemode_skin(/obj/item/smartgun_powerpack)
		..()
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
		if(do_after(user,50, TRUE, 5, BUSY_ICON_CLOCK))
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
		if(istype(A,/obj/item/weapon/cell))
			var/obj/item/weapon/cell/C = A
			visible_message("[user.name] swaps out the power cell in the [src.name].","You swap out the power cell in the [src] and drop the old one.")
			user << "The new cell contains: [C.charge] power."
			pcell.loc = get_turf(user)
			pcell = C
			C.loc = src
			playsound(src,'sound/machines/click.ogg', 25, 1)
		else
			..()

	examine()
		set src in oview(1)
		..()

		if (get_dist(usr, src) <= 1)
			if(pcell)
				usr << "A small gauge in the corner reads: Ammo: [rounds_remaining] / 250."

/obj/item/smartgun_powerpack/snow
	icon = 'icons/mob/back.dmi'
	item_state = "s_powerpack"
	icon_state = "s_powerpack"

/obj/item/smartgun_powerpack/fancy
	icon = 'icons/mob/back.dmi'
	item_state = "powerpackw"
	icon_state = "powerpackw"

/obj/item/smartgun_powerpack/merc
	icon = 'icons/mob/back.dmi'
	item_state = "powerpackp"
	icon_state = "powerpackp"

/obj/item/weapon/storage/box/heavy_armor
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
			opened = 1
		..()

/obj/item/weapon/storage/box/m42c_system
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
			new /obj/item/weapon/storage/backpack/marine/smock(src)
			new /obj/item/weapon/gun/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/ammo_magazine/pistol/vp70(src)
			new /obj/item/weapon/gun/rifle/sniper/M42A(src)


	open(var/mob/user as mob) //A ton of runtimes were caused by ticker being null, so now we do the special items when its first opened
		if(!opened) //First time opening it, so add the round-specific items
			opened = 1
			if(ticker && ticker.mode)
				switch(ticker.mode.name)
					if("Ice Colony")
						new /obj/item/clothing/head/helmet/marine(src)
					else
						new /obj/item/clothing/head/helmet/durag(src)
						new /obj/item/weapon/facepaint/sniper(src)
		..()

/obj/item/weapon/storage/box/m42c_system_Jungle
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
			opened = 1
			if(ticker && ticker.mode)
				switch(ticker.mode.name)
					if("Ice Colony")
						new /obj/item/clothing/under/marine/sniper(src)
						new /obj/item/weapon/storage/backpack/marine/satchel(src)
						new /obj/item/bodybag/tarp/snow(src)
					else
						new /obj/item/weapon/facepaint/sniper(src)
						new /obj/item/weapon/storage/backpack/marine/smock(src)
						new /obj/item/bodybag/tarp(src)
		..()

/obj/item/weapon/storage/box/grenade_system
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
			new /obj/item/weapon/storage/belt/grenade(src)
			new /obj/item/weapon/storage/belt/grenade(src)


/obj/item/weapon/storage/box/rocket_system
	name = "\improper M83 rocket launcher crate"
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

/obj/item/weapon/tank/phoron/m240
	name = "\improper M240 fuel tank"
	desc = "A fuel tank of powerful sticky-fire chemicals for use in the M240 Incinerator unit. Handle with care."
	icon_state = "flametank"


///***GRENADES***///
/obj/item/weapon/grenade/explosive
	name = "\improper M40 HEDP grenade"
	desc = "A small, but deceptively strong fragmentation grenade that has been phasing out the M15 Fragmentation Grenades. Capable of being loaded in the M92 Launcher, or thrown by hand."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	det_time = 40
	item_state = "grenade"
	dangerous = 1

	prime()
		spawn(0)
			explosion(src.loc,-1,-1,2)
			del(src)
		return

/obj/item/weapon/grenade/explosive/flamer_fire_act()
	var/turf/T = loc
	cdel(src)
	explosion(T,-1,-1,2)


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

/obj/item/weapon/grenade/explosive/m40
	name = "\improper M15 fragmentation grenade"
	desc = "An outdated USCM Fragmentation Grenade. With decades of service in the USCM, the old M15 Fragmentation Grenade is slowly being replaced with the slightly safer M40 HEDP. It is set to detonate in 4 seconds."
	icon_state = "grenade_ex"
	item_state = "grenade_ex"

	prime()
		spawn(0)
			explosion(src.loc,-1,-1,2.5)
			del(src)
		return

/obj/item/weapon/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_fire"
	det_time = 40
	item_state = "grenade_fire"
	flags_equip_slot = SLOT_WAIST
	dangerous = 1

	prime()
		spawn(0)
			flame_radius(1,get_turf(src))
			del(src)
		return

proc/flame_radius(radius = 1, turf/turf) //~Art updated fire.
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
		F.burnlevel = 15 //make it sort of deadly.
		if(F.firelevel < 1) F.firelevel = 1
		if(F.firelevel > 16) F.firelevel = 16


/obj/item/weapon/grenade/smokebomb
	name = "\improper M40 HSDP smoke grenade"
	desc = "The M40 HSDP is a small, but powerful smoke grenade. Based off the same platform as the M40 HEDP. It is set to detonate in 2 seconds."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_smoke"
	det_time = 20
	item_state = "grenade_smoke"
	var/datum/effect/effect/system/smoke_spread/bad/smoke

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/bad
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, -3)
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
	name = "\improper M40 HPDP grenade"
	desc = "The M40 HPDP is a small, but powerful phosphorus grenade. It is set to detonate in 2 seconds."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_phos"
	det_time = 20
	item_state = "grenade_phos"
	var/datum/effect/effect/system/smoke_spread/phosphorus/smoke
	dangerous = 1

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/phosphorus
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, -3)
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
//Mines have an invisible "tripwire" atom that explodes when crossed
//Stepping directly on the mine will also blow it up
/obj/item/device/mine
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the United States Colonial Marines."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "m20"
	force = 5.0
	w_class = 2.0
	//layer = MOB_LAYER - 0.1 //You can't just randomly hide claymores under boxes. Booby-trapping bodies is fine though
	throwforce = 5.0
	throw_range = 6
	throw_speed = 3
	unacidable = 1
	flags_atom = FPRINT|CONDUCT

	var/iff_signal = ACCESS_IFF_MARINE
	var/triggered = 0
	var/armed = 0 //Will the mine explode or not
	var/trigger_type = "explosive" //Calls that proc
	var/obj/effect/mine_tripwire/tripwire
	/*
		"explosive"
		//"incendiary" //New bay//
	*/

	ex_act() trigger_explosion() //We don't care about how strong the explosion was.
	emp_act() trigger_explosion() //Same here. Don't care about the effect strength.

/obj/item/device/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the United States Colonial Marines. It has been modified for use by the W-Y PMC forces."
	icon_state = "m20p"
	iff_signal = ACCESS_IFF_PMC

//Arming
/obj/item/device/mine/attack_self(mob/living/user)
	if(locate(/obj/item/device/mine) in get_turf(src))
		user << "<span class='warning'>There already is a mine at this position!</span>"
		return

	if(user.loc && user.loc.density)
		user << "<span class='warning'>How do you plan to put a mine inside a wall?</span>"
		return

	if(user.z == 3 || user.z == 4) // On the Sulaco.
		user << "<span class='warning'>Are you crazy? You can't plant a mine on a spaceship!</span>"
		return

	if(!armed)
		user.visible_message("<span class='notice'>[user] starts deploying [src].</span>", \
		"<span class='notice'>You start deploying [src].</span>")
		if(!do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
			user.visible_message("<span class='notice'>[user] stops deploying [src].</span>", \
		"<span class='notice'>You stop deploying \the [src].</span>")
			return
		user.visible_message("<span class='notice'>[user] finishes deploying [src].</span>", \
		"<span class='notice'>You finish deploying [src].</span>")
		anchored = 1
		armed = 1
		playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1, -1)
		icon_state += "_armed"
		user.drop_held_item()
		dir = user.dir //The direction it is planted in is the direction the user faces at that time
		var/tripwire_loc = get_turf(get_step(loc, dir))
		tripwire = new /obj/effect/mine_tripwire(tripwire_loc)
		tripwire.linked_claymore = src

//Disarming
/obj/item/device/mine/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		if(anchored)
			user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", \
			"<span class='notice'>You start disarming [src].</span>")
			if(!do_after(user, 80, TRUE, 5, BUSY_ICON_CLOCK))
				user.visible_message("<span class='warning'>[user] stops disarming [src].", \
				"<span class='warning'>You stop disarming [src].")
				return
			user.visible_message("<span class='notice'>[user] finishes disarming [src].", \
			"<span class='notice'>You finish disarming [src].")
			anchored = 0
			armed = 0
			icon_state = copytext(icon_state,1,-6)
			if(tripwire) cdel(tripwire)

//Mine can also be triggered if you "cross right in front of it" (same tile)
/obj/item/device/mine/Crossed(atom/A)
	if(ismob(A)) Bumped(A)

/obj/item/device/mine/Bumped(mob/living/carbon/human/H)
	if(!armed || triggered) return

	if((istype(H) && H.get_target_lock(iff_signal)) || isrobot(H)) return

	H.visible_message("<span class='danger'>\icon[src] [src] clicks as [H] moves in front of it.</span>", \
	"<span class='danger'>\icon[src] [src] clicks as you move in front of it.</span>", \
	"<span class='danger'>You hear a click.</span>")

	triggered = 1
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1, -1)
	trigger_explosion()

//Note : May not be actual explosion depending on linked method
/obj/item/device/mine/proc/trigger_explosion()
	set waitfor = 0

	switch(trigger_type)
		if("explosive")
			if(tripwire)
				explosion(tripwire.loc, -1, -1, 2)
				if(tripwire) cdel(tripwire)
				cdel(src)

/obj/item/device/mine/attack_alien(mob/living/carbon/Xenomorph/M)
	if(triggered) //Mine is already set to go off
		return

	if(M.a_intent == "help") return
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)

	//We move the tripwire randomly in either of the four cardinal directions
	triggered = 1
	if(tripwire)
		var/direction = pick(cardinal)
		var/step_direction = get_step(src, direction)
		tripwire.forceMove(step_direction)
	trigger_explosion()

/obj/effect/mine_tripwire
	name = "claymore tripwire"
	anchored = 1
	mouse_opacity = 0
	invisibility = 101
	unacidable = 1 //You never know
	var/obj/item/device/mine/linked_claymore

/obj/effect/mine_tripwire/Crossed(atom/A)
	if(!linked_claymore)
		cdel(src)
		return

	if(linked_claymore.triggered) //Mine is already set to go off
		return

	if(linked_claymore && ismob(A))
		linked_claymore.Bumped(A)

/obj/item/device/mine/flamer_fire_act() //adding mine explosions
	var/turf/T = loc
	cdel(src)
	explosion(T, -1, -1, 2)