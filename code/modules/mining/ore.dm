/obj/item/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	var/oretag

/obj/item/ore/uranium
	name = "pitchblende"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	oretag = "uranium"

/obj/item/ore/iron
	name = "hematite"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	oretag = "hematite"

/obj/item/ore/coal
	name = "carbonaceous rock"
	icon_state = "Coal ore"
	origin_tech = "materials=1"
	oretag = "coal"

/obj/item/ore/glass
	name = "impure silicates"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	oretag = "sand"

/obj/item/ore/phoron
	name = "phoron crystals"
	icon_state = "Phoron ore"
	origin_tech = "materials=2"
	oretag = "phoron"

/obj/item/ore/silver
	name = "native silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	oretag = "silver"

/obj/item/ore/gold
	name = "native gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	oretag = "gold"

/obj/item/ore/diamond
	name = "diamonds"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	oretag = "diamond"

/obj/item/ore/osmium
	name = "raw platinum"
	icon_state = "Platinum ore"
	oretag = "platinum"

/obj/item/ore/hydrogen
	name = "raw hydrogen"
	icon_state = "Phazon"
	oretag = "hydrogen"

/obj/item/ore/slag
	name = "Slag"
	desc = "Completely useless"
	icon_state = "slag"
	oretag = "slag"

/obj/item/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
