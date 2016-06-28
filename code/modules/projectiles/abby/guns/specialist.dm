//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

/obj/item/ammo_magazine/sniper
	name = "M42A Scoped Rifle Magazine (10×28mm Caseless)"
	desc = "A magazine of sniper rifle ammo."
	caliber = "10×28mm Caseless"
	icon_state = "75"
	icon_empty = "75-0"
	max_rounds = 7
	default_ammo = "/datum/ammo/bullet/sniper"
	gun_type = "/obj/item/weapon/gun/rifle/sniper"
	handful_type = "Bullets (10×28mm Caseless)"
	reload_delay = 3

/obj/item/ammo_magazine/sniper/incendiary
	name = "M42A Incendiary Magazine (10×28mm Caseless)"
	default_ammo = "/datum/ammo/bullet/sniper/incendiary"
	handful_type = "Incendiary Bullets (10×28mm Caseless)"

/obj/item/ammo_magazine/sniper/flak
	name = "M42A Flak Magazine (10×28mm Caseless)"
	default_ammo = "/datum/ammo/bullet/sniper/flak"
	handful_type = "Flak Bullets (10×28mm Caseless)"
	icon_state = "a762"
	icon_empty = "a762-0"

//Pow! Headshot.
/obj/item/weapon/gun/rifle/sniper
	name = "\improper M42A Scoped Rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 7-round magazine.\n'Peace Through Superior Firepower'"
	icon_state = "M42c"
	icon_empty = "M42c_empty"
	item_state = "m42a"  //placeholder!!
	origin_tech = "combat=6;materials=5"
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	can_pointblank = 0 //Cannot pointblank, too big.
	mag_type = "/obj/item/ammo_magazine/sniper"
	burst_amount = 1 //Fix so the sniper scopes don't set burst fire to -1 ~N
	fire_delay = 60
	w_class = 4.0
	force = 12
	recoil = 1
	twohanded = 1
	zoomdevicename = "scope"
	slot_flags = SLOT_BACK
	muzzle_pixel_x = 33
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 20
	under_pixel_x = 19
	under_pixel_y = 14
	accuracy = 10

	New()
		..()
		var/obj/item/attachable/scope/S = new(src)
		S.icon_state = "" //Let's make it invisible. The sprite already has one.
		S.can_be_removed = 0
		S.Attach(src)
		var/obj/item/attachable/sniperbarrel/Q = new(src)
		Q.Attach(src)
		update_attachables()

/obj/item/ammo_magazine/sniper/elite
	name = "M42C Magazine (12.7×99mm Caseless)"
	default_ammo = "/datum/ammo/bullet/sniper/elite"
	gun_type = "/obj/item/weapon/gun/rifle/sniper/elite"
	caliber = ".50 Caseless"
	max_rounds = 9
	handful_type = "Bullets (12.7×99mm Caseless)"

/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C Anti-Tank Sniper Rifle"
	desc = "A high end mag-rail heavy sniper rifle from Weyland-Armat chambered in the heaviest ammo available, .75 AP."
	icon_state = "pmcM42c"
	icon_empty = "pmcM42c_empty"
	item_state = "m42a"  //placeholder!!
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/sniper_heavy.ogg'
	mag_type = "/obj/item/ammo_magazine/sniper/elite"
	fire_delay = 90
	w_class = 5.0
	force = 17
	recoil = 10
	twohanded = 1
	zoomdevicename = "scope"
	slot_flags = SLOT_BACK
	muzzle_pixel_x = 32
	muzzle_pixel_y = 18
	rail_pixel_x = 15
	rail_pixel_y = 19
	under_pixel_x = 20
	under_pixel_y = 15

	New()
		..()
		if(rail)
			rail.icon_state = "pmcscope"

	afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
		..()
		if(istype(user,/mob/living/carbon/human))
			if(user.lying == 0 && !istype(user:wear_suit,/obj/item/clothing/suit/storage/marine/PMCarmor/commando) && !istype(user:wear_suit,/obj/item/clothing/suit/storage/marine/PMCarmor))
				user.visible_message("[user] is blown backwards from the recoil of the [src]!")
				user.Weaken(5)

//-------------------------------------------------------
//SMARTGUN
/obj/item/ammo_magazine/smartgun_integrated
	name = "Integrated Smartgun Belt"
	caliber = "10×28mm Caseless"
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 50
	default_ammo = "/datum/ammo/bullet/smartgun"
	gun_type = "/obj/item/weapon/gun/smartgun"
	handful_type = "Bullets (10×28mm Caseless)"

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper M56 Smartgun"
	desc = "The actual firearm in the 4-piece M56 Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a Powerpack. Click the powerpack icon in the top left to reload."
	icon_state = "m56"
	item_state = "m56"
	origin_tech = "combat=6;materials=5"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	can_pointblank = 0 //Cannot pointblank, too big.
	mag_type_internal = "/obj/item/ammo_magazine/smartgun_integrated"
	w_class = 5.0
	force = 20.0
	twohanded = 1
	recoil = 0
	fire_delay = 3
	muzzle_pixel_x = 33
	muzzle_pixel_y = 16
	rail_pixel_x = 17
	rail_pixel_y = 19
	under_pixel_x = 22
	under_pixel_y = 14
	burst_amount = 3
	burst_delay = 1
	autoejector = 0
	slot_flags = 0
	accuracy = 5
	var/shells_fired_max = 20 //Smartgun only; once you fire # of shells, it will attempt to reload automatically. If you start the reload, the counter resets.
	var/shells_fired_now = 0 //The actual counter used. shells_fired_max is what it is compared to.
//	var/restriction_toggled = 1 //Begin with the safety on.

	examine()
		..()

		if(current_mag.current_rounds)
			usr << "Ammo counter shows [current_mag.current_rounds] round\s remaining."
		else
			usr << "It's dry."
//		usr << "The restriction system is [restriction_toggled ? "<B>on</b>" : "<B>off</b>"]."

/*
	proc/toggle_restriction(var/mob/user as mob) //Works like reloading the gun. We don't actually change the ammo though.
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
	unique_action(var/mob/living/carbon/human/user as mob)
//		toggle_restriction(user)
		return

	able_to_fire(var/mob/user as mob)
		if(!ishuman(user)) return
		var/mob/living/carbon/human/smart_gunner = user
		if( !istype(smart_gunner.wear_suit,/obj/item/clothing/suit/storage/marine_smartgun_armor) || !istype(smart_gunner.back,/obj/item/smartgun_powerpack))
			click_empty(user)
			return
		return ..()

	load_into_chamber()
		if(active_attachable)
			active_attachable = null

		return ready_in_chamber()

	reload_into_chamber(var/mob/user as mob)
		var/mob/living/carbon/human/smart_gunner = user
		var/obj/item/smartgun_powerpack/power_pack = smart_gunner.back
		if(shells_fired_now >= shells_fired_max && power_pack.rounds_remaining > 0) // If shells fired exceeds shells needed to reload, and we have ammo.
			spawn(1)
				power_pack.attack_self(smart_gunner)
		else
			shells_fired_now++
		return current_mag.current_rounds

	delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
		del(projectile_to_fire)
		if(refund)
			current_mag.current_rounds++
		return 1

	reload()
		return

	unload()
		return

	make_casing()
		return

/obj/item/ammo_magazine/smartgun_integrated/dirty
	default_ammo = "/datum/ammo/bullet/smartgun/dirty"
	gun_type = "/obj/item/weapon/gun/smartgun/dirty"

//Cannot be upgraded.
/obj/item/weapon/gun/smartgun/dirty
	name = "\improper M57D 'Dirty' Smartgun"
	desc = "The actual firearm in the 4-piece M57D Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way. Otherwise identical to the M56."
	origin_tech = "combat=7;materials=5"
//	restriction_toggled = 0
	mag_type_internal = "/obj/item/ammo_magazine/smartgun_integrated/dirty"
	accuracy = 10 //Slightly more accurate.

	unique_action() //Cannot toggle restrictions. It has none.
		return

//-------------------------------------------------------
//SADAR

/obj/item/ammo_magazine/rocket_tube
	name = "High Explosive Rocket"
	desc = "A rocket tube for an M83 SADAR rocket. Activate it without a missile inside to receive some materials."
	caliber = "rocket"
	caliber_type = "rocket"
	icon_state = "rocket_tube"
	icon_empty = "rocket_tube_empty"
	origin_tech = "combat=3;materials=3"
	matter = list("metal" = 100000)
	w_class = 3.0
	max_rounds = 1
	default_ammo = "/datum/ammo/rocket"
	gun_type = "/obj/item/weapon/gun/rocketlauncher"
	reload_delay = 60

	attack_self(mob/living/user as mob)
		if(current_rounds <= 0)
			user << "You begin taking apart the empty tube frame..."
			if(do_after(user,10))
				user.visible_message("[user] deconstructs the rocket tube frame.","You take apart the empty frame!")
				var/obj/item/stack/sheet/metal/M = new(get_turf(user))
				M.amount = 2
				user.drop_item(src)
				del(src)
				return
		else
			user << "Not with a missile inside!"
			return

	update_icon()
		..()
		if(current_rounds <= 0) name = "Empty Rocket Frame"

/obj/item/ammo_magazine/rocket_tube/ap
	name = "Anti Tank Rocket"
	icon_state = "rocket_tube_ap"
	default_ammo = "/datum/ammo/rocket/ap"
	desc = "A tube for an AP rocket - the warhead of which is extremely dense and turns molten on impact. When empty, use this frame to deconstruct it."

/obj/item/ammo_magazine/rocket_tube/wp
	name = "Phosphorous Rocket"
	icon_state = "rocket_tube_wp"
	default_ammo = "/datum/ammo/rocket/wp"
	desc = "A highly destructive warhead that bursts into deadly flames on impact. Use this in hand to deconstruct it."


/obj/item/ammo_magazine/rocket_tube/internal
	name = "Internal Tube"
	desc = "The internal tube of a M83 SADAR."

/obj/item/weapon/gun/rocketlauncher
	name = "M83 SADAR rocket launcher"
	desc = "The M83 SADAR is the primary anti-armor weapon of the USCM. Used to take out light-tanks and enemy structures, the SADAR is a dangerous weapon with a variety of combat uses."
	icon_state = "M83sadar"
	item_state = "rocket"
	icon_wielded = "rocket"
	can_pointblank = 0 //Cannot pointblank, too big.
	origin_tech = "combat=6;materials=5"
	matter = list("metal" = 100000)
	w_class = 5.0
	fire_delay = 10
	force = 15.0
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = 0
	twohanded = 1
	mag_type_internal = "/obj/item/ammo_magazine/rocket_tube/internal"
	recoil = 3
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 12
	rail_pixel_y = 18
	under_pixel_x = 30
	under_pixel_y = 14
	can_pointblank = 0
	var/datum/effect/effect/system/smoke_spread/puff

	New()
		..()
		puff = new /datum/effect/effect/system/smoke_spread()
		puff.attach(src)

	examine()
		..()

		if(current_mag.current_rounds)
			usr << "It's ready to rocket."
		else
			usr << "It's empty."

	able_to_fire(var/mob/user as mob)
		if(user)
			var/turf/current_turf = get_turf(user)
			if(current_turf.z == 3 || current_turf.z == 4) //Can't fire on the Sulaco, bub.
				click_empty(user)
				user << "\red You can't fire that here!"
				return
		return ..()

	load_into_chamber()
		if(active_attachable)
			active_attachable = null

		return ready_in_chamber()

	reload_into_chamber(var/mob/user as mob)
		sleep(1)
		var/directions = pick(1,2,4,8)
		var/direct[] = list()
		if(user)
			switch(user.dir) //We want the opposite of their direction.
				if(2,8)
					directions = user.dir / 2
				if(1,4)
					directions = user.dir * 2
		direct += directions
		puff.set_up(1,direct)
		puff.start()
		return 1

	delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
		del(projectile_to_fire)
		if(refund)
			current_mag.current_rounds++
		return 1

	reload(var/mob/user = null, var/obj/item/ammo_magazine/rocket)
		if(!rocket || !istype(rocket) || rocket.caliber != current_mag.caliber)
			if(user) user << "That's not going to fit!"
			return

		if(current_mag.current_rounds > 0)
			if(user) user << "\The [src] is already loaded!"
			return

		if(rocket.current_rounds <= 0)
			if(user) user << "That frame is empty!"
			return

		if(user)
			var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
			if( in_hand != src ) //It has to be held.
				user << "You have to hold \the [src] to reload!"
				return

		if(user)
			user << "You begin reloading \the [src]. Hold still!"
			if(do_after(user,current_mag.reload_delay))
				user.drop_from_inventory(rocket)
				replace_ammo(user,rocket)
				current_mag.current_rounds = current_mag.max_rounds
				rocket.current_rounds = 0
				user << "\blue You load \the [rocket] into \the [src]!"
				if(reload_sound)
					playsound(user, reload_sound, 100, 1)
				else
					playsound(user,'sound/machines/click.ogg', 100, 1)
			else
				user << "Your reload was interrupted."
				return
		else
			rocket.loc = get_turf(src)
			replace_ammo(,rocket)
			current_mag.current_rounds = current_mag.max_rounds
			rocket.current_rounds = 0
		rocket.update_icon()

	unload(var/mob/user as mob)
		if(user)
			if(!current_mag.current_rounds)
				user << "\The [src] is already empty."
			else
				user << "It would be too much trouble to unload \the [src] now. Should have thought ahead!"
		return

	make_casing()
		return

//-------------------------------------------------------
//SADARS MEAN FUCKING COUSIN

/obj/item/ammo_magazine/rocket_tube/quad
	name = "Thermobaric Rocket Array"
	desc = "A thermobaric rocket tube for an M83AM quad launcher. Activate in hand to receive some metal when it's used up."
	caliber = "rocket array"
	icon_state = "rocket_tube4"
	icon_empty = "rocket_tube_empty4"
	origin_tech = "combat=4;materials=4"
	max_rounds = 4
	default_ammo = "/datum/ammo/rocket/wp/quad"
	gun_type = "/obj/item/weapon/gun/rocketlauncher/quad"
	reload_delay = 200

/obj/item/ammo_magazine/rocket_tube/quad/internal
	name = "Internal Tube"
	desc = "The internal tube of an M83AM Thermobaric Launcher."

/obj/item/weapon/gun/rocketlauncher/quad
	name = "M83AM Thermobaric Launcher"
	desc = "The M83AM is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "quaddar"
	item_state = "rocket4"
	icon_wielded = "rocket4"
	origin_tech = "combat=7;materials=5"
	mag_type_internal = "/obj/item/ammo_magazine/rocket_tube/quad/internal"
	w_class = 4.0
	fire_delay = 6
	burst_amount = 4
	burst_delay = 4
	accuracy = -20

