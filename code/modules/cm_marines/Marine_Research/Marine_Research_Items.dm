//Updated 23FEB16



//////////////ALIUM PARTS////////////////////
/obj/item/XenoBio
	name = "An unidentified Alien Organ"
	desc = "Looking at it makes you want to vomit"
	icon = 'icons/Marine/Research/Marine_Research.dmi'
	icon_state = "biomass"
	origin_tech = "bio=10" //For all of them for now, until we have specific organs/more techs

/obj/item/XenoBio/Biomass
	name = "Alien Biomass"
	desc = "A piece of alien Biomass"
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
	desc = "Some sort of fucked up item from the Weyland Yutani brand 3d Biometric Printer...  Probably should make a bug report if you got this..."
	icon_state = "chitin-chunk"
	icon = 'icons/Marine/Research/Marine_Research.dmi'



/obj/item/XenoItem/ChitinPlate
	name = "Chitin Plate"
	desc = "A plate of Chitin Armor that can be attached to your Marine Armor to make it stronger, but will also slow you down.  (Use by clicking the plate with the armor)."
	icon_state = "chitin-armor"
	icon = 'icons/Marine/Research/Marine_Research.dmi'

/obj/item/XenoItem/ChitinPlate/attackby(obj/item/clothing/suit/storage/marine/A as obj, mob/usr as mob)
	if (!istype(A) || !istype(usr))
		usr << "Doesn't work that way"
		return
	if (A.reinforced)
		usr <<"This armor is already reinforced."
		return
	usr << "You reinforce the armor with some Chitin Plating..."
	A.armor = list(melee = 70, bullet = 90, laser = 7, energy = 40, bomb = 50, bio = 40, rad = 20)
	A.slowdown++
	A.reinforced = 1
	del(src)
	return


/obj/item/XenoItem/AntiAcid
	name = "Anti-Acid Spray"
	desc = "A spray that makes whatever it's used on unacidable.  Single use."
	icon_state = "Anti-acid"
	icon = 'icons/Marine/Research/Marine_Research.dmi'











// if(do_after(user,30)) //NOTE FOR ANTI-ACID SPRAY




