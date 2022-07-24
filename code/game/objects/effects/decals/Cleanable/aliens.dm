

//Alien blood effects.
/atom/movable/effect/decal/cleanable/blood/xeno
	name = "sizzling blood"
	desc = "It's yellow and acidic. It looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	basecolor = "#dffc00"
	amount = 0

/atom/movable/effect/decal/cleanable/blood/gibs/xeno
	name = "steaming gibs"
	desc = "Gnarly..."
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	basecolor = "#dffc00"
	amount = 0

/atom/movable/effect/decal/cleanable/blood/gibs/xeno/update_icon()
	color = "#FFFFFF"

/atom/movable/effect/decal/cleanable/blood/gibs/xeno/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/atom/movable/effect/decal/cleanable/blood/gibs/xeno/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/atom/movable/effect/decal/cleanable/blood/gibs/xeno/body
	random_icon_states = list("xgibhead", "xgibtorso")

/atom/movable/effect/decal/cleanable/blood/gibs/xeno/limb
	random_icon_states = list("xgibleg", "xgibarm")

/atom/movable/effect/decal/cleanable/blood/gibs/xeno/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/atom/movable/effect/decal/cleanable/blood/xtracks
	basecolor = "#dffc00"
