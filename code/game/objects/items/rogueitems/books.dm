/obj/item/book/rogue
	var/open = FALSE
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "temp"
	slot_flags = ITEM_SLOT_HIP
	var/base_icon_state
	unique = TRUE
	firefuel = 2 MINUTES
	dropshrink = 0.6
	drop_sound = 'sound/foley/dropsound/book_drop.ogg'

/obj/item/book/rogue/getonmobprop(tag)
	. = ..()
	if(tag)
		if(open)
			switch(tag)
				if("gen")
					return list("shrink" = 0.4,
	"sx" = -2,
	"sy" = -3,
	"nx" = 10,
	"ny" = -2,
	"wx" = 1,
	"wy" = -3,
	"ex" = 5,
	"ey" = -3,
	"northabove" = 0,
	"southabove" = 1,
	"eastabove" = 1,
	"westabove" = 0,
	"nturn" = 0,
	"sturn" = 0,
	"wturn" = 0,
	"eturn" = 0,
	"nflip" = 0,
	"sflip" = 0,
	"wflip" = 0,
	"eflip" = 0)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
		else
			switch(tag)
				if("gen")
					return list("shrink" = 0.4,
	"sx" = -2,
	"sy" = -3,
	"nx" = 10,
	"ny" = -2,
	"wx" = 1,
	"wy" = -3,
	"ex" = 5,
	"ey" = -3,
	"northabove" = 0,
	"southabove" = 1,
	"eastabove" = 1,
	"westabove" = 0,
	"nturn" = 0,
	"sturn" = 0,
	"wturn" = 0,
	"eturn" = 0,
	"nflip" = 0,
	"sflip" = 0,
	"wflip" = 0,
	"eflip" = 0)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)


/obj/item/book/rogue/attack_self(mob/user)
	if(!open)
		attack_right(user)
		return
	..()
	user.update_inv_hands()

/obj/item/book/rogue/rmb_self(mob/user)
	attack_right(user)
	return

/obj/item/book/rogue/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me first.</span>")
		return FALSE
	. = ..()

/obj/item/book/rogue/attackby(obj/item/I, mob/user, params)
	return

/obj/item/book/rogue/attack_right(mob/user)
	if(!open)
		slot_flags &= ~ITEM_SLOT_HIP
		open = TRUE
		playsound(loc, 'sound/items/book_open.ogg', 100, FALSE, -1)
	else
		slot_flags |= ITEM_SLOT_HIP
		open = FALSE
		playsound(loc, 'sound/items/book_close.ogg', 100, FALSE, -1)
	curpage = 1
	update_icon()
	user.update_inv_hands()

/obj/item/book/rogue/update_icon()
	icon_state = "[base_icon_state][open]"

/obj/item/book/rogue/secret/ledger
	name = "catatoma"
	icon_state = "ledger0"
	base_icon_state = "ledger"
	title = "Catatoma"
	dat = "To create a shipping order, use a papyrus on me."

/obj/item/book/rogue/ledger/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/paper/scroll/cargo))
		if(!open)
			to_chat(user, "<span class='info'>Open me first.</span>")
			return FALSE
		var/obj/item/paper/scroll/cargo/C = I
		if(C.orders.len > 4)
			to_chat(user, "<span class='warning'>Too much order.</span>")
			return
		var/picked_cat = input(user, "Categories", "Shipping Ledger") as null|anything in sortList(SSshuttle.supply_cats)
		if(!picked_cat)
			testing("yeye")
			return
		var/list/pax = list()
		for(var/pack in SSshuttle.supply_packs)
			var/datum/supply_pack/PA = SSshuttle.supply_packs[pack]
			if(PA.group == picked_cat)
				pax += PA
		var/picked_pack = input(user, "Shipments", "Shipping Ledger") as null|anything in sortList(pax)
		if(!picked_pack)
			return
		var/namer = user.name
		var/rankr = "None"
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			namer = H.get_authentification_name()
			rankr = H.get_assignment(hand_first = TRUE)
		var/datum/supply_order/SO = new (picked_pack, namer, rankr, user.ckey, "None", SSeconomy.get_dep_account(ACCOUNT_CAR))
		C.orders += SO
		C.rebuild_info()
		return
	if(istype(I, /obj/item/paper/scroll))
		if(!open)
			to_chat(user, "<span class='info'>Open me first.</span>")
			return FALSE
		var/obj/item/paper/scroll/P = I
		if(P.info)
			to_chat(user, "<span class='warning'>Something is written here already.</span>")
			return
		var/picked_cat = input(user, "Categories", "Shipping Ledger") as null|anything in sortList(SSshuttle.supply_cats)
		if(!picked_cat)
			return
		var/list/pax = list()
		for(var/pack in SSshuttle.supply_packs)
			var/datum/supply_pack/PA = SSshuttle.supply_packs[pack]
			if(PA.group == picked_cat)
				pax += PA
		var/picked_pack = input(user, "Shipments", "Shipping Ledger") as null|anything in sortList(pax)
		if(!picked_pack)
			return
		var/obj/item/paper/scroll/cargo/C = new(user.loc)
		var/namer = user.name
		var/rankr = "None"
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			namer = H.get_authentification_name()
			rankr = H.get_assignment(hand_first = TRUE)
		var/datum/supply_order/SO = new (picked_pack, namer, rankr, user.ckey, "None", SSeconomy.get_dep_account(ACCOUNT_CAR))
		C.orders += SO
		C.rebuild_info()
		user.dropItemToGround(P)
		qdel(P)
		user.put_in_active_hand(C)
	..()

/obj/item/book/rogue/bibble
	name = "The Book"
	icon_state = "bibble0"
	base_icon_state = "bibble"
	title = "bible"
	dat = "Gott"

/obj/item/book/rogue/bibble/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me first.</span>")
		return FALSE
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	if(in_range(user, src) || isobserver(user))
		user.changeNext_move(CLICK_CD_MELEE)
		var/m
		var/list/verses = world.file2list("strings/bibble.txt")
		m = pick(verses)
		if(m)
			user.say(m)

/obj/item/book/rogue/bibble/attack(mob/living/M, mob/user)
	if(user.mind && user.mind.assigned_role == "Priest")
		if(!user.can_read(src))
			to_chat(user, "<span class='warning'>I don't understand these scribbly black lines.</span>")
			return
		M.apply_status_effect(/datum/status_effect/buff/blessed)
		M.add_stress(/datum/stressevent/blessed)
		user.visible_message("<span class='notice'>[user] blesses [M].</span>")
		playsound(user, 'sound/magic/bless.ogg', 100, FALSE)
		return

/datum/status_effect/buff/blessed
	id = "blessed"
	alert_type = /obj/screen/alert/status_effect/buff/blessed
	effectedstats = list("fortune" = 1)
	duration = 20 MINUTES

/obj/screen/alert/status_effect/buff/blessed
	name = "Blessed"
	desc = ""
	icon_state = "buff"


/obj/item/book/rogue/law
	name = "Tome of Justice"
	desc = ""
	icon_state ="lawtome0"
	base_icon_state = "lawtome"
	bookfile = "law.json"

		//no more theif stole the books
/obj/item/book/rogue/knowledge1
	name = "Book of Knowledge"
	desc = ""
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "knowledge.json"

/obj/item/book/rogue/secret/xylix
	name = "Book of Gold"
	desc = "{<font color='red'><blink>An ominous book with untold powers.</blink></font>}"
	icon_state ="xylix0"
	base_icon_state = "xylix"
	bookfile = "xylix.json"

	/obj/item/book/rogue/xylix/attack_self(mob/user)
		if(!open)
			attack_right(user)
			return
		..()
		user.update_inv_hands()
		to_chat(user, "<span class='notice'>You feel laughter echo in your head.</span>")
//player made books
/obj/item/book/rogue/tales1
	name = "Assorted Tales From Yester Yils"
	desc = "By Alamere J Wevensworth"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales1.json"

/obj/item/book/rogue/festus
	name = "Book of Festus"
	desc = "Unknown Author"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales2.json"


/obj/item/book/rogue/tales3
	name = "Myths & Legends of Rockhill & Beyond Volume I"
	desc = "Arbalius The Younger"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales3.json"

/obj/item/book/rogue/bookofpriests
	name = "Holy book of saphria"
	desc = ""
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "holyguide.json"

/obj/item/book/rogue/robber
	name = "Reading for Robbers"
	desc = "By Flavius of Dendor"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales4.json"

/obj/item/book/rogue/cardgame
	name = "Graystone's Torment Basic Rules"
	desc = "By Johnus of Doe"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales5.json"

/obj/item/book/rogue/blackmountain
	name = "Zabrekalrek, The Black Mountain Saga: Part One"
	desc = "Written by Gorrek Tale-Writer, translated by Hargrid Men-Speaker."
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales6.json"

/obj/item/book/rogue/beardling
	name = "Rock and Stone - ABC & Tales for Beardlings"
	desc = "Distributed by the Dwarven Federation"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales7.json"

/obj/item/book/rogue/abyssor
	name = "A Tale of Those Who Live At Sea"
	desc = "By Bellum Aegir"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales8.json"

/obj/item/book/rogue/necra
	name = "Burial Rites for Necra"
	desc = "By Hunlaf, Gravedigger. Revised by Lenore, Priest of Necra."
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales9.json"

/obj/item/book/rogue/noc
	name = "Dreamseeker"
	desc = "By Hunlaf, Gravedigger. Revised by Lenore, Priest of Necra."
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales10.json"

/obj/item/book/rogue/fishing
	name = "Fontaine's Advanced Guide to Fishery"
	desc = "By Ford Fontaine"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales11.json"

/obj/item/book/rogue/sword
	name = "The Six Follies: How To Survive by the Sword"
	desc = "By Theodore Spillguts"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales12.json"

/obj/item/book/rogue/arcyne
	name = "Latent Magicks, where does Arcyne Power come from?"
	desc = "By Kildren Birchwood, scholar of Magicks"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales13.json"

/obj/item/book/rogue/nitebeast
	name = "Legend of the Nitebeast"
	desc = "By Paquetto the Scholar"
	icon_state ="knowledge0"
	base_icon_state = "knowledge"
	bookfile = "tales14.json"
