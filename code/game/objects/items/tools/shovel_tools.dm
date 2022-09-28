/*****************************Shovels********************************/

/obj/item/tool/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "shovel"
	item_state = "shovel"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 8
	throwforce = 4
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	var/dirt_overlay = "shovel_overlay"
	var/folded = FALSE
	var/dirt_type = NO_DIRT // 0 for no dirt, 1 for brown dirt, 2 for snow, 3 for big red, 4 for basalt(lava-land).
	var/shovelspeed = 15
	var/dirt_amt = 0
	var/dirt_amt_per_dig = 5

/obj/item/tool/shovel/update_overlays()
	. = ..()
	if(!dirt_amt)
		return
	var/image/I = image(icon,src,dirt_overlay)
	switch(dirt_type) // We can actually shape the color for what enviroment we dig up our dirt in.
		if(DIRT_TYPE_GROUND)
			I.color = "#512A09"
		if(DIRT_TYPE_MARS)
			I.color = "#FF5500"
		if(DIRT_TYPE_SNOW)
			I.color = "#EBEBEB"
		if(DIRT_TYPE_LAVALAND)
			I.color = "#7A6D6A"
	. += I

/obj/item/tool/shovel/examine(mob/user)
	. = ..()
	if(dirt_amt)
		var/dirt_name = dirt_type == DIRT_TYPE_SNOW ? "snow" : "dirt"
		. += "It holds [dirt_amt] layer\s of [dirt_name]."

/obj/item/tool/shovel/attack_self(mob/user)

	if(dirt_amt)
		var/dirt_name = dirt_type == DIRT_TYPE_SNOW ? "snow" : "dirt"
		to_chat(user, span_notice("You dump the [dirt_name]!"))
		if(dirt_type == DIRT_TYPE_SNOW)
			var/turf/T = get_turf(user.loc)
			var/obj/item/stack/snow/S = locate() in T
			if(S && S.amount < S.max_amount)
				S.amount += dirt_amt
			else
				new /obj/item/stack/snow(T, dirt_amt)
		dirt_amt = 0

	update_icon()

/obj/item/tool/shovel/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(folded)
		return

	if(user.do_actions)
		return

	if(isturf(target))
		if(!dirt_amt)
			var/turf/T = target
			var/turfdirt = T.get_dirt_type()
			if(turfdirt)
				if(turfdirt == DIRT_TYPE_SNOW)
					var/turf/open/floor/plating/ground/snow/ST = T
					if(!ST.slayer)
						return
				to_chat(user, span_notice("You start digging."))
				playsound(user.loc, 'sound/effects/thud.ogg', 40, 1, 6)
				if(!do_after(user, shovelspeed, TRUE, T, BUSY_ICON_BUILD))
					return
				var/transf_amt = dirt_amt_per_dig
				if(turfdirt == DIRT_TYPE_SNOW)
					var/turf/open/floor/plating/ground/snow/ST = T
					if(!ST.slayer)
						return
					ST.slayer -= 1
					ST.update_icon(1,0)
					to_chat(user, span_notice("You dig up some snow."))
				else
					to_chat(user, span_notice("You dig up some dirt."))
				dirt_amt = transf_amt
				dirt_type = turfdirt
				update_icon()

		else
			var/turf/T = target
			to_chat(user, span_notice("you dump the [dirt_type == DIRT_TYPE_SNOW ? "snow" : "dirt"]!"))
			playsound(user.loc, "rustle", 30, 1, 6)
			if(dirt_type == DIRT_TYPE_SNOW)
				var/obj/item/stack/snow/S = locate() in T
				if(S && S.amount + dirt_amt < S.max_amount)
					S.amount += dirt_amt
				else
					new /obj/item/stack/snow(T, dirt_amt)
			dirt_amt = 0
			update_icon()

/obj/item/tool/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	dirt_overlay = "spade_overlay"
	shovelspeed = 40
	dirt_amt_per_dig = 1

//Snow Shovel----------
/obj/item/tool/shovel/snow
	name = "snow shovel"
	desc = "I had enough winter for this year!"
	w_class = WEIGHT_CLASS_BULKY
	force = 5
	throwforce = 3

// Entrenching tool.
/obj/item/tool/shovel/etool
	name = "entrenching tool"
	desc = "Used to dig holes and bash heads in. Folds in to fit in small spaces. Use a sharp item on it to sharpen it."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "etool_c"
	force = 2
	throwforce = 2
	item_state = "crowbar"
	hitsound = "swing_hit"
	w_class = WEIGHT_CLASS_SMALL //three for unfolded, 3 for folded. This should keep it outside backpacks until its folded, made it 3 because 2 lets you fit in pockets appearntly.
	folded = TRUE
	dirt_overlay = "etool_overlay"
	dirt_amt_per_dig = 5
	shovelspeed = 20

/obj/item/tool/shovel/etool/update_icon_state()
	if(!folded && !sharp)
		icon_state = "etool"
	else if(sharp)
		icon_state = "etool_s"
	else
		icon_state = "etool_c"
	..()

/obj/item/tool/shovel/etool/attack_self(mob/user as mob)
	if(sharp)
		to_chat(user, "It has been sharpened and cannot be folded")
		return
	folded = !folded
	if(!folded)
		w_class = WEIGHT_CLASS_BULKY
		force = 30
	else
		w_class = WEIGHT_CLASS_SMALL
		force = 2
	..()

/obj/item/tool/shovel/etool/attackby(obj/item/I, mob/user, params)
	if(!I.sharp && !folded)
		return ..()
	if(sharp)
		to_chat(user, span_notice("The entrenching tool is already sharpened."))
		return
	if(folded)
		to_chat(user, span_notice("You cannot sharpen the entrenching tool while it is folded."))
		return
	if(user.do_actions)
		to_chat(user, span_notice("You're busy doing something else right now!"))
		return
	user.visible_message(span_notice("[user] begins to sharpen the [src] with the [I]."),
	span_notice("You begin to sharpen the [src] with the [I]."))
	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return
	sharp = IS_SHARP_ITEM_SIMPLE
	name = "sharpened " + name
	shovelspeed = 10
	force = 60
	update_icon()

/obj/item/tool/shovel/etool/examine(mob/user)
	. = ..()
	if(sharp)
		. += span_notice("This one has been sharpened and can no longer be folded.")
