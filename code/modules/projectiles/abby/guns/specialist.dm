//-------------------------------------------------------
//SNIPER RIFLES

/obj/item/ammo_magazine/sniper
	name = "M42A Scoped Rifle Magazine (.50)"
	desc = "A magazine of sniper rifle ammo."
	icon_state = "75"
	icon_empty = "75-0"
	max_rounds = 7
	default_ammo = "/datum/ammo/bullet/sniper"
	gun_type = "/obj/item/weapon/gun/sniper"
	reload_delay = 3

/obj/item/ammo_magazine/sniper/incendiary
	name = "M42A Incendiary Magazine (.50)"
	default_ammo = "/datum/ammo/bullet/sniper/incendiary"

/obj/item/ammo_magazine/sniper/flak
	name = "M42A Flak Magazine (.50)"
	default_ammo = "/datum/ammo/bullet/sniper/flak"
	icon_state = "a762"
	icon_empty = "a762-0"

//Pow! Headshot.
/obj/item/weapon/gun/sniper
	name = "\improper M42A Scoped Rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 7-round magazine.\n'Peace Through Superior Firepower'"
	icon_state = "M42c"
	icon_empty = "M42c_empty"
	item_state = "m42a"  //placeholder!!
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	mag_type = "/obj/item/ammo_magazine/sniper"
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
		S.Attach(src)
		var/obj/item/attachable/sniperbarrel/Q = new(src)
		Q.Attach(src)
		update_attachables()

/obj/item/ammo_magazine/sniper/elite
	name = "M42C Magazine (.75)"
	default_ammo = "/datum/ammo/bullet/sniper/elite"
	gun_type = "/obj/item/weapon/gun/sniper/elite"
	max_rounds = 9

/obj/item/weapon/gun/sniper/elite
	name = "\improper M42C Anti-Tank Sniper Rifle"
	desc = "A high end mag-rail heavy sniper rifle from Weyland-Armat chambered in the heaviest ammo available, .75 AP."
	icon_state = "pmcM42c"
	icon_empty = "pmcM42c_empty"
	item_state = "m42a"  //placeholder!!
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
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
		var/obj/item/attachable/scope/S = new(src)
		if(S)
			S.icon_state = "pmcscope"
			S.Attach(src)
			update_attachables()

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
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 50
	default_ammo = "/datum/ammo/bullet/smartgun"
	gun_type = "/obj/item/weapon/gun/smartgun"

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper M56 Smartgun"
	desc = "The actual firearm in the 4-piece M56 Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a Powerpack. Click the powerpack icon in the top left to reload."
	icon_state = "m56"
	item_state = "m56"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	mag_type = "/obj/item/ammo_magazine/smartgun_integrated"
	w_class = 5.0
	force = 20.0
	twohanded = 1
	recoil = 0
	fire_delay = 3
	muzzle_pixel_x = 33
	muzzle_pixel_y = 16
	rail_pixel_x = 18
	rail_pixel_y = 18
	under_pixel_x = 22
	under_pixel_y = 14
	burst_amount = 3
	burst_delay = 1
	autoejector = 0
	slot_flags = 0
	accuracy = 5

	attackby(obj/item/I as obj, mob/user as mob)
		if(!istype(I,/obj/item/attachable)) //Don't allow reloading by clicking it somehow.
			return
		return ..()

	unload(var/mob/user as mob)
		if(user) user << "The smartgun has an integrated ammo feed and cannot be unloaded."
		return

	Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, atom/original_target as mob|obj|turf)
		if(!istype(user,/mob/living/carbon/human)) return 0
		if(istype(user:wear_suit,/obj/item/clothing/suit/storage/marine_smartgun_armor) && istype(user:back,/obj/item/smartgun_powerpack))
			return ..()

		user << "\blue *click*"
		return 0

//-------------------------------------------------------
//SADAR

/obj/item/ammo_magazine/rocket_tube
	name = "High Explosive Rocket Tube"
	desc = "A rocket tube for an M83 SADAR rocket. Activate it without a missile inside to receive some materials."
	icon_state = "rocket_tube"
	icon_empty = "rocket_tube_empty"
	max_rounds = 1
	default_ammo = "/datum/ammo/rocket"
	gun_type = "/obj/item/weapon/gun/rocketlauncher"
	reload_delay = 60

	attack_self(mob/living/user as mob)
		if(current_rounds == 0)
			user << "You begin taking apart the empty tube frame.."
			if(do_after(user,10))
				user.visible_message("[user] deconstructs the rocket tube frame.","You take apart the empty frame!")
				var/obj/item/stack/sheet/metal/M = new()
				M.amount = 2
				user.drop_item(src)
				del(src)
				return
		else
			user << "Not with a missile inside!"
			return

/obj/item/ammo_magazine/rocket_tube/ap
	name = "Anti Tank Rocket Tube"
	icon_state = "rocket_tube_ap"
	default_ammo = "/datum/ammo/rocket/ap"
	desc = "A tube for an AP rocket - the warhead of which is extremely dense and turns molten on impact. When empty, use this frame to deconstruct it."

/obj/item/ammo_magazine/rocket_tube/wp
	name = "Phosphorous Rocket Tube"
	icon_state = "rocket_tube_wp"
	default_ammo = "/datum/ammo/rocket/wp"
	desc = "A highly destructive warhead that bursts into deadly flames on impact. Use this in hand to deconstruct it."


/obj/item/weapon/gun/rocketlauncher
	name = "M83 SADAR rocket launcher"
	desc = "The M83 SADAR is the primary anti-armor weapon of the USCM. Used to take out light-tanks and enemy structures, the SADAR is a dangerous weapon with a variety of combat uses."
	icon_state = "M83sadar"
	item_state = "rocket"
	icon_wielded = "rocket"
	w_class = 5.0
	fire_delay = 10
	force = 15.0
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = 0
	twohanded = 1
	mag_type = "/obj/item/ammo_magazine/rocket_tube"
	recoil = 3
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 12
	rail_pixel_y = 18
	under_pixel_x = 30
	under_pixel_y = 14
	var/datum/effect/effect/system/smoke_spread/puff

	New()
		..()
		puff = new /datum/effect/effect/system/smoke_spread()
		puff.attach(src)

	load_into_chamber()
		if(current_mag && current_mag.current_rounds > 0)
			sleep(1)
			var/list/cardinals = list(1,2,4,8)
			for(var/Q in cardinals)
				if(Q == usr.dir)
					cardinals -= Q //Shouldnt puff back into their face.
					break
			puff.set_up(1,cardinals)
			puff.start()
			return ..()


//-------------------------------------------------------
//SADARS MEAN FUCKING COUSIN

/obj/item/ammo_magazine/rocket_tube/quad
	name = "Thermobaric Rocket Array"
	desc = "A thermobaric rocket tube for an M83AM quad launcher. Activate in hand to receive some metal when it's used up."
	icon_state = "rocket_tube4"
	icon_empty = "rocket_tube_empty4"
	max_rounds = 4
	default_ammo = "/datum/ammo/rocket/wp/quad"
	gun_type = "/obj/item/weapon/gun/quadlauncher"
	reload_delay = 200

/obj/item/weapon/gun/rocketlauncher/quad
	name = "M83AM Thermobaric Launcher"
	desc = "The M83AM is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "quaddar"
	item_state = "rocket4"
	icon_wielded = "rocket4"
	fire_delay = 6
	burst_amount = 4
	burst_delay = 4
	accuracy = -20

