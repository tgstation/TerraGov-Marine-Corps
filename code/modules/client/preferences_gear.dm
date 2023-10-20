GLOBAL_LIST_INIT(gear_datums, populate_gear_list())


/proc/populate_gear_list()
	. = list()
	for(var/type in subtypesof(/datum/gear))
		var/datum/gear/G = new type()
		.[G.display_name] = G

/datum/gear
	var/display_name       //Name/index.
	var/path               //Path to item.
	var/cost               //Number of points used.
	var/slot               //Slot to equip to.

/datum/gear/flower
	display_name = "Flower Pin"
	path = /obj/item/clothing/head/hairflower
	cost = 1
	slot = SLOT_HEAD

/datum/gear/bandanna_grey
	display_name = "surplus bandanna (grey)"
	path = /obj/item/clothing/head/bandanna/grey
	cost = 3
	slot = SLOT_HEAD

/datum/gear/bandanna_red
	display_name = "surplus bandanna (red)"
	path = /obj/item/clothing/head/bandanna/red
	cost = 3
	slot = SLOT_HEAD

/datum/gear/bandanna_brown
	display_name = "surplus bandanna (brown)"
	path = /obj/item/clothing/head/bandanna/brown
	cost = 3
	slot = SLOT_HEAD
/datum/gear/eye_patch
	display_name = "Eye Patch"
	path = /obj/item/clothing/glasses/eyepatch
	cost = 2
	slot = SLOT_GLASSES

/datum/gear/beret
	display_name = "surplus beret (blue)"
	path = /obj/item/clothing/head/tgmcberet
	cost = 3
	slot = SLOT_HEAD


/datum/gear/beret_tan
	display_name = "surplus beret (tan)"
	path = /obj/item/clothing/head/tgmcberet/tan
	cost = 3
	slot = SLOT_HEAD


/datum/gear/beret_green
	display_name = "surplus beret (green)"
	path = /obj/item/clothing/head/tgmcberet/green
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_green
	display_name = "surplus beret (red)"
	path = /obj/item/clothing/head/tgmcberet/red2
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_darkgreen
	display_name = "surplus beret (dark green)"
	path = /obj/item/clothing/head/tgmcberet/darkgreen
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_bloodred
	display_name = "surplus beret (blood red)"
	path = /obj/item/clothing/head/tgmcberet/bloodred
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_bloodred/blue
	display_name = "surplus beret (dark blue)"
	path = /obj/item/clothing/head/tgmcberet/blueberet
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_snow
	display_name = "surplus beret (snow)"
	path = /obj/item/clothing/head/tgmcberet/snow
	cost = 3
	slot = SLOT_HEAD


/datum/gear/headband_green
	display_name = "surplus headband (green)"
	path = /obj/item/clothing/head/headband
	cost = 3
	slot = SLOT_HEAD


/datum/gear/headband_red
	display_name = "surplus headband (red)"
	path = /obj/item/clothing/head/headband/red
	cost = 3
	slot = SLOT_HEAD


/datum/gear/headpiece
	display_name = "surplus earpiece"
	path = /obj/item/clothing/head/headset
	cost = 3
	slot = SLOT_HEAD


/datum/gear/cap
	display_name = "surplus cap"
	path = /obj/item/clothing/head/tgmccap
	cost = 3
	slot = SLOT_HEAD


/datum/gear/booniehat
	display_name = "surplus boonie hat"
	path = /obj/item/clothing/head/boonie
	cost = 3
	slot = SLOT_HEAD


/datum/gear/eyepatch
	display_name = "Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch
	cost = 2
	slot = SLOT_GLASSES

/datum/gear/glasses
	display_name = "Prescription Glasses"
	path = /obj/item/clothing/glasses/regular
	cost = 2
	slot = SLOT_GLASSES


/datum/gear/shades
	display_name = "Big shades"
	path = /obj/item/clothing/glasses/sunglasses/fake/big
	cost = 2
	slot = SLOT_GLASSES


/datum/gear/shades_prescription
	display_name = "Big shades (prescription)"
	path = /obj/item/clothing/glasses/sunglasses/fake/big/prescription
	cost = 2
	slot = SLOT_GLASSES


/datum/gear/sunglasses
	display_name = "Sunglasses"
	path = /obj/item/clothing/glasses/sunglasses/fake
	cost = 2
	slot = SLOT_GLASSES


/datum/gear/sunglasses_prescription
	display_name = "Sunglasses (prescription)"
	path = /obj/item/clothing/glasses/sunglasses/fake/prescription
	cost = 2
	slot = SLOT_GLASSES


/datum/gear/cigar
	display_name = "Cigar"
	path = /obj/item/clothing/mask/cigarette/cigar
	cost = 2
	slot = SLOT_WEAR_MASK


/datum/gear/cigarette
	display_name = "Cigarette"
	path = /obj/item/clothing/mask/cigarette
	cost = 2
	slot = SLOT_WEAR_MASK

/datum/gear/cigarette/pipe
	display_name = "Smoking pipe"
	path = /obj/item/clothing/mask/cigarette/pipe
	cost = 3
	slot = SLOT_WEAR_MASK

/datum/gear/cigarette/pipe/corn
	display_name = "Corn cob pipe"
	path = /obj/item/clothing/mask/cigarette/pipe/cobpipe
	cost = 3
	slot = SLOT_WEAR_MASK

/datum/gear/cigarette/pipe/corn/curved
	display_name = "Curved corn cob pipe"
	path = /obj/item/clothing/mask/cigarette/pipe/cobpipe/curved
	cost = 3
	slot = SLOT_WEAR_MASK

/datum/gear/cigarette/pipe/bone
	display_name = "Europan bone pipe"
	path = /obj/item/clothing/mask/cigarette/pipe/bonepipe
	cost = 3
	slot = SLOT_WEAR_MASK

/datum/gear/bgoggles
	display_name = "Ballistic goggles"
	path = /obj/item/clothing/glasses/mgoggles
	cost = 2
	slot = SLOT_GLASSES


/datum/gear/bgoggles_prescription
	display_name = "Ballistic goggles (prescription)"
	path = /obj/item/clothing/glasses/mgoggles/prescription
	cost = 2
	slot = SLOT_GLASSES

/datum/gear/kotahi
	display_name = "Kotahi deck"
	path = /obj/item/toy/deck/kotahi
	cost = 2
	slot = SLOT_R_HAND

