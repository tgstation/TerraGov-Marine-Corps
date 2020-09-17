/obj/effect/decal/medical_decals
	icon = 'icons/effects/medical_decals.dmi'
	layer = TURF_LAYER

/obj/effect/decal/medical_decals/Initialize()
	. = ..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL

/obj/effect/decal/medical_decals/cryo
	icon_state = "cryotop"

/obj/effect/decal/medical_decals/cryo/mid
	icon_state = "cryomid"

/obj/effect/decal/medical_decals/cryo/cell
	icon_state = "cryocell1decal"

/obj/effect/decal/medical_decals/cryo/cell/two
	icon_state = "cryocell2decal"

/obj/effect/decal/medical_decals/cryo/cell/three
	icon_state = "cryocell3decal"

/obj/effect/decal/medical_decals/cryo/cell/four
	icon_state = "cryocell4decal"

/obj/effect/decal/medical_decals/doc
	icon_state = "docdecal1"

/obj/effect/decal/medical_decals/doc/two
	icon_state = "docdecal2"

/obj/effect/decal/medical_decals/doc/three
	icon_state = "docdecal3"

/obj/effect/decal/medical_decals/doc/four
	icon_state = "docdecal4"

/obj/effect/decal/medical_decals/doc/stripe
	icon_state = "docstriping"

/obj/effect/decal/medical_decals/triage/
	icon_state = "triagedecalline"

/obj/effect/decal/medical_decals/triage/corner
	icon_state = "triagedecalcorner"

/obj/effect/decal/medical_decals/triage/edge
	icon_state = "triagedecaledge"

/obj/effect/decal/medical_decals/triage/top
	icon_state = "triagedecaltop"

/obj/effect/decal/medical_decals/triage/middle
	icon_state = "triagedecal"

/obj/effect/decal/medical_decals/triage/bottom
	icon_state = "triagedecalbottom"
