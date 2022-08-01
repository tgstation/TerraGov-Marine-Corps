/// Temporary visual effects
/atom/movable/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 1 SECONDS
	var/randomdir = TRUE
	var/timerid


/atom/movable/effect/temp_visual/Initialize()
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinals))

	timerid = QDEL_IN(src, duration)


/atom/movable/effect/temp_visual/Destroy()
	deltimer(timerid)
	return ..()


/atom/movable/effect/temp_visual/ex_act()
	return


/atom/movable/effect/temp_visual/dir_setting
	randomdir = FALSE


/atom/movable/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	return ..()


///Image that appears at the Xeno Rally target; only Xenos can see it
/atom/movable/effect/temp_visual/xenomorph/xeno_tracker_target
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

/atom/movable/effect/temp_visual/xenomorph/xeno_tracker_target/Initialize(mapload, atom/target)
	. = ..()
	prepare_huds()
	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds) //Add to the xeno tachud
		xeno_tac_hud.add_to_hud(src)
	hud_set_xeno_tracker_target(target)

/atom/movable/effect/temp_visual/xenomorph/xeno_tracker_target/Destroy()
	if(tracker_target && holder) //Check to avoid runtimes
		tracker_target.overlays -= holder //remove the overlay
	for(var/datum/atom_hud/xeno_tactical/xeno_tac_hud in GLOB.huds)
		xeno_tac_hud.remove_from_hud(src)
	tracker_target = null //null the target var
	QDEL_NULL(holder) //remove the holder and null the var
	return ..()

/atom/movable/effect/temp_visual/xenomorph/xeno_tracker_target/proc/hud_set_xeno_tracker_target(atom/target)
	holder = hud_list[XENO_TACTICAL_HUD]
	if(!holder)
		return
	holder.icon = 'icons/Marine/marine-items.dmi'
	holder.icon_state = "detector_blip"
	tracker_target = target
	tracker_target.overlays += holder
	hud_list[XENO_TACTICAL_HUD] = holder
