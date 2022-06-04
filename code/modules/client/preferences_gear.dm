GLOBAL_LIST_EMPTY(gear_datums)


/proc/populate_gear_list()
	for(var/type in subtypesof(/datum/gear))
		var/datum/gear/G = new type()
		GLOB.gear_datums[G.display_name] = G
	return TRUE


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
	display_name = "TGMC bandanna (grey)"
	path = /obj/item/clothing/head/bandanna/grey
	cost = 3
	slot = SLOT_HEAD

/datum/gear/bandanna_red
	display_name = "TGMC bandanna (red)"
	path = /obj/item/clothing/head/bandanna/red
	cost = 3
	slot = SLOT_HEAD

/datum/gear/bandanna_brown
	display_name = "TGMC bandanna (brown)"
	path = /obj/item/clothing/head/bandanna/brown
	cost = 3
	slot = SLOT_HEAD
/datum/gear/eye_patch
	display_name = "Eye Patch"
	path = /obj/item/clothing/glasses/eyepatch
	cost = 2
	slot = SLOT_GLASSES

/datum/gear/beret
	display_name = "TGMC beret (blue)"
	path = /obj/item/clothing/head/tgmcberet
	cost = 3
	slot = SLOT_HEAD


/datum/gear/beret_tan
	display_name = "TGMC beret (tan)"
	path = /obj/item/clothing/head/tgmcberet/tan
	cost = 3
	slot = SLOT_HEAD


/datum/gear/beret_green
	display_name = "TGMC beret (green)"
	path = /obj/item/clothing/head/tgmcberet/green
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_green
	display_name = "TGMC beret (red)"
	path = /obj/item/clothing/head/tgmcberet/red2
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_darkgreen
	display_name = "TGMC beret (dark green)"
	path = /obj/item/clothing/head/tgmcberet/darkgreen
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_bloodred
	display_name = "TGMC beret (blood red)"
	path = /obj/item/clothing/head/tgmcberet/bloodred
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_bloodred
	display_name = "TGMC beret (dark blue)"
	path = /obj/item/clothing/head/tgmcberet/blueberet
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_snow
	display_name = "TGMC beret (snow)"
	path = /obj/item/clothing/head/tgmcberet/snow
	cost = 3
	slot = SLOT_HEAD


/datum/gear/headband_green
	display_name = "TGMC headband (green)"
	path = /obj/item/clothing/head/headband
	cost = 3
	slot = SLOT_HEAD


/datum/gear/headband_red
	display_name = "TGMC headband (red)"
	path = /obj/item/clothing/head/headband/red
	cost = 3
	slot = SLOT_HEAD


/datum/gear/headpiece
	display_name = "TGMC earpiece"
	path = /obj/item/clothing/head/headset
	cost = 3
	slot = SLOT_HEAD


/datum/gear/cap
	display_name = "TGMC cap"
	path = /obj/item/clothing/head/tgmccap
	cost = 3
	slot = SLOT_HEAD


/datum/gear/booniehat
	display_name = "TGMC boonie hat"
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
