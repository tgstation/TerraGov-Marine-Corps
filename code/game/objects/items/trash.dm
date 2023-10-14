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

/obj/item/trash/barcardine
	name = "barcardine bar wrapper"
	desc = "An empty wrapper from a barcardine bar. You notice the inside has several medical labels. You're not sure if you care or not about that."
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
