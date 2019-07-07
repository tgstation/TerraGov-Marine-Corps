//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 3
	max_storage_space = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(ACCESS_MARINE_CAPTAIN)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/card/id))
			if(src.broken)
				to_chat(user, "<span class='warning'>It appears to be broken.</span>")
				return
			if(src.allowed(user))
				src.locked = !( src.locked )
				if(src.locked)
					src.icon_state = src.icon_locked
					to_chat(user, "<span class='warning'>You lock the [src.name]!</span>")
					return
				else
					src.icon_state = src.icon_closed
					to_chat(user, "<span class='warning'>You unlock the [src.name]!</span>")
					return
			else
				to_chat(user, "<span class='warning'>Access Denied</span>")
		else if(istype(W, /obj/item/card/emag) && !broken)
			broken = 1
			locked = 0
			desc = "It appears to be broken."
			icon_state = src.icon_broken
			for(var/mob/O in viewers(user, 3))
				O.show_message("<span class='notice'> The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)

		if(!locked)
			..()
		else
			to_chat(user, "<span class='warning'>Its locked!</span>")
		return


	show_to(mob/user as mob)
		if(locked)
			to_chat(user, "<span class='warning'>Its locked!</span>")
		else
			..()
		return


/obj/item/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_MARINE_BRIG)

	New()
		..()
		new /obj/item/explosive/grenade/flashbang/clusterbang(src)
