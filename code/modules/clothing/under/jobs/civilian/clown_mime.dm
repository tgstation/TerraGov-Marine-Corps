
/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = ""
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	desc = ""
	icon_state = "mime_skirt"
	item_state = "mime"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = ""
	icon_state = "sexymime"
	item_state = "sexymime"
	body_parts_covered = CHEST|GROIN|LEGS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown
	name = "clown suit"
	desc = ""
	icon_state = "clown"
	item_state = "clown"

/obj/item/clothing/under/rank/civilian/clown/blue
	name = "blue clown suit"
	desc = ""
	icon_state = "blueclown"
	item_state = "blueclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/green
	name = "green clown suit"
	desc = ""
	icon_state = "greenclown"
	item_state = "greenclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/yellow
	name = "yellow clown suit"
	desc = ""
	icon_state = "yellowclown"
	item_state = "yellowclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/purple
	name = "purple clown suit"
	desc = ""
	icon_state = "purpleclown"
	item_state = "purpleclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/orange
	name = "orange clown suit"
	desc = ""
	icon_state = "orangeclown"
	item_state = "orangeclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/rainbow
	name = "rainbow clown suit"
	desc = ""
	icon_state = "rainbowclown"
	item_state = "rainbowclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/jester
	name = "jester suit"
	desc = ""
	icon_state = "jester"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/jester/alt
	icon_state = "jester2"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = ""
	icon_state = "sexyclown"
	item_state = "sexyclown"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/blank.ogg'=1), 50)
