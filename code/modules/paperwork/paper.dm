/*
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */

#ifdef TESTSERVER

/client/verb/textperp()
	set category = "PAPER"
	set name = "textper+"
	set desc = ""

	var/obj/item/I
	I = mob.get_active_held_item()
	if(I)
		if(istype(I,/obj/item/paper))
			var/obj/item/paper/P = I
			P.textper++
			P.read(mob)
		if(istype(I,/obj/item/book))
			var/obj/item/book/P = I
			P.textper++
			P.read(mob)

/client/verb/textperm()
	set category = "PAPER"
	set name = "textper-"
	set desc = ""

	var/obj/item/I
	I = mob.get_active_held_item()
	if(I)
		if(istype(I,/obj/item/paper))
			var/obj/item/paper/P = I
			P.textper--
			P.read(mob)
		if(istype(I,/obj/item/book))
			var/obj/item/book/P = I
			P.textper--
			P.read(mob)

#endif

/obj/item/paper
	name = "parchment"
	gender = NEUTER
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 30
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/foley/dropsound/paper_drop.ogg'
	pickup_sound =  'sound/blank.ogg'
	grind_results = list(/datum/reagent/cellulose = 3)


	var/extra_headers //For additional styling or other js features.

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields = 0	//Amount of user created fields
	var/list/stamped
	var/rigged = 0
	var/spam_flag = 0
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0
	dropshrink = 0.5
	var/textper = 100
	var/maxlen = 2000

	var/cached_mailer
	var/cached_mailedto

/obj/item/paper/get_real_price()
	if(info)
		return 0
	else
		return sellprice

/obj/item/paper/spark_act()
	fire_act()

/obj/item/paper/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.3,"sx" = 0,"sy" = -1,"nx" = 13,"ny" = -1,"wx" = 4,"wy" = 0,"ex" = 7,"ey" = -1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 2,"sflip" = 0,"wflip" = 0,"eflip" = 8)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison,contact_poison_volume)
			contact_poison = null
	..()

/obj/item/paper/update_icon()
	. = ..()
	update_icon_state()

/obj/item/paper/Initialize()
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	update_icon_state()
	updateinfolinks()

/obj/item/paper/update_icon_state()
	if(mailer)
		icon_state = "paper_prep"
		name = "letter"
		throw_range = 7
		return
	name = initial(name)
	throw_range = initial(throw_range)
	if(info)
		icon_state = "paperwrite"
		return
	icon_state = "paper"

/obj/item/paper/examine(mob/user)
	. = ..()
	if(!mailer)
		. += "<a href='?src=[REF(src)];read=1'>Read</a>"
	else
		. += "It's from [mailer], addressed to [mailedto].</a>"

/obj/item/paper/proc/read(mob/user)
//	var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/paper)
//	assets.send(user)
	user << browse_rsc('html/book.png')
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	if(mailer)
		return
	if(in_range(user, src) || isobserver(user))
//		var/obj/screen/read/R = user.hud_used.reads
		user.hud_used.reads.icon_state = "scrap"
		user.hud_used.reads.show()
		var/dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
					<html><head><style type=\"text/css\">
					body { background-image:url('book.png');background-repeat: repeat; }</style></head><body scroll=yes>"}
		dat += "[info]<br>"
		dat += "<a href='?src=[REF(src)];close=1' style='position:absolute;right:50px'>Close</a>"
		dat += "</body></html>"
		user << browse(dat, "window=reading;size=460x300;can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0")
		onclose(user, "reading", src)
	else
		return "<span class='warning'>I'm too far away to read it.</span>"

/*
	if(in_range(user, src) || isobserver(user))
		if(user.is_literate())
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE>[extra_headers]</HEAD><BODY>[info]<HR></BODY></HTML>", "window=paper[md5(name)]")
			onclose(user, "paper[md5(name)]")
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE>[extra_headers]</HEAD><BODY>[stars(info)]<HR></BODY></HTML>", "window=paper[md5(name)]")
			onclose(user, "paper[md5(name)]")
	else
		return "<span class='warning'>You're too far away to read it.</span>"
*/
/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set hidden = 1
	set src in usr

	if(usr.incapacitated() || !usr.is_literate())
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(25))
			to_chat(H, "<span class='warning'>I cut myself on the paper! Ahhhh! Ahhhhh!</span>")
			H.damageoverlaytemp = 9001
			H.update_damage_hud()
			return
	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)


/obj/item/paper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/obj/item/paper/proc/reset_spamflag()
	spam_flag = FALSE

/obj/item/paper/attack_self(mob/user)
	if(mailer)
		user.visible_message("<span class='notice'>[user] opens the letter from [mailer].</span>")
		cached_mailer = mailer
		cached_mailedto = mailedto
		mailer = null
		mailedto = null
		update_icon()
		return
	read(user)
	if(rigged && (SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/blank.ogg', 50, TRUE)
			addtimer(CALLBACK(src, .proc/reset_spamflag), 20)


/obj/item/paper/attack_ai(mob/living/silicon/ai/user)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")


/obj/item/paper/proc/addtofield(id, text, links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid < 15)	//hey whoever decided a while(1) was a good idea here, i hate you
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart == 0)
			return	//No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()


/obj/item/paper/proc/updateinfolinks()
	info_links = info
	for(var/i in 1 to min(fields, 15))
		addtofield(i, "<font face=\"[PEN_FONT]\"><A href='?src=[REF(src)];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[PEN_FONT]\"><A href='?src=[REF(src)];write=end'>write</A></font>"


/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	LAZYCLEARLIST(stamped)
	cut_overlays()
	updateinfolinks()
	update_icon_state()


/obj/item/paper/proc/parsepencode(t, obj/item/P, mob/user, iscrayon = 0)
	if(length(t) < 1)		//No input means nothing needs to be parsed
		return

	t = parsemarkdown(t, user, iscrayon)

	if(!iscrayon)
		if(istype(P, /obj/item/pen))
			var/obj/item/pen/J = P
			t = "<font face=\"[J.font]\" color=[J.colour]>[t]</font>"
		else if(istype(P, /obj/item/natural/thorn))
			t = "<font face=\"[FOUNTAIN_PEN_FONT]\" color=#862f20>[t]</font>"
		else if(istype(P, /obj/item/natural/feather))
			t = "<font face=\"[FOUNTAIN_PEN_FONT]\" color=#14103f>[t]</font>"

	else
		var/obj/item/toy/crayon/C = P
		t = "<font face=\"[CRAYON_FONT]\" color=[C.paint_color]><b>[t]</b></font>"

	// Count the fields
	var/laststart = 1
	while(fields < 15)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)
		if(i == 0)
			break
		laststart = i+1
		fields++

	return t

/obj/item/paper/proc/reload_fields() // Useful if you made the paper programicly and want to include fields. Also runs updateinfolinks() for you.
	fields = 0
	var/laststart = 1
	while(fields < 15)
		var/i = findtext(info, "<span class=\"paper_field\">", laststart)
		if(i == 0)
			break
		laststart = i+1
		fields++
	updateinfolinks()


/obj/item/paper/proc/openhelp(mob/user)
	user << browse({"<HTML><HEAD><TITLE>Paper Help</TITLE></HEAD>
	<BODY>
		You can use backslash (\\) to escape special characters.<br>
		<br>
		# text : Defines a header.<br>
		|text| : Centers the text.<br>
		**text** : Makes the text <b>bold</b>.<br>
		*text* : Makes the text <i>italic</i>.<br>
		^text^ : Increases the <font size = \"4\">size</font> of the text.<br>
		%s : Inserts a signature of your name in a foolproof way.<br>
		%f : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		((text)) : Decreases the <font size = \"1\">size</font> of the text.<br>
		* item : An unordered list item.<br>
		&nbsp;&nbsp;* item: An unordered list child item.<br>
		--- : Adds a horizontal rule.
	</BODY></HTML>"}, "window=paper_help")


/obj/item/paper/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["close"])
		var/mob/user = usr
		if(user?.client && user.hud_used)
			if(user.hud_used.reads)
				user.hud_used.reads.destroy_read()
			user << browse(null, "window=reading")

	var/literate = usr.is_literate()
	if(!usr.canUseTopic(src, BE_CLOSE, literate))
		return

	if(href_list["read"])
		read(usr)

	if(href_list["help"])
		openhelp(usr)
		return
	if(href_list["write"])
		var/id = href_list["write"]
		var/t =  stripped_multiline_input("Enter what you want to write:", "Write", no_trim=TRUE)
		if(!t || !usr.canUseTopic(src, BE_CLOSE, literate))
			return
		var/obj/item/i = usr.get_active_held_item()	//Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/pen))
			if(istype(i, /obj/item/toy/crayon))
				iscrayon = 1
			else
				if(!istype(i, /obj/item/natural/thorn))
					if(!istype(i, /obj/item/natural/feather))
						return

		if(!in_range(src, usr) && loc != usr && !istype(loc, /obj/item/clipboard) && loc.loc != usr && usr.get_active_held_item() != i)	//Some check to see if he's allowed to write
			return

		log_paper("[key_name(usr)] writing to paper [t]")
		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if(t != null)	//No input from the user means nothing needs to be added
			if(id!="end")
				addtofield(text2num(id), t) // He wants to edit a field, let him.
			else
				info += t // Oh, he wants to edit to the end of the file, let him.
				testing("[length(info)]")
				testing("[findtext(info, "\n")]")
				updateinfolinks()
			playsound(src, 'sound/items/write.ogg', 100, FALSE)
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links]<HR>[stamps]</BODY><div align='right'style='position:fixed;bottom:0;font-style:bold;'><A href='?src=[REF(src)];help=1'>\[?\]</A></div></HTML>", "window=[name]") // Update the window
			update_icon_state()

/obj/item/paper/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(resistance_flags & ON_FIRE)
		return ..()

	if(mailer)
		return ..()

	if(is_blind(user))
		return ..()

	if(istype(P, /obj/item/pen) || istype(P, /obj/item/natural/thorn)|| istype(P, /obj/item/natural/feather))
		if(length(info) > maxlen)
			to_chat(user, "<span class='warning'>[src] is full of verba.</span>")
			return
		if(user.can_read(src))
			var/t = stripped_multiline_input("Write Something", "Paper", no_trim=TRUE)
			if(t)
				if((length(info) + length(t)) > maxlen)
					to_chat(user, "<span class='warning'>Too long. Try again.</span>")
					return
				info += t
			update_icon_state()
			return
		else
			to_chat(user, "<span class='warning'>I can't write.</span>")
			return


	if(!P.can_be_package_wrapped())
		return ..()

	to_chat(user, "<span class='info'>I start to wrap [P] in [src]...</span>")
	if(do_after(user, 30, 0, target = src))
		if(user.is_holding(P))
			if(!user.dropItemToGround(P))
				return
		else if(!isturf(P.loc))
			return
		var/obj/item/smallDelivery/D = new /obj/item/smallDelivery(get_turf(P.loc))
		if(user.Adjacent(D))
			D.add_fingerprint(user)
			P.add_fingerprint(user)
			user.put_in_hands(D)
		P.forceMove(D)
		var/size = round(P.w_class)
		D.name = "[weightclass2text(size)] package"
		D.w_class = size
		size = min(size, 5)
		D.icon_state = "deliverypackage[size]"

/*	else if(istype(P, /obj/item/stamp))

		if(!in_range(src, user))
			return

		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		if (isnull(stamps))
			stamps = sheet.css_tag()
		stamps += sheet.icon_tag(P.icon_state)
		var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[P.icon_state]")
		stampoverlay.pixel_x = rand(-2, 2)
		stampoverlay.pixel_y = rand(-3, 2)

		LAZYADD(stamped, P.icon_state)
		add_overlay(stampoverlay)

		to_chat(user, "<span class='notice'>I stamp the paper with your rubber stamp.</span>")

	if(P.get_temperature())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='danger'>I miss the paper and accidentally light myself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.dropItemToGround(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>I light [src] on fire!</span>")
		fire_act()*/

	add_fingerprint(user)
	return ..()

/obj/item/paper/fire_act(added, maxstacks)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		add_overlay("paper_onfire_overlay")
		info = "[stars(info)]"


/obj/item/paper/extinguish()
	..()
	cut_overlay("paper_onfire_overlay")

/*
 * Construction paper
 */

/obj/item/paper/construction

/obj/item/paper/construction/Initialize()
	. = ..()
	color = pick("FF0000", "#33cc33", "#ffb366", "#551A8B", "#ff80d5", "#4d94ff")

/*
 * Natural paper
 */

/obj/item/paper/natural/Initialize()
	. = ..()
	color = "#FFF5ED"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"
	slot_flags = null

/obj/item/paper/crumpled/update_icon_state()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/muddy
	icon_state = "scrap_mud"
