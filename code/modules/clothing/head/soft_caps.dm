/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags_inventory = COVEREYES
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = 0
	siemens_coefficient = 0.9
	flags_armor_protection = 0

	dropped()
		src.icon_state = "[item_color]soft"
		src.flipped=0
		..()

	verb/flip()
		set category = "Object"
		set name = "Flip cap"
		set src in usr
		if(usr.canmove && !usr.stat && !usr.is_mob_restrained())
			src.flipped = !src.flipped
			if(src.flipped)
				icon_state = "[item_color]soft_flipped"
				usr << "You flip the hat backwards."
			else
				icon_state = "[item_color]soft"
				usr << "You flip the hat back in normal position."
			update_clothing_icon()	//so our mob-overlays update

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	item_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	item_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	item_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	item_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	item_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	item_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	item_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	item_color = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red color."
	icon_state = "secsoft"
	item_color = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	item_color = "corp"



//marine cap

/obj/item/clothing/head/soft/marine
	name = "marine sergeant cap"
	desc = "It's a soft cap made from advanced ballistic-resistant fibres. Fails to prevent lumps in the head."
	icon_state = "greysoft"
	item_color = "grey"
	armor = list(melee = 35, bullet = 35, laser = 35,energy = 15, bomb = 10, bio = 0, rad = 0)
	flags_inventory = BLOCKSHARPOBJ

/obj/item/clothing/head/soft/marine/alpha
	name = "alpha squad sergeant cap"
	icon_state = "redsoft"
	item_color = "red"

/obj/item/clothing/head/soft/marine/beta
	name = "beta squad sergeant cap"
	icon_state = "yellowsoft"
	item_color = "yellow"

/obj/item/clothing/head/soft/marine/charlie
	name = "charlie squad sergeant cap"
	icon_state = "purplesoft"
	item_color = "purple"

/obj/item/clothing/head/soft/marine/delta
	name = "delta squad sergeant cap"
	icon_state = "bluesoft"
	item_color = "blue"

/obj/item/clothing/head/soft/marine/mp
	name = "marine police sergeant cap"
	icon_state = "greensoft"
	item_color = "green"