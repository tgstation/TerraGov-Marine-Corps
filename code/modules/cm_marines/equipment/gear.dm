
/**********************Marine Gear**************************/

//MARINE COMBAT LIGHT

/obj/item/device/flashlight/combat
	name = "combat flashlight"
	desc = "A Flashlight designed to be held in the hand, or attached to a rifle"
	icon_state = "flashlight"
	item_state = "flashlight"
	var/attachable = 0  //Can this be attached to another weapon or device?
	brightness_on = 5 //Pretty luminous, but still a flashlight that fits in a pocket

/obj/item/device/flashlight/combat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(attachable)
			attachable = 0
			usr << "\red You screw the side panel on [src] closed. It can no longer be attached!"
		else if(!attachable)
			attachable = 1
			usr << "\red You screw open the side panel on [src], which can now be attached!"
	return

//MARINE SNIPER TARPS

/obj/item/bodybag/tarp
	name = "\improper V1 thermal-dapening tarp (folded)"
	desc = "A tarp carried by USCM Snipers. When laying underneath the tarp, the sniper is almost indistinguishable from the landscape if utilized correctly. The tarp contains a thermal-dampening weave to hide the wearer's heat signatures, optical camoflauge, and smell dampening."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "jungletarp_folded"
	w_class = 3.0
	unfolded_path = /obj/structure/closet/bodybag/tarp



/obj/item/bodybag/tarp/snow
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "snowtarp_folded"
	unfolded_path = /obj/structure/closet/bodybag/tarp/snow

/obj/structure/closet/bodybag/tarp
	name = "\improper V1 thermal-dampening tarp"
	desc = "A tarp carried by USCM Snipers. When laying underneath the tarp, the sniper is almost indistinguishable from the landscape if utilized correctly. The tarp contains a thermal-dampening weave to hide the wearer's heat signatures, optical camouflage, and smell dampening."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "jungletarp_closed"
	icon_closed = "jungletarp_closed"
	icon_opened = "jungletarp_open"
	open_sound = 'sound/effects/vegetation_walk_1.ogg'
	close_sound = 'sound/effects/vegetation_walk_2.ogg'
	item_path = /obj/item/bodybag/tarp
	anchored = 1

/obj/structure/closet/bodybag/tarp/snow
	icon_state = "snowtarp_closed"
	icon_closed = "snowtarp_closed"
	icon_opened = "snowtarp_open"
	item_path = /obj/item/bodybag/tarp/snow

/obj/item/device/squad_tracking_beacon
	name = "\improper Tracking Beacon"
	desc ="A weak transmitter allowing marines to locate their squad over short distances.\nIt is inactive."
	var/base_desc = "A weak transmitter allowing marines to locate their squad over short distances."
	icon_state = "tracking0"
	var/icon_deactivated = "tracking0"
	var/icon_activated = "tracking1"
	var/activated = 0
	w_class = 2
	var/datum/squad/squad = null

	attack_self(mob/user)
		if(activated)
			active_tracking_beacons -= src
			activated = 0
			icon_state = "[icon_deactivated]"
			user << "You deactivate [src]."
			desc = "[base_desc]\nIt is inactive."
			return
		if(!ishuman(user)) return
		if(!user.mind)
			user << "It doesn't seem to do anything for you."
			return

		squad = get_squad_data_from_card(user)

		if(squad == null)
			user << "You need a squad ID to activate this."
			return

		active_tracking_beacons += src
		activated = 1
		icon_state = "[icon_activated]"
		user << "You activate [src]."
		desc = "[base_desc]\nIt is set to Squad [squad.name]."

		for(var/obj/item/device/squad_tracking_beacon/B in active_tracking_beacons)
			if(B.squad == squad && B != src)
				active_tracking_beacons -= B
				B.activated = 0
				B.icon_state = "[icon_deactivated]"
				B.desc = "[base_desc]\nIt is inactive."

				var/turf/T = get_turf(src)
				T.visible_message("[B] shuts off. Looks like a tracking beacon was activated elsewhere with the same squad ID .")
				user << "[src] beeps, indicating that a tracking beacon with the same squad ID elsewhere has been automatically deactivated."

		return

	Dispose()
		if (activated)
			active_tracking_beacons -= src
		. = ..()


//MARINE RADIO

/obj/item/device/radio/marine
	frequency = PUB_FREQ


/obj/item/weapon/storage/box/explosive_mines
	name = "\improper M20 mine box"
	desc = "A secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	w_class = 3
	storage_slots = 4
	can_hold = list(
		"/obj/item/device/mine"
		)

	New()
		..()
		contents = list()
		sleep(1)
		var/I = type == /obj/item/weapon/storage/box/explosive_mines/pmc ? /obj/item/device/mine/pmc : /obj/item/device/mine
		var/i = 0
		while(++i < 5)
			new I(src)

/obj/item/weapon/storage/box/explosive_mines/pmc
	name = "\improper M20P mine box"

/obj/item/weapon/storage/box/m94
	name = "\improper M94 marking flare pouch"
	desc = "A packet of four M94 Marking Flares. Carried by USCM soldiers to light dark areas that cannot be reached with the usual TNR Shoulder Lamp."
	icon_state = "m94"
	w_class = 2
	storage_slots = 4
	can_hold = list(
		"/obj/item/device/flashlight/flare"
		)

	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		return

/obj/item/weapon/coin/marine
	name = "marine specialist weapon token"
	desc = "Insert this into a specialist vendor in order to access a single highly dangerous weapon."
	icon_state = "coin_adamantine"

	attackby(obj/item/weapon/W as obj, mob/user as mob) //To remove attaching a string functionality
		return

/obj/structure/broken_apc
	name = "\improper M577 armored personnel carrier"
	desc = "A large, armored behemoth capable of ferrying marines around. \nThis one is sitting nonfunctional."
	anchored = 1
	opacity = 1
	density = 1
	icon = 'icons/Marine/apc.dmi'
	icon_state = "apc"

//Possibly the most generically named procs in history. congrats
/obj/structure/largecrate/random
	name = "supply crate"
	var/num_things = 0
	var/list/stuff = list(/obj/item/weapon/cell/high,
						/obj/item/weapon/storage/belt/utility/full,
						/obj/item/device/multitool,
						/obj/item/weapon/crowbar,
						/obj/item/device/flashlight,
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/airlock_electronics,
						/obj/item/device/assembly/igniter,
						/obj/item/weapon/weldingtool,
						/obj/item/weapon/wirecutters,
						/obj/item/device/analyzer,
						/obj/item/clothing/under/marine,
						/obj/item/clothing/shoes/marine)

	New()
		spawn(1)
			if(!num_things) num_things = rand(0,3)

			while(num_things)
				if(!num_things)
					break
				num_things--
				var/obj/item/thing = pick(stuff)
				new thing(src)

/obj/structure/largecrate/guns
	name = "\improper USCM firearms crate (x3)"
	var/num_guns = 3
	var/num_mags = 0
	var/list/stuff = list(
					/obj/item/weapon/gun/pistol/m4a3 = /obj/item/ammo_magazine/pistol,
					/obj/item/weapon/gun/pistol/m4a3 = /obj/item/ammo_magazine/pistol,
					/obj/item/weapon/gun/revolver/m44 = /obj/item/ammo_magazine/revolver,
					/obj/item/weapon/gun/rifle/m41a = /obj/item/ammo_magazine/rifle,
					/obj/item/weapon/gun/rifle/m41a = /obj/item/ammo_magazine/rifle,
					/obj/item/weapon/gun/shotgun/pump = /obj/item/ammo_magazine/shotgun,
					/obj/item/weapon/gun/smg/m39 = /obj/item/ammo_magazine/smg/m39,
					/obj/item/weapon/gun/smg/m39 = /obj/item/ammo_magazine/smg/m39,
					/obj/item/weapon/gun/rifle/m41a/scoped = /obj/item/ammo_magazine/rifle/marksman,
					/obj/item/weapon/gun/rifle/lmg = /obj/item/ammo_magazine/rifle/lmg
				)
	New()
		spawn(1)
			var/gun_type
			var/i = 0
			while(++i <= num_guns)
				gun_type = pick(stuff)
				new gun_type(src)
				var/obj/item/ammo_magazine/new_mag = stuff[gun_type]
				var/m = 0
				while(++m <= num_mags)
					new new_mag(src)

/obj/structure/largecrate/guns/russian
	num_guns = 1
	num_mags = 1
	name = "\improper Nagant-Yamasaki firearm crate"
	stuff = list(	/obj/item/weapon/gun/revolver/upp = /obj/item/ammo_magazine/revolver/upp,
					/obj/item/weapon/gun/pistol/c99 = /obj/item/ammo_magazine/pistol/c99,
					/obj/item/weapon/gun/pistol/kt42 = /obj/item/ammo_magazine/pistol/automatic,
					/obj/item/weapon/gun/rifle/mar40 = /obj/item/ammo_magazine/rifle/mar40,
					/obj/item/weapon/gun/rifle/mar40/carbine = /obj/item/ammo_magazine/rifle/mar40/extended,
					/obj/item/weapon/gun/rifle/sniper/svd = /obj/item/ammo_magazine/rifle/sniper/svd,
					/obj/item/weapon/gun/smg/ppsh = /obj/item/ammo_magazine/smg/ppsh
				)

/obj/structure/largecrate/guns/merc
	num_guns = 1
	num_mags = 1
	name = "\improper Black market firearm crate"
	stuff = list(	/obj/item/weapon/gun/pistol/holdout = /obj/item/ammo_magazine/pistol/holdout,
					/obj/item/weapon/gun/pistol/highpower = /obj/item/ammo_magazine/pistol/highpower,
					/obj/item/weapon/gun/pistol/m1911 = /obj/item/ammo_magazine/pistol/m1911,
					/obj/item/weapon/gun/pistol/vp70 = /obj/item/ammo_magazine/pistol/vp70,
					/obj/item/weapon/gun/pistol/heavy = /obj/item/ammo_magazine/pistol/heavy,
					/obj/item/weapon/gun/revolver/small = /obj/item/ammo_magazine/revolver/small,
					/obj/item/weapon/gun/revolver/cmb = /obj/item/ammo_magazine/revolver/cmb,
					/obj/item/weapon/gun/shotgun/merc = /obj/item/ammo_magazine/shotgun,
					/obj/item/weapon/gun/shotgun/pump/cmb = /obj/item/ammo_magazine/shotgun/incendiary,
					/obj/item/weapon/gun/shotgun/double = /obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/weapon/gun/smg/mp7 = /obj/item/ammo_magazine/smg/mp7,
					/obj/item/weapon/gun/smg/skorpion = /obj/item/ammo_magazine/smg/skorpion,
					/obj/item/weapon/gun/smg/uzi = /obj/item/ammo_magazine/smg/uzi,
					/obj/item/weapon/gun/smg/p90 = /obj/item/ammo_magazine/smg/p90
				)

/obj/item/weapon/storage/box/uscm_mre
	name = "\improper USCM meal ready to eat"
	desc = "<B>Instructions:</B> Extract food using maximum firepower. Eat.\n\nOn the box is a picture of a shouting Squad Leader. \n\"YOU WILL EAT YOUR NUTRIENT GOO AND YOU WILL ENJOY IT, MAGGOT.\""
	icon_state = "mre1"

	New()
		..()
		pixel_y = rand(-3,3)
		pixel_x = rand(-3,3)
		for(var/i = 0,i < 5,i++)
			var/rand_type = rand(0,8)
			if(rand_type <= 2)
				new /obj/item/weapon/reagent_containers/food/snacks/protein_pack(src)
			else if(rand_type == 3)
				new /obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1(src)
			else if(rand_type == 4)
				new /obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2(src)
			else if(rand_type == 5)
				new /obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3(src)
			else if(rand_type == 6)
				new /obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4(src)
			else if(rand_type == 7)
				new /obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5(src)
			else if(rand_type == 8)
				new /obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6(src)


/obj/item/weapon/reagent_containers/food/snacks/protein_pack
	name = "stale USCM protein bar"
	desc = "The most fake looking protein bar you have ever laid eyes on, covered in the a subtitution chocolate. The powder used to make these is a subsitute of a substitute of whey substitute."
	icon_state = "yummers"
	filling_color = "#ED1169"

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 4

/obj/item/trash/USCMtray
	name = "\improper USCM Tray"
	desc = "Finished with its tour of duty"
	icon = 'icons/obj/trash.dmi'
	icon_state = "MREtray"


/obj/item/weapon/reagent_containers/food/snacks/mre_pack
	name = "\improper generic MRE pack"
	//trash = /obj/item/trash/USCMtray
	trash = null
	w_class = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1
	name = "\improper USCM Prepared Meal (cornbread)"
	desc = "A tray of standard USCM food. Stale cornbread, tomato paste and some green goop fill this tray."
	icon_state = "MREa"
	filling_color = "#ED1169"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2
	name = "\improper USCM Prepared Meal (pork)"
	desc = "A tray of standard USCM food. Partially raw pork, goopy corn and some water mashed potatos fill this tray."
	icon_state = "MREb"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3
	name = "\improper USCM Prepared Meal (pasta)"
	desc = "A tray of standard USCM food. Overcooked spaghetti, waterlogged carrots and two french fries fill this tray."
	icon_state = "MREc"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4
	name = "\improper USCM Prepared Meal (pizza)"
	desc = "A tray of standard USCM food. Cold pizza, wet greenbeans and a shitty egg fill this tray. Get something other than pizza, lardass."
	icon_state = "MREd"

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5
	name = "\improper USCM Prepared Meal (chicken)"
	desc = "A tray of standard USCM food. Moist chicken, dry rice and a mildly depressed piece of broccoli fill this tray."
	icon_state = "MREe"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6
	name = "\improper USCM Prepared Meal (tofu)"
	desc = "The USCM doesn't serve tofu you grass sucking hippie. The flag signifies your defeat."
	icon_state = "MREf"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas1
	name = "\improper Xmas Prepared Meal:sugar cookies"
	desc = "Delicious Sugar Cookies"
	icon_state = "mreCookies"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas2
	name = "\improper Xmas Prepared Meal:gingerbread cookie"
	desc = "A cookie without a soul."
	icon_state = "mreGingerbread"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas3
	name = "\improper Xmas Prepared Meal:fruitcake"
	desc = "Also known as ''the Commander''."
	icon_state = "mreFruitcake"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/storage/box/pizza
	name = "food delivery box"
	desc = "A space-age food storage device, capable of keeping food extra fresh. Actually, it's just a box."

	New()
		..()
		pixel_y = rand(-3,3)
		pixel_x = rand(-3,3)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		var/randsnack
		for(var/i = 1 to 3)
			randsnack = rand(0,5)
			switch(randsnack)
				if(0)
					new /obj/item/weapon/reagent_containers/food/snacks/fries(src)
				if(1)
					new /obj/item/weapon/reagent_containers/food/snacks/cheesyfries(src)
				if(2)
					new /obj/item/weapon/reagent_containers/food/snacks/bigbiteburger(src)
				if(4)
					new /obj/item/weapon/reagent_containers/food/snacks/taco(src)
				if(5)
					new /obj/item/weapon/reagent_containers/food/snacks/hotdog(src)

/obj/item/weapon/paper/janitor
	name = "crumbled paper"
	icon_state = "pamphlet"
	info = "In loving memory of Cub Johnson."



/obj/item/weapon/storage/box/wy_mre
	name = "\improper Weyland-Yutani brand MRE"
	desc = "A prepackaged, long-lasting food box from Weyland Yutani Industries.\nOn the box is the Weyland Yutani logo, with a slogan surrounding it: \n<b>WEYLAND-YUTANI. BUILDING BETTER LUNCHES</b>"
	icon_state = "mre2"
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks")
	w_class = 2

	New()
		..()
		pixel_y = rand(-3,3)
		pixel_x = rand(-3,3)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)
		new /obj/item/weapon/reagent_containers/food/drinks/coffee(src)
		var/randsnack = rand(0,5)
		switch(randsnack)
			if(0)
				new /obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers(src)
			if(1)
				new /obj/item/weapon/reagent_containers/food/snacks/no_raisin(src)
			if(2)
				new /obj/item/weapon/reagent_containers/food/snacks/spacetwinkie(src)
			if(4)
				new /obj/item/weapon/reagent_containers/food/snacks/cookie(src)
			if(5)
				new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(src)

/obj/item/weapon/book/manual/lazarus_landing_map
	name = "\improper Lazarus landing map"
	desc = "A satellite printout of the Lazarus Landing colony."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	author = "Weyland Yutani"
	title = "Lazarus Landing Map"
	// Map images should be placed in html\icons. The image must then be added to the send_resources() proc in \code\modules\client\client procs.dm. From there it can be linked to directly.
	dat = {"

		<html><head>
		</head>

		<body>
		<img src="LV624.png" alt="Map">
		</body>

		</html>

		"}

/obj/item/weapon/book/manual/ice_colony_map
	name = "\improper Ice Colony map"
	desc = "A satellite printout of the Ice Colony."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	color = "blue"
	author = "Weyland Yutani"
	title = "Ice Colony Map"
	// Map images should be placed in html\icons. The image must then be added to the send_resources() proc in \code\modules\client\client procs.dm. From there it can be linked to directly.
	dat = {"

		<html><head>
		</head>

		<body>
		<img src="IceColony.png" alt="Map">
		</body>

		</html>

		"}

/obj/item/weapon/book/manual/whiskey_outpost_map
	name = "\improper Whiskey Outpost map"
	desc = "A tactical printout of the Whiskey Outpost defensive positions and locations."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	color = "grey"
	author = "Weyland Yutani"
	title = "Whiskey Outpost Map"
	// Map images should be placed in html\icons. The image must then be added to the send_resources() proc in \code\modules\client\client procs.dm. From there it can be linked to directly.
	dat = {"

		<html><head>
		</head>

		<body>
		<img src="whiskeyoutpost.png" alt="Map">
		</body>

		</html>

		"}

/obj/item/weapon/book/manual/big_red_map
	name = "\improper Solaris Ridge Map"
	desc = "A censored blueprint of the Solaris Ridge facility"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	color = "#e88a10"
	author = "Weyland Yutani"
	title = "Solaris Ridge Map"
	// Map images should be placed in html\icons. The image must then be added to the send_resources() proc in \code\modules\client\client procs.dm. From there it can be linked to directly.
	dat = {"

		<html><head>
		</head>

		<body>
		<img src="BigRed.png" alt="Map">
		</body>

		</html>

		"}
