



/*****************************Shovels********************************/

/obj/item/tool/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "shovel"
	item_state = "shovel"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 8
	throwforce = 4
	w_class = 3
	matter = list("metal" = 50)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	var/dirt_overlay = "shovel_overlay"
	var/folded = FALSE
	var/dirt_type = NO_DIRT // 0 for no dirt, 1 for brown dirt, 2 for snow, 3 for big red.
	var/shovelspeed = 15
	var/dirt_amt = 0
	var/dirt_amt_per_dig = 3


/obj/item/tool/shovel/update_icon()
	var/image/reusable/I = rnew(/image/reusable, list(icon,src,dirt_overlay))
	switch(dirt_type) // We can actually shape the color for what enviroment we dig up our dirt in.
		if(DIRT_TYPE_GROUND) I.color = "#512A09"
		if(DIRT_TYPE_MARS) I.color = "#FF5500"
		if(DIRT_TYPE_SNOW) I.color = "#EBEBEB"
	overlays -= I
	if(dirt_amt)
		overlays += I
	else
		cdel(I)



/obj/item/tool/shovel/examine(mob/user)
	..()
	if(dirt_amt)
		var/dirt_name = dirt_type == DIRT_TYPE_SNOW ? "snow" : "dirt"
		user << "It holds [dirt_amt] layer\s of [dirt_name]."

/obj/item/tool/shovel/attack_self(mob/user)
	add_fingerprint(user)

	if(dirt_amt)
		user << "<span class='notice'>You dump the dirt!</span>"
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
	if(!proximity) return
	if(folded) return

	if(user.action_busy)
		return


	if(isturf(target))
		if(!dirt_amt)
			var/turf/T = target
			var/turfdirt = T.get_dirt_type()
			if(turfdirt)
				if(turfdirt == DIRT_TYPE_SNOW)
					var/turf/open/snow/ST = T
					if(!ST.slayer)
						return
				user << "<span class='notice'>You start digging.</span>"
				playsound(user.loc, 'sound/effects/thud.ogg', 40, 1, 6)
				if(!do_after(user, shovelspeed, TRUE, 5, BUSY_ICON_BUILD))
					return
				var/transf_amt = dirt_amt_per_dig
				if(turfdirt == DIRT_TYPE_SNOW)
					var/turf/open/snow/ST = T
					if(!ST.slayer)
						return
					transf_amt = min(ST.slayer, dirt_amt_per_dig)
					ST.slayer -= transf_amt
					ST.update_icon(1,0)
					user << "<span class='notice'>You dig up some snow.</span>"
				else
					user << "<span class='notice'>You dig up some dirt.</span>"
				dirt_amt = transf_amt
				dirt_type = turfdirt
				update_icon()

		else
			var/turf/T = target
			user << "<span class='notice'>you dump the [dirt_type == DIRT_TYPE_SNOW ? "snow" : "dirt"]!</span>"
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
	w_class = 2
	dirt_overlay = "spade_overlay"
	shovelspeed = 40
	dirt_amt_per_dig = 1


//Snow Shovel----------
/obj/item/tool/shovel/snow
	name = "snow shovel"
	desc = "I had enough winter for this year!"
	w_class = 4
	force = 5
	throwforce = 3




// Entrenching tool.
/obj/item/tool/shovel/etool
	name = "entrenching tool"
	desc = "Used to dig holes and bash heads in. Folds in to fit in small spaces."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "etool"
	force = 30
	throwforce = 2
	item_state = "crowbar"
	w_class = 4 //three for unfolded, 3 for folded. This should keep it outside backpacks until its folded, made it 3 because 2 lets you fit in pockets appearntly.
	origin_tech = "engineering=1"
	dirt_overlay = "etool_overlay"
	dirt_amt_per_dig = 2
	shovelspeed = 25


/obj/item/tool/shovel/etool/update_icon()
	if(folded) icon_state = "etool_c"
	else icon_state = "etool"
	..()


/obj/item/tool/shovel/etool/attack_self(mob/user as mob)
	folded = !folded
	if(folded)
		w_class = 3
		force = 2
	else
		w_class = 4
		force = 30
	..()





