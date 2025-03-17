//stuff found in mines
/obj/structure/mine_structure
	name = "misc mine structure"
	desc = "You shouldn't see this."
	icon = 'icons/obj/structures/cave_decor.dmi'
	icon_state = ""
	max_integrity = 200
	anchored = TRUE
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/structure/mine_structure/cart
	name = "mine cart"
	desc = "A big metal bucket on wheels for moving heavy loads. This one has fallen over."
	icon_state = "minecart_fallen"
	max_integrity = 300
	coverage = 85
	density = TRUE

/obj/structure/mine_structure/wooden/fire_act(burn_level)
	take_damage(burn_level, BURN, FIRE)

/obj/structure/mine_structure/wooden/support_wall
	name = "wooden support"
	desc = "A wooden bracing design to prevent cave collapse"
	icon_state = "support_wall"
	pixel_y = 26

/obj/structure/mine_structure/wooden/support_wall/Initialize(mapload)
	. = ..()
	if(dir == NORTH)
		pixel_y = 0
		layer = ABOVE_MOB_LAYER
		AddComponent(/datum/component/largetransparency, 0, 0, 0, 0)

/obj/structure/mine_structure/wooden/support_wall/above
	dir = NORTH

/obj/structure/mine_structure/wooden/support_wall/broken
	desc = "A wooden bracing design to prevent cave collapse. Its seen better days."
	icon_state = "support_wall_broken"

/obj/structure/mine_structure/wooden/support_wall/broken/above
	dir = NORTH

/obj/structure/mine_structure/wooden/support_wall/t_bar
	desc = "A simple wooden support beam designed to prevent cave collapse."
	icon_state = "support"

/obj/structure/mine_structure/wooden/support_wall/t_bar/above
	dir = NORTH

/obj/structure/mine_structure/wooden/support_wall/beams
	desc = "A pair of wooden support beams designed to prevent cave collapse."
	icon_state = "support_beams"

/obj/structure/mine_structure/wooden/support_wall/beams/above
	dir = NORTH

/obj/structure/mine_structure/wooden/plank
	name = "wooden board"
	desc = "A wood boarden. Good under foot."
	icon_state = "boards_drought_ns"
	///number of icon variants this object has
	var/icon_variants = 6

/obj/structure/mine_structure/wooden/plank/Initialize(mapload)
	. = ..()
	icon_state = "[initial(icon_state)]_[rand(1, icon_variants)]"

/obj/structure/mine_structure/wooden/plank/horizontal
	icon_state = "boards_drought_we"

/obj/structure/mine_structure/wooden/plank/alt
	icon_state = "boards_mammoth_ns"

/obj/structure/mine_structure/wooden/plank/alt/horizontal
	icon_state = "boards_mammoth_we"

/obj/structure/mine_structure/wooden/sign
	name = "wooden sign"
	desc = "A wood sign post. It seems to be pointing somewhere."
	icon_state = "sign_left"

/obj/structure/mine_structure/wooden/sign/right
	icon_state = "sign_right"
