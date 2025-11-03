//Items labled as 'trash' for the trash bag.

/obj/item/trash
	icon = 'icons/obj/items/trash.dmi'
	w_class = WEIGHT_CLASS_SMALL
	desc = "This is rubbish."

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/pillpacket
	name = "crumpled pill packet"
	desc = "After healing a lot of damage, the empty packet is laid to rest"
	icon = 'icons/obj/items/trash.dmi'
	icon_state = "pillpacketempty"

/obj/item/trash/candy
	name = "Candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "Cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "Chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "Popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "Syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "Waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "Plate"
	icon_state = "plate"

/obj/item/trash/snack_bowl
	name = "Snack bowl"
	icon_state = "snack_bowl"

/obj/item/trash/pistachios
	name = "Pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "Semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "Tray"
	icon_state = "tray"

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/items/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	resistance_flags = NONE

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/burger
	name = "Burger wrapper"
	icon_state = "burger"
	desc = "A greasy plastic film that once held a Cheeseburger. Packaged by the Nanotrasen Corporation."

/obj/item/trash/buritto
	name = "Burrito wrapper"
	icon_state = "burrito"
	desc = "A foul smelling plastic film that once held a microwave burrito. Packaged by the Nanotrasen Corporation."

/obj/item/trash/hotdog
	name = "Hotdog wrapper"
	icon_state = "hotdog"
	desc = "A musty plastic film that once held a hotdog. Packaged by the Nanotrasen Corporation."

/obj/item/trash/kepler
	name = "Kepler wrapper"
	icon_state = "kepler"

/obj/item/trash/eat
	name = "EAT bar wrapper"
	icon_state = "eat"

/obj/item/trash/fortunecookie
	name = "Fortune cookie fortune"
	icon_state = "fortune" //Thank you Alterist

/obj/item/trash/fortunecookie/Initialize(mapload, ...)
	. = ..()
	desc = "The fortune reads. <br>[span_tip("[pick(SSstrings.get_list_from_file("tips/marine"))]")]"

/obj/item/trash/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "c_tube"
	throwforce = 1
	throw_speed = 4
	throw_range = 5


/obj/item/trash/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/cigbutt/Initialize(mapload, ...)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	transform = turn(transform,rand(0,360))

/obj/item/trash/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"


/obj/item/trash/tgmc_tray
	name = "\improper TGMC tray"
	desc = "Finished with its tour of duty"
	icon_state = "MREtray"

/obj/item/trash/boonie
	name = "boonie bar wrapper"
	desc = "A minty green wrapper. Reminds you of another terrible decision involving minty green, but you can't remember what..."
	icon_state = "boonie_trash"

/obj/item/trash/chunk
	name = "chunk bar box"
	desc = "An empty box from a chunk bar. Significantly less heavy."
	icon_state = "chunk_trash"

/obj/item/trash/barcaridine
	name = "barcaridine bar wrapper"
	desc = "An empty wrapper from a barcaridine bar. You notice the inside has several medical labels. You're not sure if you care or not about that."
	icon_state = "barcardine_trash"

/obj/item/trash/berrybar
	name = "berry bar wrapper"
	desc = "An empty wrapper from a berry bar. You notice the inside has several medical labels and ingredients but You're not sure if you care or not about that."
	icon_state = "berrybar_trash"

/obj/item/trash/mre
	name = "\improper crumbled TGMC MRE"
	desc = "It has done its part for the TGMC. Have you?"
	icon = 'icons/obj/items/trash.dmi'
	icon_state = "mealpackempty"

/obj/item/trash/mre/som
	name = "\improper crumbled SOM MFR"
	desc = "It has done its part for the SOM. Have you?"
	icon_state = "som_mealpackempty"

/obj/item/trash/nt_chips
	name = "\improper Nanotrasen Pepper Chips"
	icon_state = "nt_chips_pepper"
	desc = "An oily empty bag that once held Nanotrasen Chips."

/obj/item/trash/nt_chips/pepper
	name = "\improper Nanotrasen Pepper Chips"
	icon_state = "nt_chips_pepper"
	desc = "An oily empty bag that once held Nanotrasen Pepper Chips."

/obj/item/trash/crushed_cup
	name = "crushed cup"
	desc = "A sad crushed and destroyed cup. It's now useless trash. What a waste."
	icon_state = "crushed_solocup"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("bludgeons", "whacks", "slaps")

/obj/item/trash/trashbag
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon_state = "ztrashbag"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/crushed_wbottle
	name = "crushed waterbottle"
	desc = "Overpriced 'Spring' water. Bottled by the Nanotrasen Corporation."
	icon_state = "waterbottle_crushed"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/crushed_bottle
	name = "crushed bottle"
	desc = "A crushed bottle, it's hard to see the label."
	icon_state = "blank_can_crushed"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/crushed_bottle/beer
	icon_state = "beer_crushed"

/obj/item/trash/crushed_bottle/ale
	icon_state = "ale_crushed"

/obj/item/trash/crushed_bottle/fruitbeer
	icon_state = "fruit_beer_crushed"

/obj/item/trash/crushed_bottle/sodawater
	icon_state = "soda_water_crushed"

/obj/item/trash/crushed_bottle/tonic
	icon_state = "tonic_crushed"

/obj/item/trash/crushed_bottle/purple_can
	icon_state = "purple_can_crushed"

/obj/item/trash/crushed_bottle/cola
	icon_state = "cola_crushed"

/obj/item/trash/crushed_bottle/grapesoda
	icon_state = "grapesoda_crushed"

/obj/item/trash/crushed_bottle/icetea
	icon_state = "ice_tea_can_crushed"

/obj/item/trash/crushed_bottle/thirteenloko
	icon_state = "thirteen_loko_crushed"

/obj/item/trash/crushed_bottle/spacemount
	icon_state = "space_mountain_wind_crushed"

/obj/item/trash/crushed_bottle/drgibb
	icon_state = "dr_gibb_crushed"

/obj/item/trash/crushed_bottle/starkist
	icon_state = "starkist_crushed"

/obj/item/trash/crushed_bottle/spaceup
	icon_state = "space-up_crushed"

/obj/item/trash/crushed_bottle/lemonlime
	icon_state = "lemon-lime_crushed"

/obj/item/trash/crushed_bottle/boda
	icon_state = "boda_crushed"

/obj/item/trash/crushed_bottle/energydrink
	icon_state = "energy_drink_crushed"

/obj/item/trash/crushed_bottle/sixpackcrushed_1
	icon_state = "6_pack_1_crushed"

/obj/item/trash/crushed_bottle/soutoclassic
	icon_state = "souto_classic_crushed"

/obj/item/trash/crushed_bottle/soutocherry
	icon_state = "souto_cherry_crushed"

/obj/item/trash/crushed_bottle/soutolime
	icon_state = "souto_lime_crushed"

/obj/item/trash/crushed_bottle/soutogrape
	icon_state = "souto_grape_crushed"

/obj/item/trash/crushed_bottle/soutoblueraspberry
	icon_state = "souto_blueraspberry_crushed"

/obj/item/trash/crushed_bottle/soutopeach
	icon_state = "souto_peach_crushed"

/obj/item/trash/crushed_bottle/soutocranberry
	icon_state = "souto_cranberry_crushed"

/obj/item/trash/crushed_bottle/soutovanilla
	icon_state = "souto_vanilla_crushed"

/obj/item/trash/crushed_bottle/soutopineapple
	icon_state = "souto_pineapple_crushed"

/obj/item/trash/crushed_bottle/soutodietclassic
	icon_state = "souto_diet_classic_crushed"

/obj/item/trash/crushed_bottle/soutodietcherry
	icon_state = "souto_diet_cherry_crushed"

/obj/item/trash/crushed_bottle/soutodietlime
	icon_state = "souto_diet_lime_crushed"

/obj/item/trash/crushed_bottle/soutodietgrape
	icon_state = "souto_diet_grape_crushed"

/obj/item/trash/crushed_bottle/soutodietblueraspberry
	icon_state = "souto_diet_blueraspberry_crushed"

/obj/item/trash/crushed_bottle/soutodietpeach
	icon_state = "souto_diet_peach_crushed"

/obj/item/trash/crushed_bottle/soutodietcranberry
	icon_state = "souto_diet_cranberry_crushed"

/obj/item/trash/crushed_bottle/soutodietvanilla
	icon_state = "souto_diet_vanilla_crushed"

/obj/item/trash/crushed_bottle/soutodietpineapple
	icon_state = "souto_diet_pineapple_crushed"

// Cuppa Joe's Trash
/obj/item/trash/cuppa_joes/lid
	name = "Cuppa Joe's coffee cup lid"
	desc = "Have you got the CuppaJoe Smile? Stay perky! Freeze-dried CuppaJoe's Coffee."
	icon_state = "coffeecuppajoelid"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/cuppa_joes/empty_cup
	name = "Empty Cuppa Joe's coffee cup"
	desc = "Have you got the CuppaJoe Smile? Stay perky! Freeze-dried CuppaJoe's Coffee."
	icon_state = "coffeecuppajoenolid"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/cuppa_joes/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

// Cuppa Joes no random axis
/obj/item/trash/cuppa_joes_static/lid
	name = "Cuppa Joe's coffee cup lid"
	desc = "Have you got the CuppaJoe Smile? Stay perky! Freeze-dried CuppaJoe's Coffee."
	icon_state = "coffeecuppajoelid"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/cuppa_joes_static/empty_cup
	name = "Empty Cuppa Joe's coffee cup"
	desc = "Have you got the CuppaJoe Smile? Stay perky! Freeze-dried CuppaJoe's Coffee."
	icon_state = "coffeecuppajoenolid"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/cuppa_joes_static/empty_cup_stack
	name = "Empty Cuppa Joe's coffee cup stack"
	desc = "Have you got the CuppaJoe Smile? Stay perky! Freeze-dried CuppaJoe's Coffee."
	icon_state = "coffeecuppajoestacknolid"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1

/obj/item/trash/cuppa_joes_static/lid_stack
	name = "Cuppa Joe's coffee cup lid stack"
	desc = "Have you got the CuppaJoe Smile? Stay perky! Freeze-dried CuppaJoe's Coffee."
	icon_state = "coffeecuppajoelidstack"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 1
