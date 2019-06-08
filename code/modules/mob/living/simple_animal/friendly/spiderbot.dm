/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	var/obj/item/radio/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/mmi/mmi = null
	var/list/req_access = list(ACCESS_MARINE_RESEARCH) //Access needed to pop out the brain.

	name = "Spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"

	wander = 0

	health = 10
	maxHealth = 10

	attacktext = "shocks"
	attacktext = "shocks"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.
	speed = -1                    //Spiderbots gotta go fast.
	//flags_pass = PASSTABLE      //Maybe griefy?
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("beeps","clicks","chirps")

/mob/living/simple_animal/spiderbot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mmi))
		var/obj/item/mmi/B = I
		if(mmi) //There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return

		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return

		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in GLOB.player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = TRUE
						break
			if(!ghost_can_reenter)
				to_chat(user, "<span class='notice'>[B] is completely unresponsive; there's no point.</span>")
				return

		if(B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[B] is dead. Sticking it into the frame would sort of defeat the purpose.</span>")
			return

		user.transferItemToLoc(I, src)
		to_chat(user, "<span class='notice'>You install [I] in [src]!</span>")
		mmi = I
		transfer_personality(I)
		update_icon()
		return TRUE

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0))
			to_chat(user, "Need more welding fuel!")
			return

		if(health >= maxHealth)
			to_chat(user, "<span class='notice'>[src] is undamaged!</span>")
			return

		health += pick(1,1,1,2,2,3)
		if(health > maxHealth)
			health = maxHealth

		visible_message("<span class='warning'> [user] has spot-welded some of the damage to [src]!</span>")

	else if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/id_card = I

		if(!mmi)
			to_chat(user, "<span class='warning'>There's no reason to swipe your ID - the spiderbot has no brain to remove.</span>")
			return

		if(!(ACCESS_MARINE_RESEARCH in id_card.access))
			to_chat(user, "<span class='warning'>You swipe your card, with no effect.</span>")
			return

		to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>")
		eject_brain()

		if(held_item)
			held_item.forceMove(loc)
			held_item = null

		return TRUE

	else if(istype(I, /obj/item/card/emag))
		var/obj/item/card/emag/emag = I

		if(emagged)
			to_chat(user, "<span class='warning'>[src] is already overloaded - better run.</span>")
			return

		emag.uses--
		emagged = TRUE
		to_chat(user, "<span class='notice'>You short out the security protocols and overload [src]'s cell, priming it to explode in a short time.</span>")
		spawn(100)	
			to_chat(src, "<span class='warning'>Your cell seems to be outputting a lot of power...</span>")
		spawn(200)	
			to_chat(src, "<span class='warning'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>")
		spawn(300)	
			explode()

	else
		return ..()

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		if(client) client.change_view(world.view)
		src.name = "Spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	for(var/mob/M in viewers(src, null))
		if ((M.client && !is_blind(M)))
			M.show_message("<span class='warning'> [src] makes an odd warbling noise, fizzles, and explodes.</span>")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	death()

/mob/living/simple_animal/spiderbot/update_icon()
	if(mmi)
		if(istype(mmi,/obj/item/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		src.name = "Spider-bot"
		update_icon()

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	. = ..()

/mob/living/simple_animal/spiderbot/Initialize()

	radio = new /obj/item/radio(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "Spiderbot-[real_name]"
	camera.network = list("SS13")

	return ..()

/mob/living/simple_animal/spiderbot/death()

	GLOB.alive_mob_list -= src
	GLOB.dead_mob_list += src

	if(camera)
		camera.status = 0

	held_item.loc = src.loc
	held_item = null

	robogibs(loc)
	qdel(src)

//Cannibalized from the parrot mob. ~Zuhayr
/mob/living/simple_animal/spiderbot/verb/drop_spider_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		to_chat(usr, "<span class='warning'>You have nothing to drop!</span>")
		return 0

	if(istype(held_item, /obj/item/explosive/grenade))
		visible_message("<span class='warning'> [src] launches \the [held_item]!</span>", "<span class='warning'> You launch \the [held_item]!</span>", "You hear a skittering noise and a thump!")
		var/obj/item/explosive/grenade/G = held_item
		G.forceMove(loc)
		G.prime()
		held_item = null
		return 1

	visible_message("<span class='notice'> [src] drops \the [held_item]!</span>", "<span class='notice'> You drop \the [held_item]!</span>", "You hear a skittering noise and a soft thump.")

	held_item.forceMove(loc)
	held_item = null
	return 1


/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding \the [held_item]</span>")
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= 2 && I.Adjacent(src) )
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("<span class='notice'> [src] scoops up \the [held_item]!</span>", "<span class='notice'> You grab \the [held_item]!</span>", "You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, "<span class='warning'>\The [selection] is too far away.</span>")
		return 0

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..()
	if(held_item)
		to_chat(user, "It is carrying \a [held_item] [icon2html(held_item, user)].")
