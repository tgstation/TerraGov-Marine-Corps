

/obj/item/clothing/shoes/marine
	name = "marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "marine"
	item_state = "marine"
	flags_armor_protection = FEET
	armor = list("melee" = 15, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 25)
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	var/obj/item/knife

/obj/item/clothing/shoes/marine/Destroy()
	if(knife)
		QDEL_NULL(knife)
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/shoes/marine/attack_hand(mob/living/user)
	if(knife && src.loc == user && !user.incapacitated()) //Only allow someone to take out the knife if it's being worn or held. So you can pick them up off the floor
		if(user.put_in_active_hand(knife))
			to_chat(user, "<span class='notice'>You slide [knife] out of [src].</span>")
			playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 15, 1)
			knife = 0
			update_icon()
	else
		return ..()

/obj/item/clothing/shoes/marine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/weapon/combat_knife) || istype(I, /obj/item/weapon/throwing_knife))
		if(knife)
			return
		user.drop_held_item()
		knife = I
		I.forceMove(src)
		to_chat(user, "<div class='notice'>You slide the [I] into [src].</div>")
		playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 15, 1)
		update_icon()


/obj/item/clothing/shoes/marine/update_icon()
	if(knife)
		icon_state = "[initial(icon_state)]-knife"
	else
		icon_state = initial(icon_state)


/obj/item/clothing/shoes/marine/pyro
	name = "flame-resistant combat boots"
	desc = "Protects you from fire and even contains a pouch for your knife!"
	icon_state = "marine_armored"


/obj/item/clothing/shoes/marinechief
	name = "chief officer shoes"
	desc = "Only a small amount of monkeys, kittens, and orphans were killed in making this."
	icon_state = "laceups"
	armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)
	flags_inventory = NOSLIPPING
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/marinechief/captain
	name = "captain's shoes"
	desc = "Has special soles for better trampling those underneath."

/obj/item/clothing/shoes/marinechief/sa
	name = "spatial agent's shoes"
	desc = "Shoes worn by a spatial agent."

/obj/item/clothing/shoes/veteran

/obj/item/clothing/shoes/veteran/PMC
	name = "polished shoes"
	desc = "The height of fashion, but these look to be woven with protective fiber."
	icon_state = "jackboots"
	item_state = "jackboots"
	flags_armor_protection = FEET
	armor = list("melee" = 15, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 15)
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	flags_inventory = NOSLIPPING
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/veteran/PMC/commando
	name = "\improper PMC commando boots"
	desc = "A pair of heavily armored, acid-resistant boots."
	icon_state = "commando_boots"
	permeability_coefficient = 0.01
	flags_armor_protection = FEET
	armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	siemens_coefficient = 0.2
	resistance_flags = UNACIDABLE

//=========//Imperium\\=========\\

/obj/item/clothing/shoes/marine/imperial
	name = "guardsmen combat boots"
	desc = "A pair of boots issued to the Imperial Guard, just like anything else they use, they are mass produced."
	//icon_state = ""
	armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)

/obj/item/clothing/shoes/marine/imperial/Initialize()
	. = ..()
	knife = new /obj/item/weapon/combat_knife
	update_icon()



/obj/item/clothing/shoes/marine/som
	name = "\improper S11 combat shoes"
	desc = "Shoes with origins dating back to the old mining colonies."
	icon_state = "som"
	item_state = "som"
	armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 25)
