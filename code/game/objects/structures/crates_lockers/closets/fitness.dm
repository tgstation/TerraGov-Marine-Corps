/obj/structure/closet/athletic_mixed
	name = "athletic wardrobe"
	desc = "It's a storage unit for athletic wear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/athletic_mixed/Initialize()
	. = ..()
	new /obj/item/clothing/under/shorts/grey(src)
	new /obj/item/clothing/under/shorts/black(src)
	new /obj/item/clothing/under/shorts/red(src)
	new /obj/item/clothing/under/shorts/blue(src)
	new /obj/item/clothing/under/shorts/green(src)
	new /obj/item/clothing/under/swimsuit/red(src)
	new /obj/item/clothing/under/swimsuit/black(src)
	new /obj/item/clothing/under/swimsuit/blue(src)
	new /obj/item/clothing/under/swimsuit/green(src)
	new /obj/item/clothing/under/swimsuit/purple(src)
	new /obj/item/clothing/mask/snorkel(src)
	new /obj/item/clothing/mask/snorkel(src)
	new /obj/item/clothing/shoes/swimmingfins(src)
	new /obj/item/clothing/shoes/swimmingfins(src)



/obj/structure/closet/boxinggloves
	name = "boxing gloves"
	desc = "It's a storage unit for gloves for use in the boxing ring."

/obj/structure/closet/boxinggloves/Initialize()
	. = ..()
	new /obj/item/clothing/gloves/heldgloves/boxing/blue(src)
	new /obj/item/clothing/gloves/heldgloves/boxing/green(src)
	new /obj/item/clothing/gloves/heldgloves/boxing/yellow(src)
	new /obj/item/clothing/gloves/heldgloves/boxing(src)


/obj/structure/closet/masks
	name = "mask closet"
	desc = "IT'S A STORAGE UNIT FOR FIGHTER MASKS OLE!"

/obj/structure/closet/masks/Initialize()
	. = ..()
	new /obj/item/clothing/mask/luchador(src)
	new /obj/item/clothing/mask/luchador/rudos(src)
	new /obj/item/clothing/mask/luchador/tecnicos(src)


/obj/structure/closet/lasertag/red
	name = "red laser tag equipment"
	desc = "It's a storage unit for laser tag equipment."
	icon_state = "red"
	icon_closed = "red"

/obj/structure/closet/lasertag/red/Initialize()
	. = ..()
	new /obj/item/clothing/suit/redtag(src)
	new /obj/item/clothing/suit/redtag(src)


/obj/structure/closet/lasertag/blue
	name = "blue laser tag equipment"
	desc = "It's a storage unit for laser tag equipment."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lasertag/blue/Initialize()
	. = ..()
	new /obj/item/clothing/suit/bluetag(src)
	new /obj/item/clothing/suit/bluetag(src)

/obj/structure/closet/basketball
	name = "basketball wardrobe"
	desc = "It's a storage unit for basketball wear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/basketball/Initialize()
	. = ..()
	new /obj/item/clothing/under/shorts/grey(src)
	new /obj/item/clothing/under/shorts/black(src)
	new /obj/item/clothing/under/shorts/red(src)
	new /obj/item/clothing/under/shorts/blue(src)
	new /obj/item/clothing/under/shorts/green(src)

/obj/structure/closet/swimsuit
	name = "swimsuit wardrobe"
	desc = "It's a storage unit for swimsuits."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/swimsuit/Initialize()
	. = ..()
	new /obj/item/clothing/under/swimsuit/red(src)
	new /obj/item/clothing/under/swimsuit/black(src)
	new /obj/item/clothing/under/swimsuit/blue(src)
	new /obj/item/clothing/under/swimsuit/green(src)
	new /obj/item/clothing/under/swimsuit/purple(src)
	new /obj/item/clothing/mask/snorkel(src)
	new /obj/item/clothing/mask/snorkel(src)
	new /obj/item/clothing/shoes/swimmingfins(src)
	new /obj/item/clothing/shoes/swimmingfins(src)
