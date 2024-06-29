/*!
 * All the non-turf decorative pieces that make up the old shuttles
 */
// half-tile structure pieces
/obj/structure/dropship_piece
	icon = 'icons/obj/structures/dropship_structures.dmi'
	density = TRUE
	resistance_flags = RESIST_ALL
	opacity = TRUE
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR

/obj/structure/dropship_piece/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

/obj/structure/dropship_piece/ex_act(severity)
	return

/obj/structure/dropship_piece/one
	name = "\improper Alamo"

/obj/structure/dropship_piece/one/front
	icon_state = "brown_front"
	opacity = FALSE

/obj/structure/dropship_piece/one/front/right
	icon_state = "brown_fr"

/obj/structure/dropship_piece/one/front/left
	icon_state = "brown_fl"


/obj/structure/dropship_piece/one/cockpit/left
	icon_state = "brown_cockpit_fl"

/obj/structure/dropship_piece/one/cockpit/right
	icon_state = "brown_cockpit_fr"


/obj/structure/dropship_piece/one/weapon
	opacity = FALSE

/obj/structure/dropship_piece/one/weapon/leftleft
	icon_state = "brown_weapon_ll"

/obj/structure/dropship_piece/one/weapon/leftright
	icon_state = "brown_weapon_lr"

/obj/structure/dropship_piece/one/weapon/rightleft
	icon_state = "brown_weapon_rl"

/obj/structure/dropship_piece/one/weapon/rightright
	icon_state = "brown_weapon_rr"


/obj/structure/dropship_piece/one/wing
	opacity = FALSE

/obj/structure/dropship_piece/one/wing/left/top
	icon_state = "brown_wing_lt"

/obj/structure/dropship_piece/one/wing/left/bottom
	icon_state = "brown_wing_lb"

/obj/structure/dropship_piece/one/wing/right/top
	icon_state = "brown_wing_rt"

/obj/structure/dropship_piece/one/wing/right/bottom
	icon_state = "brown_wing_rb"


/obj/structure/dropship_piece/one/corner/middleleft
	icon_state = "brown_middle_lc"

/obj/structure/dropship_piece/one/corner/middleright
	icon_state = "brown_middle_rc"

/obj/structure/dropship_piece/one/corner/rearleft
	icon_state = "brown_rear_lc"

/obj/structure/dropship_piece/one/corner/rearright
	icon_state = "brown_rear_rc"


/obj/structure/dropship_piece/one/engine
	opacity = FALSE

/obj/structure/dropship_piece/one/engine/lefttop
	icon_state = "brown_engine_lt"

/obj/structure/dropship_piece/one/engine/righttop
	icon_state = "brown_engine_rt"

/obj/structure/dropship_piece/one/engine/leftbottom
	icon_state = "brown_engine_lb"

/obj/structure/dropship_piece/one/engine/rightbottom
	icon_state = "brown_engine_rb"

/obj/structure/dropship_piece/one/rearwing/lefttop
	icon_state = "brown_rearwing_lt"

/obj/structure/dropship_piece/one/rearwing/righttop
	icon_state = "brown_rearwing_rt"

/obj/structure/dropship_piece/one/rearwing/leftbottom
	icon_state = "brown_rearwing_lb"

/obj/structure/dropship_piece/one/rearwing/rightbottom
	icon_state = "brown_rearwing_rb"

/obj/structure/dropship_piece/one/rearwing/leftlbottom
	icon_state = "brown_rearwing_llb"
	opacity = FALSE
	allow_pass_flags = PASSABLE

/obj/structure/dropship_piece/one/rearwing/rightrbottom
	icon_state = "brown_rearwing_rrb"
	opacity = FALSE
	allow_pass_flags = PASSABLE

/obj/structure/dropship_piece/one/rearwing/leftllbottom
	icon_state = "brown_rearwing_lllb"
	opacity = FALSE
	allow_pass_flags = PASSABLE

/obj/structure/dropship_piece/one/rearwing/rightrrbottom
	icon_state = "brown_rearwing_rrrb"
	opacity = FALSE
	allow_pass_flags = PASSABLE



/obj/structure/dropship_piece/two
	name = "\improper Normandy"

/obj/structure/dropship_piece/two/front
	icon_state = "blue_front"
	opacity = FALSE

/obj/structure/dropship_piece/two/front/right
	icon_state = "blue_fr"

/obj/structure/dropship_piece/two/front/left
	icon_state = "blue_fl"

/obj/structure/dropship_piece/tadpole
	name = "\improper Tadpole"

/obj/structure/dropship_piece/tadpole/rearleft
	icon_state = "blue_rear_lc"

/obj/structure/dropship_piece/tadpole/rearright
	icon_state = "blue_rear_rc"

/obj/structure/dropship_piece/glassone
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_glass1"

/obj/structure/dropship_piece/glassone/tadpole
	icon_state = "shuttle_glass1"
	resistance_flags = NONE
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/obj/structure/dropship_piece/glasstwo
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_glass2"

/obj/structure/dropship_piece/glasstwo/tadpole
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_glass2"
	resistance_flags = NONE
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/obj/structure/dropship_piece/singlewindow/tadpole
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "shuttle_single_window"
	allow_pass_flags = PASS_GLASS
	resistance_flags = NONE
	opacity = FALSE

/obj/structure/dropship_piece/tadpole/cockpit
	desc = "The nose part of the tadpole, able to be destroyed."
	max_integrity = 500
	resistance_flags = XENO_DAMAGEABLE | DROPSHIP_IMMUNE
	opacity = FALSE
	layer = BELOW_OBJ_LAYER
	allow_pass_flags = NONE

/obj/structure/dropship_piece/tadpole/cockpit/left
	icon_state = "blue_cockpit_fl"

/obj/structure/dropship_piece/tadpole/cockpit/right
	icon_state = "blue_cockpit_fr"

/obj/structure/dropship_piece/tadpole/cockpit/window
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"

/obj/structure/dropship_piece/tadpole/engine
	icon_state = "tadpole_engine"
	density = FALSE
	opacity = FALSE

/obj/structure/dropship_piece/tadpole/tadpole_nose
	icon_state = "blue_front"
	opacity = FALSE
	density = FALSE

/obj/structure/dropship_piece/tadpole/tadpole_nose/right
	icon_state = "blue_fr"

/obj/structure/dropship_piece/tadpole/tadpole_nose/left
	icon_state = "blue_fl"

/obj/structure/dropship_piece/two/cockpit/left
	icon_state = "blue_cockpit_fl"

/obj/structure/dropship_piece/two/cockpit/right
	icon_state = "blue_cockpit_fr"


/obj/structure/dropship_piece/two/weapon
	opacity = FALSE

/obj/structure/dropship_piece/two/weapon/leftleft
	icon_state = "blue_weapon_ll"

/obj/structure/dropship_piece/two/weapon/leftright
	icon_state = "blue_weapon_lr"

/obj/structure/dropship_piece/two/weapon/rightleft
	icon_state = "blue_weapon_rl"

/obj/structure/dropship_piece/two/weapon/rightright
	icon_state = "blue_weapon_rr"


/obj/structure/dropship_piece/two/wing
	opacity = FALSE

/obj/structure/dropship_piece/two/wing/left/top
	icon_state = "blue_wing_lt"

/obj/structure/dropship_piece/two/wing/left/bottom
	icon_state = "blue_wing_lb"

/obj/structure/dropship_piece/two/wing/right/top
	icon_state = "blue_wing_rt"

/obj/structure/dropship_piece/two/wing/right/bottom
	icon_state = "blue_wing_rb"


/obj/structure/dropship_piece/two/corner/middleleft
	icon_state = "blue_middle_lc"

/obj/structure/dropship_piece/two/corner/middleright
	icon_state = "blue_middle_rc"

/obj/structure/dropship_piece/two/corner/rearleft
	icon_state = "blue_rear_lc"

/obj/structure/dropship_piece/two/corner/rearright
	icon_state = "blue_rear_rc"

/obj/structure/dropship_piece/two/corner/frontleft
	icon_state = "blue_front_lc"

/obj/structure/dropship_piece/two/corner/frontright
	icon_state = "blue_front_rc"


/obj/structure/dropship_piece/two/engine
	opacity = FALSE

/obj/structure/dropship_piece/two/engine/lefttop
	icon_state = "blue_engine_lt"

/obj/structure/dropship_piece/two/engine/righttop
	icon_state = "blue_engine_rt"

/obj/structure/dropship_piece/two/engine/leftbottom
	icon_state = "blue_engine_lb"

/obj/structure/dropship_piece/two/engine/rightbottom
	icon_state = "blue_engine_rb"


/obj/structure/dropship_piece/two/rearwing/lefttop
	icon_state = "blue_rearwing_lt"

/obj/structure/dropship_piece/two/rearwing/righttop
	icon_state = "blue_rearwing_rt"

/obj/structure/dropship_piece/two/rearwing/leftbottom
	icon_state = "blue_rearwing_lb"

/obj/structure/dropship_piece/two/rearwing/rightbottom
	icon_state = "blue_rearwing_rb"

/obj/structure/dropship_piece/two/rearwing/leftlbottom
	icon_state = "blue_rearwing_llb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/rightrbottom
	icon_state = "blue_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/leftllbottom
	icon_state = "blue_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/rightrrbottom
	icon_state = "blue_rearwing_rrrb"
	opacity = FALSE


/obj/structure/dropship_piece/three
	name = "\improper Triumph"

/obj/structure/dropship_piece/three/front
	icon_state = "brown_front"
	opacity = FALSE

/obj/structure/dropship_piece/three/front/right
	icon_state = "brown_fr"

/obj/structure/dropship_piece/three/front/left
	icon_state = "brown_fl"


/obj/structure/dropship_piece/three/cockpit/left
	icon_state = "brown_cockpit_fl"

/obj/structure/dropship_piece/three/cockpit/right
	icon_state = "brown_cockpit_fr"


/obj/structure/dropship_piece/three/weapon
	opacity = FALSE

/obj/structure/dropship_piece/three/weapon/leftleft
	icon_state = "brown_weapon_ll"

/obj/structure/dropship_piece/three/weapon/leftright
	icon_state = "brown_weapon_lr"

/obj/structure/dropship_piece/three/weapon/rightleft
	icon_state = "brown_weapon_rl"

/obj/structure/dropship_piece/three/weapon/rightright
	icon_state = "brown_weapon_rr"


/obj/structure/dropship_piece/three/wing
	opacity = FALSE

/obj/structure/dropship_piece/three/wing/left/top
	icon_state = "brown_wing_lt"

/obj/structure/dropship_piece/three/wing/left/bottom
	icon_state = "brown_wing_lb"

/obj/structure/dropship_piece/three/wing/right/top
	icon_state = "brown_wing_rt"

/obj/structure/dropship_piece/three/wing/right/bottom
	icon_state = "brown_wing_rb"


/obj/structure/dropship_piece/three/corner/middleleft
	icon_state = "brown_middle_lc"

/obj/structure/dropship_piece/three/corner/middleright
	icon_state = "brown_middle_rc"

/obj/structure/dropship_piece/three/corner/rearleft
	icon_state = "brown_rear_lc"

/obj/structure/dropship_piece/three/corner/rearright
	icon_state = "brown_rear_rc"


/obj/structure/dropship_piece/three/engine
	opacity = FALSE

/obj/structure/dropship_piece/three/engine/lefttop
	icon_state = "brown_engine_lt"

/obj/structure/dropship_piece/three/engine/righttop
	icon_state = "brown_engine_rt"

/obj/structure/dropship_piece/three/engine/leftbottom
	icon_state = "brown_engine_lb"

/obj/structure/dropship_piece/three/engine/rightbottom
	icon_state = "brown_engine_rb"


/obj/structure/dropship_piece/three/rearwing/lefttop
	icon_state = "brown_rearwing_lt"

/obj/structure/dropship_piece/three/rearwing/righttop
	icon_state = "brown_rearwing_rt"

/obj/structure/dropship_piece/three/rearwing/leftbottom
	icon_state = "brown_rearwing_lb"

/obj/structure/dropship_piece/three/rearwing/rightbottom
	icon_state = "brown_rearwing_rb"

/obj/structure/dropship_piece/three/rearwing/leftlbottom
	icon_state = "brown_rearwing_llb"
	opacity = FALSE

/obj/structure/dropship_piece/three/rearwing/rightrbottom
	icon_state = "brown_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/three/rearwing/leftllbottom
	icon_state = "brown_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/three/rearwing/rightrrbottom
	icon_state = "brown_rearwing_rrrb"
	opacity = FALSE
