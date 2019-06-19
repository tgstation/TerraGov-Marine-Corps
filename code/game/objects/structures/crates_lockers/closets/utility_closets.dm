/* Utility Closets
* Contains:
*		Emergency Closet
*		Fire Closet
*		Tool Closet
*		Radiation Closet
*		Bombsuit Closet
*		Hydrant
*		First Aid
*/

/*
* Emergency Closet
*/
/obj/structure/closet/emcloset
	name = "emergency closet"
	desc = "It's a storage unit for emergency breathmasks and o2 tanks."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/structure/closet/emcloset/New()
	..()

	switch (pickweight(list("small" = 55, "aid" = 25, "tank" = 10, "both" = 10, "nothing" = 0, "delete" = 0)))
		if ("small")
			new /obj/item/tank/emergency_oxygen(src)
			new /obj/item/tank/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/gas(src)
			new /obj/item/clothing/mask/gas(src)
		if ("aid")
			new /obj/item/tank/emergency_oxygen(src)
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/storage/firstaid/o2(src)
			new /obj/item/clothing/mask/gas(src)
		if ("tank")
			new /obj/item/tank/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/tank/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/gas(src)
		if ("both")
			new /obj/item/storage/toolbox/emergency(src)
			new /obj/item/tank/emergency_oxygen/engi(src)
			new /obj/item/clothing/mask/gas(src)
			new /obj/item/clothing/mask/gas(src)
			new /obj/item/storage/firstaid/o2(src)
		if ("nothing")
			// doot

		// teehee - Ah, tg coders...
		if ("delete")
			qdel(src)

		//If you want to re-add fire, just add "fire" = 15 to the pick list.
		/*if ("fire")
			new /obj/structure/closet/firecloset(src.loc)
			qdel(src)*/

/obj/structure/closet/emcloset/legacy/New()
	..()
	new /obj/item/tank/oxygen(src)
	new /obj/item/clothing/mask/gas(src)

/*
* Fire Closet
*/
/obj/structure/closet/firecloset
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "firecloset"
	icon_closed = "firecloset"
	icon_opened = "fireclosetopen"

/obj/structure/closet/firecloset/New()
	..()

	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/oxygen/red(src)
	new /obj/item/tool/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/firecloset/full/New()
	..()
	sleep(4)
	contents = list()

	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/tank/oxygen/red(src)
	new /obj/item/tool/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/firecloset/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened


/*
* Tool Closet
*/
/obj/structure/closet/toolcloset
	name = "tool closet"
	desc = "It's a storage unit for tools."
	icon_state = "toolcloset"
	icon_closed = "toolcloset"
	icon_opened = "toolclosetopen"


/obj/structure/closet/toolcloset/Initialize()
	. = ..()
	new /obj/item/clothing/suit/storage/hazardvest(src)
	new /obj/item/flashlight(src)
	new /obj/item/t_scanner(src)
	new /obj/item/storage/belt/utility/full(src)
	new /obj/item/clothing/head/hardhat(src)
	if(prob(10))
		new /obj/item/clothing/gloves/yellow(src)


/*
* Radiation Closet
*/
/obj/structure/closet/radiation
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "radsuitcloset"
	icon_opened = "radsuitclosetopen"
	icon_closed = "radsuitcloset"

/obj/structure/closet/radiation/New()
	..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/*
* Bombsuit closet
*/
/obj/structure/closet/bombcloset
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bombsuit"
	icon_closed = "bombsuit"
	icon_opened = "bombsuitopen"

/obj/structure/closet/bombcloset/New()
	..()
	sleep(2)
	new /obj/item/clothing/suit/bomb_suit( src )
	new /obj/item/clothing/under/color/black( src )
	new /obj/item/clothing/shoes/black( src )
	new /obj/item/clothing/head/bomb_hood( src )


/obj/structure/closet/bombclosetsecurity
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bombsuitsec"
	icon_closed = "bombsuitsec"
	icon_opened = "bombsuitsecopen"

/obj/structure/closet/bombclosetsecurity/New()
	..()
	sleep(2)
	new /obj/item/clothing/suit/bomb_suit/security( src )
	new /obj/item/clothing/under/rank/security( src )
	new /obj/item/clothing/shoes/brown( src )
	new /obj/item/clothing/head/bomb_hood/security( src )