/obj/structure/platform
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform"
	coverage = 10
	density = TRUE
	layer = BELOW_OBJ_LAYER
	atom_flags = ON_BORDER
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/platform/Initialize(mapload)
	. = ..()
	update_icon()
	icon_state = null

	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit),
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/platform/update_overlays()
	. = ..()
	var/image/new_overlay

	if(dir & EAST)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, EAST)
		new_overlay.pixel_x = 32
		. += new_overlay

	if(dir & WEST)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, WEST)
		new_overlay.pixel_x = -32
		. += new_overlay

	if(dir & NORTH)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTH)
		new_overlay.pixel_y = 32
		new_overlay.layer = ABOVE_MOB_LAYER //perspective
		. += new_overlay

	if(dir & SOUTH)
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTH)
		new_overlay.pixel_y = -32
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, NORTHEAST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTHEAST)
		new_overlay.pixel_y = 32
		new_overlay.pixel_x = 32
		new_overlay.layer = ABOVE_MOB_PLATFORM_LAYER
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, NORTHWEST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, NORTHWEST)
		new_overlay.pixel_y = 32
		new_overlay.pixel_x = -32
		new_overlay.layer = ABOVE_MOB_PLATFORM_LAYER
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, SOUTHEAST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTHEAST)
		new_overlay.pixel_y = -32
		new_overlay.pixel_x = 32
		. += new_overlay

	if(CHECK_MULTIPLE_BITFIELDS(dir, SOUTHWEST))
		new_overlay = image(icon, src, "[initial(icon_state)]_overlay", layer, SOUTHWEST)
		new_overlay.pixel_y = -32
		new_overlay.pixel_x = -32
		. += new_overlay

/obj/structure/platform/nondense
	density = FALSE
	climbable = FALSE
	coverage = 0

/obj/structure/platform/rockcliff
	icon_state = "rockcliff"
	name = "rock cliff"
	desc = "A collection of stones and rocks that form a steep cliff, it looks climbable."

/obj/structure/platform/rockcliff/orange
	icon_state = "rockcliff_orange"

/obj/structure/platform/rockcliff/red
	icon_state = "rockcliff_red"

/obj/structure/platform/rockcliff/icycliff
	icon_state = "icerock"

/obj/structure/platform/rockcliff/icycliff/nondense
	density = FALSE
	climbable = FALSE
	coverage = 0

/obj/structure/platform/metalplatform
	icon_state = "metalplatform"

/obj/structure/platform/metalplatform/nondense
	density = FALSE
	climbable = FALSE
	coverage = 0

/obj/structure/platform/trench
	icon_state = "platformtrench"
	name = "trench wall"
	desc = "A group of roughly cut planks forming the side of a dug in trench."

/obj/structure/platform/trench/nondense
	density = FALSE
	climbable = FALSE
	coverage = 0

/obj/structure/platform/adobe
	name = "brick wall"
	desc = "A low adobe brick wall."
	icon_state = "adobe"

/obj/structure/platform/adobe/nondense
	density = FALSE
	climbable = FALSE
	coverage = 0

//decorative corner platform bits
/obj/structure/platform_decoration
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform_deco"
	atom_flags = ON_BORDER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/platform_decoration/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			layer = ABOVE_MOB_PLATFORM_LAYER
		if(SOUTH)
			layer = ABOVE_MOB_PLATFORM_LAYER
		if(SOUTHEAST)
			layer = ABOVE_MOB_PLATFORM_LAYER
		if(SOUTHWEST)
			layer = ABOVE_MOB_PLATFORM_LAYER

/obj/structure/platform_decoration/rockcliff_deco
	icon_state = "rockcliff_deco"
	name = "rock cliff"
	desc = "A collection of stones and rocks that form a steep cliff, it looks climbable."

/obj/structure/platform_decoration/rockcliff_deco/orange
	icon_state = "rockcliff_orange_deco"

/obj/structure/platform_decoration/rockcliff_deco/red
	icon_state = "rockcliff_red_deco"

/obj/structure/platform_decoration/rockcliff_deco/icycliff_deco
	icon_state = "icerock_deco"

/obj/structure/platform_decoration/metalplatform_deco
	icon_state = "metalplatform_deco"

/obj/structure/platform_decoration/adobe_deco
	icon_state = "adobe_deco"


/// Hybrisa Platforms

/obj/structure/platform/hybrisa
	icon_state = "hybrisa"

/obj/structure/platform_decoration/hybrisa
	icon_state = "hybrisa"

/obj/structure/platform/urban
	max_integrity = 120

/obj/structure/platform/urban/engineer
	icon_state = "engineer_platform"
	name = "raised metal edge"
	desc =  "A raised level of metal, often used to elevate areas above others, or construct bridges. You could probably climb it."

/obj/structure/platform_decoration/urban/engineer_corner
	name = "raised metal corner"
	desc = "The corner of what appears to be raised piece of metal, often used to imply the illusion of elevation in non-Euclidean 2d spaces. But you don't know that, you're just a spaceman with a rifle."
	icon_state = "engineer_platform_deco"

/obj/structure/platform_decoration/urban/engineer_cornerbits
	name = "raised metal corner"
	desc = "The corner of what appears to be raised piece of metal, often used to imply the illusion of elevation in non-Euclidean 2d spaces. But you don't know that, you're just a spaceman with a rifle."
	icon_state = "engineer_platform_platformcorners"


/obj/structure/platform/urban/rockdark
	icon_state = "kutjevo_rockdark"
	name = "raised rock edges"
	desc = "A collection of stones and rocks that provide ample grappling and vaulting opportunity. Indicates a change in elevation. You could probably climb it."

/obj/structure/platform_decoration/urban/rockdark
	name = "raised rock corner"
	desc = "A collection of stones and rocks that cap the edge of some conveniently 1-meter-long lengths of perfectly climbable chest high walls."
	icon_state = "kutjevo_rock_decodark"


/obj/structure/platform/urban/metalplatform1
	icon_state = "hybrisastone"
	name = "raised metal edge"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform_decoration/urban/metalplatformdeco1
	icon_state = "hybrisastone_deco"
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. This is the corner."

/obj/structure/platform_decoration/urban/metalplatformdeco2
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. This is the corner."
	icon_state = "strata_metalplatform_deco2"

/obj/structure/platform/urban/metalplatform2
	name = "raised metal edge"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."
	icon_state = "strata_metalplatform2"

/obj/structure/platform_decoration/urban/metalplatformdeco3
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. This is the corner."
	icon_state = "strata_metalplatform_deco3"

/obj/structure/platform/urban/metalplatform3
	name = "raised metal edge"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."
	icon_state = "strata_metalplatform3"

/obj/structure/platform/urban/metalplatform4
	icon_state = "hybrisaplatform"
	name = "raised metal platform"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform_decoration/urban/metalplatformdeco4
	icon_state = "hybrisaplatform_deco"
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform/urban/metalplatform5
	icon_state = "hybrisaplatform2"
	name = "raised metal platform"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform_decoration/urban/metalplatformdeco5
	icon_state = "hybrisaplatform_deco2"
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform/urban/metalplatform6
	icon_state = "hybrisaplatform3"
	name = "raised metal platform"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform/urban/metalplatformstair1
	icon_state = "hybrisaplatform_stair"
	name = "raised metal platform"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform/urban/metalplatformstair2
	icon_state = "hybrisaplatform_stair_alt"
	name = "raised metal platform"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."

/obj/structure/platform_decoration/urban/metalplatformdeco6
	icon_state = "hybrisaplatform_deco3"
	name = "raised metal corner"
	desc = "A raised level of metal, often used to elevate areas above others. You could probably climb it."


/obj/structure/platform/mineral
	icon_state = "stone"

/obj/structure/platform_decoration/mineral
	icon_state = "stone_deco"

/obj/structure/platform/mineral/sandstone
	name = "sandstone platform"
	desc = "A platform supporting elevated ground, made of sandstone. Has what seem to be ancient hieroglyphs on its side."
	color = "#c6a480"

/obj/structure/platform/mineral/sandstone/runed
	name = "sandstone temple platform"
	color = "#b29082"


/obj/structure/platform_decoration/mineral/sandstone
	name = "sandstone platform corner"
	desc = "A platform corner supporting elevated ground, made of sandstone. Has what seem to be ancient hieroglyphs on its side."
	color = "#c6a480"

/obj/structure/platform/shiva/catwalk
	icon_state = "shiva"
	name = "raised rubber cord platform"
	desc = "Reliable steel and a polymer rubber substitute. Doesn't crack under cold weather."

/obj/structure/platform_decoration/shiva/catwalk
	icon_state = "shiva_deco"
	name = "raised rubber cord platform"
	desc = "Reliable steel and a polymer rubber substitute. Doesn't crack under cold weather."

/obj/structure/platform_decoration/mineral/sandstone/runed
	name = "sandstone temple platform corner"
	color = "#b29082"

