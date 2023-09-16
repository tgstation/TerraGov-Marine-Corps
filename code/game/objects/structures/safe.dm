/*
CONTAINS:
SAFES
FLOOR SAFES
*/

//SAFES

/obj/item/paper/safe_key
	name = "Secure Safe Combination"
	var/obj/structure/safe/safe = null

/obj/item/paper/safe_key/Initialize(mapload)
	. = ..()
	for(var/obj/structure/safe/safe in loc)
		if(safe)
			info = "This looks like a handwritten page with two numbers on it: \n\n<b>[safe.tumbler_1_open]|[safe.tumbler_2_open]</b>."
			info_links = info
			icon_state = "paper_words"
			break

/obj/structure/safe
	name = "safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "safe"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	resistance_flags = RESIST_ALL
	coverage = 25
	var/spawnkey = 1 //Spawn safe code on top of it?
	var/open = 0		//is the safe open?
	var/tumbler_1_pos	//the tumbler position- from 0 to 72
	var/tumbler_1_open	//the tumbler position to open at- 0 to 72
	var/tumbler_2_pos
	var/tumbler_2_open
	var/dial = 0		//where is the dial pointing?
	var/space = 0		//the combined w_class of everything in the safe
	var/maxspace = 24	//the maximum combined w_class of stuff in the safe

/obj/structure/safe/Initialize(mapload)
	. = ..()
	tumbler_1_pos = 0
	tumbler_1_open = (rand(0,10) * 5)

	tumbler_2_pos = 0
	tumbler_2_open = (rand(0,10) * 5)
	for(var/obj/item/I in loc)
		if(istype(I,/obj/item/paper/safe_key))
			continue
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.loc = src

	// do this after swallowing items for obvious reasons
	if(loc && spawnkey)
		new /obj/item/paper/safe_key(loc) //Spawn the key on top of the safe.


/obj/structure/safe/proc/check_unlocked(mob/user as mob, canhear)
	if(user && canhear)
		if(tumbler_1_pos == tumbler_1_open)
			to_chat(user, span_notice("You hear a [pick("tonk", "krunk", "plunk")] from [src]."))
		if(tumbler_2_pos == tumbler_2_open)
			to_chat(user, span_notice("You hear a [pick("tink", "krink", "plink")] from [src]."))
	if(tumbler_1_pos == tumbler_1_open && tumbler_2_pos == tumbler_2_open)
		if(user) visible_message("<b>[pick("Spring", "Sprang", "Sproing", "Clunk", "Click")]!</b>")
		return 1
	return 0


/obj/structure/safe/proc/decrement()
	tumbler_1_pos -= 5
	if(tumbler_1_pos < 0)
		tumbler_1_pos = 50

/obj/structure/safe/proc/increment()
	tumbler_1_pos += 5
	if(tumbler_1_pos > 50)
		tumbler_1_pos = 0


/obj/structure/safe/proc/decrement2()
	tumbler_2_pos -= 5
	if(tumbler_2_pos < 0)
		tumbler_2_pos = 50


/obj/structure/safe/proc/increment2()
	tumbler_2_pos += 5
	if(tumbler_2_pos > 50)
		tumbler_2_pos = 0


/obj/structure/safe/update_icon_state()
	if(open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)


/obj/structure/safe/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = "<center>"
	dat += "<a href='?src=[text_ref(src)];open=1'>[open ? "Close" : "Open"] [src]</a><br>"
	dat += "Dial 1: <a href='?src=[text_ref(src)];decrement=1'>-</a> [tumbler_1_pos] <a href='?src=[text_ref(src)];increment=1'>+</a><br>"
	dat += "Dial 2: <a href='?src=[text_ref(src)];decrement2=1'>-</a> [tumbler_2_pos] <a href='?src=[text_ref(src)];increment2=1'>+</a><br>"
	if(open)
		dat += "<table>"
		for(var/i = length(contents), i>=1, i--)
			var/obj/item/P = contents[i]
			dat += "<tr><td><a href='?src=[text_ref(src)];retrieve=[text_ref(P)]'>[P.name]</a></td></tr>"
		dat += "</table></center>"

	var/datum/browser/popup = new(user, "safe", "<div align='center'>[src]</div>", 350, 300)
	popup.set_content(dat)
	popup.open()


/obj/structure/safe/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))	return
	var/mob/living/carbon/human/user = usr

	var/canhear = 0
	if(istype(user.l_hand, /obj/item/clothing/tie/stethoscope) || istype(user.r_hand, /obj/item/clothing/tie/stethoscope))
		canhear = 1

	if(href_list["open"])
		if(check_unlocked())
			to_chat(user, span_notice("You [open ? "close" : "open"] [src]."))
			open = !open
			update_icon()
			updateUsrDialog()
			return
		else
			to_chat(user, span_notice("You can't [open ? "close" : "open"] [src], the lock is engaged!"))
			return

	if(href_list["decrement"])
		decrement()
		check_unlocked(user, canhear)
		updateUsrDialog()
		return
	if(href_list["increment"])
		increment()
		check_unlocked(user, canhear)
		updateUsrDialog()
		return
	if(href_list["decrement2"])
		decrement2()
		check_unlocked(user, canhear)
		updateUsrDialog()
		return
	if(href_list["increment2"])
		increment2()
		check_unlocked(user, canhear)
		updateUsrDialog()
		return

	if(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"]) in src
		if(open)
			if(P && in_range(src, user))
				user.put_in_hands(P)
				space -= P.w_class
				updateUsrDialog()


/obj/structure/safe/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!open)
		return

	else if(istype(I, /obj/item/clothing/tie/stethoscope))
		to_chat(user, "Hold [I] in one of your hands while you manipulate the dial.")

	else if(I.w_class + space <= maxspace)
		space += I.w_class
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("You put [I] in [src]."))
		updateUsrDialog()

	else
		to_chat(user, span_notice("[I] won't fit in [src]."))


//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = FALSE
	level = 1	//underfloor
	layer = UNDERFLOOR_OBJ_LAYER


/obj/structure/safe/floor/Initialize(mapload)
	. = ..()
	var/turf/T = loc
	hide(T.intact_tile)


/obj/structure/safe/floor/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0

/obj/structure/safe/floor/lvcolony
	name = "safe"
	spawnkey = FALSE
	pixel_x = 30
