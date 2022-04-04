/datum/playingcard
	var/name = "playing card"
	var/card_icon = "card_back"

/obj/item/toy/deck
	name = "deck of cards"
	desc = "A simple deck of playing cards."
	icon = 'icons/obj/items/playing_cards.dmi'
	icon_state = "deck"
	w_class = WEIGHT_CLASS_TINY

	var/card_type = "normal"
	var/list/cards = list()

/obj/item/toy/deck/Initialize()
	. = ..()
	populate_deck()

/obj/item/toy/deck/proc/populate_deck()
	var/datum/playingcard/P
	for(var/suit in list("spades","clubs","diamonds","hearts"))

		for(var/number in list("ace","two","three","four","five","six","seven","eight","nine","ten","jack","queen","king"))
			P = new()
			P.name = "[number] of [suit]"
			P.card_icon = "[suit]_[number]"
			cards += P

/obj/item/toy/deck/examine(mob/user)
	. = ..()
	. += span_notice("Right-click the pack to draw a card. Click-drag to someone to deal them a card. Right click a card to discard it, and place it face up. You can also use the cards in your hand to conceal or reveal them")

/obj/item/toy/deck/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/toy/handcard))
		var/obj/item/toy/handcard/H = I
		for(var/datum/playingcard/P in H.cards)
			cards += P
		update_icon()
		qdel(I)
		to_chat(user, "You place your cards on the bottom of the deck.")

/obj/item/toy/deck/update_icon_state()
	switch(cards.len)
		if(52)
			icon_state = "deck"
		if(1 to 51)
			icon_state = "deck_half"
		if(0)
			icon_state = "deck_empty"

/obj/item/toy/deck/verb/draw_card()

	set category = "Object"
	set name = "Draw"
	set desc = "Draw a card from a deck."
	set src in view(1)

	draw(usr)

/obj/item/toy/deck/attack_hand_alternate(mob/living/user)
	draw(user)

/// Takes a card from the deck, and (if possible) puts it in the user's hand
/obj/item/toy/deck/proc/draw(mob/user)
	if(user.stat || !Adjacent(user)) return

	if(!ishuman(user))
		return

	if(!cards.len)
		to_chat(usr, "There are no cards in the deck.")
		return

	var/obj/item/toy/handcard/H
	if(user.l_hand && istype(user.l_hand,/obj/item/toy/handcard))
		H = user.l_hand
	else if(user.r_hand && istype(user.r_hand,/obj/item/toy/handcard))
		H = user.r_hand
	else
		H = new(get_turf(src), card_type)
		user.put_in_hands(H)

	if(!H || !user) return

	var/datum/playingcard/P = cards[1]
	H.cards += P
	cards -= P
	H.update_icon()
	update_icon()
	user.visible_message("\The [user] draws a card.")
	to_chat(user, "It's the [P].")

/obj/item/toy/deck/verb/deal_card()

	set category = "Object"
	set name = "Deal"
	set desc = "Deal a card from a deck."
	set src in view(1)

	if(usr.stat || !Adjacent(usr)) return

	if(!cards.len)
		to_chat(usr, "There are no cards in the deck.")
		return

	var/list/players = list()
	for(var/mob/living/player in viewers(3))
		if(!player.stat)
			players += player
	//players -= usr

	var/mob/living/M = tgui_input_list(usr, "Who do you wish to deal a card?", null, players)
	if(!usr || gc_destroyed || !Adjacent(usr) || !M || M.gc_destroyed) return

	if(!cards.len)
		return

	for(var/mob/living/L in viewers(3))
		if(L == M)
			deal_at(usr, M)
			break

/obj/item/toy/deck/proc/deal_at(mob/user, mob/target)
	var/obj/item/toy/handcard/H = new(get_step(user, user.dir), card_type)

	H.cards += cards[1]
	cards -= cards[1]
	H.concealed = 1
	H.update_icon()
	update_icon()
	if(user==target)
		user.visible_message("\The [user] deals a card to [user.p_them()]self.")
	else
		user.visible_message("\The [user] deals a card to \the [target].")
	H.throw_at(get_step(target,target.dir),10,1,H)

/obj/item/toy/deck/attack_self(mob/user as mob)

	var/list/newcards = list()
	while(cards.len)
		var/datum/playingcard/P = pick(cards)
		newcards += P
		cards -= P
	cards = newcards
	user.visible_message("\The [user] shuffles [src].")

/obj/item/toy/deck/MouseDrop(atom/over)
	if(!usr || !over) return
	if(!Adjacent(usr) || !over.Adjacent(usr)) return // should stop you from dragging through windows

	if(!ishuman(over) || !(over in viewers(3))) return

	if(!cards.len)
		to_chat(usr, "There are no cards in the deck.")
		return

	deal_at(usr, over)


/obj/item/toy/handcard
	name = "hand of cards"
	desc = "Some playing cards."
	icon_state = "empty"
	w_class = WEIGHT_CLASS_TINY

	var/concealed = 0
	var/list/cards = list()

/obj/item/toy/handcard/Initialize(mapload, card_type)
	. = ..()
	switch(card_type)
		if("normal")
			icon = 'icons/obj/items/playing_cards.dmi'
		if("kotahi")
			icon = 'icons/obj/items/kotahi_cards.dmi'

/obj/item/toy/handcard/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/toy/handcard))
		var/obj/item/toy/handcard/H = I
		for(var/datum/playingcard/P in H.cards)
			cards += P
		concealed = H.concealed
		qdel(I)
		if(loc != user)
			user.put_in_hands(src)
		update_icon()

/// Takes a selected card, and puts it down, face-up, in front
/obj/item/toy/handcard/verb/discard()

	set category = "Object"
	set name = "Discard"
	set desc = "Place a card from your hand in front of you."

	discard_card(usr)

/obj/item/toy/handcard/attack_hand_alternate(mob/living/user)
	discard_card(user)

/// Takes a selected card, and puts it down, face-up, in front
/obj/item/toy/handcard/proc/discard_card(mob/user)
	var/list/to_discard = list()
	for(var/datum/playingcard/P in cards)
		to_discard[P.name] = P
	var/discarding = tgui_input_list(user, "Which card do you wish to put down?", null, to_discard)

	if(!discarding || !user || gc_destroyed || loc != user)
		return

	var/datum/playingcard/card = to_discard[discarding]
	if(card.gc_destroyed)
		return
	var/found = FALSE
	for(var/datum/playingcard/P in cards)
		if(P == card)
			found = TRUE
			break
	if(!found)
		return
	qdel(to_discard)

	var/obj/item/toy/handcard/H = new(src.loc)
	H.icon = icon
	H.cards += card
	cards -= card
	H.concealed = 0
	H.update_icon()
	update_icon()
	user.visible_message("\The [user] plays \the [discarding].")
	H.loc = get_step(user, user.dir)

	if(!cards.len)
		qdel(src)

/obj/item/toy/handcard/attack_self(mob/user as mob)
	concealed = !concealed
	update_icon()
	user.visible_message("\The [user] [concealed ? "conceals" : "reveals"] their hand.")

/obj/item/toy/handcard/examine(mob/user)
	. = ..()
	if(cards.len)
		. += span_notice("It has [cards.len] cards.")
		if((!concealed || loc == user))
			. += span_notice("The cards are: ")
			for(var/datum/playingcard/P in cards)
				. += "-[P.name]"

/obj/item/toy/handcard/update_icon(direction = 0)
	if(cards.len > 1)
		name = "hand of cards"
		desc = "Some playing cards."
	else
		name = "a playing card"
		desc = "A playing card."

	overlays.Cut()

	if(!cards.len)
		return

	if(cards.len == 1)
		var/datum/playingcard/P = cards[1]
		var/image/I = new(src.icon, (concealed ? "card_back" : "[P.card_icon]") )
		I.pixel_x += (-5+rand(10))
		I.pixel_y += (-5+rand(10))
		overlays += I
		return

	var/offset = FLOOR(20/cards.len, 1)

	var/matrix/M = matrix()
	if(direction)
		switch(direction)
			if(NORTH)
				M.Translate( 0,  0)
			if(SOUTH)
				M.Translate( 0,  4)
			if(WEST)
				M.Turn(90)
				M.Translate( 3,  0)
			if(EAST)
				M.Turn(90)
				M.Translate(-2,  0)
	var/i = 0
	for(var/datum/playingcard/P in cards)
		var/image/I = new(src.icon, (concealed ? "card_back" : "[P.card_icon]") )
		//I.pixel_x = origin+(offset*i)
		switch(direction)
			if(SOUTH)
				I.pixel_x = 8-(offset*i)
			if(WEST)
				I.pixel_y = -6+(offset*i)
			if(EAST)
				I.pixel_y = 8-(offset*i)
			else
				I.pixel_x = -7+(offset*i)
		I.transform = M
		overlays += I
		i++

/obj/item/toy/handcard/dropped(mob/user as mob)
	..()
	if(locate(/obj/structure/table, loc))
		src.update_icon(user.dir)
	else
		update_icon()

/obj/item/toy/handcard/pickup(mob/user as mob)
	src.update_icon()


/obj/item/toy/deck/kotahi
	name = "KOTAHI deck"
	desc = "A flashy deck of Nanotrasen KOTAHI playing cards. Usually sold alongside crayon packages."
	icon = 'icons/obj/items/kotahi_cards.dmi'
	icon_state = "deck"
	card_type = "kotahi"

/obj/item/toy/deck/kotahi/populate_deck()
	var/datum/playingcard/P
	var/datum/playingcard/I

	for(var/colour in list("Red","Yellow","Green","Blue"))
		P = new()
		P.name = "[colour] 0" //kotahi decks have only one colour of each 0, weird huh?
		P.card_icon = "[colour] 0"
		cards += P
		for(var/k in 0 to 1) //two of each colour of number
			I = new()
			I.name = "[colour] skip"
			I.card_icon = "[colour] skip"
			cards += I
		for(var/k in 0 to 1)
			I = new()
			I.name = "[colour] reverse"
			I.card_icon = "[colour] reverse"
			cards += I
		for(var/k in 0 to 1)
			I = new()
			I.name = "[colour] draw 2"
			I.card_icon = "[colour] draw 2"
			cards += I
		for(var/i in 1 to 9)
			I = new()
			I.name = "[colour] [i]"
			I.card_icon = "[colour] [i]"
			cards += I

	for(var/k in 0 to 3) //4 wilds and draw 4s
		P = new()
		P.name = "Wildcard"
		P.card_icon = "Wildcard"
		cards += P
	for(var/k in 0 to 3)
		P.name= "Draw 4"
		P.card_icon = "Draw 4"
		cards += P

/obj/item/toy/deck/kotahi/update_icon_state()
	switch(cards.len)
		if(72 to 108) icon_state = "deck"
		if(37 to 72) icon_state = "deck_half"
		if(0 to 36) icon_state = "deck_empty"
