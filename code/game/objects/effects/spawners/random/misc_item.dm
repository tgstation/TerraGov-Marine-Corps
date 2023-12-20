
/obj/effect/spawner/random/misc
	name = "Random base misc item spawner"
	icon = 'icons/effects/random/misc.dmi'
	icon_state = "random_trash"
	loot = list(
		/obj/structure/prop/mainship/errorprop,
	)

/obj/effect/spawner/random/misc/shard
	name = "Random shard spawner"
	icon_state = "random_shard"
	spawn_random_offset = TRUE
	spawn_loot_count = 2
	spawn_scatter_radius = 1
	spawn_loot_chance = 90
	loot = list(
		/obj/item/shard = 6,
		/obj/effect/decal/cleanable/glass = 2,
	)

/obj/effect/spawner/random/misc/seeds
	name = "Random seed spawner"
	icon_state = "random_seed"
	spawn_loot_chance = 90
	loot = list(
		/obj/item/seeds/appleseed,
		/obj/item/seeds/bananaseed,
		/obj/item/seeds/cocoapodseed,
		/obj/item/seeds/grapeseed,
		/obj/item/seeds/orangeseed,
		/obj/item/seeds/sugarcaneseed,
		/obj/item/seeds/wheatseed,
		/obj/item/seeds/watermelonseed,
		/obj/item/seeds/chiliseed,
		/obj/item/seeds/cornseed,
		/obj/item/seeds/lemonseed,
		/obj/item/seeds/peanutseed,
		/obj/item/seeds/poppyseed,
		/obj/item/seeds/pumpkinseed,
		/obj/item/seeds/carrotseed,
		/obj/item/seeds/wheatseed,
		/obj/item/seeds/tomatoseed,
	)

/obj/effect/spawner/random/misc/book
	name = "Random book spawner"
	icon_state = "random_book"
	spawn_loot_chance = 90
	loot_subtype_path = /obj/item/book/manual
	loot = list()

/obj/effect/spawner/random/misc/table_lighting
	name = "Random table lighting spawner"
	icon_state = "random_lamp"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/flashlight/lamp = 100,
		/obj/item/flashlight/lamp/green = 5,
		/obj/item/flashlight/lantern = 3,
		/obj/item/flashlight/combat = 3,
		/obj/item/flashlight/pen = 3,
		/obj/item/flashlight/lamp/menorah = 1,
	)

/obj/effect/spawner/random/misc/earmuffs
	name = "Random earmuffs spawner"
	icon_state = "random_earmuffs"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/clothing/ears/earmuffs,
		/obj/item/clothing/ears/earmuffs/gold,
		/obj/item/clothing/ears/earmuffs/green,
	)

/obj/effect/spawner/random/misc/cigarettes
	name = "Random cigarette spawner"
	icon_state = "random_cigarette"
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/storage/fancy/cigarettes/dromedaryco = 30,
		/obj/item/storage/fancy/cigarettes/kpack = 25,
		/obj/item/storage/fancy/cigarettes/lady_finger = 25,
		/obj/item/storage/fancy/cigarettes/luckystars = 25,
		/obj/item/storage/fancy/chemrettes = 15,
		/obj/item/storage/fancy/cigar = 15,
	)

/obj/effect/spawner/random/misc/soap
	name = "Random soap spawner"
	icon_state = "random_soap"
	spawn_loot_chance = 50
	loot = list(
		/obj/item/tool/soap,
		/obj/item/tool/soap/deluxe,
		/obj/item/tool/soap/nanotrasen,
		/obj/item/tool/soap/syndie,
	)

/obj/effect/spawner/random/misc/soap/regularweighted
	loot = list(
		/obj/item/tool/soap = 40,
		/obj/item/tool/soap/deluxe = 15,
		/obj/item/tool/soap/nanotrasen = 10,
		/obj/item/tool/soap/syndie = 1,
	)

/obj/effect/spawner/random/misc/soap/deluxeweighted
	loot = list(
		/obj/item/tool/soap/deluxe = 40,
		/obj/item/tool/soap = 15,
		/obj/item/tool/soap/nanotrasen = 10,
		/obj/item/tool/soap/syndie = 1,
	)

//random plushie spawner
/obj/effect/spawner/random/misc/plushie
	name = "Random plush spawner"
	icon_state = "random_plush"
	spawn_loot_chance = 15
	loot = list(
		/obj/item/toy/plush/moth,
		/obj/item/toy/plush/rouny,
		/obj/item/toy/plush/therapy_blue,
		/obj/item/toy/plush/therapy_green,
		/obj/item/toy/plush/therapy_yellow,
		/obj/item/toy/plush/therapy_orange,
		/obj/item/toy/plush/therapy_red,
		/obj/item/toy/plush/therapy_purple,
	)

/obj/effect/spawner/random/misc/plushie/fiftyfifty
	spawn_loot_chance = 50

/obj/effect/spawner/random/misc/plushie/nospawnninety
	spawn_loot_chance = 10

/obj/effect/spawner/random/misc/plushie/nospawnninetyfive
	spawn_loot_chance = 5

/obj/effect/spawner/random/misc/plushie/nospawnninetynine
	spawn_loot_chance = 1

/obj/effect/spawner/random/misc/gnome
	name = "Random gnome spawner"
	icon_state = "random_gnome"
	spawn_loot_chance = 15
	loot = list(
		/obj/item/toy/plush/gnome = 25,
		/obj/item/toy/plush/gnome/living = 1,
	)

/obj/effect/spawner/random/misc/gnome/fiftyfifty
	spawn_loot_chance = 50

/obj/effect/spawner/random/misc/plant
	name = "Random potted plant spawner"
	icon_state = "random_plant"
	loot = list(
		/obj/structure/flora/pottedplant,
		/obj/structure/flora/pottedplant/one,
		/obj/structure/flora/pottedplant/two,
		/obj/structure/flora/pottedplant/three,
		/obj/structure/flora/pottedplant/four,
		/obj/structure/flora/pottedplant/five,
		/obj/structure/flora/pottedplant/six,
		/obj/structure/flora/pottedplant/seven,
		/obj/structure/flora/pottedplant/eight,
		/obj/structure/flora/pottedplant/ten,
		/obj/structure/flora/pottedplant/eleven,
		/obj/structure/flora/pottedplant/twelve,
		/obj/structure/flora/pottedplant/thirteen,
		/obj/structure/flora/pottedplant/fourteen,
		/obj/structure/flora/pottedplant/fifteen,
		/obj/structure/flora/pottedplant/sixteen,
		/obj/structure/flora/pottedplant/seventeen,
		/obj/structure/flora/pottedplant/eighteen,
		/obj/structure/flora/pottedplant/twenty,
		/obj/structure/flora/pottedplant/twentyone,
		/obj/structure/flora/pottedplant/twentytwo,
		/obj/structure/flora/pottedplant/twentythree,
		/obj/structure/flora/pottedplant/twentyfour,
		/obj/structure/flora/pottedplant/twentyfive,
	)

/obj/effect/spawner/random/misc/folder
	name = "folder spawner"
	icon_state = "random_folder"
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/folder/black = 15,
		/obj/item/folder/black_random = 15,
		/obj/item/folder/white = 15,
		/obj/item/folder/red = 10,
		/obj/item/folder/yellow = 10,
		/obj/item/folder/blue = 10,
		/obj/item/folder/grape = 5,
	)

/obj/effect/spawner/random/misc/folder/nooffset
	spawn_random_offset = FALSE


/obj/effect/spawner/random/misc/bedsheet
	name = "bedsheet spawner"
	icon_state = "random_bedsheet"
	loot_subtype_path = /obj/item/bedsheet
	loot = list()

/obj/effect/spawner/random/misc/handcuffs
	name = "handcuff spawner"
	icon_state = "random_handcuffs"
	spawn_loot_chance = 85
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/restraints/handcuffs = 15,
		/obj/item/restraints/handcuffs/cable = 1,
	)

/obj/effect/spawner/random/misc/hand_labeler
	name = "hand labeler spawner"
	icon_state = "random_labeler"
	spawn_loot_chance = 90
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/tool/hand_labeler = 9,
		/obj/item/paper,
	)

///All the trash.
/obj/effect/spawner/random/misc/trash
	name = "Random trash"
	icon_state = "random_trash"
	loot = list(
		/obj/item/trash/raisins,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/popcorn,
		/obj/item/trash/sosjerky,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/waffles,
		/obj/item/trash/plate,
		/obj/item/trash/snack_bowl,
		/obj/item/trash/pistachios,
		/obj/item/trash/semki,
		/obj/item/trash/tray,
		/obj/item/trash/candle,
		/obj/item/trash/liquidfood,
		/obj/item/trash/burger,
		/obj/item/trash/buritto,
		/obj/item/trash/hotdog,
		/obj/item/trash/kepler,
		/obj/item/trash/eat,
		/obj/item/trash/fortunecookie,
		/obj/item/trash/c_tube,
		/obj/item/trash/cigbutt,
		/obj/item/trash/cigbutt/cigarbutt,
		/obj/item/trash/tgmc_tray,
		/obj/item/trash/boonie,
		/obj/item/trash/chunk,
		/obj/item/trash/barcardine,
		/obj/item/trash/mre,
		/obj/item/trash/berrybar,
	)

/obj/effect/spawner/random/misc/greytide
	name = "greytide spawner"
	icon_state = "random_greytide"
	spawn_loot_chance = 25
	spawn_loot_count = 2
	loot = list(
		/obj/effect/landmark/corpsespawner/assistant/regular = 15,
		/obj/item/clothing/under/color/grey = 10,
		/obj/item/clothing/shoes/black = 10,
		/obj/item/storage/backpack/satchel/norm = 10,
		/obj/item/clothing/suit/armor/vest = 10,
		/obj/effect/spawner/random/engineering/toolbox = 5,
		/obj/item/storage/belt/utility = 5,
		/obj/effect/spawner/random/engineering/insulatedgloves = 5,
		/obj/effect/spawner/random/decal/blood = 5,
		/obj/item/card/id/guest = 5,
		/obj/item/weapon/twohanded/fireaxe = 1,
		/obj/item/storage/belt/utility/full = 1,
	)

/obj/effect/spawner/random/misc/prizemecha
	name = "random toy mecha"
	icon_state = "random_durand"
	loot_type_path = /obj/item/toy/prize
	loot = list()

/obj/effect/spawner/random/misc/cigar
	name = "random cigar spawner"
	icon_state = "random_cigar"
	spawn_loot_chance = 75
	loot = list(
		/obj/item/clothing/mask/cigarette/cigar/cohiba,
		/obj/item/clothing/mask/cigarette/cigar/havana,
		/obj/item/clothing/mask/cigarette/cigar,
	)

/obj/effect/spawner/random/misc/paperbin
	name = "random paperbin spawner"
	icon_state = "random_paperbin"
	spawn_loot_chance = 85
	loot = list(
		/obj/structure/paper_bin = 9,
		/obj/item/paper = 1,
	)

/obj/effect/spawner/random/misc/clipboard
	name = "random clipboard spawner"
	icon_state = "random_clipboard"
	spawn_loot_chance = 65
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/clipboard = 8,
		/obj/item/paper = 2,
	)

/obj/effect/spawner/random/misc/table_parts
	name = "table parts spawner"
	icon_state = "random_tableparts"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/frame/table = 15,
		/obj/item/frame/table/nometal = 10,
		/obj/item/frame/table/reinforced = 10,
		/obj/item/frame/table/wood = 5,
		/obj/item/frame/table/fancywood = 5,
		/obj/item/frame/table/rusticwood = 5,
		/obj/item/frame/table/gambling = 1,
	)

//random decals live in here

/obj/effect/spawner/random/decal
	name = "Random base misc decal spawner"
	icon = 'icons/effects/random/misc.dmi'
	loot_subtype_path = /obj/effect/spawner/random/decal
	loot = list()

/obj/effect/spawner/random/decal/blood
	name = "random blood spawner"
	icon_state = "random_blood_splatter"
	spawn_loot_chance = 85
	spawn_scatter_radius = 1
	loot = list(
		/obj/effect/decal/cleanable/blood,
	)
