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
	flags_atom = FPRINT|OPENCONTAINER

	var/label_text = ""

	var/list/can_be_placed_into = list(
		/obj/machinery/chem_master/,
		/obj/machinery/chem_dispenser/,
		/obj/machinery/reagentgrinder,
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/item/explosive/grenade/chem_grenade,
		/obj/machinery/bot/medbot,
		/obj/machinery/computer/pandemic,
		/obj/item/storage/secure/safe,
		/obj/machinery/iv_drip,
		/obj/machinery/disposal,
		/obj/machinery/apiary,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/hostile/retaliate/goat,
		/obj/machinery/sleeper,
		/obj/machinery/smartfridge/,
		/obj/machinery/biogenerator,
		/obj/machinery/constructable_frame)

	New()
		..()
		base_name = name

/obj/item/reagent_container/glass/examine(mob/user)
	..()
	if(get_dist(user, src) > 2 && user != loc) return
	if(reagents && reagents.reagent_list.len)
		user << "<span class='info'>It contains [reagents.total_volume] units of liquid.</span>"
	else
		user << "<span class='info'>It is empty.</span>"
	if(!is_open_container())
		user << "<span class='info'>An airtight lid seals it completely.</span>"

/obj/item/reagent_container/glass/attack_self()
	..()
	if(is_open_container())
		usr << "<span class='notice'>You put the lid on \the [src].</span>"
		flags_atom ^= OPENCONTAINER
	else
		usr << "<span class='notice'>You take the lid off \the [src].</span>"
		flags_atom |= OPENCONTAINER
	update_icon()

/obj/item/reagent_container/glass/afterattack(obj/target, mob/user , flag)

	if(!is_open_container() || !flag)
		return

	for(var/type in src.can_be_placed_into)
		if(istype(target, type))
			return

	if(ismob(target) && target.reagents && reagents.total_volume)
		user << "<span class='notice'>You splash the solution onto [target].</span>"
		playsound(target, 'sound/effects/slosh.ogg', 25, 1)

		var/mob/living/M = target
		var/list/injected = list()
		for(var/datum/reagent/R in src.reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been splashed with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to splash [M.name] ([M.key]). Reagents: [contained]</font>")
		msg_admin_attack("[user.name] ([user.ckey]) splashed [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		visible_message("<span class='warning'>[target] has been splashed with something by [user]!</span>")
		reagents.reaction(target, TOUCH)
		spawn(5) reagents.clear_reagents()
		return
	else if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
		target.add_fingerprint(user)

		if(!target.reagents.total_volume && target.reagents)
			user << "<span class='warning'>[target] is empty.</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='warning'>[src] is full.</span>"
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		user << "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>"

	else if(target.is_open_container() && target.reagents) //Something like a glass. Player probably wants to transfer TO it.

		if(!reagents.total_volume)
			user << "<span class='warning'>[src] is empty.</span>"
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='warning'>[target] is full.</span>"
			return

		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		user << "<span class='notice'>You transfer [trans] units of the solution to [target].</span>"

	else if(istype(target, /obj/machinery/smartfridge))
		return

	else if(reagents.total_volume)
		user << "<span class='notice'>You splash the solution onto [target].</span>"
		playsound(target, 'sound/effects/slosh.ogg', 25, 1)
		reagents.reaction(target, TOUCH)
		spawn(5) src.reagents.clear_reagents()
		return

/obj/item/reagent_container/glass/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [name]","Label", label_text))
		if(length(tmp_label) > MAX_NAME_LEN)
			user << "<span class='warning'>The label can be at most [MAX_NAME_LEN] characters long.</span>"
		else
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
	..()
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
	amount_per_transfer_from_this = 10
	flags_atom = FPRINT|OPENCONTAINER|NOREACT

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
	flags_atom = FPRINT|OPENCONTAINER

/obj/item/reagent_container/glass/beaker/cryoxadone
	New()
		..()
		reagents.add_reagent("cryoxadone", 30)
		update_icon()

/obj/item/reagent_container/glass/beaker/cryopredmix
	New()
		..()
		reagents.add_reagent("cryoxadone", 30)
		reagents.add_reagent("clonexadone", 30)
		update_icon()

/obj/item/reagent_container/glass/beaker/sulphuric
	New()
		..()
		reagents.add_reagent("sacid", 60)
		update_icon()

/obj/item/reagent_container/glass/bucket
	desc = "It's a bucket."
	name = "bucket"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	item_state = "bucket"
	matter = list("metal" = 200)
	w_class = 3.0
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10,20,30,60,120)
	volume = 120
	flags_atom = FPRINT|OPENCONTAINER

/obj/item/reagent_container/glass/bucket/attackby(obj/item/I, mob/user)
	if(isprox(I))
		user << "You add [I] to [src]."
		cdel(I)
		user.put_in_hands(new /obj/item/frame/bucket_sensor)
		user.drop_inv_item_on_ground(src)
		cdel(src)
	else if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume < 1)
			user << "[src] is out of water!</span>"
		else
			reagents.trans_to(I, 5)
			user << "<span class='notice'>You wet [I] in [src].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return
	else
		..()

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

