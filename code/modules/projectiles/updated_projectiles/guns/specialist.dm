//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

/obj/item/ammo_magazine/sniper
	name = "\improper M42A marksman magazine (10x28mm Caseless)"
	desc = "A magazine of sniper rifle ammo."
	caliber = "10×28mm Caseless"
	icon_state = "75"
	icon_empty = "75-0"
	max_rounds = 7
	default_ammo = "sniper bullet"
	gun_type = /obj/item/weapon/gun/rifle/sniper/M42A
	reload_delay = 3

/obj/item/ammo_magazine/sniper/incendiary
	name = "\improper M42A incendiary magazine (10x28mm caseless)"
	default_ammo = "incendiary sniper bullet"

/obj/item/ammo_magazine/sniper/flak
	name = "\improper M42A flak magazine (10x28mm caseless)"
	default_ammo = "flak sniper bullet"
	icon_state = "a762"
	icon_empty = "a762-0"

//Pow! Headshot.
/obj/item/weapon/gun/rifle/sniper/M42A
	name = "\improper M42A scoped rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 7-round magazine.\n'Peace Through Superior Firepower'"
	icon_state = "M42c"
	icon_empty = "M42c_empty"
	item_state = "m42a"  //placeholder!!
	origin_tech = "combat=6;materials=5"
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	mag_type = /obj/item/ammo_magazine/sniper
	slot_flags = SLOT_BACK
	accuracy = 10
	fire_delay = 60
	burst_amount = 1
	force = 12
	recoil = 1
	zoomdevicename = "scope"
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_AUTO_EJECTOR

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14)
		var/obj/item/attachable/scope/S = new(src)
		S.icon_state = "" //Let's make it invisible. The sprite already has one.
		S.attach_features &= ~ATTACH_REMOVABLE
		S.Attach(src)
		var/obj/item/attachable/sniperbarrel/Q = new(src)
		Q.Attach(src)
		update_attachables()

/obj/item/weapon/gun/rifle/sniper/M42A/jungle
	icon_state = "M42cG"
	icon_empty = "M42cG_empty"
	item_state = "m42aG"

/obj/item/ammo_magazine/sniper/elite
	name = "\improper M42C marksman magazine (12.7x99mm Caseless)"
	default_ammo = "supersonic sniper bullet"
	gun_type = /obj/item/weapon/gun/rifle/sniper/elite
	caliber = "12.7×99mm Caseless"
	max_rounds = 9

/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C anti-tank sniper rifle"
	desc = "A high end mag-rail heavy sniper rifle from Weyland-Armat chambered in the heaviest ammo available, 12.7×99mm Caseless."
	icon_state = "pmcM42c"
	icon_empty = "pmcM42c_empty"
	item_state = "m42a"  //placeholder!!
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/sniper_heavy.ogg'
	mag_type = /obj/item/ammo_magazine/sniper/elite
	slot_flags = SLOT_BACK
	accuracy = 35
	fire_delay = 90
	burst_amount = 1
	force = 17
	recoil = 10
	zoomdevicename = "scope"
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_AUTO_EJECTOR | GUN_WY_RESTRICTED

	New()
		..()
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15)
		var/obj/item/attachable/scope/S = new(src)
		S.icon_state = "pmcscope"
		S.attach_features &= ~ATTACH_REMOVABLE
		S.Attach(src)
		var/obj/item/attachable/sniperbarrel/Q = new(src)
		Q.Attach(src)
		update_attachables()

	simulate_recoil(var/total_recoil = 0, var/mob/user, atom/target)
		. = ..()
		if(.)
			var/mob/living/carbon/human/PMC_sniper = user
			var/o_x = target.x < user.x ? -1 : 1
			var/o_y = target.y < user.y ? -1 : 1
			var/new_x = target.x == user.x ? user.x : user.x + o_x
			var/new_y = target.y == user.y ? user.y : user.y + o_y
			var/near_target = locate(new_x,new_y,target.z)
			if(PMC_sniper.lying == 0 && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/smartgunner/gunner) && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/veteran))
				PMC_sniper.visible_message("<span class='warning'>[PMC_sniper] is blown backwards from the recoil of the [src]!</span>","<span class='highdanger'>You are knocked prone by the blowback!</span>")
				step_away(PMC_sniper,near_target)
				PMC_sniper.Weaken(5)

/obj/item/ammo_magazine/rifle/sniper/svd
	name = "\improper SVD magazine (7.62x54mmR)"
	desc = "A 12mm marksman rifle magazine."
	caliber = "7.62×54mmR"
	icon_state = "a762"
	icon_empty = "a762-0"
	default_ammo = "marksman rifle bullet"
	max_rounds = 30
	gun_type = /obj/item/weapon/gun/rifle/sniper/svd

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper SVD Dragunov-033 sniper rifle"
	desc = "A sniper variant of the MAR-40 rifle, with a new stock, barrel, and scope. It doesn't have the punch of modern sniper rifles, but it's finely crafted in 2133 by someone probably illiterate. Fires 7.62×54mmR rounds."
	icon_state = "VSS"
	icon_empty = "VSS_empty"
	origin_tech = "combat=5;materials=3;syndicate=5"
	icon_wielded = "SVD-w"
	item_state = "mar40"
	fire_sound = 'sound/weapons/automag.ogg'
	mag_type = /obj/item/ammo_magazine/rifle/sniper/svd
	eject_casings = 1
	recoil = 1
	burst_amount = 2
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_AUTO_EJECTOR | GUN_ON_MERCS | GUN_ON_RUSSIANS

	New()
		..()
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 24, "under_y" = 13)
		var/obj/item/attachable/S = new /obj/item/attachable/scope/slavic(src)
		S.Attach(src)
		S = new /obj/item/attachable/slavicbarrel(src)
		S.Attach(src)
		S = new /obj/item/attachable/stock/slavic(src)
		S.Attach(src)
		update_attachables()

//-------------------------------------------------------
//SMARTGUN
/obj/item/ammo_magazine/internal/smartgun
	name = "integrated smartgun belt"
	caliber = "10×28mm Caseless"
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 50
	default_ammo = "smartgun bullet"

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper M56 smartgun"
	desc = "The actual firearm in the 4-piece M56 Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a Powerpack. Click the powerpack icon in the top left to reload."
	icon_state = "m56"
	item_state = "m56"
	origin_tech = "combat=6;materials=5"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	mag_type = /obj/item/ammo_magazine/internal/smartgun
	slot_flags = 0
	w_class = 5
	force = 20
	accuracy = 5
	fire_delay = 3
	burst_amount = 3
	burst_delay = 1
	var/shells_fired_max = 20 //Smartgun only; once you fire # of shells, it will attempt to reload automatically. If you start the reload, the counter resets.
	var/shells_fired_now = 0 //The actual counter used. shells_fired_max is what it is compared to.
//	var/restriction_toggled = 1 //Begin with the safety on.
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_INTERNAL_MAG


	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 16,"rail_x" = 17, "rail_y" = 19, "under_x" = 22, "under_y" = 14)

	examine()
		..()

		if(current_mag.current_rounds) usr << "Ammo counter shows [current_mag.current_rounds] round\s remaining."
		else usr << "It's dry."

//		usr << "The restriction system is [restriction_toggled ? "<B>on</b>" : "<B>off</b>"]."

/*
/obj/item/weapon/gun/smartgun/proc/toggle_restriction(var/mob/user as mob) //Works like reloading the gun. We don't actually change the ammo though.
	user << "\icon[src] You [restriction_toggled ? "<B>disable</b>" : "<B>enable</b>"] the [src]'s fire restriction. You will [restriction_toggled ? "harm anyone in your way" : "not harm allies"]."
	playsound(src.loc,'sound/machines/click.ogg', 50, 1)
	if(restriction_toggled)
		ammo.damage = 33
		ammo.skips_marines = 0
		ammo.armor_pen = 10
	else
		ammo.damage = 28
		ammo.skips_marines = 1
		ammo.armor_pen = 5
	restriction_toggled = !restriction_toggled
	return
*/
	unique_action(mob/user)
//		toggle_restriction(user)
		return

	able_to_fire(mob/user)
		if(!ishuman(user)) return
		var/mob/living/carbon/human/smart_gunner = user
		if( !istype(smart_gunner.wear_suit,/obj/item/clothing/suit/storage/smartgunner) || !istype(smart_gunner.back,/obj/item/smartgun_powerpack))
			click_empty(smart_gunner)
			return
		return ..()

	load_into_chamber(mob/user)
		if(active_attachable) active_attachable = null
		return ready_in_chamber()

	reload_into_chamber(mob/user)
		var/mob/living/carbon/human/smart_gunner = user
		var/obj/item/smartgun_powerpack/power_pack = smart_gunner.back
		if(power_pack) //I don't know how it would break, but it is possible.
			if(shells_fired_now >= shells_fired_max && power_pack.rounds_remaining > 0) // If shells fired exceeds shells needed to reload, and we have ammo.
				auto_reload(smart_gunner, power_pack)
			else shells_fired_now++

		return current_mag.current_rounds

	delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) current_mag.current_rounds++
		return 1

	reload()
		return

	unload()
		return

	make_casing()
		return

/obj/item/weapon/gun/smartgun/proc/auto_reload(mob/smart_gunner, var/obj/item/smartgun_powerpack/power_pack)
	set waitfor = 0
	sleep(5)
	if(power_pack && power_pack.loc)
		power_pack.attack_self(smart_gunner)

/obj/item/ammo_magazine/internal/smartgun/dirty
	default_ammo = "irradiated smartgun bullet"
	gun_type = /obj/item/weapon/gun/smartgun/dirty

//Cannot be upgraded.
/obj/item/weapon/gun/smartgun/dirty
	name = "\improper M57D 'dirty' smartgun"
	desc = "The actual firearm in the 4-piece M57D Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way. Otherwise identical to the M56."
	origin_tech = "combat=7;materials=5"
//	restriction_toggled = 0
	mag_type = /obj/item/ammo_magazine/internal/smartgun/dirty
	accuracy = 10 //Slightly more accurate.
	gun_features = GUN_INTERNAL_MAG | GUN_WY_RESTRICTED


	unique_action() //Cannot toggle restrictions. It has none.
		return

//-------------------------------------------------------
//GRENADE LAUNCHER

/obj/item/weapon/gun/m92
	name = "\improper M92 grenade launcher"
	desc = "A heavy, 5-shot grenade launcher used by the Colonial Marines for area denial and big explosions."
	icon_state = "m92"
	icon_wielded = "riotgun"
	item_state = "riotgun" //Ugh replace this plz
	origin_tech = "combat=5;materials=5"
	matter = list("metal" = 80000)
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	fire_sound = 'sound/weapons/armbomb.ogg'
	cocked_sound = 'sound/weapons/grenadelaunch.ogg'
	fire_delay = 22
	var/list/grenades = new/list()
	var/max_grenades = 6
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_UNUSUAL_DESIGN

	New()
		set waitfor = 0
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14)
		sleep(1)
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
			usr << "\blue It is loaded with <b>[grenades.len] / [max_grenades]</b> grenades."

	attackby(var/obj/item/I, var/mob/user)
		if((istype(I, /obj/item/weapon/grenade)))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "<span class='notice'>You put \the [I] in the grenade launcher.</span>"
				user << "<span class='info'>Now storing: [grenades.len] / [max_grenades] grenades.</span>"
			else
				user << "<span class='warning'>The grenade launcher cannot hold more grenades!</span>"

		else if(istype(I,/obj/item/attachable))
			if(check_inactive_hand(user)) attach_to_gun(user,I)

	afterattack(atom/target, mob/user , flag)
		if(able_to_fire(user))
			if(get_dist(target,user) <= 2)
				user << "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>"
				return
			if(grenades.len)
				fire_grenade(target,user)
				playsound(user.loc, cocked_sound, 50, 1)
			else user << "<span class='warning'>The grenade launcher is empty.</span>"

/obj/item/weapon/gun/m92/proc/fire_grenade(atom/target, mob/user)
	set waitfor = 0
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("\red [] fired a grenade!", user), 1)
	user << "<span class='warning'>You fire the grenade launcher!</span>"
	var/obj/item/weapon/grenade/F = grenades[1]
	grenades -= F
	F.loc = user.loc
	F.throw_range = 20
	F.throw_at(target, 20, 2, user)
	if(F && F.loc) //Apparently it can get deleted before the next thing takes place, so it run times.
		message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from \a ([name]).")
		log_game("[key_name_admin(user)] used a grenade ([name]).")
		F.icon_state = initial(F.icon_state) + "_active"
		F.active = 1
		F.updateicon()
		playsound(F.loc, fire_sound, 50, 1)
		sleep(10)
		if(F && F.loc) F.prime()

/obj/item/weapon/gun/m92
	//Doesn't use most of any of these. Listed for reference.
	load_into_chamber()
		return

	reload_into_chamber()
		return

	reload()
		return

	unload(var/mob/user)
		if(grenades.len)
			var/obj/item/weapon/grenade/nade = grenades[grenades.len] //Grab the last one.
			if(user)
				user.put_in_hands(nade)
				playsound(user, unload_sound, 20, 1)
			else nade.loc = get_turf(src)
			grenades -= nade
		else user << "<span class='warning'>It's empty!</span>"

	make_casing()
		return

//-------------------------------------------------------
//SADAR

/obj/item/ammo_magazine/rocket
	name = "high explosive rocket"
	desc = "A rocket tube for an M83 SADAR rocket. Activate it without a missile inside to receive some materials."
	caliber = "rocket"
	icon_state = "rocket_tube"
	icon_empty = "rocket_tube_empty"
	origin_tech = "combat=3;materials=3"
	matter = list("metal" = 100000)
	w_class = 3.0
	max_rounds = 1
	default_ammo = "high explosive rocket"
	gun_type = /obj/item/weapon/gun/rocketlauncher

	attack_self(mob/user as mob)
		if(current_rounds <= 0)
			user << "<span class='notice'>You begin taking apart the empty tube frame...</span>"
			if(do_after(user,10))
				user.visible_message("[user] deconstructs the rocket tube frame.","<span class='notice'>You take apart the empty frame.</span>")
				var/obj/item/stack/sheet/metal/M = new(get_turf(user))
				M.amount = 2
				user.drop_item(src)
				cdel(src)
		else user << "Not with a missile inside!"

	update_icon()
		..()
		if(current_rounds <= 0) name = "Empty Rocket Frame"

/obj/item/ammo_magazine/rocket/ap
	name = "anti-tank rocket"
	icon_state = "rocket_tube_ap"
	default_ammo = "anti-armor rocket"
	desc = "A tube for an AP rocket - the warhead of which is extremely dense and turns molten on impact. When empty, use this frame to deconstruct it."

/obj/item/ammo_magazine/rocket/wp
	name = "phosphorous rocket"
	icon_state = "rocket_tube_wp"
	default_ammo = "white phosphorous rocket"
	desc = "A highly destructive warhead that bursts into deadly flames on impact. Use this in hand to deconstruct it."

/obj/item/ammo_magazine/internal/rocket
	name = "internal tube"
	desc = "The internal tube of a M83 SADAR."
	caliber = "rocket"
	default_ammo = "high explosive rocket"
	max_rounds = 1
	reload_delay = 60

/obj/item/weapon/gun/rocketlauncher
	name = "\improper M83 SADAR rocket launcher"
	desc = "The M83 SADAR is the primary anti-armor weapon of the USCM. Used to take out light-tanks and enemy structures, the SADAR is a dangerous weapon with a variety of combat uses."
	icon_state = "M83sadar"
	item_state = "rocket"
	icon_wielded = "rocket"
	origin_tech = "combat=6;materials=5"
	matter = list("metal" = 100000)
	mag_type = /obj/item/ammo_magazine/internal/rocket
	slot_flags = 0
	w_class = 5
	force = 15
	fire_delay = 10
	recoil = 3
	flags = FPRINT | CONDUCT | TWOHANDED
	gun_features = GUN_INTERNAL_MAG
	var/datum/effect/effect/system/smoke_spread/puff

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14)
		puff = new /datum/effect/effect/system/smoke_spread()
		puff.attach(src)

	examine()
		..()

		if(current_mag.current_rounds)  usr << "It's ready to rocket."
		else 							usr << "It's empty."


	able_to_fire(mob/user)
		if(user)
			var/turf/current_turf = get_turf(user)
			if(current_turf.z == 3 || current_turf.z == 4) //Can't fire on the Sulaco, bub.
				click_empty(user)
				user << "<span class='warning'>You can't fire that here!</span>"
				return
		return ..()

	load_into_chamber(mob/user)
		if(active_attachable) active_attachable = null
		return ready_in_chamber()

	reload_into_chamber(mob/user)
		set waitfor = 0
		sleep(1)
		var/smoke_dir = user.dir
		if(user)
			switch(smoke_dir) //We want the opposite of their direction.
				if(2,8)
					smoke_dir /= 2
				if(1,4)
					smoke_dir *= 2
		puff.set_up(1,,,smoke_dir)
		puff.start()
		return 1

	delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
		cdel(projectile_to_fire)
		if(refund) current_mag.current_rounds++
		return 1

	reload(mob/user = null, var/obj/item/ammo_magazine/rocket)
		if(!rocket || !istype(rocket) || rocket.caliber != current_mag.caliber)
			user << "<span class='warning'>That's not going to fit!</span>"
			return

		if(current_mag.current_rounds > 0)
			user << "<span class='warning'>\The [src] is already loaded!</span>"
			return

		if(rocket.current_rounds <= 0)
			user << "<span class='warning'>That frame is empty!</span>"
			return

		if(user)
			user << "<span class='notice'>You begin reloading \the [src]. Hold still...</span>"
			if(do_after(user,current_mag.reload_delay))
				user.remove_from_mob(rocket)
				replace_ammo(user,rocket)
				current_mag.current_rounds = current_mag.max_rounds
				rocket.current_rounds = 0
				user << "<span class='notice'>You load \the [rocket] into \the [src].</span>"
				if(reload_sound) playsound(user, reload_sound, 100, 1)
				else playsound(user,'sound/machines/click.ogg', 100, 1)
			else
				user << "<span class='warning'>Your reload was interrupted!</span>"
				return
		else
			rocket.loc = get_turf(src)
			replace_ammo(,rocket)
			current_mag.current_rounds = current_mag.max_rounds
			rocket.current_rounds = 0
		rocket.update_icon()
		update_icon()
		return 1

	unload(mob/user)
		if(user)
			if(!current_mag.current_rounds) user << "<span class='warning'>\The [src] is already empty!</span>"
			else 							user << "<span class='warning'>It would be too much trouble to unload \the [src] now. Should have thought ahead!</span>"

	make_casing()
		return

//-------------------------------------------------------
//SADARS MEAN FUCKING COUSIN

/obj/item/ammo_magazine/rocket/quad
	name = "thermobaric rocket array"
	desc = "A thermobaric rocket tube for an M83AM quad launcher. Activate in hand to receive some metal when it's used up."
	caliber = "rocket array"
	icon_state = "rocket_tube4"
	icon_empty = "rocket_tube_empty4"
	origin_tech = "combat=4;materials=4"
	max_rounds = 4
	default_ammo = "thermobaric rocket"
	gun_type = /obj/item/weapon/gun/rocketlauncher/quad
	reload_delay = 200

/obj/item/ammo_magazine/internal/rocket/quad
	desc = "The internal tube of an M83AM Thermobaric Launcher."
	caliber = "rocket array"
	default_ammo = "thermobaric rocket"
	max_rounds = 4

/obj/item/weapon/gun/rocketlauncher/quad
	name = "\improper M83AM thermobaric launcher"
	desc = "The M83AM is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "quaddar"
	item_state = "rocket4"
	icon_wielded = "rocket4"
	origin_tech = "combat=7;materials=5"
	mag_type = /obj/item/ammo_magazine/internal/rocket/quad
	fire_delay = 6
	burst_amount = 4
	burst_delay = 4
	accuracy = -20
	gun_features = GUN_INTERNAL_MAG | GUN_WY_RESTRICTED
