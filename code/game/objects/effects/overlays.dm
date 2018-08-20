/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/tmp/atom/BeamSource
	New()
		..()
		spawn(10) cdel(src)

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = FLY_LAYER
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = FLY_LAYER
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/danger
	name = "Danger"
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "danger"
	layer = ABOVE_FLY_LAYER

/obj/effect/overlay/temp
	anchored = 1
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
	cdel(src)

/obj/effect/overlay/temp/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen1.dmi'
	icon_state = "arrow"
	anchored = 1
	effect_duration = 25

/obj/effect/overlay/temp/point/big
	icon_state = "big_arrow"
	effect_duration = 40

//Special laser for coordinates, not for CAS
/obj/effect/overlay/temp/laser_coordinate
	name = "laser"
	anchored = TRUE
	mouse_opacity = 1
	luminosity = 2
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target_coordinate"
	effect_duration = 600
	var/obj/item/device/binoculars/tactical/source_binoc

/obj/effect/overlay/temp/laser_coordinate/Dispose()
	if(source_binoc)
		source_binoc.laser_cooldown = world.time + source_binoc.cooldown_duration
		source_binoc.coord = null
		source_binoc = null
	SetLuminosity(0)
	. = ..()

/obj/effect/overlay/temp/laser_target
	name = "laser"
	anchored = TRUE
	mouse_opacity = 1
	luminosity = 2
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target2"
	effect_duration = 600
	var/target_id
	var/obj/item/device/binoculars/tactical/source_binoc
	var/obj/machinery/camera/laser_cam/linked_cam

	New(loc, squad_name)
		..()
		if(squad_name)
			name = "[squad_name] laser"
		target_id = rand(1,1000) //giving it a pseudo unique id.
		active_laser_targets += src
		linked_cam = new(loc, name)

/obj/effect/overlay/temp/laser_target/Dispose()
	active_laser_targets -= src
	if(source_binoc)
		source_binoc.laser_cooldown = world.time + source_binoc.cooldown_duration
		source_binoc.laser = null
		source_binoc = null
	if(linked_cam)
		cdel(linked_cam)
		linked_cam = null
	SetLuminosity(0)
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
	luminosity = 2
	effect_duration = 10
	mouse_opacity = 0
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "laser_target3"

/obj/effect/overlay/temp/blinking_laser/Dispose()
	SetLuminosity(0)
	. = ..()

/obj/effect/overlay/temp/emp_sparks
	icon = 'icons/effects/effects.dmi'
	icon_state = "empdisable"
	name = "emp sparks"
	effect_duration = 10

	New(loc)
		dir = pick(cardinal)
		..()

/obj/effect/overlay/temp/emp_pulse
	name = "emp pulse"
	icon = 'icons/effects/effects.dmi'
	icon_state = "emppulse"
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
	icon = 'icons/Xeno/xenomorph_48x48.dmi'
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
	..()