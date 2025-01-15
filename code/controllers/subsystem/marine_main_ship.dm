/// This subsystem handles shipside maintenance AA, and quick access to the orbital cannon
/// and rail gun.
SUBSYSTEM_DEF(marine_main_ship)
	name = "Marine Main Ship"
	flags = SS_NO_FIRE|SS_NO_INIT
	/// The active orbital cannon on ship
	var/obj/structure/orbital_cannon/orbital_cannon
	/// The active rail gun on ship
	var/obj/structure/ship_rail_gun/rail_gun
	/// Is maintenance AA enabled on ship?
	var/maint_all_access = FALSE

/// Sets the [maint_all_access] var. Maintenance airlocks will refer to this.
/datum/controller/subsystem/marine_main_ship/proc/make_maint_all_access()
	maint_all_access = TRUE
	priority_announce(
		"The maintenance access requirement has been revoked on all airlocks.",
		"Attention!",
		"Shipside emergency declared.",
		sound = 'sound/misc/notice1.ogg',
		color_override = "grey"
	)

/// Disables the [maint_all_access] var. Maintenance airlocks will refer to this.
/datum/controller/subsystem/marine_main_ship/proc/revoke_maint_all_access()
	maint_all_access = FALSE
	priority_announce(
		"The maintenance access requirement has been readded on all maintenance airlocks.",
		"Attention!",
		"Shipside emergency revoked.",
		sound = 'sound/misc/notice2.ogg',
		color_override = "grey"
	)
