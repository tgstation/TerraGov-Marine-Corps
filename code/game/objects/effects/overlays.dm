/obj/effect/overlay
	name = "overlay"
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/tmp/atom/BeamSource
	New()
		..()
		spawn(10) qdel(src)

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
	mouse_opacity = 0 //can't click to examine it
	var/effect_duration = 10 //in deciseconds

	New()
		..()
		flick(icon_state, src)
		start_countdown()

/obj/effect/overlay/temp/proc/start_countdown()
	set waitfor = 0
	sleep(effect_duration)
	qdel(src)

/obj/effect/overlay/temp/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "arrow"
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
		source_binoc.coord = null
		source_binoc = null
	. = ..()

/obj/effect/overlay/temp/laser_target
	name = "laser"
	anchored = TRUE
	mouse_opacity = 1
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target2"
	effect_duration = 600
	var/target_id
	var/obj/item/binoculars/tactical/source_binoc
	var/obj/machinery/camera/laser_cam/linked_cam
	var/datum/squad/squad

/obj/effect/overlay/temp/laser_target/New(loc, named, assigned_squad = null)
	. = ..()
	if(named)
		name = "[named] laser"
	target_id = UNIQUEID //giving it a unique id.
	GLOB.active_laser_targets += src
	squad = assigned_squad
	if(squad)
		squad.squad_laser_targets += src
	linked_cam = new(loc, name)

/obj/effect/overlay/temp/laser_target/Destroy()
	GLOB.active_laser_targets -= src
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
	. = ..()

/obj/effect/overlay/temp/laser_target/ex_act(severity) //immune to explosions
	return

/obj/effect/overlay/temp/laser_target/examine()
	..()
	if(ishuman(usr))
		to_chat(usr, "<span class='danger'>It's a laser to designate artillery targets, get away from it!</span>")


//used to show where dropship ordnance will impact.
/obj/effect/overlay/temp/blinking_laser
	name = "blinking laser"
	anchored = TRUE
	effect_duration = 10
	mouse_opacity = 0
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target3"


/obj/effect/overlay/temp/sniper_laser
	name = "laser"
	mouse_opacity = 0
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "sniper_laser"


/obj/effect/overlay/temp/emp_sparks
	icon = 'icons/effects/effects.dmi'
	icon_state = "empdisable"
	name = "emp sparks"
	effect_duration = 10

	New(loc)
		setDir(pick(GLOB.cardinals))
		..()

/obj/effect/overlay/temp/emp_pulse
	name = "emp pulse"
	icon = 'icons/effects/effects.dmi'
	icon_state = "emppulse"
	effect_duration = 20


/obj/effect/overlay/temp/tank_laser
	name = "tanklaser"
	anchored = TRUE
	mouse_opacity = 0
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target3"
	effect_duration = 20



//gib animation

/obj/effect/overlay/temp/gib_animation
	icon = 'icons/mob/mob.dmi'
	effect_duration = 14

/obj/effect/overlay/temp/gib_animation/New(Loc, mob/source_mob, gib_icon)
	pixel_x = source_mob.pixel_x
	pixel_y = source_mob.pixel_y
	icon_state = gib_icon
	..()

/obj/effect/overlay/temp/gib_animation/ex_act(severity)
	return


/obj/effect/overlay/temp/gib_animation/animal
	icon = 'icons/mob/animal.dmi'
	effect_duration = 12


/obj/effect/overlay/temp/gib_animation/xeno
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	effect_duration = 10

/obj/effect/overlay/temp/gib_animation/xeno/New(Loc, mob/source_mob, gib_icon, new_icon)
	icon = new_icon
	..()



//dust animation

/obj/effect/overlay/temp/dust_animation
	icon = 'icons/mob/mob.dmi'
	effect_duration = 12

/obj/effect/overlay/temp/dust_animation/New(Loc, mob/source_mob, gib_icon)
	pixel_x = source_mob.pixel_x
	pixel_y = source_mob.pixel_y
	icon_state = gib_icon
	return ..()
