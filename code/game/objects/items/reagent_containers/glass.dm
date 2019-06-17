////////////////////////////////////////////////////////////////////////////////
/// (Mixing) Glass
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_container/glass
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60)
	volume = 60
	init_reagent_flags = OPENCONTAINER

	var/label_text = ""


/obj/item/reagent_container/glass/Initialize()
	. = ..()
	base_name = name


/obj/item/reagent_container/glass/examine(mob/user)
	..()
	if(get_dist(user, src) > 2 && user != loc)
		if(!is_open_container())
			to_chat(user, "<span class='info'>An airtight lid seals it completely.</span>")

/obj/item/reagent_container/glass/verb/attach_lid()
	set name = "Attach/Detach lid"
	set category = "Object"
	if(is_open_container())
		to_chat(usr, "<span class='notice'>You put the lid on \the [src].</span>")
		DISABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)
		ENABLE_BITFIELD(reagents.reagent_flags, TRANSPARENT)
	else
		to_chat(usr, "<span class='notice'>You take the lid off \the [src].</span>")
		DISABLE_BITFIELD(reagents.reagent_flags, TRANSPARENT)
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)
	update_icon()

/obj/item/reagent_container/glass/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return

	user.changeNext_move(CLICK_CD_RAPID)

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!is_drainable())
			to_chat(user, "<span class='warning'>take [src]'s lid off first!</span>")
			return
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>")

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!is_refillable())
			to_chat(user, "<span class='warning'>take [src]'s lid off first!</span>")
			return
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty and can't be refilled!</span>")
			return
		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>")

	if(user.a_intent == INTENT_HARM)
		if(!is_open_container()) //Can't splash stuff from a sealed container. I dare you to try.
			to_chat(user, "<span class='warning'>An airtight seal prevents you from splashing the solution!</span>")
			return

		if(ismob(target) && target.reagents && reagents.total_volume)
			to_chat(user, "<span class='notice'>You splash the solution onto [target].</span>")
			playsound(target, 'sound/effects/slosh.ogg', 25, 1)

			var/mob/living/M = target
			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			log_combat(user, M, "splashed", src, "Reagents: [contained]")
			msg_admin_attack("[ADMIN_TPMONTY(usr)] splashed [ADMIN_TPMONTY(M)] with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]).")

			visible_message("<span class='warning'>[target] has been splashed with something by [user]!</span>")
			reagents.reaction(target, TOUCH)
			spawn(5) reagents.clear_reagents()
			return


		else if(reagents.total_volume)
			to_chat(user, "<span class='notice'>You splash the solution onto [target].</span>")
			playsound(target, 'sound/effects/slosh.ogg', 25, 1)
			reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return

/obj/item/reagent_container/glass/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen) || istype(I, /obj/item/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [name]", "Label", label_text))
		if(length(tmp_label) > MAX_NAME_LEN)
			to_chat(user, "<span class='warning'>The label can be at most [MAX_NAME_LEN] characters long.</span>")
			return

		user.visible_message("<span class='notice'>[user] labels [src] as \"[tmp_label]\".</span>", \
							 "<span class='notice'>You label [src] as \"[tmp_label]\".</span>")

		label_text = tmp_label
		update_name_label()

/obj/item/reagent_container/glass/proc/update_name_label()
	if(label_text == "")
		name = base_name
	else
		name = "[base_name] ([label_text])"

/obj/item/reagent_container/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 60 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	matter = list("glass" = 500)
	attack_speed = 4

/obj/item/reagent_container/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/reagent_container/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_container/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_container/glass/beaker/attack_hand()
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_container/glass/beaker/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)			filling.icon_state = "[icon_state]-10"
			if(10 to 24) 		filling.icon_state = "[icon_state]10"
			if(25 to 49)		filling.icon_state = "[icon_state]25"
			if(50 to 74)		filling.icon_state = "[icon_state]50"
			if(75 to 79)		filling.icon_state = "[icon_state]75"
			if(80 to 90)		filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/reagent_container/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 120 units."
	icon_state = "beakerlarge"
	matter = list("glass" = 5000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60,120)

/obj/item/reagent_container/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 60 units."
	icon_state = "beakernoreact"
	matter = list("glass" = 500)
	volume = 60
	init_reagent_flags = OPENCONTAINER|NO_REACT
	amount_per_transfer_from_this = 10

/obj/item/reagent_container/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology. Can hold up to 300 units."
	icon_state = "beakerbluespace"
	matter = list("glass" = 5000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,60,120,300)


/obj/item/reagent_container/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 30 units."
	icon_state = "vial"
	matter = list("glass" = 250)
	volume = 30
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)

/obj/item/reagent_container/glass/beaker/cryoxadone
	list_reagents = list("cryoxadone" = 30)


/obj/item/reagent_container/glass/beaker/cryoxadone/Initialize()
	. = ..()
	update_icon()


/obj/item/reagent_container/glass/beaker/cryomix
	list_reagents = list("cryoxadone" = 10, "clonexadone" = 10, "iron" = 10, "tricordrazine" = 10, "quickclot" = 5, "peridaxon" = 5, "dexalinplus" = 5, "spaceacillin" = 5)


/obj/item/reagent_container/glass/beaker/cryomix/Initialize()
	. = ..()
	update_icon()


/obj/item/reagent_container/glass/beaker/sulphuric
	list_reagents = list("sacid" = 60)


/obj/item/reagent_container/glass/beaker/sulphuric/Initialize()
	. = ..()
	update_icon()


/obj/item/reagent_container/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	matter = list("metal" = 200)
	w_class = 3
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60,120)
	volume = 120

/obj/item/reagent_container/glass/bucket/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isprox(I))
		to_chat(user, "You add [I] to [src].")
		qdel(I)
		user.put_in_hands(new /obj/item/frame/bucket_sensor)
		user.dropItemToGround(src)
		qdel(src)

	else if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "[src] is out of water!</span>")
			return

		reagents.trans_to(I, 5)
		to_chat(user, "<span class='notice'>You wet [I] in [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/item/reagent_container/glass/bucket/update_icon()
	overlays.Cut()

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/reagent_container/glass/bucket/janibucket
	name = "janitorial bucket"
	desc = "It's a large bucket that fits in a janitorial cart."
	icon_state = "janibucket"

/obj/item/reagent_container/glass/bucket/janibucket/on_reagent_change()
	update_icon()


/obj/item/reagent_container/glass/bucket/janibucket/update_icon()
	..()
	if(reagents.total_volume)
		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)			icon_state = "janibucket"
			if(10 to 65) 		icon_state = "janibucket_half"
			if(66 to INFINITY)	icon_state = "janibucket_full"
	else
		icon_state = "janibucket"

