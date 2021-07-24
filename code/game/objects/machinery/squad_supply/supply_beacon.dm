/obj/item/beacon
	w_class = WEIGHT_CLASS_SMALL
	/// If this beacon is activated
	var/activated = FALSE
	/// How long to activate this beacon
	var/activation_time = 80
	/// The icon when acticated
	var/icon_activated = ""
	/// The camera attached to the beacon
	var/obj/machinery/camera/beacon_cam = null

/obj/item/beacon/update_icon_state()
	icon_state = activated ? icon_activated : initial(icon_state)

/obj/item/beacon/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	activate(H)

/obj/item/beacon/attack_hand(mob/living/carbon/human/H)
	if(!ishuman(H))
		return ..()
	if(activated)
		deactivate(H)
		return
	return ..()

/// Set this beacon on the ground and activate it
/obj/item/beacon/proc/activate(mob/living/carbon/human/H)
	if(!is_ground_level(H.z))
		to_chat(H, "<span class='warning'>You have to be on the planet to use this or it won't transmit.</span>")
		return FALSE
	var/area/A = get_area(H)
	if(A && istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(H, "<span class='warning'>This won't work if you're standing deep underground.</span>")
		return FALSE
	if(istype(A, /area/shuttle/dropship))
		to_chat(H, "<span class='warning'>You have to be outside the dropship to use this or it won't transmit.</span>")
		return FALSE
	var/delay = max(1.5 SECONDS, activation_time - 2 SECONDS * H.skills.getRating("leadership"))
	H.visible_message("<span class='notice'>[H] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(!do_after(H, delay, TRUE, src, BUSY_ICON_GENERIC))
		return FALSE
	GLOB.active_orbital_beacons += src
	var/obj/machinery/camera/beacon_cam/BC = new(src, "[H.get_paygrade()] [H.name] [src]")
	H.transferItemToLoc(src, H.loc)
	beacon_cam = BC
	message_admins("[ADMIN_TPMONTY(usr)] set up an orbital strike beacon.")
	name = "transmitting orbital beacon"
	activated = TRUE
	anchored = TRUE
	w_class = 10
	layer = ABOVE_FLY_LAYER
	set_light(2)
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	H.visible_message("[H] activates [src].",
	"You activate [src].")
	update_icon()
	return TRUE

/// Deactivate this beacon and put it in the hand of the human
/obj/item/beacon/proc/deactivate(mob/living/carbon/human/H)
	var/delay = max(1 SECONDS, activation_time * 0.5 - 2 SECONDS * H.skills.getRating("leadership")) //Half as long as setting it up.
	H.visible_message("<span class='notice'>[H] starts removing [src] from the ground.</span>",
	"<span class='notice'>You start removing [src] from the ground, deactivating it.</span>")
	if(!do_after(H, delay, TRUE, src, BUSY_ICON_GENERIC))
		return FALSE
	GLOB.active_orbital_beacons -= src
	QDEL_NULL(beacon_cam)
	activated = FALSE
	anchored = FALSE
	w_class = initial(w_class)
	layer = initial(layer)
	name = initial(name)
	set_light(0)
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	H.visible_message("[H] deactivates [src].",
	"You deactivate [src].")
	H.put_in_active_hand(src)
	update_icon()
	return TRUE

/obj/item/beacon/Destroy()
	GLOB.active_orbital_beacons -= src
	if(beacon_cam)
		qdel(beacon_cam)
		beacon_cam = null
	return ..()

/obj/item/beacon/orbital_bombardment_beacon
	name = "orbital beacon"
	desc = "A bulky device that fires a beam up to an orbiting vessel to send local coordinates."
	icon_state = "motion4"
	icon_activated = "motion1"
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
		return
	else	//So we can just get a goshdarn name.
		name += " ([H])"

/obj/item/beacon/orbital_bombardment_beacon/deactivate(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return
	squad?.squad_orbital_beacons -= src
	squad = null

/obj/item/beacon/orbital_bombardment_beacon/Destroy()
	squad?.squad_orbital_beacons -= src
	squad = null
	return ..()

/obj/item/beacon/supply_beacon
	name = "supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon_state = "motion0"
	icon_activated = "motion2"
	activation_time = 60
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

/obj/item/beacon/supply_beacon/Destroy()
	if(beacon_datum)
		UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
		QDEL_NULL(beacon_datum)
	return ..()

/// Signal handler to nullify beacon datum
/obj/item/beacon/supply_beacon/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

/obj/item/beacon/supply_beacon/activate(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return
	var/area/A = get_area(H)
	beacon_datum = new /datum/supply_beacon("[H.name] + [A]", loc, H.faction)
	RegisterSignal(beacon_datum, COMSIG_PARENT_QDELETING, .proc/clean_beacon_datum)

/obj/item/beacon/supply_beacon/deactivate(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return
	UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
	QDEL_NULL(beacon_datum)

/datum/supply_beacon
	/// Name printed on the supply console
	var/name = ""
	/// Where the supply drops will land
	var/turf/drop_location
	/// The faction of the beacon
	var/faction = ""

/datum/supply_beacon/New(_name, turf/_drop_location, _faction, life_time = 0 SECONDS)
	name= _name
	drop_location = _drop_location
	faction = _faction
	GLOB.supply_beacon[name] = src
	if(life_time)
		QDEL_IN(src, life_time)

/// Remove that beacon from the list of glob supply beacon
/datum/supply_beacon/Destroy()
	GLOB.supply_beacon[name] = null
	return ..()
