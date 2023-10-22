/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	//Not given any special protective value since the magic robes are full-body protection --NEO
	siemens_coefficient = 0.8
	flags_armor_protection = NONE

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking, red, hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"
	flags_armor_protection = HEAD|FACE

/obj/item/clothing/head/wizard/marisa
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/magus
	name = "Magus Helm"
	desc = "A mysterious helmet that hums with an unearthly power"
	icon_state = "magus"
	item_state = "magus"
	siemens_coefficient = 0.8
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/head/wizard/amp
	name = "psychic amplifier"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/cap
	name = "Gentlemans Cap"
	desc = "A checkered gray flat cap woven together with the rarest of threads."
	icon_state = "gentcap"
	siemens_coefficient = 0.8

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificant, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	soft_armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 20, FIRE = 20, ACID = 20)
	allowed = list()
	flags_inv_hide = HIDEJUMPSUIT
	siemens_coefficient = 0.8

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificant, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	item_state = "redwizrobe"


/obj/item/clothing/suit/wizrobe/marisa
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power"
	icon_state = "magusblue"
	item_state = "magusblue"
	flags_armor_protection = CHEST|GROIN|ARMS|HANDS|LEGS|FEET

/obj/item/clothing/suit/wizrobe/magusred
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power"
	icon_state = "magusred"
	item_state = "magusred"
	flags_armor_protection = CHEST|GROIN|ARMS|HANDS|LEGS|FEET

/obj/item/clothing/suit/wizrobe/psypurple
	name = "purple robes"
	desc = "Heavy, royal purple robes threaded with psychic amplifiers and weird, bulbous lenses. Do not machine wash."
	icon_state = "psyamp"
	item_state = "psyamp"

/obj/item/clothing/suit/wizrobe/gentlecoat
	name = "Gentlemans Coat"
	desc = "A heavy threaded twead gray jacket. For a different sort of Gentleman."
	icon_state = "gentlecoat"
	item_state = "gentlecoat"
	flags_armor_protection = CHEST|GROIN|ARMS
	flags_inv_hide = NONE

/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull, blue robe meant to mimick real wizard robes."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	siemens_coefficient = 1

/obj/item/clothing/head/wizard/marisa/fake
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	siemens_coefficient = 1

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	siemens_coefficient = 1

