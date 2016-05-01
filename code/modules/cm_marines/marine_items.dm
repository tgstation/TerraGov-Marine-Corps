
/**********************Marine Gear**************************/

//MARINE COMBAT LIGHT

/obj/item/device/flashlight/combat
	name = "Combat Flashlight"
	desc = "A Flashlight designed to be held in the hand, or attached to a rifle"
	icon_state = "flashlight"
	item_state = "flashlight"
	var/attachable = 0  //Can this be attached to another weapon or device?
	brightness_on = 7 //luminosity when on

/obj/item/device/flashlight/combat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(attachable)
			attachable = 0
			usr << "\red You screw the side panel on [src] closed. It can no longer be attached!"
		else if(!attachable)
			attachable = 1
			usr << "\red You screw open the side panel on [src], which can now be attached!"
	return
/*
/obj/item/weapon/gun/projectile/Assault/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/device/flashlight/combat))
		var/obj/item/device/flashlight/combat/F = A
		if(F.attachable)
			src.contents += A
			user << "\red You attach [A] to [src]."
			haslight = 1
			del(A)
	return
*/


//MARINE ENCRYPTION KEYS

/obj/item/device/encryptionkey/mcom
	name = "Marine Command Radio Encryption Key"
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
	name = "Alpha Leader Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Alpha" = 1, "Command" = 1)

/obj/item/device/encryptionkey/mbravol
	name = "Bravo Leader Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Bravo" = 1, "Command" = 1)

/obj/item/device/encryptionkey/mcharliel
	name = "Charlie Leader Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Charlie" = 1, "Command" = 1)

/obj/item/device/encryptionkey/mdeltal
	name = "Delta Leader Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hop_cypherkey"
	channels = list("Delta" = 1, "Command" = 1)

/obj/item/device/encryptionkey/malp
	name = "Alpha Squad Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "eng_cypherkey"
	channels = list("Alpha" = 1)

/obj/item/device/encryptionkey/mbra
	name = "Bravo Squad Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "cypherkey"
	channels = list("Bravo" = 1)

/obj/item/device/encryptionkey/mcha
	name = "Charlie Squad Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "sci_cypherkey"
	channels = list("Charlie" = 1)

/obj/item/device/encryptionkey/mdel
	name = "Delta Squad Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "hos_cypherkey"
	channels = list("Delta" = 1)

/obj/item/device/encryptionkey/mmpo
	name = "Military Police Radio Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	icon_state = "rob_cypherkey"
	channels = list("MP" = 1)

//MARINE HEADSETS

/obj/item/device/radio/headset/mcom
	name = "marine command radio headset"
	desc = "This is used by the marine command. Channels are as follows: :v - marine command, :p - military police, :q - alpha squad, :b - bravo squad, :c - charlie squad, :d - delta squad, :m - medbay, :u - requisitions"
	icon_state = "med_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mcom
	frequency = 1461

/obj/item/device/radio/headset/malphal
	name = "marine alpha leader radio headset"
	desc = "This is used by the marine alpha squad leader. Channels are as follows: :v - marine command, :q - alpha squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/malphal
	frequency = 1461

/obj/item/device/radio/headset/malpha
	name = "marine alpha radio headset"
	desc = "This is used by  alpha squad members. Channels are as follows: :q - alpha squad."
	icon_state = "sec_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/malp
	frequency = 1461

/obj/item/device/radio/headset/mbravol
	name = "marine bravo leader radio headset"
	desc = "This is used by the marine bravo squad leader. Channels are as follows: :v - marine command, :b - bravo squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mbravol
	frequency = 1461

/obj/item/device/radio/headset/mbravo
	name = "marine bravo radio headset"
	desc = "This is used by bravo squad members. Channels are as follows: :b - bravo squad."
	icon_state = "eng_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mbra
	frequency = 1461

/obj/item/device/radio/headset/msulaco
	name = "marine radio headset"
	desc = "A standard Sulaco radio headset"
	icon_state = "cargo_headset"
	item_state = "headset"
	frequency = 1461

/obj/item/device/radio/headset/mcharliel
	name = "marine charlie leader radio headset"
	desc = "This is used by the marine charlie squad leader. Channels are as follows: :v - marine command, :c - charlie squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mcharliel
	frequency = 1461

/obj/item/device/radio/headset/mcharlie
	name = "marine charlie radio headset"
	desc = "This is used by charlie squad members. Channels are as follows: :c - charlie squad."
	icon_state = "rob_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mcha
	frequency = 1461

/obj/item/device/radio/headset/mdeltal
	name = "marine delta leader radio headset"
	desc = "This is used by the marine delta squad leader. Channels are as follows: :v - marine command, :d - delta squad."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mdeltal
	frequency = 1461

/obj/item/device/radio/headset/mdelta
	name = "marine delta radio headset"
	desc = "This is used by delta squad members. Channels are as follows: :d - delta squad."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mdel
	frequency = 1461

/obj/item/device/radio/headset/mmpo
	name = "marine military police radio headset"
	desc = "This is used by marine military police members. Channels are as follows: :p - military police."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/mmpo
	frequency = 1461



//MARINE RADIO

/obj/item/device/radio/marine
	frequency = 1461

//MARINE CONTAINERS
/*
/obj/item/weapon/storage/box/beanbags
	name = "box of beanbag shells"
	desc = "A box of 12 gauge beanbag rounds. Manufactured by Armat Systems for prison guard and police use in non-lethal pacification."
	icon_state = "box"
	storage_slots = 14
	can_hold = list(
		"/obj/item/ammo_casing/shotgun",
		)
	New()
		..()
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)


/obj/item/weapon/storage/box/shotguns
	name = "box of shotgun shells"
	desc = "A box of standard issue high-powered 12 gauge buckshot rounds. Manufactured by Armat Systems for military and civilian use."
	icon_state = "shells"
	w_class = 2
	storage_slots = 14
	can_hold = list(
		"/obj/item/ammo_casing/shotgun",
		)

	New()
		..()
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)

/obj/item/weapon/storage/box/incendiary
	name = "box of shotgun shells"
	desc = "A box of incednairy rounds. Manufactured by Armat Systems for military and civilian use."
	icon_state = "incendiary"
	w_class = 2
	storage_slots = 14
	can_hold = list(
		"/obj/item/ammo_casing/shotgun",
		)

	New()
		..()
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
		new /obj/item/ammo_casing/shotgun/incendiary(src)
*/
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

/obj/item/weapon/coin/marine
	name = "marine specialist weapon token"
	desc = "Insert this into a specialist vendor in order to access a single highly dangerous weapon."
	icon_state = "coin_adamantine"

	attackby(obj/item/weapon/W as obj, mob/user as mob) //To remove attaching a string functionality
		return

/obj/structure/broken_apc
	name = "M577 Armored Personnel Carrier"
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
						/obj/item/clothing/under/marine_jumpsuit,
						/obj/item/clothing/under/marine_underoos,
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
	name = "USCM firearms crate (x3)" //Doubling up stuff on the list will just make it twice as likely.
	var/num_things = 3
	var/list/stuff = list(	/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/weapon/gun/revolver/m44,
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/weapon/gun/shotgun/pump,
					/obj/item/weapon/gun/smg/m39,
					/obj/item/weapon/gun/smg/m39,
					/obj/item/weapon/gun/rifle/m41a/scoped,
					/obj/item/weapon/gun/rifle/lmg
				)
	New()
		spawn(1)
			while(num_things)
				if(!num_things)
					break
				num_things--
				var/guntype = pick(stuff)
				var/obj/item/weapon/gun/thing = new guntype(src)
				var/magpath = text2path(thing.mag_type)
				if(magpath)
					new magpath(src)
					new magpath(src) //2 spare mags for each, if it has one

/obj/structure/largecrate/guns/russian
	num_things = 1
	name = "Nagant-Yamasaki firearm crate"
	stuff = list(	/obj/item/weapon/gun/revolver/upp,
					/obj/item/weapon/gun/pistol/c99,
					/obj/item/weapon/gun/pistol/kt42,
					/obj/item/weapon/gun/rifle/mar40,
					/obj/item/weapon/gun/rifle/mar40/carbine,
					/obj/item/weapon/gun/rifle/mar40/svd,
					/obj/item/weapon/gun/smg/ppsh
				)

/obj/structure/largecrate/guns/merc
	num_things = 1
	name = "Black market firearm crate"
	stuff = list(	/obj/item/weapon/gun/pistol/holdout,
					/obj/item/weapon/gun/pistol/highpower,
					/obj/item/weapon/gun/pistol/m1911,
					/obj/item/weapon/gun/pistol/vp70,
					/obj/item/weapon/gun/pistol/heavy,
					/obj/item/weapon/gun/revolver/small,
					/obj/item/weapon/gun/revolver/cmb,
					/obj/item/weapon/gun/shotgun/merc,
					/obj/item/weapon/gun/shotgun/pump/cmb,
					/obj/item/weapon/gun/shotgun/double,
					/obj/item/weapon/gun/smg/mp7,
					/obj/item/weapon/gun/smg/skorpion,
					/obj/item/weapon/gun/smg/uzi,
					/obj/item/weapon/gun/smg/p90
				)

/obj/item/weapon/storage/box/uscm_mre
	name = "USCM Meal Ready to Eat"
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
	name = "Generic MRE Pack"

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal1
	name = "USCM MRE (cornbread)"
	desc = "A tray of standard USCM rations. Stale cornbread, tomato paste and some green goop fill this tray."
	icon_state = "MREa"
	filling_color = "#ED1169"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal2
	name = "USCM MRE (pork)"
	desc = "A tray of standard USCM rations. Partially raw pork, goopy corn and some water mashed potatos fill this tray."
	icon_state = "MREb"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal3
	name = "USCM MRE (pasta)"
	desc = "A tray of standard USCM rations. Overcooked spaghetti, waterlogged carrots and two french fries fill this tray."
	icon_state = "MREc"

	New()
		..()
		reagents.add_reagent("nutriment", 9)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal4
	name = "USCM MRE (pizza)"
	desc = "A tray of standard USCM rations. Cold pizza, wet greenbeans and a shitty egg fill this tray. Get something other than pizza, lardass."
	icon_state = "MREd"

	New()
		..()
		reagents.add_reagent("nutriment", 8)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal5
	name = "USCM MRE (chicken)"
	desc = "A tray of standard USCM rations. Moist chicken, dry rice and a mildly depressed piece of broccoli fill this tray."
	icon_state = "MREe"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/meal6
	name = "USCM MRE (tofu)"
	desc = "The USCM doesn't serve tofu you grass sucking hippie. The flag signifies your defeat."
	icon_state = "MREf"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas1
	name = "Xmas MRE:Sugar cookies"
	desc = "Delicious Sugar Cookies"
	icon_state = "mreCookies"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas2
	name = "Xmas MRE:Gingerbread cookie"
	desc = "A cookie without a soul."
	icon_state = "mreGingerbread"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mre_pack/xmas3
	name = "Xmas MRE:Fruitcake"
	desc = "Also known as ''the Commander''."
	icon_state = "mreFruitcake"

	New()
		..()
		reagents.add_reagent("nutriment", 10)
		bitesize = 2



/obj/item/weapon/paper/janitor
	name = "Crumbled paper"
	icon_state = "pamphlet"
	info = "In loving memory of Cub Johnson."



/obj/item/weapon/storage/box/wy_mre
	name = "Weyland-Yutani Brand MRE"
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
	name = "Lazarus Landing Map"
	desc = "A satellite printout of the Lazarus Landing colony."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	author = "Weyland Yutani"
	title = "Lazarus Landing Map"

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src='http://www.colonial-marines.com/wiki/images/thumb/6/6f/LV624.png/800px-LV624.png' frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}


