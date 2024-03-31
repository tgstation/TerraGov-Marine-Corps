/turf/closed
	name = ""
	layer = CLOSED_TURF_LAYER
	opacity = 1
	density = TRUE
	blocks_air = TRUE
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	rad_insulation = RAD_MEDIUM_INSULATION
	baseturfs = list(/turf/open/floor/rogue/naturalstone, /turf/open/transparent/openspace)
	var/above_floor
	var/wallpress = TRUE
	var/wallclimb = FALSE
	var/climbdiff = 0

/turf/closed/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!wallpress)
		return
	if(user == O && isliving(O))
		var/mob/living/L = O
		if(isanimal(L))
			var/mob/living/simple_animal/A = L
			if (!A.dextrous)
				return
		if(L.mobility_flags & MOBILITY_MOVE)
			wallpress(L)
			return

/turf/closed/proc/wallpress(mob/living/user)
	if(user.wallpressed)
		return
	if(!(user.mobility_flags & MOBILITY_STAND))
		return
	var/dir2wall = get_dir(user,src)
	if(!(dir2wall in GLOB.cardinals))
		return
	user.wallpressed = dir2wall
	user.update_wallpress_slowdown()
	user.visible_message("<span class='info'>[user] leans against [src].</span>")
	switch(dir2wall)
		if(NORTH)
			user.setDir(SOUTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = 20)
		if(SOUTH)
			user.setDir(NORTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = -10)
		if(EAST)
			user.setDir(WEST)
			user.set_mob_offsets("wall_press", _x = 12, _y = 0)
		if(WEST)
			user.setDir(EAST)
			user.set_mob_offsets("wall_press", _x = -12, _y = 0)

/turf/closed/proc/wallshove(mob/living/user)
	if(user.wallpressed)
		return
	if(!(user.mobility_flags & MOBILITY_STAND))
		return
	var/dir2wall = get_dir(user,src)
	if(!(dir2wall in GLOB.cardinals))
		return
	user.wallpressed = dir2wall
	user.update_wallpress_slowdown()
	switch(dir2wall)
		if(NORTH)
			user.setDir(NORTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = 20)
		if(SOUTH)
			user.setDir(SOUTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = -10)
		if(EAST)
			user.setDir(EAST)
			user.set_mob_offsets("wall_press", _x = 12, _y = 0)
		if(WEST)
			user.setDir(WEST)
			user.set_mob_offsets("wall_press", _x = -12, _y = 0)

/mob/living/proc/update_wallpress_slowdown()
	if(wallpressed)
		add_movespeed_modifier("wallpress", TRUE, 100, override = TRUE, multiplicative_slowdown = 3)
	else
		remove_movespeed_modifier("wallpress")

/turf/closed/Bumped(atom/movable/AM)
	..()
	if(density)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.dir == get_dir(H,src) && H.m_intent == MOVE_INTENT_RUN && !H.lying)
				H.Immobilize(10)
				H.apply_damage(15, BRUTE, "head", H.run_armor_check("head", "melee", damage = 15))
				H.toggle_rogmove_intent(MOVE_INTENT_WALK, TRUE)
				playsound(src, "genblunt", 100, TRUE)
				H.visible_message("<span class='warning'>[H] runs into [src]!</span>", "<span class='warning'>I run into [src]!</span>")
				addtimer(CALLBACK(H, /mob/living/carbon/human/.proc/Knockdown, 10), 10)

/turf/closed/Initialize()
	. = ..()
	if(above_floor)
		var/turf/open/transparent/openspace/target = get_step_multiz(src, UP)
		if(istype(target))
			target.ChangeTurf(above_floor)

/turf/closed/Destroy()
	if(above_floor)
		var/turf/above = get_step_multiz(src, UP)
		if(above)
			if(istype(above, above_floor))
				var/count
				for(var/D in GLOB.cardinals)
					var/turf/T = get_step(above, D)
					if(T)
						var/turf/closed/C = get_step_multiz(T, DOWN)
						if(istype(C))
							count++
					if(count >= 2)
						break
				if(count < 2)
					above.ScrapeAway()
	. = ..()

/turf/closed/attack_paw(mob/user)
	return attack_hand(user)

/turf/closed/attack_hand(mob/user)
	if(wallclimb)
		if(isliving(user))
			var/mob/living/L = user
			var/climbsound = 'sound/foley/climb.ogg'
			if(L.stat != CONSCIOUS)
				return
			var/turf/target = get_step_multiz(user, UP)
			if(!istype(target, /turf/open/transparent/openspace))
				to_chat(user, "<span class='warning'>I can't climb here.</span>")
				return
			if(!L.can_zTravel(target, UP))
				to_chat(user, "<span class='warning'>I can't climb there.</span>")
				return
			target = get_step_multiz(src, UP)
			if(!target || istype(target, /turf/closed) || istype(target, /turf/open/transparent/openspace))
				target = get_step_multiz(user.loc, UP)
				if(!target || !istype(target, /turf/open/transparent/openspace))
					to_chat(user, "<span class='warning'>I can't climb here.</span>")
					return
			for(var/obj/structure/F in target)
				if(F && (F.density && !F.climbable))
					to_chat(user, "<span class='warning'>I can't climb here.</span>")
					return
			var/used_time = 0
			if(L.mind)
				var/myskill = L.mind.get_skill_level(/datum/skill/misc/climbing)
				var/obj/structure/table/TA = locate() in L.loc
				if(TA)
					myskill += 1
				else
					var/obj/structure/chair/CH = locate() in L.loc
					if(CH)
						myskill += 1
					var/obj/structure/wallladder/WL = locate() in L.loc
					if(WL)
						if(get_dir(WL.loc,src) == WL.dir)
							myskill += 8
							climbsound = 'sound/foley/ladder.ogg'

				if(myskill < climbdiff)
					to_chat(user, "<span class='warning'>I can't climb here.</span>")
					return
				used_time = max(70 - (myskill * 10) - (L.STASPD * 3), 30)
			if(user.m_intent != MOVE_INTENT_SNEAK)
				playsound(user, climbsound, 100, TRUE)
			user.visible_message("<span class='warning'>[user] starts to climb [src].</span>", "<span class='warning'>I start to climb [src]...</span>")
			if(do_after(L, used_time, target = src))
				var/pulling = user.pulling
				if(ismob(pulling))
					user.pulling.forceMove(target)
				user.forceMove(target)
				user.start_pulling(pulling,supress_message = TRUE)
				if(user.m_intent != MOVE_INTENT_SNEAK)
					playsound(user, 'sound/foley/climb.ogg', 100, TRUE)
	else
		..()

/turf/closed/attack_ghost(mob/dead/observer/user)
	if(!user.Adjacent(src))
		return
	var/turf/target = get_step_multiz(user, UP)
	if(!target)
		to_chat(user, "<span class='warning'>I can't go there.</span>")
		return
	if(!istype(target, /turf/open/transparent/openspace))
		to_chat(user, "<span class='warning'>I can't go there.</span>")
		return
	user.forceMove(target)
	to_chat(user, "<span class='warning'>I crawl up the wall.</span>")
	. = ..()


/turf/closed/AfterChange()
	..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSCLOSEDTURF))
		return TRUE
	return ..()

/turf/closed/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	explosion_block = 50

/turf/closed/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/closed/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/closed/indestructible/singularity_act()
	return

/turf/closed/indestructible/oldshuttle
	name = "strange shuttle wall"
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "block"

/turf/closed/indestructible/sandstone
	name = "sandstone wall"
	desc = ""
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	baseturfs = /turf/closed/indestructible/sandstone
	smooth = SMOOTH_TRUE

/turf/closed/indestructible/oldshuttle/corner
	icon_state = "corner"

/turf/closed/indestructible/splashscreen
	name = ""
	icon = 'icons/default_title.dmi'
	icon_state = ""
	layer = FLY_LAYER
	bullet_bounce_sound = null

/turf/closed/indestructible/splashscreen/New()
	SStitle.splash_turf = src
	if(SStitle.icon)
		icon = SStitle.icon
	..()

/turf/closed/indestructible/splashscreen/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if("icon")
				SStitle.icon = icon

/turf/closed/indestructible/riveted
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "riveted"
	smooth = SMOOTH_TRUE

/turf/closed/indestructible/syndicate
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle"
	smooth = SMOOTH_MORE

/turf/closed/indestructible/riveted/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"

/turf/closed/indestructible/abductor
	icon_state = "alien1"

/turf/closed/indestructible/opshuttle
	icon_state = "wall3"

/turf/closed/indestructible/fakeglass
	name = "window"
	icon_state = "fake_window"
	opacity = 0
	smooth = SMOOTH_TRUE
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'

/turf/closed/indestructible/fakeglass/Initialize()
	. = ..()
	icon_state = null //set the icon state to null, so our base state isn't visible
	underlays += mutable_appearance('icons/obj/structures.dmi', "grille") //add a grille underlay
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating") //add the plating underlay, below the grille

/turf/closed/indestructible/opsglass
	name = "window"
	icon_state = "plastitanium_window"
	opacity = 0
	smooth = SMOOTH_TRUE
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'

/turf/closed/indestructible/opsglass/Initialize()
	. = ..()
	icon_state = null
	underlays += mutable_appearance('icons/obj/structures.dmi', "grille")
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating")

/turf/closed/indestructible/fakedoor
	name = "CentCom Access"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "fake_door"

/turf/closed/indestructible/rock
	name = "granite"
	desc = ""
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock2"

/turf/closed/indestructible/rock/snow
	name = "mountainside"
	desc = ""
	icon = 'icons/turf/walls.dmi'
	icon_state = "snowrock"
	bullet_sizzle = TRUE
	bullet_bounce_sound = null

/turf/closed/indestructible/rock/snow/ice
	name = "iced rock"
	desc = ""
	icon = 'icons/turf/walls.dmi'
	icon_state = "icerock"

/turf/closed/indestructible/paper
	name = "thick paper wall"
	desc = ""
	icon = 'icons/turf/walls.dmi'
	icon_state = "paperwall"

/turf/closed/indestructible/necropolis
	name = "necropolis wall"
	desc = ""
	icon = 'icons/turf/walls.dmi'
	icon_state = "necro"
	explosion_block = 50
	baseturfs = /turf/closed/indestructible/necropolis

/turf/closed/indestructible/necropolis/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "necro1"
	return TRUE

/turf/closed/indestructible/riveted/boss
	name = "necropolis wall"
	desc = ""
	icon = 'icons/turf/walls/boss_wall.dmi'
	icon_state = "wall"
	canSmoothWith = list(/turf/closed/indestructible/riveted/boss, /turf/closed/indestructible/riveted/boss/see_through)
	explosion_block = 50
	baseturfs = /turf/closed/indestructible/riveted/boss

/turf/closed/indestructible/riveted/boss/see_through
	opacity = FALSE

/turf/closed/indestructible/riveted/boss/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/closed/indestructible/riveted/hierophant
	name = "wall"
	desc = ""
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "wall"
