/// Temporary visual effects
/obj/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///How long before the temp_visual gets deleted
	var/duration = 1 SECONDS
	///Timer that our duration is stored in
	var/timerid
	///Gives our effect a random direction on init
	var/randomdir = TRUE



/obj/effect/temp_visual/Initialize(mapload)
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinals))

	timerid = QDEL_IN_STOPPABLE(src, duration)


/obj/effect/temp_visual/Destroy()
	deltimer(timerid)
	return ..()


/obj/effect/temp_visual/ex_act()
	return


/obj/effect/temp_visual/dir_setting
	randomdir = FALSE


/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	return ..()


///Image that appears at the Xeno Rally target; only Xenos can see it
/obj/effect/temp_visual/xenomorph/xeno_tracker_target
	name = "xeno tracker target"
	icon_state = "nothing"
	duration = XENO_HEALTH_ALERT_POINTER_DURATION
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	color = COLOR_RED
	hud_possible = list(XENO_TACTICAL_HUD)
	///The target we're pinging and adding this effect to
	var/atom/tracker_target
	///The visual effect we're attaching
	var/image/holder

/obj/effect/temp_visual/xenomorph/xeno_tracker_target/Initialize(mapload, atom/target)
	. = ..()
	prepare_huds()
	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds) //Add to the xeno tachud
		xeno_tac_hud.add_to_hud(src)
	hud_set_xeno_tracker_target(target)

/obj/effect/temp_visual/xenomorph/xeno_tracker_target/Destroy()
	if(tracker_target && holder) //Check to avoid runtimes
		tracker_target.overlays -= holder //remove the overlay
	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds)
		xeno_tac_hud.remove_from_hud(src)
	tracker_target = null //null the target var
	QDEL_NULL(holder) //remove the holder and null the var
	return ..()

/obj/effect/temp_visual/xenomorph/xeno_tracker_target/proc/hud_set_xeno_tracker_target(atom/target)
	holder = hud_list[XENO_TACTICAL_HUD]
	if(!holder)
		return
	holder.icon = 'icons/effects/blips.dmi'
	holder.icon_state = "close_blip_hostile"
	tracker_target = target
	tracker_target.overlays += holder
	hud_list[XENO_TACTICAL_HUD] = holder

GLOBAL_DATUM_INIT(flare_particles, /particles/flare_smoke, new)
/particles/flare_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 100
	height = 200
	count = 1000
	spawning = 3
	lifespan = 2 SECONDS
	fade = 7 SECONDS
	velocity = list(0, 5, 0)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	scale = 0.3
	friction = 0.2
	gravity = list(0, 0.95)
	grow = 0.05

/obj/effect/temp_visual/above_flare
	icon = 'icons/effects/64x64.dmi'
	icon_state = "flare"
	layer = FLY_LAYER
	light_system = STATIC_LIGHT
	light_power = 12
	light_color = COLOR_VERY_SOFT_YELLOW
	light_range = 12 //Way brighter than most lights
	pixel_x = -18
	pixel_y = 150
	duration = 90 SECONDS

/obj/effect/temp_visual/above_flare/Initialize(mapload)
	. = ..()
	particles = GLOB.flare_particles
	loc.visible_message(span_warning("You see a tiny flash, and then a blindingly bright light from a flare as it lights off in the sky!"))
	playsound(loc, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4)
	animate(src, time = duration, pixel_y = 0)

/obj/effect/temp_visual/dropship_flyby
	icon = 'icons/obj/structures/prop/dropship.dmi'
	icon_state = "fighter_shadow"
	layer = FLY_LAYER
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 3 SECONDS
	pixel_x = -48
	pixel_y = -120
	pixel_z = -480

/obj/effect/temp_visual/dropship_flyby/Initialize(mapload)
	. = ..()
	animate(src, pixel_z = 960, time = 3 SECONDS)

/obj/effect/temp_visual/dropship_flyby/som
	icon_state = "harbinger_shadow"

/obj/effect/temp_visual/oppose_shatter
	icon = 'icons/effects/96x96.dmi'
	icon_state = "oppose_shatter"
	name = "veined terrain"
	desc = "blood rushes below the ground, forcing it upwards."
	layer = BLASTDOOR_LAYER
	pixel_x = -32
	pixel_y = -32
	duration = 3 SECONDS
	alpha = 200

/obj/effect/temp_visual/oppose_shatter/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = 3 SECONDS)

/obj/effect/temp_visual/hugger_ball_launch
	icon = 'icons/mob/radial.dmi'
	icon_state = "hugger_ball"
	duration = 4 SECONDS
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/thrown_minion
	duration = 4 SECONDS
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	randomdir = TRUE

/obj/effect/temp_visual/thrown_minion/Initialize(mapload, list/minion_options)
	. = ..()
	var/mob/living/carbon/xenomorph/type = pick(minion_options)
	icon = initial(type.icon)
	icon_state = initial(type.icon_state)

/particles/blood_explosion
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 45
	spawning = 45
	lifespan = 0.7 SECONDS
	fade = 0.9 SECONDS
	grow = 0.1
	scale = 0.4
	spin = generator(GEN_NUM, -20, 20)
	velocity = generator(GEN_CIRCLE, 15, 15)
	friction = generator(GEN_NUM, 0.15, 0.65)
	position = generator(GEN_CIRCLE, 6, 6)

/particles/gib_splatter
	icon = 'icons/effects/blood.dmi'
	icon_state = list("mgibbl3" = 1, "mgibbl5" = 1)
	width = 500
	height = 500
	count = 22
	spawning = 22
	lifespan = 1 SECONDS
	fade = 1.7 SECONDS
	grow = 0.05
	gravity = list(0, -3)
	scale = generator(GEN_NUM, 1, 1.25)
	rotation = generator(GEN_NUM, -10, 10)
	spin = generator(GEN_NUM, -10, 10)
	velocity = list(0, 18)
	friction = generator(GEN_NUM, 0.15, 0.1)
	position = generator(GEN_CIRCLE, 9, 9)
	drift = generator(GEN_CIRCLE, 2, 1)

/obj/effect/temp_visual/gib_particles
	///blood explosion particle holder
	var/obj/effect/abstract/particle_holder/blood
	///gib blood splatter particle holder
	var/obj/effect/abstract/particle_holder/gib_splatter
	duration = 1 SECONDS

/obj/effect/temp_visual/gib_particles/Initialize(mapload, gib_color)
	. = ..()
	blood = new(src, /particles/blood_explosion)
	blood.color = gib_color
	gib_splatter = new(src, /particles/gib_splatter)
	gib_splatter.color = gib_color
	addtimer(CALLBACK(src, PROC_REF(stop_spawning)), 5, TIMER_CLIENT_TIME)

/obj/effect/temp_visual/gib_particles/proc/stop_spawning()
	blood.particles.count = 0
	gib_splatter.particles.count = 0

/obj/effect/temp_visual/leap_dust
	name = "dust"
	desc = "It's just a dust cloud!"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "leap_cloud"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	pixel_x = -16
	pixel_y = -16
	duration = 1 SECONDS

/obj/effect/temp_visual/leap_dust/small

/obj/effect/temp_visual/leap_dust/small/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)
