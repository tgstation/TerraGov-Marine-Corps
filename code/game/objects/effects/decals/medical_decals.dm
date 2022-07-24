/atom/movable/effect/decal/medical_decals
	icon = 'icons/effects/medical_decals.dmi'
	layer = TURF_LAYER

/atom/movable/effect/decal/medical_decals/Initialize()
	. = ..()

	loc.overlays += src
	return INITIALIZE_HINT_QDEL

/atom/movable/effect/decal/medical_decals/cryo
	icon_state = "cryotop"

/atom/movable/effect/decal/medical_decals/cryo/mid
	icon_state = "cryomid"

/atom/movable/effect/decal/medical_decals/cryo/cell
	icon_state = "cryocell1decal"

/atom/movable/effect/decal/medical_decals/cryo/cell/two
	icon_state = "cryocell2decal"

/atom/movable/effect/decal/medical_decals/cryo/cell/three
	icon_state = "cryocell3decal"

/atom/movable/effect/decal/medical_decals/cryo/cell/four
	icon_state = "cryocell4decal"

/atom/movable/effect/decal/medical_decals/doc
	icon_state = "docdecal1"

/atom/movable/effect/decal/medical_decals/doc/two
	icon_state = "docdecal2"

/atom/movable/effect/decal/medical_decals/doc/three
	icon_state = "docdecal3"

/atom/movable/effect/decal/medical_decals/doc/four
	icon_state = "docdecal4"

/atom/movable/effect/decal/medical_decals/doc/stripe
	icon_state = "docstriping"

/atom/movable/effect/decal/medical_decals/triage/
	icon_state = "triagedecalline"

/atom/movable/effect/decal/medical_decals/triage/corner
	icon_state = "triagedecalcorner"

/atom/movable/effect/decal/medical_decals/triage/edge
	icon_state = "triagedecaledge"

/atom/movable/effect/decal/medical_decals/triage/top
	icon_state = "triagedecaltop"

/atom/movable/effect/decal/medical_decals/triage/middle
	icon_state = "triagedecal"

/atom/movable/effect/decal/medical_decals/triage/bottom
	icon_state = "triagedecalbottom"
