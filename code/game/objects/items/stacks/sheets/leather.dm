/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	icon_state = "sheet-hide"


/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"


/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"


/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"


/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"


/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"


//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"


/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"


/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"


/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of it's hair, but still needs tanning."
	singular_name = "hairless hide piece"
	icon_state = "sheet-hairlesshide"


/obj/item/stack/sheet/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon_state = "sheet-wetleather"
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon_state = "sheet-leather"


//Step one - dehairing.
/obj/item/stack/sheet/animalhide/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.sharp)
		user.visible_message(span_notice(" \the [user] starts cutting hair off \the [src]"), span_notice(" You start cutting the hair off \the [src]"), "You hear the sound of a knife rubbing against flesh")
		if(!do_after(user,50, NONE, src, BUSY_ICON_HOSTILE))
			return

		to_chat(user, span_notice("You cut the hair from this [singular_name]"))
		for(var/obj/item/stack/sheet/hairlesshide/HS in user.loc)
			if(HS.amount < 50)
				HS.amount++
				use(1)
				break
		var/obj/item/stack/sheet/hairlesshide/HS = new(user.loc)
		HS.amount = 1
		use(1)

//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/sheet/wetleather/fire_act(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/sheet/leather/HS in src.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					wetness = initial(wetness)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/sheet/leather/HS = new(src.loc)
			HS.amount = 1
			wetness = initial(wetness)
			src.use(1)
