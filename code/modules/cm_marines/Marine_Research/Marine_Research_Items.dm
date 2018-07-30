//Updated 23FEB16



//////////////ALIUM PARTS////////////////////
/obj/item/XenoBio
	name = "An unidentified Alien Organ"
	desc = "Looking at it makes you want to vomit"
	icon = 'icons/Marine/Research/Marine_Research.dmi'
	icon_state = "biomass"
	origin_tech = "Bio=10" //For all of them for now, until we have specific organs/more techs

/obj/item/XenoBio/Resin
	name = "Alien Resin"
	desc = "A piece of alien Resin"
	icon_state = "biomass"
	origin_tech = "Bio=10"

/obj/item/XenoBio/Chitin
	name = "Alien Chitin"
	desc = "A chunk of alien Chitin"
	icon_state = "chitin-chunk"
	origin_tech = "Bio=10"

/obj/item/XenoBio/Blood
	name = "Alien Blood"
	desc = "A sample of alien Blood"
	icon_state = "blood-vial"
	origin_tech = "Bio=10"







//////////////ITEMS YOU CAN MAKE THAT ARE BADASS////////////////////

/obj/item/XenoItem/
	name = "Strange Item"
	desc = "Some sort of fucked up item from the Weyland Yutani brand 3D Biometric Printer...  Probably should make a bug report if you got this..."
	icon_state = "chitin-chunk"
	icon = 'icons/Marine/Research/Marine_Research.dmi'

/obj/item/XenoItem/ResinPaste
	name = "Resin Paste"
	desc = "This resin paste will fix a broken helmet.  (Use by clicking the glue with the armor)."
	icon_state = "resin-glue"
	icon = 'icons/Marine/Research/Marine_Research.dmi'

/obj/item/XenoItem/ResinPaste/afterattack(obj/item/clothing/head/helmet/marine/A as obj, mob/user as mob)
	if (!istype(A) || !istype(usr))
		usr << "Doesn't work that way"
		return
	if (A.anti_hug >= 1)
		usr <<"This Helmet can't be further reinforced."
		return
	usr << "You reinforce the Helmet..."
	A.anti_hug++
	user.temp_drop_inv_item(src)
	cdel(src)
	..()
	return

/obj/item/XenoItem/ChitinPlate
	name = "Chitin Plate"
	desc = "A plate of Chitin Armor that can be attached to your Marine Armor to make it stronger, but will also slow you down.  (Use by clicking the plate with the armor)."
	icon_state = "chitin-armor"
	icon = 'icons/Marine/Research/Marine_Research.dmi'

/obj/item/XenoItem/ChitinPlate/afterattack(obj/item/clothing/suit/storage/marine/A as obj, mob/user as mob)
	if (!istype(A) || !istype(usr))
		usr << "Doesn't work that way..."
		return
	if (A.flags_marine_armor & ARMOR_IS_REINFORCED)
		usr <<"This armor is already reinforced."
		return
	usr << "You reinforce the armor with some Chitin Plating..."
	A.armor = list(melee = 70, bullet = 90, laser = 7, energy = 40, bomb = 50, bio = 40, rad = 20)
	A.slowdown++
	A.flags_marine_armor |= ARMOR_IS_REINFORCED
	user.temp_drop_inv_item(src)
	cdel(src)
	..()
	return


/obj/item/XenoItem/AntiAcid
	name = "Anti-Acid Spray"
	desc = "A spray that makes whatever it's used on unacidable.  Single use."
	icon_state = "anti-acid"
	icon = 'icons/Marine/Research/Marine_Research.dmi'


/obj/item/XenoItem/AntiAcid/afterattack(obj/A as obj, mob/user as mob, proximity)
	if (!isobj(A))
		usr << "Doesn't work that way..."
		return
	if (A.unacidable == 1)
		usr << "It's already resistant to acid..."
		return
	if (istype(A, /obj/machinery/door))
		usr << "It doesn't work on doors..."
		return
	usr << "You spray [A] with the Anti-Acid spray making it unacidable..."
	A.unacidable = 1
	user.temp_drop_inv_item(src)
	cdel(src)
	..()
	return






