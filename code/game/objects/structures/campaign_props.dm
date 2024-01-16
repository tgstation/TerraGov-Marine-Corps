/obj/structure/prop/som_fighter
	name = "\improper Harbinger"
	desc = "A state of the art Harbinger class fighter. The premier fighter for SOM forces in space and atmosphere, bristling with high tech systems and weapons."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "SOM_fighter"
	pixel_x = -33
	pixel_y = -10
	density = TRUE
	allow_pass_flags = PASS_AIR

/obj/structure/prop/som_fighter/empty
	icon_state = "SOM_fighter_empty"
	desc = "A state of the art Harbinger class fighter. The premier fighter for SOM forces in space and atmosphere, this one seems to be unarmed currently."

/obj/structure/prop/train
	name = "locomotive"
	desc = "A heavy duty maglev locomotive. Designed for moving large quantities of goods from point A to point B."
	icon = 'icons/obj/structures/train.dmi'
	icon_state = "maglev"
	density = TRUE
	allow_pass_flags = PASS_AIR
	bound_width = 128

/obj/structure/prop/train/carriage
	name = "rail carriage"
	desc = "A heavy duty maglev carriage. I wonder what's inside?."
	icon_state = "carriage"

/obj/structure/prop/train/carriage_lit
	name = "rail carriage"
	desc = "A heavy duty maglev carriage. I wonder what's inside?."
	icon_state = "carriage_lit"

/obj/structure/prop/train/cargo_nt
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a large cargo container on it."
	icon_state = "nt"

/obj/structure/prop/train/cargo_sat
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a large cargo container on it."
	icon_state = "sat"

/obj/structure/prop/train/cargo_hyperdyne
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a large cargo container on it."
	icon_state = "hyperdyne"

/obj/structure/prop/train/construction
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one is carrying a variety of construction materials."
	icon_state = "construction"
	allow_pass_flags = PASSABLE

/obj/structure/prop/train/crates
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a variety of crates on it."
	icon_state = "crates"
	allow_pass_flags = PASSABLE

/obj/structure/prop/train/weapons
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one is carrying a shipment of weapons."
	icon_state = "weapons"
	allow_pass_flags = PASSABLE

/obj/structure/prop/train/mech
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a variety of mech equipment on it."
	icon_state = "mech"
	allow_pass_flags = PASSABLE

/obj/structure/prop/train/empty
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one is currently empty."
	icon_state = "empty"
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER

/obj/structure/prop/nt_computer
	name = "server rack"
	desc = "A server rack. Who knows what's on it?."
	icon = 'icons/obj/structures/campaign/tall_structures.dmi'
	icon_state = "serverrack_on"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_FLARE

/obj/structure/prop/nt_computer/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/prop/nt_computer/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)

/obj/structure/prop/nt_computer/rack
	name = "control rack"
	desc = "A system control rack. Who knows what's on it?."
	icon_state = "recorder_on"

/obj/structure/prop/nt_computer/recorder
	name = "backup recorder"
	desc = "A backup data recorder. Who knows what's on it?."
	icon_state = "rack_on"
	light_range = 0
	light_power = 0

/obj/structure/gauss_cannon
	name = "\improper Gauss Cannon"
	desc = "A powerful gauss cannon. Designed to punch holes through hostile spacecraft."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "gauss_cannon"
	density = TRUE
	anchored = TRUE
	layer = LADDER_LAYER
	bound_width = 128
	bound_height = 64
	bound_y = 64
	resistance_flags = RESIST_ALL
	allow_pass_flags = NONE
	light_range = 4
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUEGREEN

/obj/structure/gauss_cannon/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/gauss_cannon/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)
