///Marine steel rain style drop pods, very cool!
/obj/structure/droppod
	name = "TGMC "
	desc = "A menacing metal hunk of steel that is used by the TGMC for quick tactical redeployment."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	layer = OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	soft_armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	max_integrity = 50
	var/occupant
	var/max_occupants = 5
	var/target_turf
	var/entertime = 5
	var/image/userimg

/obj/structure/droppod/Initialize()
	. = ..()
	GLOB.droppod_list += src

/obj/structure/droppod/Destroy()
	. = ..()
	GLOB.droppod_list -= src

/obj/structure/droppod/attack_hand(mob/living/user)
	if(occcupant)
		to_chat(user, "full")
		return

	if(!do_after(user, entertime, TRUE, src))
		return

	if(occupant)
		to_chat(user, "full")
		return

	occupant = user
	user.forceMove(src)
	userimg = image(user)
	userimg.plane = ABOVE_HUMAN_PLANE//tofix
	userimg.layer = LADDER_LAYER//tofix
	userimg.pixel_y = 7
	overlays += userimg

/obj/structure/droppod/verb/launchpod()

