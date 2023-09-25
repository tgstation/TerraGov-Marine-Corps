//Destroy mission objectives

/obj/structure/campaign_objective/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200) //require c4 normally


//Howitzer
/obj/effect/landmark/campaign_objective/howitzer_objective
	name = "howitzer objective"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	objective_type = /obj/structure/campaign_objective/destruction_objective/howitzer

/obj/structure/campaign_objective/destruction_objective/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	pixel_x = -16

//MLRS
/obj/effect/landmark/campaign_objective/mlrs
	name = "MLRS objective"
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	icon_state = "mlrs"
	pixel_y = -15
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	objective_type = /obj/structure/campaign_objective/destruction_objective/mlrs

/obj/structure/campaign_objective/destruction_objective/mlrs
	name = "\improper SOT-A1 MLRS"
	desc = "A massive multi launch rocket system on a tracked chassis. Can unleash a tremendous amount of firepower in a short amount of time."
	icon = 'icons/obj/structures/campaign/campaign_big.dmi'
	icon_state = "mlrs"
	bound_height = 64
	bound_width = 128
	pixel_y = -15
	coverage = 100

/obj/structure/campaign_objective/destruction_objective/mlrs/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/campaign_objective/destruction_objective/mlrs/update_overlays()
	. = ..()
	var/image/new_overlay = image(icon, src, "[initial(icon_state)]_overlay", ABOVE_MOB_LAYER, dir)
	. += new_overlay

//Supply depot objectives
/obj/effect/landmark/campaign_objective/supply_objective
	name = "howitzer objective"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	mission_types = list(/datum/campaign_mission/destroy_mission/fire_support_raid)
	objective_type = /obj/structure/campaign_objective/destruction_objective/howitzer

/obj/structure/campaign_objective/destruction_objective/supply_objective
	name = "SUPPLY_OBJECTIVE"
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_deployed"
	pixel_x = -16

//Train
/obj/structure/campaign_objective/destruction_objective/supply_objective/train
	name = "locomotive"
	desc = "A heavy duty maglev locomotive. Designed for moving large quantities of goods from point A to point B."
	icon = 'icons/obj/structures/train.dmi'
	icon_state = "maglev"
	pixel_x = -63

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/cargo_nt
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a large cargo container on it."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/cargo_sat
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a large cargo container on it."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/cargo_hyperdyne
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a large cargo container on it."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/construction
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one is carrying a variety of construction materials."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/crates
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a variety of crates on it."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/weapons
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one is carrying a shipment of weapons."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/mech
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one has a variety of mech equipment on it."
	icon_state = "nt"

/obj/structure/campaign_objective/destruction_objective/supply_objective/train/empty
	name = "railcar"
	desc = "A heavy duty maglev railcar. This one is currently empty."
	icon_state = "nt"
