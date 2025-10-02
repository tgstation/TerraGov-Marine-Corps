/// non-singleton ammo datum for maw launches. One is created every time the maw fires for every fire.
/datum/maw_ammo
	///dont change this var name it makes the tooltip show the name when you hover in the radial
	var/name = "generic maw ammo"
	///radial icon to display in the selection radial for this ammo
	var/radial_icon_state = "acid_smoke"
	/// time in ticks this maw ammo will cause the maw to go on cooldown for
	var/cooldown_time = 1
	///NEVER SET THIS BELOW 2 SECONDS, THATS THE IMPACT ANIM TIME, PROBABLY SET IT HIGHER CUS LAUNCH ANIMS EXIST
	var/impact_time = 6 SECONDS

///called when the maw fires its payload
/datum/maw_ammo/proc/launch_animation(turf/target, obj/structure/xeno/acid_maw/maw)
	CRASH("UNIMPLEMENTED MAW OR CALLED PARENT")

///called 2 seconds before impact
/datum/maw_ammo/proc/impact_visuals(turf/target)
	return

///actual impact effects after the impact visuals
/datum/maw_ammo/proc/on_impact(turf/target)
	CRASH("UNIMPLEMENTED MAW OR CALLED PARENT")


/datum/maw_ammo/smoke
	name = "GENERIC_SMOKEAMMOTYPE"
	cooldown_time = 4 MINUTES
	///radius of the smoke we deploy
	var/smokeradius = 5
	///The duration of the smoke in 2 second ticks
	var/duration = 10
	///datum typepath for the smoke we wanna use
	var/datum/effect_system/smoke_spread/smoke_type = /datum/effect_system/smoke_spread/bad

/particles/maw_smoke_glob
	width = 100
	height = 200
	count = 300
	spawning = 30
	gravity = list(0, 0.95, 0)
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	lifespan = 10
	fade = generator(GEN_NUM, 12, 2, LINEAR_RAND)
	fadein = 1
	color = "#ffbf58" // set by glob type
	position = generator(GEN_SPHERE, 15, 0, SQUARE_RAND)
	velocity = list(0, 12, 0)
	scale = 0.4
	grow = -0.02
	spin = generator(GEN_NUM, 0, 10, UNIFORM_RAND)
	friction = 0.2

/particles/maw_smoke_glob/launch
	velocity = list(0, -12, 0)
	gravity = list(0, -0.95, 0)

/obj/effect/temp_visual/maw_gas_launch
	duration = 4 SECONDS

/obj/effect/temp_visual/maw_gas_launch/Initialize(mapload)
	. = ..()
	particles = new /particles/maw_smoke_glob/launch

/obj/effect/temp_visual/maw_gas_land
	duration = 2 SECONDS

/obj/effect/temp_visual/maw_gas_land/Initialize(mapload)
	. = ..()
	particles = new /particles/maw_smoke_glob

/datum/maw_ammo/smoke/launch_animation(turf/target, obj/structure/xeno/acid_maw/maw)
	var/obj/effect/temp_visual/maw_gas_launch/anim = new(maw.loc)
	var/obj/effect/particle_effect/smoke/smoke_effecttype = smoke_type::smoke_type
	anim.particles.color = smoke_effecttype::color
	anim.pixel_x = (maw.bound_width/2) - 16
	animate(anim, anim.duration, easing=EASE_IN|CUBIC_EASING, pixel_z=600)

/datum/maw_ammo/smoke/impact_visuals(turf/target)
	. = ..()
	var/obj/effect/temp_visual/maw_gas_land/anim = new(target)
	var/obj/effect/particle_effect/smoke/smoke_effecttype = smoke_type::smoke_type
	anim.particles.color = smoke_effecttype::color
	anim.pixel_z = 700
	animate(anim, anim.duration, easing=EASE_IN|CUBIC_EASING, pixel_z=0)
	animate(alpha = 0, pixel_z = 700)

/datum/maw_ammo/smoke/on_impact(turf/target)
	var/datum/effect_system/smoke_spread/smoke = new smoke_type
	smoke.set_up(smokeradius, target, duration)
	smoke.start()

/datum/maw_ammo/smoke/neuro
	name = "neurotoxin maw glob"
	radial_icon_state = "smoke_mortar"
	smoke_type = /datum/effect_system/smoke_spread/xeno/neuro

/datum/maw_ammo/smoke/acid_small
	name = "tactical acid maw glob"
	cooldown_time = 3 MINUTES
	radial_icon_state = "acid_smoke_mortar"
	smoke_type = /datum/effect_system/smoke_spread/xeno/acid
	smokeradius = 7
	duration = 10

/datum/maw_ammo/smoke/acid_small/on_impact(turf/target)
	. = ..()
	for(var/turf/newspray in view(smokeradius*0.5, target))
		xenomorph_spray(newspray, duration*2, XENO_DEFAULT_ACID_PUDDLE_DAMAGE)

/datum/maw_ammo/hugger
	name = "ball of huggers"
	radial_icon_state = "hugger_ball"
	cooldown_time = 10 MINUTES
	impact_time = 12 SECONDS
	/// range_turfs that huggers will be dropped around the target
	var/drop_range = 10
	/// how many huggers get dropped at once, does not stack on turfs if theres not enough turfs
	var/hugger_count = 60
	///huggers to choose to spawn
	var/list/hugger_options = list(
		/obj/item/clothing/mask/facehugger,
		/obj/item/clothing/mask/facehugger/combat/slash,
		/obj/item/clothing/mask/facehugger/combat/acid,
		/obj/item/clothing/mask/facehugger/combat/resin,
		/obj/item/clothing/mask/facehugger/combat/chem_injector/ozelomelyn,
	)
	/// used to track our spawned huggers for animations and stuff
	var/list/spawned_huggers = list()

/datum/maw_ammo/hugger/launch_animation(turf/target, obj/structure/xeno/acid_maw/maw)
	var/obj/effect/temp_visual/hugger_ball_launch/anim = new(maw.loc)
	anim.pixel_x = (maw.bound_width/2) - 16
	animate(anim, anim.duration, easing=EASE_OUT|CUBIC_EASING, pixel_z=600)
	playsound_z_humans(target.z, 'sound/voice/strategic_launch_detected.ogg', 100)

/datum/maw_ammo/hugger/impact_visuals(turf/target)
	var/list/turf/turfs = RANGE_TURFS(drop_range, target)
	assignturfs:
		while(length(turfs) && hugger_count) // does not double stackhuggers: if 5 tiles free 5 huggers spawn
			var/turf/candidate = pick_n_take(turfs)
			if(candidate.density)
				continue assignturfs
			for(var/atom/blocker AS in candidate.contents)
				if(blocker.density)
					continue assignturfs
			hugger_count--
			var/hugger_type = pick(hugger_options)
			var/obj/item/clothing/mask/facehugger/paratrooper = new hugger_type(candidate)
			paratrooper.go_idle()

			var/xoffset = (target.x - candidate.x) * 32
			var/yoffset = (target.y - candidate.y) * 32 + 600
			paratrooper.pixel_w = xoffset
			paratrooper.pixel_z = yoffset

			var/current_hugger_iconstate = paratrooper.icon_state
			animate(paratrooper, 2 SECONDS, pixel_w=0, pixel_z=0, icon_state=initial(paratrooper.icon_state)+"_thrown", easing=EASE_OUT|CUBIC_EASING)
			animate(icon_state=current_hugger_iconstate)
			spawned_huggers += paratrooper
			CHECK_TICK // not in a hurry, we have 2 sec after all :)

/datum/maw_ammo/hugger/on_impact(turf/target)
	for(var/obj/item/clothing/mask/facehugger/paratrooper AS in spawned_huggers)
		paratrooper.go_active()

/datum/maw_ammo/minion
	name = "ball of minions"
	radial_icon_state = "minion"
	cooldown_time = 10 MINUTES
	impact_time = 12 SECONDS
	/// range_turfs that minions will be dropped around the target
	var/drop_range = 7
	/// how many minions get dropped at once, does not stack on turfs if theres not enough turfs
	var/minion_count = 16
	///minions to choose to spawn
	var/list/minion_options = list(
		/mob/living/carbon/xenomorph/beetle/ai,
		/mob/living/carbon/xenomorph/mantis/ai,
		/mob/living/carbon/xenomorph/scorpion/ai,
	)
	/// used to track our spawned minions for animations and stuff
	var/list/spawned_minions = list()

/datum/maw_ammo/minion/launch_animation(turf/target, obj/structure/xeno/acid_maw/maw)
	create_launch_minion_anim(maw)//0 length timer avoidance
	for(var/i=1 to minion_count)
		addtimer(CALLBACK(src, PROC_REF(create_launch_minion_anim), maw), i*2) // staggers launches
	playsound_z_humans(target.z, 'sound/voice/strategic_launch_detected.ogg', 100)

//literally just to make minion throw into the air anim
/datum/maw_ammo/minion/proc/create_launch_minion_anim(obj/structure/xeno/acid_maw/maw)
	playsound(maw, 'sound/effects/thoomp.ogg', 80, TRUE)
	var/obj/effect/temp_visual/thrown_minion/anim = new(maw.loc, minion_options)
	anim.pixel_x = (maw.bound_width/2) - rand(48, 30)
	anim.transform = matrix().Turn(rand(360))
	animate(anim, anim.duration, transform=matrix().Turn(rand(360)), easing=EASE_OUT|CUBIC_EASING, pixel_z=600)

/datum/maw_ammo/minion/impact_visuals(turf/target)
	var/list/turf/turfs = RANGE_TURFS(drop_range, target)
	assignturfs:
		while(length(turfs) && minion_count) // does not double stackhuggers: if 5 tiles free 5 huggers spawn
			var/turf/candidate = pick_n_take(turfs)
			if(candidate.density)
				continue assignturfs
			for(var/atom/blocker AS in candidate.contents)
				if(blocker.density)
					continue assignturfs
			minion_count--
			var/minion_type = pick(minion_options)
			var/mob/living/carbon/xenomorph/paratrooper = new minion_type(candidate)
			paratrooper.notransform = TRUE
			paratrooper.density = FALSE
			paratrooper.set_canmove(FALSE)
			paratrooper.setDir(pick(GLOB.cardinals))

			var/xoffset = (target.x - candidate.x) * 32
			var/yoffset = (target.y - candidate.y) * 32 + 600
			paratrooper.pixel_w = xoffset
			paratrooper.pixel_z = yoffset

			animate(paratrooper, 2 SECONDS, pixel_w=initial(paratrooper.pixel_w), pixel_z=initial(paratrooper.pixel_z), easing=EASE_OUT|CUBIC_EASING)
			spawned_minions += paratrooper
			CHECK_TICK // not in a hurry, we have 2 sec after all :)

/datum/maw_ammo/minion/on_impact(turf/target)
	for(var/mob/living/carbon/xenomorph/paratrooper AS in spawned_minions)
		paratrooper.density = TRUE

	addtimer(CALLBACK(src, PROC_REF(minion_activate)), 3 SECONDS)

///mkminion activate and start moving/attacking
/datum/maw_ammo/minion/proc/minion_activate()
	for(var/mob/living/carbon/xenomorph/paratrooper AS in spawned_minions)
		paratrooper.notransform = FALSE
		paratrooper.set_canmove(TRUE)

/datum/maw_ammo/xeno_fire
	name = "plasma fire fireball"
	radial_icon_state = "incendiary_mortar"
	cooldown_time = 5 MINUTES

/obj/effect/temp_visual/fireball
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "xeno_fireball"
	duration = 4 SECONDS

/datum/maw_ammo/xeno_fire/launch_animation(turf/target, obj/structure/xeno/acid_maw/maw)
	var/obj/effect/temp_visual/fireball/fireball = new
	maw.vis_contents += fireball
	fireball.pixel_x = (maw.bound_width/2) - 16
	animate(fireball, fireball.duration, easing=EASE_IN|CUBIC_EASING, pixel_z=600)
	animate(icon=null)

/datum/maw_ammo/xeno_fire/impact_visuals(turf/target)
	var/obj/effect/temp_visual/fireball/fireball = new(target)
	fireball.transform = matrix().Turn(180)
	fireball.pixel_z = 800
	animate(fireball, 2 SECONDS, easing=EASE_IN|CUBIC_EASING, pixel_z=0)
	animate(icon=null)

/datum/maw_ammo/xeno_fire/on_impact(turf/target)
	for(var/turf/affecting AS in RANGE_TURFS(4, target))
		new /obj/fire/melting_fire(affecting)
		for(var/mob/living/carbon/fired in affecting)
			fired.take_overall_damage(20, BURN, FIRE, FALSE, FALSE, TRUE, 0, , max_limbs = 2)


/obj/structure/xeno/acid_maw
	name = "acid maw"
	desc = "A deep hole in the ground. Its walls are coated with resin and you see the occasional vent or fang."
	icon = 'icons/Xeno/3x3building.dmi'
	icon_state = "maw"
	bound_width = 96
	bound_height = 64
	bound_x = -32
	pixel_x = -32
	pixel_y = -8
	max_integrity = 400
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	xeno_structure_flags = CRITICAL_STRUCTURE|IGNORE_WEED_REMOVAL
	///icon state to use for minimap icon
	var/minimap_icon = "acid_maw"
	///list of paths that we can choose from when using this maw. converts to a list for radials on init (path = image)
	var/list/maw_options = list(
		/datum/maw_ammo/hugger,
		/datum/maw_ammo/minion,
	)

/obj/structure/xeno/acid_maw/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, minimap_icon, MINIMAP_LABELS_LAYER))
	var/list/parsed_maw_options = list()
	for(var/datum/maw_ammo/path AS in maw_options)
		parsed_maw_options[path] = image(icon='icons/mob/radial.dmi', icon_state=path::radial_icon_state)
	maw_options = parsed_maw_options
	LAZYADDASSOC(GLOB.xeno_acid_jaws_by_hive, hivenumber, src)

/obj/structure/xeno/acid_maw/Destroy()
	GLOB.xeno_acid_jaws_by_hive[hivenumber] -= src
	return ..()

/obj/structure/xeno/acid_maw/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount, damage_type, armor_type, effects, armor_penetration, isrightclick)
	. = ..()
	try_fire(xeno_attacker, src)

/// Tries to fire the acid maw after going through various checks and player inputs.
/obj/structure/xeno/acid_maw/proc/try_fire(mob/living/carbon/xenomorph/xeno_shooter, atom/radical_target, slient, leaders_only = TRUE, requires_adjacency = TRUE)
	if(xeno_shooter.hivenumber != hivenumber)
		if(!slient)
			balloon_alert(xeno_shooter, "wrong hive")
		return FALSE
	if(leaders_only && xeno_shooter.tier != XENO_TIER_FOUR && !(xeno_shooter.xeno_flags & XENO_LEADER))
		if(!slient)
			balloon_alert(xeno_shooter, "must be leader")
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_MAW_GLOB)) // repeat this every time after we have a sleep for quick feedback
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_MAW_GLOB)
		if(!slient)
			balloon_alert(xeno_shooter, "cooldown: [timeleft/10] seconds")
		return FALSE

	var/selected_type = !requires_adjacency ? show_radial_menu(xeno_shooter, radical_target, maw_options) : show_radial_menu(xeno_shooter, radical_target, maw_options, custom_check = CALLBACK(src, TYPE_PROC_REF(/datum, Adjacent), xeno_shooter))
	if(!selected_type)
		return FALSE

	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_MAW_GLOB))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_MAW_GLOB)
		if(!slient)
			balloon_alert(xeno_shooter, "cooldown: [timeleft/10] seconds")
		return FALSE

	var/atom/movable/screen/minimap/map = SSminimaps.fetch_minimap_object(z, MINIMAP_FLAG_XENO)
	xeno_shooter.client.screen += map
	var/list/polled_coords = map.get_coords_from_click(xeno_shooter)
	xeno_shooter?.client?.screen -= map
	if(!polled_coords)
		return FALSE
	if(requires_adjacency && !Adjacent(xeno_shooter))
		if(!slient)
			balloon_alert(xeno_shooter, "moved too far away")
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_MAW_GLOB))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_MAW_GLOB)
		if(!slient)
			balloon_alert(xeno_shooter, "cooldown: [timeleft/10] seconds")
		return FALSE

	var/datum/maw_ammo/ammo = new selected_type
	var/turf/clicked_turf = locate(polled_coords[1], polled_coords[2], z)
	addtimer(CALLBACK(src, PROC_REF(maw_impact_start), ammo, clicked_turf, xeno_shooter), ammo.impact_time-2 SECONDS)
	notify_ghosts("<b>[xeno_shooter]</b> has just fired \the <b>[src]</b> !", source = clicked_turf, action = NOTIFY_JUMP)
	//this is stinky but we need to call parent for acid jaw regardless so have to do the tracking, for both, here
	switch(type)
		if(/obj/structure/xeno/acid_maw)
			GLOB.round_statistics.acid_maw_fires++
			if(xeno_shooter.client)
				var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[xeno_shooter.ckey]
				personal_statistics.acid_maw_uses++
		if(/obj/structure/xeno/acid_maw/acid_jaws)
			GLOB.round_statistics.acid_jaw_fires++
			if(xeno_shooter.client)
				var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[xeno_shooter.ckey]
				personal_statistics.acid_jaw_uses++
	ammo.launch_animation(clicked_turf, src)
	S_TIMER_COOLDOWN_START(src, COOLDOWN_MAW_GLOB, ammo.cooldown_time)
	return TRUE

/// incoming effects for this ammo, 2 sec prior to impact
/obj/structure/xeno/acid_maw/proc/maw_impact_start(datum/maw_ammo/ammo, turf/target, mob/living/user)
	addtimer(CALLBACK(src, PROC_REF(maw_impact), ammo, target, user), 2 SECONDS)
	ammo.impact_visuals(target)
	user.reset_perspective(target)

///actually does damage effects
/obj/structure/xeno/acid_maw/proc/maw_impact(datum/maw_ammo/ammo, turf/target, mob/living/user)
	ammo.on_impact(target)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, reset_perspective)), 1 SECONDS)

/obj/structure/xeno/acid_maw/acid_jaws
	name = "acid jaws"
	desc = "A hole in the ground. Its walls are coated with resin and there is some smoke billowing out."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "jaws"
	bound_width = 32
	bound_height = 32
	bound_x = 0
	pixel_x = -16
	pixel_y = -16
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	minimap_icon = "acid_jaw"
	maw_options = list(
		/datum/maw_ammo/smoke/neuro,
		/datum/maw_ammo/smoke/acid_small,
		/datum/maw_ammo/xeno_fire,
	)
