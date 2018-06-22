/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	flags_armor_protection = HEAD
	flags_equip_slot = SLOT_HEAD
	flags_pass = PASSTABLE
	w_class = 2.0
	var/anti_hug = 0

/obj/item/clothing/head/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_head()



/obj/item/clothing/head/cmbandana
	name = "\improper USCM bandana"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandana serves as a lightweight and comfortable hat. Comes in two stylish colors."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "band"
	flags_inv_hide = HIDETOPHAIR

/obj/item/clothing/head/cmbandana/New()
	select_gamemode_skin(type, list(MAP_ICE_COLONY = "s_band") )
	..()

/obj/item/clothing/head/cmbandana/tan
	icon_state = "band2"


/obj/item/clothing/head/beanie
	name = "\improper USCM beanie"
	desc = "A standard military beanie, often worn by non-combat military personnel and support crews, though the occasional one finds its way to the front line. Popular due to being comfortable and snug."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "beanie_cargo"
	flags_inv_hide = HIDETOPHAIR


/obj/item/clothing/head/cmberet
	name = "\improper USCM beret"
	desc = "A hat typically worn by the field-officers of the USCM. Occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "beret"

/obj/item/clothing/head/cmberet/New()
	select_gamemode_skin(/obj/item/clothing/head/cmberet, list(MAP_ICE_COLONY = "s_beret"))
	..()

/obj/item/clothing/head/cmberet/tan
	icon_state = "berettan"

/obj/item/clothing/head/cmberet/tan/New()
	select_gamemode_skin(/obj/item/clothing/head/cmberet/tan)
	..()

/obj/item/clothing/head/cmberet/red
	icon_state = "beretred"

/obj/item/clothing/head/cmberet/wo
	name = "\improper USCM chief MP beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. It shines with the glow of corrupt authority and a smudge of doughnut."
	icon_state = "beretwo"

/obj/item/clothing/head/headband
	name = "\improper USCM headband"
	desc = "A rag typically worn by the less-orthodox weapons operators in the USCM. While it offers no protection, it is certainly comfortable to wear compared to the standard helmet. Comes in two stylish colors."
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	icon_state = "headband"

/obj/item/clothing/head/headband/New()
	select_gamemode_skin(type, list(MAP_ICE_COLONY = "ushanka") )
	..()
	switch(icon_state)
		if("ushanka") //Weird case, since the item basically transforms into another item.
			name = "\improper USCM ushanka"
			desc = "Worn during cold operations by idiots."
			flags_cold_protection = HEAD
			min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
			flags_inventory = BLOCKSHARPOBJ
			flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/headband/red
	icon_state = "headbandred"

/obj/item/clothing/head/headband/rambo
	name = "headband"
	desc = "It flutters in the face of the wind, defiant and unrestrained, like the man who wears it."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "headband_rambo"
	sprite_sheet_id = 0

/obj/item/clothing/head/headset
	name = "\improper USCM headset"
	desc = "A headset typically found in use by radio-operators and officers. This one appears to be malfunctioning."
	icon_state = "headset"
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1

/obj/item/clothing/head/cmcap
	name = "\improper USCM cap"
	desc = "A casual cap occasionally worn by Squad-leaders and Combat-Engineers. While it has limited combat functionality, some prefer to wear it instead of the standard issue helmet."
	icon_state = "cap"
	icon = 'icons/obj/clothing/cm_hats.dmi'
	sprite_sheet_id = 1
	var/flipped_cap = FALSE
	var/base_cap_icon

/obj/item/clothing/head/cmcap/New()
	select_gamemode_skin(/obj/item/clothing/head/cmcap)
	base_cap_icon = icon_state
	..()

/obj/item/clothing/head/cmcap/verb/fliphat()
	set name = "Flip hat"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.is_mob_incapacitated()) return

	flipped_cap = !flipped_cap
	if(flipped_cap)
		usr << "You spin the hat backwards! You look like a tool."
		icon_state = base_cap_icon + "_b"
	else
		usr << "You spin the hat back forwards. That's better."
		icon_state = base_cap_icon

	update_clothing_icon()

/obj/item/clothing/head/cmcap/ro
	name = "\improper USCM officer cap"
	desc = "A hat usually worn by officers in the USCM. While it has limited combat functionality, some prefer to wear it instead of the standard issue helmet."
	icon_state = "rocap"

/obj/item/clothing/head/cmcap/ro/New()
	select_gamemode_skin(/obj/item/clothing/head/cmcap/ro)
	..()


/obj/item/clothing/head/cmcap/req
	name = "\improper USCM requisition cap"
	desc = "It's a fancy hat for a not-so-fancy military supply clerk."
	icon_state = "cargocap"

/obj/item/clothing/head/cmo
	name = "\improper Chief Medical hat"
	desc = "A somewhat fancy hat, typically worn by those who wish to command medical respect."
	icon_state = "cmohat"


//============================//BERETS\\=================================\\
//=======================================================================\\
//Berets have armor, so they have their own category. PMC caps are helmets, so they're in helmets.dm.
/obj/item/clothing/head/beret/marine
	name = "marine officer beret"
	desc = "A beret with the ensign insignia emblazoned on it. It radiates respect and authority."
	icon_state = "beret_badge"
	armor = list(melee = 40, bullet = 40, laser = 40,energy = 20, bomb = 10, bio = 0, rad = 0)
	flags_inventory = BLOCKSHARPOBJ

/obj/item/clothing/head/beret/marine/commander
	name = "marine commander beret"
	desc = "A beret with the commander insignia emblazoned on it. Wearer may suffer the heavy weight of responsibility upon his head and shoulders."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/beret/marine/chiefofficer
	name = "chief officer beret"
	desc = "A beret with the lieutenant-commander insignia emblazoned on it. It emits a dark aura and may corrupt the soul."
	icon_state = "hosberet"

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
	armor = list(melee = 35, bullet = 35, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR
	anti_hug = 1

	attack_self(mob/user as mob)
		if(src.icon_state == "ushankadown")
			src.icon_state = "ushankaup"
			src.item_state = "ushankaup"
			user << "You raise the ear flaps on the ushanka."
		else
			src.icon_state = "ushankadown"
			src.item_state = "ushankadown"
			user << "You lower the ear flaps on the ushanka."


/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	siemens_coefficient = 2.0
	anti_hug = 4
	flags_armor_protection = HEAD|UPPER_TORSO|ARMS
	armor = list(melee = 90, bullet = 70, laser = 45, energy = 55, bomb = 45, bio = 10, rad = 10)
	flags_cold_protection = HEAD|UPPER_TORSO|ARMS
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
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
	armor = list(melee = 50, bullet = 50, laser = 45, energy = 55, bomb = 45, bio = 10, rad = 10)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
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
	armor = list(melee = 50, bullet = 50, laser = 45, energy = 55, bomb = 45, bio = 10, rad = 10)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
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
	flags_armor_protection = HEAD|UPPER_TORSO
	armor = list(melee = 30, bullet = 30, laser = 45, energy = 35, bomb = 45, bio = 20, rad = 30)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDETOPHAIR

/obj/item/clothing/head/admiral
	name = "\improper armored Admiral cap"
	desc = "A sturdy admiral's cap. More protective than it seems. Please don't ditch this for a helmet like a punk."
	icon_state = "admiral_helmet"
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD
	armor = list(melee = 60, bullet = 60, laser = 45, energy = 55, bomb = 55, bio = 10, rad = 10)
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS

