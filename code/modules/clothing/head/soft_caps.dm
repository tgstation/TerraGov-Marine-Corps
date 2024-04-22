/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = ""
	icon_state = "cargosoft"
	item_state = "helmet"
	var/soft_type = "cargo"

	dog_fashion = /datum/dog_fashion/head/cargo_tech

	var/flipped = 0

/obj/item/clothing/head/soft/dropped()
	icon_state = "[soft_type]soft"
	flipped=0
	..()

/obj/item/clothing/head/soft/verb/flipcap()
	set hidden = 1
	set name = "Flip cap"
	if(!usr.client.holder)
		return
	flip(usr)


/obj/item/clothing/head/soft/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		flip(user)


/obj/item/clothing/head/soft/proc/flip(mob/user)
	if(!user.incapacitated())
		flipped = !flipped
		if(src.flipped)
			icon_state = "[soft_type]soft_flipped"
			to_chat(user, "<span class='notice'>I flip the hat backwards.</span>")
		else
			icon_state = "[soft_type]soft"
			to_chat(user, "<span class='notice'>I flip the hat back in normal position.</span>")
		usr.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click the cap to flip it [flipped ? "forwards" : "backwards"].</span>"

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = ""
	icon_state = "redsoft"
	soft_type = "red"
	dog_fashion = null

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = ""
	icon_state = "bluesoft"
	soft_type = "blue"
	dog_fashion = null

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = ""
	icon_state = "greensoft"
	soft_type = "green"
	dog_fashion = null

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = ""
	icon_state = "yellowsoft"
	soft_type = "yellow"
	dog_fashion = null

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = ""
	icon_state = "greysoft"
	soft_type = "grey"
	dog_fashion = null

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = ""
	icon_state = "orangesoft"
	soft_type = "orange"
	dog_fashion = null

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = ""
	icon_state = "mimesoft"
	soft_type = "mime"
	dog_fashion = null

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = ""
	icon_state = "purplesoft"
	soft_type = "purple"
	dog_fashion = null

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = ""
	icon_state = "blacksoft"
	soft_type = "black"
	dog_fashion = null

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = ""
	icon_state = "rainbowsoft"
	soft_type = "rainbow"
	dog_fashion = null

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = ""
	icon_state = "secsoft"
	soft_type = "sec"
	armor = list("melee" = 30, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/soft/emt
	name = "EMT cap"
	desc = ""
	icon_state = "emtsoft"
	soft_type = "emt"
	dog_fashion = null
