/*******************************************************************************
OPERATIONS
*******************************************************************************/
/datum/supply_packs/operations
	group = "Operations"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/operations/beacons_supply
	name = "Supply beacon"
	contains = list(/obj/item/supply_beacon)
	cost = 100

/datum/supply_packs/operations/fulton_extraction_pack
	name = "Fulton extraction pack"
	contains = list(/obj/item/fulton_extraction_pack)
	cost = 100

/datum/supply_packs/operations/autominer
	name = "Autominer upgrade"
	contains = list(/obj/item/minerupgrade/automatic)
	cost = 50

/datum/supply_packs/operations/miningwelloverclock
	name = "Mining well reinforcement upgrade"
	contains = list(/obj/item/minerupgrade/reinforcement)
	cost = 50

/datum/supply_packs/operations/miningwellresistance
	name = "Mining well overclock upgrade"
	contains = list(/obj/item/minerupgrade/overclock)
	cost = 50

/datum/supply_packs/operations/binoculars_tactical
	name = "Tactical binoculars crate"
	contains = list(
		/obj/item/binoculars/tactical,
		/obj/item/encryptionkey/cas,
	)
	cost = 300
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/pinpointer
	name = "Xeno structure tracker crate"
	contains = list(/obj/item/pinpointer)
	cost = 200
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/xeno_iff_tag
	name = "Xenomorph IFF tag crate" //Intended for corrupted or friendly rounies as rounds sometimes turn out. Avoid abuse or I'll have to admin-only it, which is no fun!
	notes = "Contains an IFF tag used to mark a xenomorph as friendly to IFF systems. Warning: Nanotrasen is not responsible for incidents related to attaching this to hostile entities."
	contains = list(/obj/item/xeno_iff_tag)
	access = ACCESS_MARINE_BRIDGE //Better be safe.
	cost = 130

/datum/supply_packs/operations/flare_crate
	name = "Surplus flare crate"
	contains = list(/obj/structure/largecrate/supply/supplies/flares)
	cost = 75

/datum/supply_packs/operations/deployable_camera
	name = "3 deployable cameras"
	contains = list(
		/obj/item/deployable_camera,
		/obj/item/deployable_camera,
		/obj/item/deployable_camera,
	)
	cost = 20

/datum/supply_packs/operations/exportpad
	name = "ASRS bluespace export point"
	contains = list(/obj/machinery/exportpad)
	cost = 300

/datum/supply_packs/operations/warhead_cluster
	name = "Cluster orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/cluster)
	cost = 200
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/warhead_explosive
	name = "HE orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/explosive)
	cost = 300
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/warhead_incendiary
	name = "Incendiary orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/incendiary)
	cost = 200
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/warhead_plasmaloss
	name = "Plasma draining orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/plasmaloss)
	cost = 150
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/ob_fuel
	name = "Solid fuel"
	contains = list(/obj/structure/ob_ammo/ob_fuel)
	cost = 50
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/droppod
	name = "Zeus orbital drop pod"
	contains = list(/obj/structure/droppod)
	containertype = null
	cost = 50

/datum/supply_packs/operations/droppod_leader
	name = "Zeus command drop pod"
	contains = list(/obj/structure/droppod/leader)
	containertype = null
	cost = 100

/datum/supply_packs/operations/researchcomp
	name = "Research console"
	contains = list(/obj/machinery/researchcomp)
	containertype = null
	cost = 200

/datum/supply_packs/operations/supply_tablet
	name = "Supply tablet"
	contains = list(/obj/item/supplytablet)
	cost = 50

/datum/supply_packs/operations/tadpole_electronics
	name = "Tadpole navigation electronics"
	contains = list(/obj/item/circuitboard/tadpole)
	cost = 750

/datum/supply_packs/operations/rappel_rope
	name = "Tadpole rappel system cord"
	contains = list(/obj/item/spare_cord)
	cost = 300
