
///random civilian clothing for flavor
/obj/effect/spawner/random/clothing
	name = "Random base clothing spawner"
	icon = 'icons/effects/random/clothing.dmi'
	icon_state = "random_clothes"
	loot = list(
		/obj/structure/prop/mainship/errorprop,
	)
/obj/effect/spawner/random/clothing/general
	name = "Random clothing spawner"
	icon_state = "random_clothes"
	loot = list(
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bomber,
		/obj/item/clothing/suit/ianshirt,
		/obj/item/clothing/suit/radiation,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/space/rig/mining,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest/lime,
		/obj/item/clothing/suit/storage/hazardvest/blue,
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/wcoat,
		/obj/item/clothing/under/colonist,
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/under/color/blackf,
		/obj/item/clothing/under/darkred,
		/obj/item/clothing/under/darkblue,
		/obj/item/clothing/under/gentlesuit,
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/liaison_suit,
		/obj/item/clothing/under/liaison_suit/formal,
		/obj/item/clothing/under/pj/blue,
		/obj/item/clothing/under/rank/cargo,
		/obj/item/clothing/under/rank/cargotech,
		/obj/item/clothing/under/rank/chaplain,
		/obj/item/clothing/under/rank/det,
		/obj/item/clothing/under/rank/engineer,
		/obj/item/clothing/under/rank/head_of_security/alt,
		/obj/item/clothing/under/rank/medical,
		/obj/item/clothing/under/rank/prisoner,
		/obj/item/clothing/under/rank/research_director/rdalt,
		/obj/item/clothing/under/marine/officer/ro_suit,
		/obj/item/clothing/under/suit_jacket,
		/obj/item/clothing/under/suit_jacket/charcoal,
		/obj/item/clothing/under/swimsuit,
		/obj/item/clothing/under/rank/miner,
	)


///random civilian hats for flavor
/obj/effect/spawner/random/clothing/hats
	name = "Random hat spawner"
	icon_state = "random_hat"
	loot = list(
		/obj/item/clothing/head/bandanna/red,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/bomb_hood/security,
		/obj/item/clothing/head/boonie,
		/obj/item/clothing/head/bowler,
		/obj/item/clothing/head/bowlerhat,
		/obj/item/clothing/head/chaplain_hood,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/HoS,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/det_hat,
		/obj/item/clothing/head/det_hat/black,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/hardhat/red,
		/obj/item/clothing/head/hardhat/white,
		/obj/item/clothing/head/headband,
		/obj/item/clothing/head/headband/rambo,
		/obj/item/clothing/head/headband/red,
		/obj/item/clothing/head/headband/snake,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet/gladiator,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/under/rank/head_of_security/alt,
		/obj/item/clothing/head/powdered_wig,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/soft,
		/obj/item/clothing/head/soft/red,
		/obj/item/clothing/head/strawhat,
		/obj/item/clothing/head/warning_cone,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/helmet/riot,
	)

/obj/effect/spawner/random/clothing/coloredgloves
	name = "colored glove spawner"
	icon_state = "random_gloves"
	spawn_scatter_radius = 1
	spawn_random_offset = TRUE
	spawn_loot_chance = 80
	loot = list(
		/obj/item/clothing/gloves/black = 30,
		/obj/item/clothing/gloves/blue = 30,
		/obj/item/clothing/gloves/brown = 30,
		/obj/item/clothing/gloves/light_brown = 30,
		/obj/item/clothing/gloves/green = 30,
		/obj/item/clothing/gloves/grey = 30,
		/obj/item/clothing/gloves/latex = 30,
		/obj/item/clothing/gloves/orange = 30,
		/obj/item/clothing/gloves/purple = 30,
		/obj/item/clothing/gloves/rainbow = 30,
		/obj/item/clothing/gloves/red = 30,
		/obj/item/clothing/gloves/white = 30,
		/obj/item/clothing/gloves/insulated = 5,
	)

/obj/effect/spawner/random/clothing/darkgloves
	name = "dark glove spawner"
	icon_state = "random_gloves"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/clothing/gloves/black = 40,
		/obj/item/clothing/gloves/blue = 40,
		/obj/item/clothing/gloves/brown = 40,
		/obj/item/clothing/gloves/grey = 40,
		/obj/item/clothing/gloves/latex = 40,
		/obj/effect/spawner/random/clothing/coloredgloves = 2,
	)

/obj/effect/spawner/random/clothing/coloredgloves/latex
	icon_state = "random_latex_gloves"
	loot = list(
		/obj/item/clothing/gloves/latex = 30,
		/obj/effect/spawner/random/clothing/coloredgloves = 1,
	)

/obj/effect/spawner/random/clothing/sunglasses
	name = "sunglasses spawner"
	icon_state = "random_sunglasses"
	spawn_random_offset = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/item/clothing/glasses/sunglasses/big = 10,
		/obj/item/clothing/glasses/sunglasses/aviator = 15,
		/obj/item/clothing/glasses/sunglasses/aviator/yellow = 15,
		/obj/item/clothing/glasses/sunglasses/big/prescription = 10,
		/obj/item/clothing/glasses/sunglasses/blindfold = 15,
		/obj/item/clothing/glasses/sunglasses/fake = 15,
		/obj/item/clothing/glasses/sunglasses/fake/prescription = 15,
		/obj/item/clothing/glasses/sunglasses/fake/big = 10,
		/obj/item/clothing/glasses/sunglasses/sechud = 3,
	)
