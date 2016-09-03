
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
	var/unfolded_tarp = /obj/structure/closet/body_bag/tarp

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/tarp/T = new unfolded_tarp(user.loc)
		T.add_fingerprint(user)
		user.remove_from_mob(src)
		cdel(src)

/obj/item/bodybag/tarp/snow
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "snowtarp_folded"
	unfolded_tarp = /obj/structure/closet/body_bag/tarp/snow

/obj/structure/closet/body_bag/tarp
	name = "\improper V1 thermal-dapening tarp"
	desc = "A tarp carried by USCM Snipers. When laying underneath the tarp, the sniper is almost indistinguishable from the landscape if utilized correctly. The tarp contains a thermal-dampening weave to hide the wearer's heat signatures, optical camoflauge, and smell dampening."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "jungletarp_closed"
	icon_closed = "jungletarp_closed"
	icon_opened = "jungletarp_open"
	open_sound = 'sound/effects/vegetation_walk_1.ogg'
	close_sound = 'sound/effects/vegetation_walk_2.ogg'
	item_path = /obj/item/bodybag/tarp
	anchored = 1

/obj/structure/closet/body_bag/tarp/snow
	icon_state = "snowtarp_closed"
	icon_closed = "snowtarp_closed"
	icon_opened = "snowtarp_open"
	item_path = /obj/item/bodybag/tarp/snow

//MARINE ENCRYPTION KEYS

/obj/item/device/encryptionkey/mcom
	name = "\improper Marine Command radio encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cap_cypherkey"
	channels = list("Command" = 1, "MP" = 1, "Alpha" = 0, "Bravo" = 0, "Charlie" = 0, "Delta" = 0, "Engi" = 1, "MedSci" = 1, "Req" = 1 )
/*
/obj/item/device/encryptionkey/mhaz
	name = "Hazteam Echo Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Hazteam Echo" = 1)
*/
/obj/item/device/encryptionkey/malphal
	name = "\improper Alpha Leader encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Alpha" = 1, "Command" = 1)

/obj/item/device/encryptionkey/mbravol
	name = "\improper Bravo Leader encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Bravo" = 1, "Command" = 1)

/obj/item/device/encryptionkey/mcharliel
	name = "\improper Charlie Leader encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Charlie" = 1, "Command" = 1)

/obj/item/device/encryptionkey/mdeltal
	name = "\improper Delta Leader encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Delta" = 1, "Command" = 1)

/obj/item/device/encryptionkey/malp
	name = "\improper Alpha Squad radio encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "eng_cypherkey"
	channels = list("Alpha" = 1)

/obj/item/device/encryptionkey/mbra
	name = "\improper Bravo Squad radio encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cypherkey"
	channels = list("Bravo" = 1)

/obj/item/device/encryptionkey/mcha
	name = "\improper Charlie Squad radio encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "sci_cypherkey"
	channels = list("Charlie" = 1)

/obj/item/device/encryptionkey/mdel
	name = "\improper Delta Squad radio encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hos_cypherkey"
	channels = list("Delta" = 1)

/obj/item/device/encryptionkey/mmpo
	name = "\improper Military Police radio encryption key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "rob_cypherkey"
	channels = list("MP" = 1)

//PMCs
/obj/item/device/encryptionkey/dutch
	name = "\improper Dutch's Dozen encryption key"
	desc = "An encyption key for a radio headset.  Contains unique cypherkeys."
	channels = list("D.Dozen" = 1)

/obj/item/device/encryptionkey/PMC
	name = "\improper Weyland Yutani encryption key"
	desc = "An encyption key for a radio headset.  Contains unique cypherkeys."
	channels = list("WY PMC" = 1)

/obj/item/device/encryptionkey/bears
	name = "\improper Iron Bears encryption key"
	desc = "An encyption key for a radio headset.  Contains unique cypherkeys."
	syndie = 1
	channels = list("Spetsnaz" = 1)

/obj/item/device/encryptionkey/commando
	name = "\improper WY commando encryption key"
	desc = "An encyption key for a radio headset.  Contains unique cypherkeys."
	channels = list("SpecOps" = 1)

//MARINE HEADSETS

/obj/item/device/radio/headset/mcom
	name = "marine command radio headset"
	desc = "This is used by the marine command. Channels are as follows: :v - marine command, :p - military police, :q - alpha squad, :b - bravo squad, :c - charlie squad, :d - delta squad, :m - medbay, :u - requisitions"
	icon_state = "med_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mcom
	frequency = PUB_FREQ

/obj/item/device/radio/headset/malphal
	name = "marine alpha leader radio headset"
	desc = "This is used by the marine alpha squad leader. Channels are as follows: :v - marine command, :q - alpha squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/malphal
	frequency = PUB_FREQ

/obj/item/device/radio/headset/malpha
	name = "marine alpha radio headset"
	desc = "This is used by  alpha squad members. Channels are as follows: :q - alpha squad."
	icon_state = "sec_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/malp
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mbravol
	name = "marine bravo leader radio headset"
	desc = "This is used by the marine bravo squad leader. Channels are as follows: :v - marine command, :b - bravo squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mbravol
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mbravo
	name = "marine bravo radio headset"
	desc = "This is used by bravo squad members. Channels are as follows: :b - bravo squad."
	icon_state = "eng_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mbra
	frequency = PUB_FREQ

/obj/item/device/radio/headset/msulaco
	name = "marine radio headset"
	desc = "A standard Sulaco radio headset"
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mcharliel
	name = "marine charlie leader radio headset"
	desc = "This is used by the marine charlie squad leader. Channels are as follows: :v - marine command, :c - charlie squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mcharliel
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mcharlie
	name = "marine charlie radio headset"
	desc = "This is used by charlie squad members. Channels are as follows: :c - charlie squad."
	icon_state = "rob_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mcha
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mdeltal
	name = "marine delta leader radio headset"
	desc = "This is used by the marine delta squad leader. Channels are as follows: :v - marine command, :d - delta squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mdeltal
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mdelta
	name = "marine delta radio headset"
	desc = "This is used by delta squad members. Channels are as follows: :d - delta squad."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mdel
	frequency = PUB_FREQ

/obj/item/device/radio/headset/mmpo
	name = "marine military police radio headset"
	desc = "This is used by marine military police members. Channels are as follows: :p - military police."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mmpo
	frequency = PUB_FREQ

//Distress headsets.
/obj/item/device/radio/headset/distress
	name = "operative headset"
	desc = "A special headset used by small groups of trained operatives. Use :h to talk on a private channel."
	frequency = PUB_FREQ

/obj/item/device/radio/headset/distress/dutch
	name = "Dutch's Dozen headset"
	New()
		..()
		keyslot2 = new /obj/item/device/encryptionkey/dutch
		recalculateChannels()

/obj/item/device/radio/headset/distress/PMC
	name = "PMC headset"
	New()
		..()
		keyslot2 = new /obj/item/device/encryptionkey/PMC
		keyslot3 = new /obj/item/device/radio/headset/mcom
		recalculateChannels()

/obj/item/device/radio/headset/distress/bears
	name = "Iron Bear headset"
	frequency = CIV_GEN_FREQ
	New()
		..()
		del(keyslot1)
		keyslot1 = new /obj/item/device/encryptionkey/bears
		recalculateChannels()

/obj/item/device/radio/headset/distress/commando
	name = "Commando headset"
	New()
		..()
		keyslot2 = new /obj/item/device/encryptionkey/commando
		keyslot3 = new /obj/item/device/radio/headset/mcom
		recalculateChannels()

//MARINE RADIO

/obj/item/device/radio/marine
	frequency = PUB_FREQ


/obj/item/weapon/storage/box/explosive_mines
	name = "mine box"
	desc = "A secure box holding anti-personel proximity mines"
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
		new /obj/item/device/mine(src)
		new /obj/item/device/mine(src)
		new /obj/item/device/mine(src)
		new /obj/item/device/mine(src)
		return

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
						/obj/item/clothing/under/marine/underoos,
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
	name = "satchel of protein substitute"
	desc = "What.. what IS this? Is this food? Are you supposed to put it in your mouth? It oozes inside the translucent bag and smells like hobo vomit."
	icon_state = "yummers"
	filling_color = "#ED1169"

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/mre_pack
	name = "\improper generic MRE pack"

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1
	name = "\improper USCM MRE (cornbread)"
	desc = "A tray of standard USCM rations. Stale cornbread, tomato paste and some green goop fill this tray."
	icon_state = "MREa"
	filling_color = "#ED1169"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2
	name = "\improper USCM MRE (pork)"
	desc = "A tray of standard USCM rations. Partially raw pork, goopy corn and some water mashed potatos fill this tray."
	icon_state = "MREb"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3
	name = "\improper USCM MRE (pasta)"
	desc = "A tray of standard USCM rations. Overcooked spaghetti, waterlogged carrots and two french fries fill this tray."
	icon_state = "MREc"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4
	name = "\improper USCM MRE (pizza)"
	desc = "A tray of standard USCM rations. Cold pizza, wet greenbeans and a shitty egg fill this tray. Get something other than pizza, lardass."
	icon_state = "MREd"

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5
	name = "\improper USCM MRE (chicken)"
	desc = "A tray of standard USCM rations. Moist chicken, dry rice and a mildly depressed piece of broccoli fill this tray."
	icon_state = "MREe"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6
	name = "\improper USCM MRE (tofu)"
	desc = "The USCM doesn't serve tofu you grass sucking hippie. The flag signifies your defeat."
	icon_state = "MREf"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas1
	name = "\improper Xmas MRE:sugar cookies"
	desc = "Delicious Sugar Cookies"
	icon_state = "mreCookies"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas2
	name = "\improper Xmas MRE:gingerbread cookie"
	desc = "A cookie without a soul."
	icon_state = "mreGingerbread"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas3
	name = "\improper Xmas MRE:fruitcake"
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
	author = "Weyland Yutani"
	title = "Whiskey Outpost Map"
	// Map images should be placed in html\icons. The image must then be added to the send_resources() proc in \code\modules\client\client procs.dm. From there it can be linked to directly.
	dat = {"

		<html><head>
		</head>

		<body>
		<b>Purple:</b> Supply Drops<br>
		<b>Orange:</b> Tcomms Tower and APC<br>
		<b>LBlue:</b>  Recycler<br>
		<b>DBlue:</b>  Defensive Positions<br>
		<b>Red:</b>    Threat<br>
		<b>Yellow:</b> Potential Threat<br><br>
		<b>Whiskey Outpost Tactical Map:</b>
		<br>
		<img src="whiskey_outpost.png" alt="Map">
		</body>

		</html>

		"}
