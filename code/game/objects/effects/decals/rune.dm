/obj/effect/decal/cleanable/rune
	name = "rune"
	desc = "A rune drawn in blood."
	icon = 'icons/obj/rune.dmi'
	icon_state = "rune1"
	anchored = TRUE


/obj/effect/decal/cleanable/rune/Initialize(mapload)
	. = ..()
	icon_state = "rune[rand(1, 6)]"

/obj/effect/decal/cleanable/rune/blank
	icon_state = "main1"

/obj/effect/decal/cleanable/rune/blank/Initialize(mapload)
	. = ..()
	icon_state = "main[rand(1, 6)]"

/obj/effect/decal/cleanable/rune/alt
	icon_state = "shade"

/obj/effect/decal/cleanable/rune/alt/Initialize(mapload)
	. = ..()
	icon_state = "shade[rand(1, 6)]"
