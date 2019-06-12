/obj/item/ashtray
	icon = 'icons/obj/items/ashtray.dmi'
	var/
		max_butts 	= 0
		empty_desc 	= ""
		icon_empty 	= ""
		icon_half  	= ""
		icon_full  	= ""
		icon_broken	= ""

/obj/item/ashtray/New()
	..()
	src.pixel_y = rand(-5, 5)
	src.pixel_x = rand(-6, 6)
	return

/obj/item/ashtray/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(obj_integrity < 1)
		return

	else if(istype(I, /obj/item/trash/cigbutt) || istype(I, /obj/item/clothing/mask/cigarette) || istype(I, /obj/item/tool/match))
		if(length(contents) >= max_butts)
			to_chat(user, "This ashtray is full.")
			return

		user.transferItemToLoc(I, src)

		if(istype(I, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cig = I
			if(!cig.heat)
				to_chat(user, "You place [cig] in [src] without even smoking it. Why would you do that?")
				return

			visible_message("[user] crushes [cig] in [src], putting it out.")
			STOP_PROCESSING(SSobj, cig)
			new cig.type_butt(src)
			qdel(cig)

		visible_message("[user] places [I] in [src].")
		user.update_inv_l_hand(0)
		user.update_inv_r_hand()

		if(length(contents) >= max_butts)
			icon_state = icon_full
			desc = empty_desc + " It's stuffed full."

		else if(length(contents) >= max_butts / 2)
			icon_state = icon_half
			desc = empty_desc + " It's half-filled."

	else
		obj_integrity = max(0, obj_integrity - I.force)
		to_chat(user, "You hit [src] with [I].")
		if(obj_integrity < 1)
			die()

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if (obj_integrity > 0)
		obj_integrity = max(0,obj_integrity - 3)
		if (obj_integrity < 1)
			die()
			return
		if (contents.len)
			src.visible_message("<span class='warning'> [src] slams into [hit_atom] spilling its contents!</span>")
		for (var/obj/item/clothing/mask/cigarette/O in contents)
			O.loc = src.loc
		icon_state = icon_empty
	return ..()

/obj/item/ashtray/proc/die()
	src.visible_message("<span class='warning'> [src] shatters spilling its contents!</span>")
	for (var/obj/item/clothing/mask/cigarette/O in contents)
		O.loc = src.loc
	icon_state = icon_broken

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_empty = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	icon_broken  = "ashtray_bork_bl"
	max_butts = 14
	max_integrity = 24.0
	matter = list("metal" = 30,"glass" = 30)
	empty_desc = "Cheap plastic ashtray."
	throwforce = 3.0
	die()
		..()
		name = "pieces of plastic"
		desc = "Pieces of plastic with ash on them."
		return


/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_empty = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	icon_broken  = "ashtray_bork_br"
	max_butts = 10
	max_integrity = 72.0
	matter = list("metal" = 80)
	empty_desc = "Massive bronze ashtray."
	throwforce = 10.0

	die()
		..()
		name = "pieces of bronze"
		desc = "Pieces of bronze with ash on them."
		return


/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_empty = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	icon_broken  = "ashtray_bork_gl"
	max_butts = 12
	max_integrity = 12.0
	matter = list("glass" = 60)
	empty_desc = "Glass ashtray. Looks fragile."
	throwforce = 6.0

	die()
		..()
		name = "shards of glass"
		desc = "Shards of glass with ash on them."
		playsound(src, "shatter", 25, 1)
		return
