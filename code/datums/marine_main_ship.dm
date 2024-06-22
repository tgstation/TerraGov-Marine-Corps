GLOBAL_DATUM_INIT(marine_main_ship, /datum/marine_main_ship, new)

// datum for stuff specifically related to the marine main ship like theseus
/datum/marine_main_ship

	var/obj/structure/orbital_cannon/orbital_cannon

	var/obj/structure/ship_rail_gun/rail_gun

	var/maint_all_access = FALSE

/datum/marine_main_ship/proc/make_maint_all_access()
	maint_all_access = TRUE
	priority_announce("The maintenance access requirement has been revoked on all airlocks.", "Attention!", "Shipside emergency declared.", sound = 'sound/misc/notice1.ogg', color_override = "grey")

/datum/marine_main_ship/proc/revoke_maint_all_access()
	maint_all_access = FALSE
	priority_announce("The maintenance access requirement has been readded on all maintenance airlocks.", "Attention!", "Shipside emergency revoked.", sound = 'sound/misc/notice2.ogg', color_override = "grey")
