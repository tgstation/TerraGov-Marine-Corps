////////////////////////////////////////////////////////////////////////////////
/// (Mixing) Glass
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/glass
	name = " "
	var/base_name = " "
	desc = " "
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "null"
	item_state = "null"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,30,60)
	volume = 60
	init_reagent_flags = OPENCONTAINER

	var/label_text = ""


/obj/item/reagent_containers/glass/Initialize(mapload)
	. = ..()
	base_name = name


/obj/item/reagent_containers/glass/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 2 && user != loc)
		if(!is_open_container())
			. += span_info("An airtight lid seals it completely.")

/obj/item/reagent_containers/glass/verb/attach_lid()
	set name = "Attach/Detach lid"
	set category = "Object"
	if(is_open_container())
		to_chat(usr, span_notice("You put the lid on \the [src]."))
		DISABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)
		ENABLE_BITFIELD(reagents.reagent_flags, TRANSPARENT)
	else
		to_chat(usr, span_notice("You take the lid off \the [src]."))
		DISABLE_BITFIELD(reagents.reagent_flags, TRANSPARENT)
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)
	update_icon()

/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return

	user.changeNext_move(CLICK_CD_RAPID)

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!is_drainable())
			to_chat(user, span_warning("take [src]'s lid off first!"))
			return
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty!"))
			return
		if(target.reagents.holder_full())
			to_chat(user, span_warning("[target] is full."))
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, span_notice("You transfer [trans] unit\s of the solution to [target]."))

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!is_refillable())
			to_chat(user, span_warning("take [src]'s lid off first!"))
			return
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty and can't be refilled!"))
			return
		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))

	if(user.a_intent == INTENT_HARM)
		if(!is_open_container()) //Can't splash stuff from a sealed container. I dare you to try.
			to_chat(user, span_warning("An airtight seal prevents you from splashing the solution!"))
			return

		if(ismob(target) && target.reagents && reagents.total_volume)
			to_chat(user, span_notice("You splash the solution onto [target]."))
			playsound(target, 'sound/effects/slosh.ogg', 25, 1)

			var/mob/living/M = target
			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			log_combat(user, M, "splashed", src, "Reagents: [contained]")
			record_reagent_consumption(reagents.total_volume, injected, user, M)

			visible_message(span_warning("[target] has been splashed with something by [user]!"))
			reagents.reaction(target, TOUCH)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, clear_reagents)), 5)
			return


		else if(reagents.total_volume)
			to_chat(user, span_notice("You splash the solution onto [target]."))
			playsound(target, 'sound/effects/slosh.ogg', 25, 1)
			reagents.reaction(target, TOUCH)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, clear_reagents)), 5)
			return

/obj/item/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen) || istype(I, /obj/item/flashlight/pen))
		var/tmp_label = stripped_input(user, "Enter a label for [name]", "Label", label_text)
		if(length(tmp_label) > MAX_NAME_LEN)
			to_chat(user, span_warning("The label can be at most [MAX_NAME_LEN] characters long."))
			return

		user.visible_message(span_notice("[user] labels [src] as \"[tmp_label]\"."), \
							span_notice("You label [src] as \"[tmp_label]\"."))

		label_text = tmp_label
		update_name_label()

/obj/item/reagent_containers/glass/proc/update_name_label()
	if(label_text == "")
		name = base_name
	else
		name = "[base_name] ([label_text])"

/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. Can hold up to 60 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	attack_speed = 4

/obj/item/reagent_containers/glass/beaker/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/beaker/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_containers/glass/beaker/update_icon()
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

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 120 units."
	icon_state = "beakerlarge"
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,30,40,60,120)

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 60 units."
	icon_state = "beakernoreact"
	volume = 60
	init_reagent_flags = OPENCONTAINER|NO_REACT
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology. Can hold up to 300 units."
	icon_state = "beakerbluespace"
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,30,40,60,120,300)

/obj/item/reagent_containers/glass/beaker/vial
	name = "vial"
	desc = "A small glass vial. Can hold up to 30 units."
	icon_state = "vial"
	volume = 30
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25)

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list(/datum/reagent/medicine/cryoxadone = 30)


/obj/item/reagent_containers/glass/beaker/cryoxadone/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/reagent_containers/glass/beaker/cryomix
	list_reagents = list(/datum/reagent/medicine/cryoxadone = 10, /datum/reagent/medicine/clonexadone = 10, /datum/reagent/medicine/saline_glucose = 5, /datum/reagent/medicine/tricordrazine = 10, /datum/reagent/medicine/quickclot = 5, /datum/reagent/medicine/dexalinplus = 5, /datum/reagent/medicine/spaceacillin = 5, /datum/reagent/medicine/bihexajuline = 5)


/obj/item/reagent_containers/glass/beaker/cryomix/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/reagent_containers/glass/beaker/sulphuric
	list_reagents = list(/datum/reagent/toxin/acid = 60)


/obj/item/reagent_containers/glass/beaker/sulphuric/Initialize(mapload)
	. = ..()
	update_icon()


/obj/item/reagent_containers/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/janitor_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/janitor_right.dmi',
	)
	item_state = "bucket"
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60,120)
	volume = 120

/obj/item/reagent_containers/glass/bucket/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "[src] is out of water!</span>")
			return

		reagents.trans_to(I, 5)
		to_chat(user, span_notice("You wet [I] in [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/item/reagent_containers/glass/bucket/update_icon()
	overlays.Cut()

	if(!is_open_container())
		var/image/lid = image(icon, src, "lid_[initial(icon_state)]")
		overlays += lid

/obj/item/reagent_containers/glass/bucket/janibucket
	name = "janitorial bucket"
	desc = "It's a large bucket that fits in a janitorial cart."
	icon_state = "janibucket"

/obj/item/reagent_containers/glass/bucket/janibucket/on_reagent_change()
	update_icon()


/obj/item/reagent_containers/glass/bucket/janibucket/update_icon()
	..()
	if(reagents.total_volume)
		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)			icon_state = "janibucket"
			if(10 to 65) 		icon_state = "janibucket_half"
			if(66 to INFINITY)	icon_state = "janibucket_full"
	else
		icon_state = "janibucket"

