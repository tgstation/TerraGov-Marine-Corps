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
	var/list/allowed_roles = null //Roles that can spawn with this item.

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
/datum/gear/og
	display_name = "Orange glasses"
	path = /obj/item/clothing/glasses/ru/orange
	cost = 1
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

/datum/gear/beret_bloodred/blue
	display_name = "TGMC beret (dark blue)"
	path = /obj/item/clothing/head/tgmcberet/blueberet
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_snow
	display_name = "TGMC beret (snow)"
	path = /obj/item/clothing/head/tgmcberet/snow
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_charlie
	display_name = "Charlie Squad beret"
	path = /obj/item/clothing/head/tgmcberet/squad
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_alpha
	display_name = "Alpha Squad beret"
	path = /obj/item/clothing/head/tgmcberet/squad/alpha
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_delta
	display_name = "Delta Squad beret"
	path = /obj/item/clothing/head/tgmcberet/squad/delta
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_bravo
	display_name = "Bravo Squad beret"
	path = /obj/item/clothing/head/tgmcberet/squad/bravo
	cost = 3
	slot = SLOT_HEAD

/datum/gear/beret_commando
	display_name = "Marine Commando beret"
	path = /obj/item/clothing/head/tgmcberet/commando
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
	path = /obj/item/clothing/head/booniehat
	cost = 3
	slot = SLOT_HEAD

/datum/gear/booniehatdg
	display_name = "Dark Green TGMC boonie hat"
	path = /obj/item/clothing/head/boonie/booniehatdg
	cost = 3
	slot = SLOT_HEAD

/datum/gear/booniehattan
	display_name = "Tan TGMC boonie hat"
	path = /obj/item/clothing/head/boonie/booniehattan
	cost = 3
	slot = SLOT_HEAD

/datum/gear/hijab_black
	display_name = "Black hijab"
	path = /obj/item/clothing/head/tgmcberet/hijab
	cost = 3
	slot = SLOT_HEAD

/datum/gear/hijab_grey
	display_name = "Grey hijab"
	path = /obj/item/clothing/head/tgmcberet/hijab/grey
	cost = 3
	slot = SLOT_HEAD

/datum/gear/hijab_red
	display_name = "Red hijab"
	path = /obj/item/clothing/head/tgmcberet/hijab/red
	cost = 3
	slot = SLOT_HEAD

/datum/gear/hijab_blue
	display_name = "Blue hijab"
	path = /obj/item/clothing/head/tgmcberet/hijab/blue
	cost = 3
	slot = SLOT_HEAD

/datum/gear/hijab_brown
	display_name = "Brown hijab"
	path = /obj/item/clothing/head/tgmcberet/hijab/brown
	cost = 3
	slot = SLOT_HEAD

/datum/gear/hijab_white
	display_name = "White hijab"
	path = /obj/item/clothing/head/tgmcberet/hijab/white
	cost = 3
	slot = SLOT_HEAD

/datum/gear/turban_black
	display_name = "Black turban"
	path = /obj/item/clothing/head/tgmcberet/hijab/turban
	cost = 3
	slot = SLOT_HEAD

/datum/gear/turban_white
	display_name = "White turban"
	path = /obj/item/clothing/head/tgmcberet/hijab/turban/white
	cost = 3
	slot = SLOT_HEAD

/datum/gear/turban_red
	display_name = "Red turban"
	path = /obj/item/clothing/head/tgmcberet/hijab/turban/red
	cost = 3
	slot = SLOT_HEAD

/datum/gear/turban_blue
	display_name = "Blue turban"
	path = /obj/item/clothing/head/tgmcberet/hijab/turban/blue
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

/datum/gear/ancient
	display_name = "Ancient Gasmask"
	path = /obj/item/clothing/mask/gas/ancient
	cost = 2
	slot = SLOT_WEAR_MASK

/datum/gear/blueskull
	display_name = "Blue Skull Balaclava"
	path = /obj/item/clothing/mask/balaclava/blackskull
	cost = 2
	slot = SLOT_WEAR_MASK

/datum/gear/blackskull
	display_name = "Black Skull Balaclava"
	path = /obj/item/clothing/mask/balaclava/blueskull
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

/datum/gear/pig
	display_name = "Pig toy"
	path = /obj/item/toy/plush/pig
	cost = 5
	slot = SLOT_IN_BACKPACK

/datum/gear/hachimaki
	display_name = "Ancient pilot headband and scarf kit"
	path = /obj/item/clothing/head/hachimaki
	cost = 2
	slot = SLOT_IN_BACKPACK

/datum/gear/koran
	display_name = "Luxury Koran (only for leaders)"
	path = /obj/item/storage/bible/koran
	cost = 1
	slot = SLOT_IN_BACKPACK
	allowed_roles = list(CAPTAIN, FIELD_COMMANDER, SQUAD_LEADER)

/datum/gear/smallkoran
	display_name = "Koran"
	path = /obj/item/storage/bible/koran/basic
	cost = 1
	slot = SLOT_IN_BACKPACK

/datum/gear/namaz
	display_name = "Prayer rug"
	path = /obj/item/namaz
	cost = 1
	slot = SLOT_IN_BACKPACK

/datum/gear/t500case
	display_name = "R-500 bundle"
	path = /obj/item/storage/box/t500case
	cost = 3
	slot = SLOT_IN_BACKPACK

/datum/gear/coin
	display_name = "Coin"
	path = /obj/item/coin/debugtoken
	cost = 2
	slot = SLOT_IN_BACKPACK
/datum/gear/kotahi
	display_name = "Kotahi deck"
	path = /obj/item/toy/deck/kotahi
	cost = 2
	slot = SLOT_R_HAND

