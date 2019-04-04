/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	flags_armor_protection = HEAD
	flags_equip_slot = ITEM_SLOT_HEAD
	w_class = 2.0
	var/anti_hug = 0

/obj/item/clothing/head/update_clothing_icon()
	if (ismob(loc))
		var/mob/M = loc
		M.update_inv_head()


/obj/item/clothing/head/tgmcbandana
	name = "\improper TGMC bandana"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandana serves as a lightweight and comfortable hat. Comes in two stylish colors."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "band"
	flags_inv_hide = HIDETOPHAIR

/obj/item/clothing/head/tgmcbandana/tan
	icon_state = "band2"


/obj/item/clothing/head/beanie
	name = "\improper TGMC beanie"
	desc = "A standard military beanie, often worn by non-combat military personnel and support crews, though the occasional one finds its way to the front line. Popular due to being comfortable and snug."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "beanie_cargo"
	flags_inv_hide = HIDETOPHAIR
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 15, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 15, "acid" = 15)


/obj/item/clothing/head/tgmcberet
	name = "\improper TGMC beret"
	desc = "A hat typically worn by the field-officers of the TGMC. Occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "beret"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)

/obj/item/clothing/head/tgmcberet/tan
	icon_state = "berettan"

/obj/item/clothing/head/tgmcberet/red
	icon_state = "beretred"

/obj/item/clothing/head/tgmcberet/wo
	name = "\improper Command Master at Arms beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. It shines with the glow of corrupt authority and a smudge of doughnut."
	icon_state = "beretwo"
	armor = list("melee" = 60, "bullet" = 80, "laser" = 80, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)

/obj/item/clothing/head/tgmcberet/fc
	name = "\improper Field Commander beret"
	desc = "A beret with the field commander insignia emblazoned on it. It commands loyalty and bravery in all who gaze upon it."
	icon_state = "beretfc"
	armor = list("melee" = 60, "bullet" = 80, "laser" = 80, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)


/obj/item/clothing/head/tgmccap
	name = "\improper TGMC cap"
	desc = "A casual cap occasionally worn by Squad-leaders and Combat-Engineers. While it has limited combat functionality, some prefer to wear it instead of the standard issue helmet."
	icon_state = "cap"
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)
	var/flipped_cap = FALSE
	var/base_cap_icon


/obj/item/clothing/head/tgmccap/verb/fliphat()
	set name = "Flip hat"
	set category = "Object"
	set src in usr
	if(!isliving(usr))
		return
	if(usr.incapacitated())
		return

	flipped_cap = !flipped_cap
	if(flipped_cap)
		to_chat(usr, "You spin the hat backwards! You look like a tool.")
		icon_state = base_cap_icon + "_b"
	else
		to_chat(usr, "You spin the hat back forwards. That's better.")
		icon_state = base_cap_icon

	update_clothing_icon()


/obj/item/clothing/head/tgmccap/ro
	name = "\improper TGMC officer cap"
	desc = "A hat usually worn by officers in the TGMC. While it has limited combat functionality, some prefer to wear it instead of the standard issue helmet."
	icon_state = "rocap"

/obj/item/clothing/head/tgmccap/req
	name = "\improper TGMC requisition cap"
	desc = "It's a fancy hat for a not-so-fancy military supply clerk."
	icon_state = "cargocap"


/obj/item/clothing/head/boonie
	name = "Boonie Hat"
	desc = "The pinnacle of tacticool technology."
	icon_state = "booniehat"
	item_state = "booniehat"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 35, "energy" = 15, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 15, "acid" = 15)


/obj/item/clothing/head/headband
	name = "\improper TGMC headband"
	desc = "A rag typically worn by the less-orthodox weapons operators in the TGMC. While it offers no protection, it is certainly comfortable to wear compared to the standard helmet. Comes in two stylish colors."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "headband"

/obj/item/clothing/head/headband/red
	icon_state = "headbandred"

/obj/item/clothing/head/headband/rambo
	name = "headband"
	desc = "It flutters in the face of the wind, defiant and unrestrained, like the man who wears it."
	icon_state = "headband_rambo"

/obj/item/clothing/head/headband/snake
	name = "headband"
	desc = "A replica of the headband of a legendary soldier. Sadly it doesn't offer infinite ammo. Yet."
	icon_state = "headband_snake"


/obj/item/clothing/head/headset
	name = "\improper TGMC headset"
	desc = "A headset typically found in use by radio-operators and officers. This one appears to be malfunctioning."
	icon_state = "headset"
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1

/obj/item/clothing/head/cmo
	name = "\improper Chief Medical hat"
	desc = "A somewhat fancy hat, typically worn by those who wish to command medical respect."
	icon_state = "cmohat"


//============================//BERETS\\=================================\\
//Berets have armor, so they have their own category. PMC caps are helmets, so they're in helmets.dm.

/obj/item/clothing/head/beret/marine
	name = "marine officer beret"
	desc = "A beret with the TGMC insignia emblazoned on it. It radiates respect and authority."
	icon_state = "hosberet"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)
	flags_inventory = BLOCKSHARPOBJ

/obj/item/clothing/head/beret/marine/captain
	name = "captain's beret"
	desc = "A beret with the captain insignia emblazoned on it. Wearer may suffer the heavy weight of responsibility upon his head and shoulders."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/beret/marine/chiefofficer
	name = "chief officer beret"
	desc = "A beret with the lieutenant-commander insignia emblazoned on it. It emits a dark aura and may corrupt the soul."
	icon_state = "hosberet"

/obj/item/clothing/head/beret/marine/chiefofficer/sa
	name = "spatial agent's beret"
	desc = "A beret with the Spatial Agent insignia on it."

/obj/item/clothing/head/beret/marine/techofficer
	name = "technical officer beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. There's something inexplicably efficient about it..."
	icon_state = "e_beret_badge"

/obj/item/clothing/head/beret/marine/logisticsofficer
	name = "logistics officer beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. It inspires a feeling of respect."
	icon_state = "hosberet"

//==========================//PROTECTIVE\\===============================\\
//=======================================================================\\

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 20, "energy" = 10, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR
	anti_hug = 1

	attack_self(mob/user as mob)
		if(src.icon_state == "ushankadown")
			src.icon_state = "ushankaup"
			src.item_state = "ushankaup"
			to_chat(user, "You raise the ear flaps on the ushanka.")
		else
			src.icon_state = "ushankadown"
			src.item_state = "ushankadown"
			to_chat(user, "You lower the ear flaps on the ushanka.")


/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	siemens_coefficient = 2.0
	anti_hug = 4
	flags_armor_protection = HEAD|CHEST|ARMS
	armor = list("melee" = 90, "bullet" = 70, "laser" = 45, "energy" = 55, "bomb" = 45, "bio" = 10, "rad" = 10, "fire" = 55, "acid" = 55)
	flags_cold_protection = HEAD|CHEST|ARMS
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR


/obj/item/clothing/head/uppcap
	name = "\improper armored UPP cap"
	desc = "Standard UPP head gear for covert operations and low-ranking officers alike. Sells for high prices on the black market due to their rarity."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	icon_state = "upp_cap"
	sprite_sheet_id = 1
	siemens_coefficient = 2.0
	//anti_hug = 2
	flags_armor_protection = HEAD
	armor = list("melee" = 50, "bullet" = 50, "laser" = 45, "energy" = 55, "bomb" = 45, "bio" = 10, "rad" = 10, "fire" = 55, "acid" = 55)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS

/obj/item/clothing/head/uppcap/beret
	name = "\improper armored UPP beret"
	icon_state = "upp_beret"

/obj/item/clothing/head/frelancer
	name = "\improper armored Freelancer cap"
	desc = "A sturdy freelancer's cap. More protective than it seems."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "freelancer_cap"
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD
	armor = list("melee" = 50, "bullet" = 50, "laser" = 45, "energy" = 55, "bomb" = 45, "bio" = 10, "rad" = 10, "fire" = 55, "acid" = 55)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS

/obj/item/clothing/head/frelancer/beret
	name = "\improper armored Freelancer beret"
	icon_state = "freelancer_beret"

/obj/item/clothing/head/militia
	name = "\improper armored militia cowl"
	desc = "A large hood in service with some militias, meant for obscurity on the frontier. Offers some head protection due to the study fibers utilized in production."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "rebel_hood"
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD|CHEST
	armor = list("melee" = 30, "bullet" = 30, "laser" = 45, "energy" = 35, "bomb" = 45, "bio" = 20, "rad" = 30, "fire" = 35, "acid" = 35)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/admiral
	name = "\improper armored Admiral cap"
	desc = "A sturdy admiral's cap. More protective than it seems. Please don't ditch this for a helmet like a punk."
	icon_state = "admiral_helmet"
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD
	armor = list("melee" = 60, "bullet" = 60, "laser" = 45, "energy" = 55, "bomb" = 55, "bio" = 10, "rad" = 10, "fire" = 55, "acid" = 55)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS

