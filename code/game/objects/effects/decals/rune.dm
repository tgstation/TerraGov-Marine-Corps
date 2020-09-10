/obj/effect/decal/cleanable/rune
	name = "rune"
	desc = "A rune drawn in blood."
	icon = 'icons/obj/rune.dmi'
	icon_state = "rune1"
	layer = ABOVE_TURF_LAYER
	anchored = TRUE


/obj/effect/decal/cleanable/rune/Initialize()
	. = ..()
	icon_state = "rune[pick("1","2","3","4","5","6")]"

/obj/effect/decal/cleanable/rune/blank
	icon_state = "main1"

/obj/effect/decal/cleanable/rune/blank/Initialize()
	. = ..()
	icon_state = "main[pick("1","2","3","4","5","6")]"

/obj/effect/decal/cleanable/rune/alt
	icon_state = "shade"

/obj/effect/decal/cleanable/rune/alt/Initialize()
	. = ..()
	icon_state = "shade[pick("1","2","3","4","5","6")]"
