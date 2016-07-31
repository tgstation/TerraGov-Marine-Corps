//========================//GLOVES & SHOES\\=============================\\
//=======================================================================\\

/*Anything that relates to hands or feet should go in here, armored or not.*/

//=======================================================================\\
//=======================================================================\\

//===========================//GLOVES\\==================================\\
//=======================================================================\\

//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2.0
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	var/clipped = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	species_restricted = list("exclude","Yautja")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/gloves.dmi')

/obj/item/clothing/gloves/marine
	name = "marine combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	icon_state = "gray"
	item_state = "graygloves"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05
	cold_protection = HANDS
	heat_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	body_parts_covered = HANDS
	armor = list(melee = 60, bullet = 40, laser = 10,energy = 10, bomb = 10, bio = 10, rad = 0)

/obj/item/clothing/gloves/marine/alpha
	name = "alpha squad gloves"
	icon_state = "red"
	item_state = "redgloves"

/obj/item/clothing/gloves/marine/bravo
	name = "bravo squad gloves"
	icon_state = "yellow"
	item_state = "ygloves"

/obj/item/clothing/gloves/marine/charlie
	name = "charlie squad gloves"
	icon_state = "purple"
	item_state = "purplegloves"

/obj/item/clothing/gloves/marine/delta
	name = "delta squad gloves"
	icon_state = "blue"
	item_state = "bluegloves"

/obj/item/clothing/gloves/marine/officer
	name = "officer gloves"
	desc = "Shiny and impressive. They look expensive."
	icon_state = "black"
	item_state = "bgloves"

/obj/item/clothing/gloves/marine/officer/chief
	name = "chief officer gloves"
	desc = "Blood crusts are attached to its metal studs, which are slightly dented."

/obj/item/clothing/gloves/marine/techofficer
	name = "tech officer gloves"
	desc = "Sterile AND insulated! Why is not everyone issued with these?"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/marine/techofficer/commander
	name = "commander's gloves"
	desc = "You may like these gloves, but THEY think you are unworthy of them."
	icon_state = "captain"
	item_state = "egloves"

/obj/item/clothing/gloves/marine/specialist
	name = "\improper B18 defensive gauntlets"
	desc = "A pair of heavily armored gloves."
	icon_state = "black"
	item_state = "bgloves"
	item_color = "black"
	armor = list(melee = 90, bullet = 95, laser = 75, energy = 60, bomb = 45, bio = 15, rad = 15)
	unacidable = 1

/obj/item/clothing/gloves/marine/veteran/PMC
	name = "specops gloves"
	desc = "Armored gloves used in special operations. They are also insulated against electrical shock."
	icon_state = "black"
	item_state = "bgloves"
	item_color="brown"
	siemens_coefficient = 0
	armor = list(melee = 60, bullet = 60, laser = 35, energy = 20, bomb = 10, bio = 10, rad = 0)

/obj/item/clothing/gloves/marine/veteran/PMC/commando
	name = "\improper PMC commando gloves"
	desc = "A pair of heavily armored, insulated, acid-resistant gloves."
	icon_state = "brown"
	item_state = "browngloves"
	item_color = "brown"
	armor = list(melee = 90, bullet = 120, laser = 100, energy = 90, bomb = 50, bio = 30, rad = 30)
	unacidable = 1

//============================//SHOES\\==================================\\
//=======================================================================\\

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude","Yautja")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/shoes.dmi')

/obj/item/clothing/shoes/snow
	name = "snow boots"
	desc = "When you feet are as cold as your heart"
	icon_state = "swat"
	siemens_coefficient = 0.6
	cold_protection = FEET
	heat_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/marine
	name = "marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	armor = list(melee = 60, bullet = 40, laser = 10,energy = 10, bomb = 10, bio = 10, rad = 0)
	cold_protection = FEET
	heat_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	var/obj/item/weapon/combat_knife/knife
	var/armor_stage = 0

/obj/item/clothing/shoes/marinechief
	name = "chief officer shoes"
	desc = "Only a small amount of monkeys, kittens, and orphans were killed in making this."
	icon_state = "laceups"
	armor = list(melee = 50, bullet = 50, laser = 25,energy = 25, bomb = 20, bio = 20, rad = 10)
	flags_inv = NOSLIPPING
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/marinechief/commander
	name = "commander shoes"
	desc = "Has special soles for better trampling those underneath."

/obj/item/clothing/shoes/veteran/PMC
	name = "polished shoes"
	desc = "The height of fashion, but these look to be woven with protective fiber."
	icon_state = "laceups"
	armor = list(melee = 60, bullet = 40, laser = 10,energy = 10, bomb = 10, bio = 10, rad = 0)
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	cold_protection = FEET
	heat_protection = FEET
	flags_inv = NOSLIPPING
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/veteran/PMC/commando
	name = "\improper PMC commando boots"
	desc = "A pair of heavily armored, acid-resistant boots."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_boots"
	icon_override = 'icons/PMC/PMC.dmi'
	permeability_coefficient = 0.01
	armor = list(melee = 90, bullet = 120, laser = 100, energy = 90, bomb = 50, bio = 30, rad = 30)
	siemens_coefficient = 0.2
	unacidable = 1


//========================//VARIOUS PROCS\\==============================\\
//=======================================================================\\

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/gloves/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_gloves()

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		//why is this not part of the powercell code?
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, var/proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/weapon/scalpel))
		if (clipped)
			user << "<span class='notice'>The [src] have already been clipped!</span>"
			update_icon()
			return

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("\red [user] cuts the fingertips off of the [src].","\red You cut the fingertips off of the [src].")

		clipped = 1
		name = "mangled [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."
		if("exclude" in species_restricted)
			species_restricted -= "Yautja"

/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()

/obj/item/clothing/shoes/marine
	attack_hand(var/mob/living/M)
		if(knife && src.loc == M && !M.stat) //Only allow someone to take out the knife if it's being worn or held. So you can pick them up off the floor
			knife.loc = get_turf(src)
			if(M.put_in_active_hand(knife))
				M << "<div class='notice'>You slide the [knife] out of [src].</div>"
				playsound(M, 'sound/weapons/shotgun_shell_insert.ogg', 40, 1)
				knife = 0
				update_icon()
			return
		..()

	attackby(var/obj/item/I, var/mob/living/M)
		if(istype(I, /obj/item/weapon/combat_knife))
			if(knife)	return
			M.drop_item()
			knife = I
			I.loc = src
			M << "<div class='notice'>You slide the [I] into [src].</div>"
			playsound(M, 'sound/weapons/shotgun_shell_insert.ogg', 40, 1)
			update_icon()

	update_icon()
		if(knife && !armor_stage)
			icon_state = "jackboots-1"
		else
			if(!armor_stage)
				icon_state = initial(icon_state)