/obj/machinery/washing_machine
	name = "Washing Machine"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = TRUE
	anchored = TRUE
	var/state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/panel = 0
	//0 = closed
	//1 = open
	var/hacked = 1 //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon

/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr)) //ew ew ew usr, but it's the only way to check.
		return

	if( state != 4 )
		to_chat(usr, "The washing machine cannot run in this state.")
		return

	if( locate(/mob,contents) )
		state = 8
	else
		state = 5
	update_icon()
	sleep(200)
	for(var/atom/A in contents)
		A.clean_blood()

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		var/obj/item/stack/sheet/wetleather/WL = new(src)
		WL.amount = HH.amount
		qdel(HH)


	if( locate(/mob,contents) )
		state = 7
		gibs_ready = 1
	else
		state = 4
	update_icon()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(state in list(1,3,6) )
		usr.loc = src.loc


/obj/machinery/washing_machine/update_icon()
	icon_state = "wm_[state][panel]"


/obj/machinery/washing_machine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/toy/crayon) || istype(I, /obj/item/tool/stamp))
		if(!(state in list(1, 3, 6)))
			return

		if(crayon)
			return

		if(!user.transferItemToLoc(I, src))
			return

		crayon = I

	else if(istype(I, /obj/item/stack/sheet/hairlesshide) || \
		istype(I, /obj/item/clothing/under) || \
		istype(I, /obj/item/clothing/mask) || \
		istype(I, /obj/item/clothing/head) || \
		istype(I, /obj/item/clothing/gloves) || \
		istype(I, /obj/item/clothing/shoes) || \
		istype(I, /obj/item/clothing/suit) || \
		istype(I, /obj/item/bedsheet))

		//YES, it's hardcoded... saves a var/can_be_washed for every single clothing item. | lol. someone with more willpower use a typecache
		if(istype(I, /obj/item/clothing/suit/space))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/suit/syndicatefake))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/suit/cyborg_suit))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/suit/bomb_suit))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/suit/armor))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/suit/armor))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/mask/gas))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/mask/cigarette))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/head/syndicatefake))
			to_chat(user, "This item does not fit.")
			return
		if(istype(I, /obj/item/clothing/head/helmet))
			to_chat(user, "This item does not fit.")
			return

		if(length(contents) >= 5)
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
			return

		if(!(state in list(1, 3)))
			to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return
			
		state = 3

		update_icon()

/obj/machinery/washing_machine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	switch(state)
		if(1)
			state = 2
		if(2)
			state = 1
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(3)
			state = 4
		if(4)
			state = 3
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1
		if(5)
			to_chat(user, "<span class='warning'>The [src] is busy.</span>")
		if(6)
			state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1


	update_icon()
