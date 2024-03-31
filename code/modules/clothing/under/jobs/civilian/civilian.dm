//Alphabetical order of civilian jobs.

/obj/item/clothing/under/rank/civilian
	icon = 'icons/obj/clothing/under/civilian.dmi'
	mob_overlay_icon = 'icons/mob/clothing/under/civilian.dmi'

/obj/item/clothing/under/rank/civilian/bartender
	desc = ""
	name = "bartender's uniform"
	icon_state = "barman"
	item_state = "bar_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/bartender/purple
	desc = ""
	name = "purple bartender's uniform"
	icon_state = "purplebartender"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/bartender/skirt
	name = "bartender's skirt"
	desc = ""
	icon_state = "barman_skirt"
	item_state = "bar_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/chaplain
	desc = ""
	name = "chaplain's jumpsuit"
	icon_state = "chaplain"
	item_state = "bl_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/chaplain/skirt
	name = "chaplain's jumpskirt"
	desc = ""
	icon_state = "chapblack_skirt"
	item_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/chef
	name = "cook's suit"
	desc = ""
	icon_state = "chef"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/chef/skirt
	name = "cook's skirt"
	desc = ""
	icon_state = "chef_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/head_of_personnel
	desc = ""
	name = "head of personnel's jumpsuit"
	icon_state = "hop"
	item_state = "b_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt
	name = "head of personnel's jumpskirt"
	desc = ""
	icon_state = "hop_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = ""
	icon_state = "teal_suit"
	item_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/head_of_personnel/suit/skirt
	name = "teal suitskirt"
	desc = ""
	icon_state = "teal_suit_skirt"
	item_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/hydroponics
	desc = ""
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	permeability_coefficient = 0.5

/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	name = "botanist's jumpskirt"
	desc = ""
	icon_state = "hydroponics_skirt"
	item_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/janitor
	desc = ""
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "janitor's jumpskirt"
	desc = ""
	icon_state = "janitor_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/janitor/maid
	name = "maid uniform"
	desc = ""
	icon_state = "janimaid"
	item_state = "janimaid"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer
	desc = ""
	name = "Lawyer suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer/dye_item(dye_color, dye_key_override)
	if(dye_color == DYE_COSMIC || dye_color == DYE_SYNDICATE)
		..(dye_color, DYE_LAWYER_SPECIAL)
	else
		..()

/obj/item/clothing/under/rank/civilian/lawyer/black
	name = "lawyer black suit"
	icon_state = "lawyer_black"
	item_state = "lawyer_black"

/obj/item/clothing/under/rank/civilian/lawyer/black/skirt
	name = "lawyer black suitskirt"
	icon_state = "lawyer_black_skirt"
	item_state = "lawyer_black"
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/lawyer/female
	name = "female black suit"
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	mob_overlay_icon = 'icons/mob/clothing/under/suits.dmi'

/obj/item/clothing/under/rank/civilian/lawyer/female/skirt
	name = "female black suitskirt"
	icon_state = "black_suit_fem_skirt"
	item_state = "black_suit_fem_skirt"
	mob_overlay_icon = 'icons/mob/clothing/under/suits.dmi'
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/lawyer/red
	name = "lawyer red suit"
	icon_state = "lawyer_red"
	item_state = "lawyer_red"

/obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	name = "lawyer red suitskirt"
	icon_state = "lawyer_red_skirt"
	item_state = "lawyer_red"
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/lawyer/blue
	name = "lawyer blue suit"
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"

/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt
	name = "lawyer blue suitskirt"
	icon_state = "lawyer_blue_skirt"
	item_state = "lawyer_blue"
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	name = "blue suit"
	desc = ""
	icon_state = "bluesuit"
	item_state = "b_suit"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt
	name = "blue suitskirt"
	desc = ""
	icon_state = "bluesuit_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	name = "purple suit"
	icon_state = "lawyer_purp"
	item_state = "p_suit"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt
	name = "purple suitskirt"
	icon_state = "lawyer_purp_skirt"
	item_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/lawyer/galaxy
	mob_overlay_icon = 'icons/mob/clothing/under/lawyer_galaxy.dmi'
	can_adjust = FALSE
	name = "blue galaxy suit"
	icon_state = "lawyer_galaxy_blue"
	item_state = "b_suit"

/obj/item/clothing/under/rank/civilian/lawyer/galaxy/red
	name = "red galaxy suit"
	icon_state = "lawyer_galaxy_red"
	item_state = "r_suit"

/obj/item/clothing/under/rank/civilian/cookjorts
	name = "grilling shorts"
	desc = ""
	icon_state = "cookjorts"
