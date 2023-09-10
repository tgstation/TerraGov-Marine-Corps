//////////////////
//////UNIFORM/////
//////////////////
/obj/item/clothing/under/marine/ru
	name = "RUTGMS UNIFORM"
	desc = "RUTGMS UNIFORM"
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_w_uniform_str = 'RUtgmc/icons/mob/clothes.dmi')
	adjustment_variants = list()

/obj/item/clothing/under/marine/ru/black
	name = "Alpha squad turtleneck"
	desc = "Tacticool looking, squad issued uniform. This one belongs to Alpha, smells like hospital."
	icon_state = "alpha_merc"
	item_state = "alpha_merc"
	adjustment_variants = list(
		"Down" = "_d",
	)

/obj/item/clothing/under/marine/ru/black/bravo
	name = "Bravo squad turtleneck"
	desc = "Tacticool looking, squad issued uniform. This one belongs to Bravo, smells like welder fuel."
	icon_state = "bravo_merc"
	item_state = "bravo_merc"

/obj/item/clothing/under/marine/ru/black/delta
	name = "Delta squad turtleneck"
	desc = "Tacticool looking, squad issued uniform. This one belongs to Delta, smells like gunpowder."
	icon_state = "delta_merc"
	item_state = "delta_merc"

/obj/item/clothing/under/marine/ru/black/charlie
	name = "Charlie squad turtleneck"
	desc = "Tacticool looking, squad issued uniform. This one belongs to Charlie, smells like perfume."
	icon_state = "charlie_merc"
	item_state = "charlie_merc"

/obj/item/clothing/under/marine/ru/black/foreign
	name = "Foreign Legion turtleneck"
	desc = "Tacticool looking, squad issued uniform. This one belongs to the Foreign Legion, smells like fast food."
	icon_state = "foreign_merc"
	item_state = "foreign_merc"

/obj/item/clothing/under/marine/ru/slav
	name = "Old slavic uniform"
	desc = "This is some sports suit. Oh wait, this is slavic military uniform."
	icon_state = "slav"
	item_state = "slav"

/obj/item/clothing/under/marine/ru/gorka_eng
	name = "Engineer Gorka"
	desc = "Gorka. Engineer Gorka."
	icon_state = "gorka_eng"
	item_state = "gorka_eng"

/obj/item/clothing/under/marine/ru/gorka_med
	name = "Medic Gorka"
	desc = "Gorka. Medic Gorka."
	icon_state = "gorka_med"
	item_state = "gorka_med"

/obj/item/clothing/under/marine/ru/camo
	name = "Old camo uniform"
	desc = "This is old man clothes for fishing, now you can die for TerraGov in this very stealth camo."
	icon_state = "camo"
	item_state = "camo"
	adjustment_variants = list(
		"Down" = "_d",
	)

//////////////////
///////SHOES//////
//////////////////

/obj/item/clothing/shoes/marine/ru
	name = "ru boots"
	desc = "ru boots."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_shoes_str = 'RUtgmc/icons/mob/clothes.dmi')

/obj/item/clothing/shoes/marine/ru/headskin
	name = "Marine veteran combat boots"
	desc = "Usual combat boots. There is nothing unusual about them. Nothing."
	icon_state = "headskin"
	item_state = "headskin"

/obj/item/clothing/shoes/marine/coolcowboy
	name = "Marine cowboy combat boots"
	desc = "Cowboy boots. Now can hold knives!"
	icon_state = "cboots"
	item_state = "cboots"

//////////////////
//////GLASSES/////
//////////////////

/obj/item/clothing/glasses/ru
	name = "ru glasses"
	desc = "ru glasses"
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_glasses_str = 'RUtgmc/icons/mob/clothes.dmi')

/obj/item/clothing/glasses/ru/orange
	name = "Orange glasses"
	desc = "Just orange glasses."
	icon_state = "og"
	item_state = "og"

/obj/item/clothing/glasses/ru/orange/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		var/obj/item/clothing/glasses/hud/og/P = new
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/night/imager_goggles))
		var/obj/item/clothing/glasses/night/imager_goggles/og/P = new
		to_chat(user, span_notice("You fasten the optical imager scaner to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)
	else if(istype(I, /obj/item/clothing/glasses/meson))
		var/obj/item/clothing/glasses/meson/og/P = new
		to_chat(user, span_notice("You fasten the optical meson scaner to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(P)

		update_icon(user)

/obj/item/clothing/glasses/meson/og
	name = "Orange glasses"
	desc = "Just orange glasses. This pair has been fitted with an optical meson scanner."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_glasses_str = 'RUtgmc/icons/mob/clothes.dmi')
	icon_state = "mesonog"
	item_state = "mesonog"
	deactive_state = "d_og"
	prescription = TRUE

/obj/item/clothing/glasses/night/imager_goggles/og
	name = "Orange glasses"
	desc = "Just orange glasses. This pair has been fitted with an internal optical imager scanner."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_glasses_str = 'RUtgmc/icons/mob/clothes.dmi')
	icon_state = "optog"
	item_state = "optog"
	deactive_state = "d_og"
	prescription = TRUE

/obj/item/clothing/glasses/hud/og
	name = "Orange glasses"
	desc = "Just orange glasses. This pair has been fitted with an internal HealthMate HUD projector."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_glasses_str = 'RUtgmc/icons/mob/clothes.dmi')
	icon_state = "medog"
	item_state = "medog"
	deactive_state = "d_og"
	prescription = TRUE
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	actions_types = list(/datum/action/item_action/toggle)

//////////////////
//////STORAGE/////
//////////////////

/obj/item/storage/backpack/marine/scav
	name = "Scav backpack"
	desc = "Pretty swag backpack."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_back_str = 'RUtgmc/icons/mob/clothes.dmi')
	icon_state = "scavpack"
	item_state = "scavpack"

//////////////////
///////SUIT///////
//////////////////

/obj/item/clothing/suit/ru
	name = "ru suit"
	desc = "ru suit."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_wear_suit_str = 'RUtgmc/icons/mob/clothes.dmi')

/obj/item/clothing/suit/ru/fartumasti
	name = "Military cook apron"
	desc = "Pretty apron. Looks like some emblem teared off from it."
	icon_state = "fartumasti"
	item_state = "fartumasti"
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/claymore/harvester,
		/obj/item/storage/belt/knifepouch,
		/obj/item/weapon/twohanded,
	)
	flags_armor_protection = CHEST
	soft_armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

//////////////////
///////HATS///////
//////////////////

/obj/item/clothing/head/tgmcberet/squad/black
	name = "\improper Alpha squad black beret"
	icon_state = "alpha_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Alpha Squad."
	icon = 'RUtgmc/icons/item/clothes.dmi'
	item_icons = list(
		slot_head_str = 'RUtgmc/icons/mob/clothes.dmi')

/obj/item/clothing/head/tgmcberet/squad/black/bravo
	name = "\improper Bravo squad black beret"
	icon_state = "bravo_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Bravo Squad."

/obj/item/clothing/head/tgmcberet/squad/black/delta
	name = "\improper Delta squad black beret"
	icon_state = "delta_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Delta Squad."

/obj/item/clothing/head/tgmcberet/squad/black/charlie
	name = "\improper Charlie squad black beret"
	icon_state = "charlie_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Charlie Squad."

/obj/item/clothing/head/tgmcberet/squad/black/foreign
	name = "\improper Foreign Legion black beret"
	icon_state = "foreign_black_beret"
	desc = "Black stylish beret with TGMC marine squad insignia. This one belongs to the Foreign Legion."
