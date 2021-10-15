/*****************************Coin********************************/

/obj/item/coin
	icon = 'icons/obj/items/items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags_atom = CONDUCT
	force = 0.0
	w_class = WEIGHT_CLASS_TINY
	var/string_attached
	var/sides = 2
	var/flags_token = TOKEN_GENERAL

/obj/item/coin/Initialize()
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/coin/gold
	name = "gold coin"
	icon_state = "coin_gold"

/obj/item/coin/silver
	name = "silver coin"
	icon_state = "coin_silver"

/obj/item/coin/diamond
	name = "diamond coin"
	icon_state = "coin_diamond"

/obj/item/coin/iron
	name = "iron coin"
	icon_state = "coin_iron"

/obj/item/coin/phoron
	name = "solid phoron coin"
	icon_state = "coin_phoron"

/obj/item/coin/uranium
	name = "uranium coin"
	icon_state = "coin_uranium"

/obj/item/coin/platinum
	name = "platinum coin"
	icon_state = "coin_adamantine"

/obj/item/coin/debugtoken
	name = "prototype universal token"
	desc = "A special nano-fiber chip, emblazed with several minuscule tags. Rarely ever seen outside emergency maintenance situations."
	icon_state = "coin_clown"
	flags_token = TOKEN_ALL

/obj/item/coin/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = I
		if(string_attached)
			to_chat(user, span_notice("There already is a string attached to this coin."))
			return

		if(!CC.use(1))
			to_chat(user, span_notice("This cable coil appears to be empty."))
			return

		overlays += image('icons/obj/items/items.dmi',"coin_string_overlay")
		string_attached = TRUE
		to_chat(user, span_notice("You attach a string to the coin."))

	else if(iswirecutter(I))
		if(!string_attached)
			return

		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = FALSE
		to_chat(user, span_notice("You detach the string from the coin."))


/obj/item/coin/attack_self(mob/user as mob)
	var/result = rand(1, sides)
	var/comment = ""
	if(result == 1)
		comment = "tails"
	else if(result == 2)
		comment = "heads"
	user.visible_message(span_notice("[user] has thrown \the [src]. It lands on [comment]! "), \
						span_notice("You throw \the [src]. It lands on [comment]! "))
