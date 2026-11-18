/obj/item/binoculars/fire_support
	name = "fire support binoculars"
	desc = "A pair of binoculars, used to mark targets for airstrikes and cruise missiles. Unique action to toggle mode. Ctrl+Click when using to target something."
	icon_state = "fire_support"
	w_class = WEIGHT_CLASS_SMALL
	///firemodes available for these binos
	var/list/mode_list = list(
		FIRESUPPORT_TYPE_GUN_UNLIMITED,
		FIRESUPPORT_TYPE_ROCKETS_UNLIMITED,
		FIRESUPPORT_TYPE_CRUISE_MISSILE_UNLIMITED,
	)

/obj/item/binoculars/fire_support/Initialize(mapload)
	. = ..()
	update_icon()
	AddComponent(/datum/component/fire_support, mode_list)

/obj/item/binoculars/fire_support/onzoom(mob/living/user)
	. = ..()
	user.reset_perspective(src)
	user.update_sight()

/obj/item/binoculars/fire_support/onunzoom(mob/living/user)
	. = ..()
	if(!user?.client)
		return

	user.reset_perspective(user)
	user.update_sight()

/obj/item/binoculars/fire_support/update_remote_sight(mob/living/user)
	user.lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
	user.sync_lighting_plane_cutoff()
	return TRUE

/obj/item/binoculars/fire_support/update_overlays()
	. = ..()
	. += "binoculars_cas"

/obj/item/binoculars/fire_support/campaign
	faction = FACTION_TERRAGOV
	mode_list = list(
		FIRESUPPORT_TYPE_GUN,
		FIRESUPPORT_TYPE_ROCKETS,
		FIRESUPPORT_TYPE_CRUISE_MISSILE,
		FIRESUPPORT_TYPE_LASER,
		FIRESUPPORT_TYPE_HE_MORTAR,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR,
		FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR,
		FIRESUPPORT_TYPE_SMOKE_MORTAR,
		FIRESUPPORT_TYPE_SENTRY_POD,
		FIRESUPPORT_TYPE_SUPPLY_POD,
	)

/obj/item/binoculars/fire_support/campaign/som
	faction = FACTION_SOM
	mode_list = list(
		FIRESUPPORT_TYPE_VOLKITE,
		FIRESUPPORT_TYPE_INCEND_ROCKETS,
		FIRESUPPORT_TYPE_RAD_MISSILE,
		FIRESUPPORT_TYPE_HE_MORTAR_SOM,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM,
		FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR,
		FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM,
		FIRESUPPORT_TYPE_TELE_COPE,
	)
