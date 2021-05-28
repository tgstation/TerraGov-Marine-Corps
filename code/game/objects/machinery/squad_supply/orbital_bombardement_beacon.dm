
/obj/item/orbital_bombardment_beacon
	name = "orbital beacon"
	desc = "A bulky device that fires a beam up to an orbiting vessel to send local coordinates."
	icon_state = "motion4"
	w_class = WEIGHT_CLASS_SMALL
	var/activated = 0
	var/activation_time = 80
	var/datum/squad/squad = null
	var/icon_activated = "motion1"
	var/obj/machinery/camera/beacon_cam = null

/obj/item/orbital_bombardment_beacon/Destroy()
	GLOB.active_orbital_beacons -= src
	if(squad)
		if(src in squad.squad_orbital_beacons)
			squad.squad_orbital_beacons -= src
		squad = null
	if(beacon_cam)
		qdel(beacon_cam)
		beacon_cam = null
	return ..()

/obj/item/orbital_bombardment_beacon/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!H.mind)
		to_chat(H, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return
	activate(H)

/obj/item/orbital_bombardment_beacon/attack_hand(mob/living/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		to_chat(H, "<span class='warning'>It doesn't seem to do anything for you.</span>")
		return ..()
	if(activated)
		deactivate(H)
	else
		return ..()

/obj/item/orbital_bombardment_beacon/proc/activate(mob/living/carbon/human/H)
	if(!is_ground_level(H.z))
		to_chat(H, "<span class='warning'>You have to be on the planet to use this or it won't transmit.</span>")
		return
	var/area/A = get_area(H)
	if(A && istype(A) && A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(H, "<span class='warning'>This won't work if you're standing deep underground.</span>")
		return
	var/delay = max(1.5 SECONDS, activation_time - 2 SECONDS * H.skills.getRating("leadership"))
	H.visible_message("<span class='notice'>[H] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(!do_after(H, delay, TRUE, src, BUSY_ICON_GENERIC))
		return
	message_admins("[ADMIN_TPMONTY(usr)] set up an orbital strike beacon.")
	name = "transmitting orbital beacon"
	GLOB.active_orbital_beacons += src
	var/cam_name = ""
	cam_name += H.get_paygrade()
	cam_name += H.name
	if(H.assigned_squad)
		squad = H.assigned_squad
		name += " ([squad.name])"
		squad.squad_orbital_beacons += src
	cam_name += " [src]"
	var/obj/machinery/camera/beacon_cam/BC = new(src, cam_name)
	H.transferItemToLoc(src, H.loc)
	beacon_cam = BC
	activated = TRUE
	anchored = TRUE
	w_class = 10
	layer = ABOVE_FLY_LAYER
	icon_state = "[icon_activated]"
	set_light(2)
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	H.visible_message("[H] activates [src]",
	"You activate [src]")

/obj/item/orbital_bombardment_beacon/proc/deactivate(mob/living/carbon/human/H)
	var/delay = max(1 SECONDS, activation_time * 0.5 - 2 SECONDS * H.skills.getRating("leadership")) //Half as long as setting it up.
	H.visible_message("<span class='notice'>[H] starts removing [src] from the ground.</span>",
	"<span class='notice'>You start removing [src] from the ground, deactivating it.</span>")
	if(!do_after(H, delay, TRUE, src, BUSY_ICON_GENERIC))
		return
	message_admins("[ADMIN_TPMONTY(usr)] removed an orbital strike beacon.")
	if(squad)
		squad.squad_orbital_beacons -= src
		squad = null
	GLOB.active_orbital_beacons -= src
	qdel(beacon_cam)
	beacon_cam = null
	activated = FALSE
	anchored = FALSE
	w_class = initial(w_class)
	layer = initial(layer)
	name = initial(name)
	icon_state = initial(icon_state)
	set_light(0)
	playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
	H.visible_message("[H] deactivates [src]",
	"You deactivate [src]")
	H.put_in_active_hand(src)
