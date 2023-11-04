/obj/item/beacon
	///Beacon minimap icon
	var/beacon_mini_icon = null

/obj/item/beacon/orbital_bombardment_beacon
	name = "orbital beacon"
	desc = "A bulky device that fires a beam up to an orbiting vessel to send local coordinates."
	icon = 'modular_RUtgmc/icons/Marine/marine-navigation.dmi'
	icon_state = "motion4"
	icon_activated = "motion1"
	underground_signal = FALSE
	beacon_mini_icon = "ob_beacon"
	///The squad this OB beacon belongs to
	var/datum/squad/squad = null

/obj/item/beacon/orbital_bombardment_beacon/activate(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return
	if(H.assigned_squad)
		squad = H.assigned_squad
		name += " ([squad.name])"
		squad.squad_orbital_beacons += src
		name += " ([H])"
		GLOB.active_orbital_beacons += src
		return
	else	//So we can just get a goshdarn name.
		name += " ([H])"
		GLOB.active_orbital_beacons += src
	message_admins("[ADMIN_TPMONTY(usr)] set up an orbital strike beacon.")

/obj/item/beacon/orbital_bombardment_beacon/deactivate(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return
	squad?.squad_orbital_beacons -= src
	squad = null
	GLOB.active_orbital_beacons -= src

/obj/item/beacon/orbital_bombardment_beacon/Destroy()
	squad?.squad_orbital_beacons -= src
	squad = null
	GLOB.active_orbital_beacons -= src
	return ..()

/obj/item/beacon/supply_beacon
	beacon_mini_icon = "supply"
