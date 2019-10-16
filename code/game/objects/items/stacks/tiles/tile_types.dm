/* Diffrent misc types of tiles
* Contains:
*		Grass
*		Wood
*		Carpet
*/

/*
* Grass
*/
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses."
	icon_state = "tile_grass"
	w_class = WEIGHT_CLASS_NORMAL
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	max_amount = 60

/*
* Wood
*/
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "An easy to fit wooden floor tile."
	icon_state = "tile-wood"
	w_class = WEIGHT_CLASS_NORMAL
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	max_amount = 60

/*
* Carpets
*/
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a normal floor tile!"
	icon_state = "tile-carpet"
	w_class = WEIGHT_CLASS_NORMAL
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	max_amount = 60
