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
	layer = 5
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/danger
	name = "Danger"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "danger"
	layer = 6

/obj/effect/overlay/temp
	anchored = 1
	layer = 5 //above mobs
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
	layer = 16
	anchored = 1
	effect_duration = 25
