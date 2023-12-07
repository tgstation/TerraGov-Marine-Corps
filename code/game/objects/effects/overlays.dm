#define LASER_TYPE_CAS "cas_laser"
#define LASER_TYPE_OB "railgun_laser"
#define LASER_TYPE_RAILGUN "railgun_laser"

/obj/effect/overlay
	name = "overlay"

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"

/obj/effect/overlay/beam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 1 SECONDS)

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = TRUE
	layer = FLY_LAYER
	anchored = TRUE

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = TRUE
	layer = FLY_LAYER
	anchored = TRUE

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/danger
	name = "Danger"
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "danger"
	layer = ABOVE_FLY_LAYER

/obj/effect/overlay/sparks
	name = "Sparks"
	layer = ABOVE_FLY_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity"

/obj/effect/overlay/temp
	anchored = TRUE
	layer = ABOVE_FLY_LAYER //above mobs
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT //can't click to examine it
	var/effect_duration = 10 //in deciseconds


//Lase dots

/obj/effect/overlay/blinking_laser //Used to indicate incoming CAS
	name = "blinking laser"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/lases.dmi'
	icon_state = "laser_target3"
	layer = ABOVE_FLY_LAYER

//CAS:

//Minirockets
/obj/effect/overlay/blinking_laser/tfoot
	icon_state = "tanglefoot_target"

/obj/effect/overlay/blinking_laser/smoke
	icon_state = "smoke_target"

/obj/effect/overlay/blinking_laser/flare
	icon_state = "flare_target"

/obj/effect/overlay/blinking_laser/minirocket
	icon_state = "minirocket_target"

/obj/effect/overlay/blinking_laser/incendiary
	icon_state = "incendiary_target"

//Directional
/obj/effect/overlay/blinking_laser/heavygun
	icon_state = "gau_target"

/obj/effect/overlay/blinking_laser/laser
	icon_state = "laser_beam_target"

//Missiles
/obj/effect/overlay/blinking_laser/widowmaker
	icon_state = "widowmaker_target"

/obj/effect/overlay/blinking_laser/banshee
	icon_state = "banshee_target"

/obj/effect/overlay/blinking_laser/keeper
	icon_state = "keeper_target"

/obj/effect/overlay/blinking_laser/fatty
	icon_state = "fatty_target"

/obj/effect/overlay/blinking_laser/napalm
	icon_state = "napalm_target"

//Marine-only visuals. Prediction HUD, etc. Does not show without marine headset
/obj/effect/overlay/blinking_laser/marine
	name = "prediction matrix"
	icon = 'icons/effects/lases.dmi'
	icon_state = "nothing"
	var/icon_state_on = "nothing"
	hud_possible = list(SQUAD_HUD_TERRAGOV)

/obj/effect/overlay/blinking_laser/marine/Initialize(mapload)
	. = ..()
	prepare_huds()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	squad_hud.add_to_hud(src)
	set_visuals()

/obj/effect/overlay/blinking_laser/marine/proc/set_visuals()
	var/image/new_hud_list = hud_list[SQUAD_HUD_TERRAGOV]
	if(!new_hud_list)
		return

	new_hud_list.icon = 'icons/effects/lases.dmi'
	new_hud_list.icon_state = icon_state_on
	hud_list[SQUAD_HUD_TERRAGOV] = new_hud_list

//Prediction lines. Those horizontal blue lines you see when CAS fires something
/obj/effect/overlay/blinking_laser/marine/lines
	layer = WALL_OBJ_LAYER //Above walls/items, not above mobs
	icon_state_on = "middle"

/obj/effect/overlay/blinking_laser/marine/lines/Initialize(mapload)
	. = ..()
	dir = pick(CARDINAL_DIRS) //Randomises type, for variation

/obj/effect/overlay/temp/Initialize(mapload, effect_duration)
	. = ..()
	flick(icon_state, src)
	QDEL_IN(src, effect_duration ? effect_duration : src.effect_duration)

/obj/effect/overlay/temp/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "arrow"
	layer = POINT_LAYER
	anchored = TRUE
	effect_duration = 25

/obj/effect/overlay/temp/point/big
	icon_state = "big_arrow"
	effect_duration = 40

//Special laser for coordinates, not for CAS
/obj/effect/overlay/temp/laser_coordinate
	name = "laser"
	anchored = TRUE
	mouse_opacity = 1
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target_coordinate"
	effect_duration = 600
	var/obj/item/binoculars/tactical/source_binoc

/obj/effect/overlay/temp/laser_coordinate/Destroy()
	if(source_binoc)
		source_binoc.laser_cooldown = world.time + source_binoc.cooldown_duration
		source_binoc = null
	return ..()

/obj/effect/overlay/temp/laser_target
	name = "laser"
	anchored = TRUE
	mouse_opacity = 1
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target_blue"
	effect_duration = 600
	var/target_id
	var/obj/item/binoculars/tactical/source_binoc
	var/obj/machinery/camera/laser_cam/linked_cam
	var/datum/squad/squad
	///what kind of laser we are, used for signals
	var/lasertype = LASER_TYPE_RAILGUN

/obj/effect/overlay/temp/laser_target/Initialize(mapload, effect_duration, named, assigned_squad = null)
	. = ..()
	if(named)
		name = "\improper[named] at [get_area_name(src)]"
	target_id = UNIQUEID //giving it a unique id.
	squad = assigned_squad
	if(squad)
		squad.squad_laser_targets += src
	switch(lasertype)
		if(LASER_TYPE_RAILGUN)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RAILGUN_LASER_CREATED, src)
		if(LASER_TYPE_CAS)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAS_LASER_CREATED, src)
		if(LASER_TYPE_OB)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OB_LASER_CREATED, src)

/obj/effect/overlay/temp/laser_target/Destroy()
	if(squad)
		squad.squad_laser_targets -= src
		squad = null
	if(source_binoc)
		source_binoc.laser_cooldown = world.time + source_binoc.cooldown_duration
		source_binoc.laser = null
		source_binoc = null
	if(linked_cam)
		qdel(linked_cam)
		linked_cam = null
	return ..()

/obj/effect/overlay/temp/laser_target/ex_act(severity) //immune to explosions
	return

/obj/effect/overlay/temp/laser_target/examine(user)
	. = ..()
	if(ishuman(user))
		. += span_danger("It's a laser to designate artillery targets, get away from it!")

/obj/effect/overlay/temp/laser_target/cas
	icon_state = "laser_target_coordinate"
	lasertype = LASER_TYPE_CAS

/obj/effect/overlay/temp/laser_target/cas/Initialize(mapload, effect_duration, named, assigned_squad = null)
	. = ..()
	linked_cam = new(src, name)
	GLOB.active_cas_targets += src

/obj/effect/overlay/temp/laser_target/cas/Destroy()
	GLOB.active_cas_targets -= src
	return ..()

/obj/effect/overlay/temp/laser_target/cas/examine(user)
	. = ..()
	if(ishuman(user))
		. += span_danger("It's a laser to designate CAS targets, get away from it!")

/obj/effect/overlay/temp/laser_target/OB //This is a subtype of CAS so that CIC gets cameras on the lase
	icon_state = "laser_target2"
	lasertype = LASER_TYPE_OB

/obj/effect/overlay/temp/laser_target/OB/Initialize(mapload, effect_duration, named, assigned_squad)
	. = ..()
	linked_cam = new(src, name)
	GLOB.active_laser_targets += src

/obj/effect/overlay/temp/laser_target/OB/Destroy()
	GLOB.active_laser_targets -= src
	return ..()

/obj/effect/overlay/temp/blinking_laser //not used for CAS anymore but some admin buttons still use it
	name = "blinking laser"
	anchored = TRUE
	effect_duration = 10
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target3"


/obj/effect/overlay/temp/sniper_laser
	name = "laser"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "sniper_laser"


/obj/effect/overlay/temp/emp_sparks
	icon = 'icons/effects/effects.dmi'
	icon_state = "empdisable"
	name = "emp sparks"
	effect_duration = 10

/obj/effect/overlay/temp/emp_sparks/Initialize(mapload, effect_duration)
	setDir(pick(GLOB.cardinals))
	return ..()

/obj/effect/overlay/temp/emp_pulse
	name = "emp pulse"
	icon = 'icons/effects/effects.dmi'
	icon_state = "emppulse"
	effect_duration = 20


/obj/effect/overlay/temp/tank_laser
	name = "tanklaser"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target3"
	effect_duration = 20



//gib animation

/obj/effect/overlay/temp/gib_animation
	icon = 'icons/mob/mob.dmi'
	effect_duration = 14

/obj/effect/overlay/temp/gib_animation/Initialize(mapload, effect_duration, mob/source_mob, gib_icon)
	. = ..()
	if(source_mob)
		pixel_x = source_mob.pixel_x
		pixel_y = source_mob.pixel_y
	icon_state = gib_icon

/obj/effect/overlay/temp/gib_animation/ex_act(severity)
	return


/obj/effect/overlay/temp/gib_animation/animal
	icon = 'icons/mob/animal.dmi'
	effect_duration = 12


/obj/effect/overlay/temp/gib_animation/xeno
	icon = 'icons/Xeno/64x64_Xeno_overlays.dmi'
	effect_duration = 10

/obj/effect/overlay/temp/gib_animation/xeno/Initialize(mapload, effect_duration, mob/source_mob, gib_icon, new_icon)
	. = ..()
	icon = new_icon



//dust animation

/obj/effect/overlay/temp/dust_animation
	icon = 'icons/mob/mob.dmi'
	effect_duration = 12

/obj/effect/overlay/temp/dust_animation/Initialize(mapload, effect_duration, mob/source_mob, gib_icon)
	. = ..()
	pixel_x = source_mob.pixel_x
	pixel_y = source_mob.pixel_y
	icon_state = gib_icon

///Lighting overlay for the Light overlay component
/obj/effect/overlay/light_visible
	name = ""
	icon = 'icons/effects/light_overlays/light_32.dmi'
	icon_state = "light"
	layer = O_LIGHTING_VISUAL_LAYER
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	vis_flags = NONE
	blocks_emissive = EMISSIVE_BLOCK_NONE

/obj/effect/overlay/temp/timestop_effect
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	pixel_x = -60
	pixel_y = -50
	alpha = 70

/obj/effect/overlay/eye
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = "eye_open"
	pixel_x = 16
	pixel_y = 16

/obj/effect/overlay/dread
	layer = ABOVE_MOB_LAYER
	icon_state = "spooky"
	pixel_x = 16
	pixel_y = 16
