/obj/item/ashtray
	icon = 'icons/obj/items/ashtray.dmi'
	var/max_butts 	= 0
	var/empty_desc 	= ""
	var/icon_empty 	= ""
	var/icon_half  	= ""
	var/icon_full  	= ""


/obj/item/ashtray/Initialize()
	. = ..()
	pixel_y = rand(-5, 5)
	pixel_x = rand(-6, 6)

/obj/item/ashtray/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/trash/cigbutt) || istype(I, /obj/item/clothing/mask/cigarette) || istype(I, /obj/item/tool/match))
		if(length(contents) >= max_butts)
			to_chat(user, "This ashtray is full.")
			return

		user.transferItemToLoc(I, src)

		if(istype(I, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cig = I
			if(!cig.heat)
				to_chat(user, "You can't place [cig] in [src] without even smoking it. Why would you do that?")
				return

			visible_message("[user] crushes [cig] in [src], putting it out.")
			STOP_PROCESSING(SSobj, cig)
			new cig.type_butt(src)
			qdel(cig)

		visible_message("[user] places [I] in [src].")


/obj/item/ashtray/deconstruct(disassembled = TRUE)
	visible_message(span_warning("[src] shatters, spilling its contents!"))
	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(loc)
	return ..()


/obj/item/ashtray/update_icon()
	if(length(contents) >= max_butts)
		icon_state = icon_full
		desc = empty_desc + " It's stuffed full."
		return

	if(length(contents) >= max_butts / 2)
		icon_state = icon_half
		desc = empty_desc + " It's half-filled."
		return

	icon_state = icon_empty
	desc = empty_desc



/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_empty = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	max_butts = 14
	max_integrity = 24
	empty_desc = "Cheap plastic ashtray."
	throwforce = 3


/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_empty = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	max_butts = 10
	max_integrity = 72
	empty_desc = "Massive bronze ashtray."
	throwforce = 10


/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_empty = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	max_butts = 12
	max_integrity = 12
	materials = list(/datum/material/glass = 60)
	empty_desc = "Glass ashtray. Looks fragile."
	throwforce = 6
