/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy box used for storing ore."
	density = TRUE
	anchored = FALSE
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/ore_box/phoron
	name = "phoron ore crate"
	desc = "A large crate filled with raw phoron crystals."
	icon_state = "orebox_phoron"
	max_integrity = 100
	soft_armor = list("acid" = 100)

/obj/structure/ore_box/platinum
	name = "platinum ore crate"
	desc = "A large crate filled with raw platinum ore."
	icon_state = "orebox_platinum"
	max_integrity = 100
	soft_armor = list("acid" = 100)
