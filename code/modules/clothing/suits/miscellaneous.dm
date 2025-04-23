/*
* Contains:
*		Lasertag
*		Costume
*		Misc
*/

/*
* Lasertag
*/
/obj/item/clothing/suit/bluetag
	name = "blue laser tag armour"
	desc = "Blue Pride, Station Wide."
	icon_state = "bluetag"
	worn_icon_state = "bluetag"
	blood_overlay_type = "armor"
	armor_protection_flags = CHEST
	allowed = list (/obj/item/weapon/gun)
	siemens_coefficient = 3

/obj/item/clothing/suit/redtag
	name = "red laser tag armour"
	desc = "Reputed to go faster."
	icon_state = "redtag"
	worn_icon_state = "redtag"
	blood_overlay_type = "armor"
	armor_protection_flags = CHEST
	allowed = list (/obj/item/weapon/gun)
	siemens_coefficient = 3

/*
* Costume
*/
/obj/item/clothing/suit/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	worn_icon_state = "pirate"
	armor_protection_flags = CHEST|ARMS


/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	worn_icon_state = "hgpirate"
	inv_hide_flags = HIDEJUMPSUIT
	armor_protection_flags = CHEST|GROIN|ARMS|LEGS
	item_flags = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 60, BULLET = 90, LASER = 60, ENERGY = 20, BOMB = 25, BIO = 10, FIRE = 20, ACID = 20)

/obj/item/clothing/suit/hgpirate/noarmor
	name = "tattered pirate captain coat"
	item_flags = NONE
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	worn_icon_state = "death"
	atom_flags = CONDUCT
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"
	worn_icon_state = "johnny"

/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "This pretty much looks ridiculous."
	icon_state = "justice"
	worn_icon_state = "justice"
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor_protection_flags = CHEST|GROIN|ARMS|HANDS|LEGS|FEET

/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	worn_icon_state = "judge"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes,/obj/item/spacecash)
	inv_hide_flags = HIDEJUMPSUIT

/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	worn_icon_state = "wcoat"
	blood_overlay_type = "armor"
	armor_protection_flags = CHEST|GROIN


/obj/item/clothing/suit/storage/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	worn_icon_state = "overalls"
	armor_protection_flags = CHEST|GROIN|LEGS


/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica"
	icon_state = "syndicate"
	worn_icon_state = "space_suit_syndicate"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/toy)
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor_protection_flags = CHEST|GROIN|ARMS|HANDS|LEGS|FEET

/obj/item/clothing/suit/hastur
	name = "Hastur's Robes"
	desc = "Robes not meant to be worn by man"
	icon_state = "hastur"
	worn_icon_state = "hastur"
	armor_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/imperium_monk
	name = "Imperium monk"
	desc = "Have YOU killed a xenos today?"
	icon_state = "imperium_monk"
	worn_icon_state = "imperium_monk"
	armor_protection_flags = HEAD|CHEST|GROIN|LEGS|FEET|ARMS
	inv_hide_flags = HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/chickensuit
	name = "Chicken Suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	worn_icon_state = "chickensuit"
	armor_protection_flags = CHEST|ARMS|GROIN|LEGS|FEET
	inv_hide_flags = HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 2


/obj/item/clothing/suit/monkeysuit
	name = "Monkey Suit"
	desc = "A suit that looks like a primate"
	icon_state = "monkeysuit"
	worn_icon_state = "monkeysuit"
	armor_protection_flags = CHEST|ARMS|GROIN|LEGS|FEET|HANDS
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 2


/obj/item/clothing/suit/holidaypriest
	name = "Holiday Priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	worn_icon_state = "holidaypriest"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	inv_hide_flags = HIDEJUMPSUIT


/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	worn_icon_state = "cardborg"
	armor_protection_flags = CHEST|GROIN
	inv_hide_flags = HIDEJUMPSUIT


/obj/item/clothing/suit/white_dress_jacket
	name = "White Dress Jacket"
	desc = "The perfect white jacket to go with your white dress uniform."
	icon_state = "white_dress_jacket" //with thanks to Baystation12
	worn_icon_state = "white_dress_jacket" //with thanks to Baystation12

	allowed = list(
		/obj/item/instrument,
		/obj/item/storage/holster/blade,
		/obj/item/weapon/sword,
		/obj/item/weapon/twohanded,
	)


/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	worn_icon_state = "straight_jacket"
	armor_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/straight_jacket/equipped(mob/living/carbon/user, slot)
	if(slot == SLOT_WEAR_SUIT)
		ENABLE_BITFIELD(user.restrained_flags, RESTRAINED_STRAIGHTJACKET)
		user.stop_pulling() //Can't pull if restrained.
		if(user.handcuffed) //Keep the cuffs on.
			user.drop_all_held_items()
		user.update_action_buttons() //Certain action buttons will no longer be usable.
		RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_removal))
	return ..()


/obj/item/clothing/suit/straight_jacket/proc/on_removal(datum/source, mob/living/user)
	SIGNAL_HANDLER
	DISABLE_BITFIELD(user.restrained_flags, RESTRAINED_STRAIGHTJACKET)
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)


/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	worn_icon_state = "ianshirt"
	armor_protection_flags = CHEST|ARMS

//Blue suit jacket toggle
/obj/item/clothing/suit/suit/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "IC.Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained())
		return 0

	if(src.icon_state == "suitjacket_blue_open")
		src.icon_state = "suitjacket_blue"
		src.worn_icon_state = "suitjacket_blue"
		to_chat(usr, "You button up the suit jacket.")
	else if(src.icon_state == "suitjacket_blue")
		src.icon_state = "suitjacket_blue_open"
		src.worn_icon_state = "suitjacket_blue_open"
		to_chat(usr, "You unbutton the suit jacket.")
	else
		to_chat(usr, "You button-up some imaginary buttons on your [src].")
		return
	update_clothing_icon()

//pyjamas
//originally intended to be pinstripes >.>

/obj/item/clothing/under/bluepyjamas
	name = "blue pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "blue_pyjamas"
	worn_icon_state = "blue_pyjamas"
	armor_protection_flags = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/under/redpyjamas
	name = "red pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "red_pyjamas"
	worn_icon_state = "red_pyjamas"
	armor_protection_flags = CHEST|GROIN|ARMS|LEGS

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"
	worn_icon_state = "leathercoat"

/obj/item/clothing/suit/browncoat
	name = "brown leather coat"
	desc = "A long, brown leather coat."
	icon_state = "browncoat"
	worn_icon_state = "browncoat"

/obj/item/clothing/suit/neocoat
	name = "black coat"
	desc = "A flowing, black coat."
	icon_state = "neocoat"
	worn_icon_state = "neocoat"

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	worn_icon_state = "xenos_helm"
	armor_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 2
//swimsuit
/obj/item/clothing/under/swimsuit/
	siemens_coefficient = 1
	armor_protection_flags = NONE

/obj/item/clothing/under/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	siemens_coefficient = 1

/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "A simple, comfortable poncho."
	icon_state = "classicponcho"

/obj/item/clothing/suit/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"

/obj/item/clothing/suit/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"

/obj/item/clothing/suit/storage/bomber
	name = "bomber jacket"
	desc = "A well-worn WW2 leather bomber jacket."
	icon_state = "bomber"
	armor_protection_flags = CHEST|ARMS
	cold_protection_flags = CHEST|ARMS
	min_cold_protection_temperature = T0C
	siemens_coefficient = 0.7
	allowed = list (
		/obj/item/flashlight,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
		/obj/item/storage/holster/blade
	)

/obj/item/clothing/suit/replica
	name = "replica armor"
	desc = "A replica of the armour of choice for colonial militia."
	icon = 'icons/obj/clothing/suits/ert_suits.dmi'
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_armor.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
	icon_state = "rebel_armor"
	worn_icon_state = "rebel_armor"
	armor_protection_flags = CHEST|GROIN|LEGS

/obj/item/clothing/suit/techpriest
	name = "Techpriest Robes"
	desc = "Praise the omnissiah!"
	icon_state = "tp_bodyrobes"
	worn_icon_state = "tp_bodyrobes"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS

