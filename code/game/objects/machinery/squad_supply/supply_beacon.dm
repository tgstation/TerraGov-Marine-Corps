/obj/item/supply_beacon
	name = "supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon_state = "motion0"
	w_class = WEIGHT_CLASS_SMALL
	var/activated = 0
	var/activation_time = 60
	var/obj/machinery/camera/beacon_cam = null
	/// Reference to the datum used by the supply drop console
	var/datum/supply_beacon/beacon_datum

/obj/item/supply_beacon/Destroy()
	GLOB.active_orbital_beacons -= src
	UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
	beacon_datum.unregister()
	if(beacon_cam)
		qdel(beacon_cam)
		beacon_cam = null
	return ..()

/// Signal handler to nullify beacon datum
/obj/item/supply_beacon/proc/clean_beacon_datum()
	SIGNAL_HANDLER
	beacon_datum = null

/obj/item/supply_beacon/attack_self(mob/living/user)
	if(activated)
		to_chat(user, "<span class='warning'>It's already been activated. Just leave it.</span>")
		return
	if(!ishuman(user))
		return
	
	var/area/A = get_area(user)
	if(A && istype(A) && A.ceiling >= CEILING_METAL)
		to_chat(user, "<span class='warning'>You have to be outside or under a glass ceiling to activate this.</span>")
		return

	var/delay = max(1 SECONDS, activation_time - 2 SECONDS * user.skills.getRating("leadership"))

	user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(!do_after(user, delay, TRUE, src, BUSY_ICON_GENERIC))
		return
	user.transferItemToLoc(src, user.loc)
	beacon_datum = new /datum/supply_beacon("[user.name] + [A]", loc, user.faction)
	RegisterSignal(beacon_datum, COMSIG_PARENT_QDELETING, .proc/clean_beacon_datum)
	activated = TRUE
	anchored = TRUE
	w_class = 10
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	user.visible_message("[user] activates [src]",
	"You activate [src]")
	update_icon()

/obj/item/supply_beacon/update_icon_state()
	icon_state = activated ? "motion2" : "motion0"

/obj/item/supply_beacon/attack_hand(mob/user)
	..()
	if(!activated)
		return
	activated = FALSE
	anchored = FALSE
	w_class = initial(w_class)
	layer = initial(layer)
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	user.visible_message("[usr] deactivates [src]",
	"You deactivate [src]")
	user.put_in_active_hand(src)
	UnregisterSignal(beacon_datum, COMSIG_PARENT_QDELETING)
	beacon_datum.unregister()
	beacon_datum = null

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
		addtimer(CALLBACK(src, .proc/unregister), life_time)

/// Remove that beacon from the list of glob supply beacon 
/datum/supply_beacon/proc/unregister()
	GLOB.supply_beacon[name] = null
	qdel(src)
