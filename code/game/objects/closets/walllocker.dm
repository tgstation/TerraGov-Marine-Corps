//added by cael from old bs12
//not sure if there's an immediate place for secure wall lockers, but i'm sure the players will think of something

/obj/structure/closet/walllocker
	desc = "A wall mounted storage locker."
	name = "Wall Locker"
	icon = 'icons/obj/structures/walllocker.dmi'
	icon_state = "wall-locker"
	density = 0
	anchored = 1
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"
	wall_mounted = 1

//spawns endless (3 sets) amounts of breathmask, emergency oxy tank and crowbar

/obj/structure/closet/walllocker/emerglocker
	name = "emergency locker"
	desc = "A wall mounted locker with emergency supplies."
	var/list/spawnitems = list(/obj/item/tank/emergency_oxygen/double,/obj/item/clothing/mask/gas)
	var/amount = 6 // spawns each items X times.
	icon_state = "emerg"

/obj/structure/closet/walllocker/emerglocker/toggle(mob/user as mob)
	src.attack_hand(user)
	return

/obj/structure/closet/walllocker/emerglocker/attackby(obj/item/W as obj, mob/user as mob)
	return

/obj/structure/closet/walllocker/emerglocker/attack_hand(mob/user as mob)
	if (istype(user, /mob/living/silicon/ai))	//Added by Strumpetplaya - AI shouldn't be able to
		return									//activate emergency lockers.  This fixes that.  (Does this make sense, the AI can't call attack_hand, can it? --Mloc)
	if(!amount)
		to_chat(usr, "<spawn class='notice'>It's empty..")
		return
	if(amount)
		to_chat(usr, "<spawn class='notice'>You take out some items from \the [src].")
		for(var/path in spawnitems)
			new path(src.loc)
		amount--
	return

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST
