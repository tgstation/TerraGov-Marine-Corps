// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line
	name = "Spray Acid"
	desc = "Spray a line of dangerous acid at your target."
	ability_cost = 250
	cooldown_duration = 30 SECONDS
	/// If the owner makes use of and has this much stored globs, non-opaque gas is created along with the acid. Must be non-zero.
	var/gaseous_spray_threshold = 0

/datum/action/ability/activable/xeno/spray_acid/line/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	xeno_owner.face_atom(target) //Face target so we don't look stupid

	if(xeno_owner.do_actions || !do_after(xeno_owner, 5, NONE, target, BUSY_ICON_DANGER))
		return

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	succeed_activate()

	playsound(xeno_owner.loc, 'sound/effects/refill.ogg', 50, 1)
	var/turflist = get_line(xeno_owner, target) //todo: use get_traversal_line and change spray_turfs to use get_dist_euclidean for range
	spray_turfs(turflist)
	add_cooldown()

	GLOB.round_statistics.spitter_acid_sprays++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "spitter_acid_sprays")


/datum/action/ability/activable/xeno/spray_acid/line/proc/spray_turfs(list/turflist)
	set waitfor = FALSE

	if(isnull(turflist))
		return

	var/turf/prev_turf
	var/distance = 0

	for(var/X in turflist)
		var/turf/T = X

		if(!prev_turf && length(turflist) > 1)
			prev_turf = get_turf(owner)
			continue //So we don't burn the tile we be standin on

		for(var/obj/structure/barricade/B in prev_turf)
			if(get_dir(prev_turf, T) & B.dir)
				B.acid_spray_act(owner)

		if(T.density || isspaceturf(T))
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(is_type_in_typecache(O, GLOB.acid_spray_hit) && O.acid_spray_act(owner))
				return // returned true if normal density applies
			if(O.density && !(O.allow_pass_flags & PASS_PROJECTILE) && !(O.atom_flags & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_turf.Adjacent(T) && (T.x != prev_turf.x || T.y != prev_turf.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_turf.x, T.y, prev_turf.z)
			var/turf/Tx = locate(T.x, prev_turf.y, prev_turf.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_turf.Adjacent(TB) && !TB.density && !isspaceturf(TB))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		for(var/obj/structure/barricade/B in TF)
			if(get_dir(TF, prev_turf) & B.dir)
				B.acid_spray_act(owner)

		xenomorph_spray(TF, xeno_owner.xeno_caste.acid_spray_duration, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner, TRUE, TRUE)
		var/current_globs = xeno_owner.corrosive_ammo + xeno_owner.neurotoxin_ammo
		if(xeno_owner.ammo && gaseous_spray_threshold && current_globs >= gaseous_spray_threshold)
			var/datum/effect_system/smoke_spread/xeno/smoke
			switch(xeno_owner.ammo.type)
				if(/datum/ammo/xeno/boiler_gas/corrosive, /datum/ammo/xeno/boiler_gas/corrosive/lance)
					smoke = new /datum/effect_system/smoke_spread/xeno/acid()
				if(/datum/ammo/xeno/boiler_gas, /datum/ammo/xeno/boiler_gas/lance)
					smoke = new /datum/effect_system/smoke_spread/xeno/neuro/light()
			if(smoke)
				smoke.set_up(0, TF)
				smoke.start()

		distance++
		if(distance > 7 || blocked)
			break

		prev_turf = T
		sleep(0.2 SECONDS)

/datum/action/ability/activable/xeno/spray_acid/line/on_cooldown_finish() //Give acid spray a proper cooldown notification
	to_chat(owner, span_xenodanger("Our dermal pouches bloat with fresh acid; we can use acid spray again."))
	owner.playsound_local(owner, 'sound/voice/alien/drool2.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Scatterspit
// ***************************************
/datum/action/ability/activable/xeno/scatter_spit
	name = "Scatter Spit"
	action_icon_state = "scatter_spit"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Spits a spread of acid projectiles that splatter on the ground."
	ability_cost = 280
	cooldown_duration = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCATTER_SPIT,
	)
	/// The amount of deciseconds for the do_after.
	var/cast_time = 0.5 SECONDS
	/// Should the projectile get bonus damage from SPIT_UPGRADE_BONUS?
	var/should_get_upgrade_bonus = TRUE

/datum/action/ability/activable/xeno/scatter_spit/use_ability(atom/target)
	if(cast_time > 0 && !do_after(xeno_owner, cast_time, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	//Shoot at the thing
	playsound(xeno_owner.loc, 'sound/effects/blobattack.ogg', 50, 1)

	var/datum/ammo/xeno/acid/heavy/scatter/scatter_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/scatter]

	var/atom/movable/projectile/newspit = new /atom/movable/projectile(get_turf(xeno_owner))
	newspit.generate_bullet(scatter_spit, scatter_spit.damage * (should_get_upgrade_bonus ? SPIT_UPGRADE_BONUS(xeno_owner) : 0)) // Note: This spit upgrade bonus only applies to the main projectile. Making it apply to the bonus projectiles would be a damage increase of 54/72.
	newspit.def_zone = xeno_owner.get_limbzone_target()

	newspit.fire_at(target, xeno_owner, xeno_owner, newspit.ammo.max_range)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.spitter_scatter_spits++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "spitter_scatter_spits")

/datum/action/ability/activable/xeno/scatter_spit/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our auxiliary sacks fill to bursting; we can use scatter spit again."))
	owner.playsound_local(owner, 'sound/voice/alien/drool1.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Acid Grenade
// ***************************************
// Cooldown between recharging grenades
#define GLOBADIER_GRENADE_REGEN_COOLDOWN 15 SECONDS
/// How much extra time is added to a grenades fuse when it is picked up
#define GLOBADIER_GRENADE_PICKUP_CD 1.5 SECONDS
/// Range that globadier can throw grenades
#define GLOBADIER_GRENADE_THROW_RANGE 7
/// Speed at which grenades fly when thrown
#define GLOBADIER_GRENADE_THROW_SPEED 1.8
//Grenade Defines, for the radial menu
#define ACID_GRENADE /obj/item/explosive/grenade/globadier
#define FIRE_GRENADE /obj/item/explosive/grenade/globadier/incen
#define RESIN_GRENADE /obj/item/explosive/grenade/globadier/resin
#define GAS_GRENADE /obj/item/explosive/grenade/globadier/gas
#define HEAL_GRENADE /obj/item/explosive/grenade/globadier/heal
//List of all images used for grenades, in the radial selection menu
GLOBAL_LIST_INIT(globadier_images_list, list(
	ACID_GRENADE = image('icons/xeno/effects.dmi', icon_state = "acid"),
	FIRE_GRENADE = image('icons/effects/fire.dmi', icon_state = "purple_3"),
	RESIN_GRENADE = image('icons/xeno/effects.dmi', icon_state = "sticky"),
	GAS_GRENADE = image('icons/effects/effects.dmi', icon_state = "smoke"),
	HEAL_GRENADE = image('icons/effects/effects.dmi', icon_state = "mech_toxin"),
))

/datum/action/ability/activable/xeno/toss_grenade
	name = "Toss Grenade"
	action_icon_state = "glob_grenade"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Toss a biological grenade at your target. Has various effects depending on selection, right click to select which grenade to use. Stores up to 6 uses."
	cooldown_duration = 2 SECONDS
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOSS_GRENADE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_PICK_GRENADE,
	)
	/// In exchange for using a grenade while at none, the percentage of maximum health to lose.
	var/health_loss_percentage_per_grenade = 0
	/// The amount of deciseconds to add to the detonation if the grenade was thrown at themselves.
	var/bonus_self_detonation_time
	/// The current amount of grenades this ability has.
	var/current_grenades = 6
	/// The max amount of grenades this ability can store.
	var/max_grenades = 6
	/// The amount of deciseconds for the timer that will restore a grenade charge.
	var/grenade_cooldown = GLOBADIER_GRENADE_REGEN_COOLDOWN
	/// The timer used for restoring a grenade charge.
	var/timer

/datum/action/ability/activable/xeno/toss_grenade/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[current_grenades]/[max_grenades]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER] = counter_maptext

	var/mutable_appearance/timer_maptext = mutable_appearance(layer = ACTION_LAYER_MAPTEXT)
	timer_maptext.pixel_x = 16
	timer_maptext.pixel_y = 24
	timer_maptext.maptext = MAPTEXT("[timeleft(timer) ? "[round(timeleft(timer) / 10)]s" : ""]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER] = timer_maptext

/datum/action/ability/activable/xeno/toss_grenade/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER])
	visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER] = null

	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER])
	visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER] = null

/datum/action/ability/activable/xeno/toss_grenade/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER]
	number.maptext = MAPTEXT("[current_grenades]/[max_grenades]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER] = number
	button.add_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER])

	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER])
	var/mutable_appearance/time = visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER]
	time.maptext = MAPTEXT("[timeleft(timer) ? "[round(timeleft(timer) / 10)]s" : ""]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER] = time
	button.add_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER])
	return ..()

/datum/action/ability/activable/xeno/toss_grenade/use_ability(atom/target)
	if(current_grenades <= 0)
		// For balance reasons, no exchanging life for healing grenades. The reason: infinite healing grenades.
		if(!health_loss_percentage_per_grenade || xeno_owner.selected_grenade == /obj/item/explosive/grenade/globadier/heal)
			owner.balloon_alert(owner, "No grenades!")
			return fail_activate()
		var/health_to_lose = xeno_owner.xeno_caste.max_health * health_loss_percentage_per_grenade;
		if(xeno_owner.health_threshold_crit > xeno_owner.health - health_to_lose) // Hugbox to stop them from suiciding into critical.
			owner.balloon_alert(owner, "Not enough health!")
			return fail_activate()
		xeno_owner.adjustBruteLoss(health_to_lose, TRUE)
		current_grenades++
	var/obj/item/explosive/grenade/globadier/nade = new xeno_owner.selected_grenade(owner.loc, owner)
	if(xeno_owner == target && bonus_self_detonation_time)
		nade.det_time = max(0.5 SECONDS, nade.det_time + bonus_self_detonation_time)
	nade.activate(owner)
	nade.throw_at(target,GLOBADIER_GRENADE_THROW_RANGE,GLOBADIER_GRENADE_THROW_SPEED)
	owner.visible_message(span_xenowarning("\The [owner] throws something towards \the [target]!"), \
	span_xenowarning("We throw a grenade towards \the [target]!"))
	current_grenades--
	timer = addtimer(CALLBACK(src, PROC_REF(regen_grenade)), grenade_cooldown, TIMER_UNIQUE|TIMER_STOPPABLE)
	START_PROCESSING(SSprocessing, src)
	update_button_icon()
	succeed_activate()
	add_cooldown()
	GLOB.round_statistics.globadier_grenades_thrown++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "globadier_grenades_thrown")

/datum/action/ability/activable/xeno/toss_grenade/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(selectgrenade))


/datum/action/ability/activable/xeno/toss_grenade/process()
	if(!timeleft(timer))
		STOP_PROCESSING(SSprocessing, src)
		button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER])
		return
	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER])
	var/mutable_appearance/time = visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER]
	time.maptext = MAPTEXT("[timeleft(timer) ? "[round(timeleft(timer) / 10)]s" : ""]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER] = time
	button.add_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER])

/// Handle automatic regeneration of grenades. The cooldown is based on grenade_cooldown.
/datum/action/ability/activable/xeno/toss_grenade/proc/regen_grenade()
	if(!(current_grenades < max_grenades))
		return
	current_grenades++
	update_button_icon()
	if((current_grenades < max_grenades)) // Second if check as current_grenades has changed
		timer = addtimer(CALLBACK(src, PROC_REF(regen_grenade)), grenade_cooldown, TIMER_UNIQUE|TIMER_STOPPABLE)
		return
	owner.balloon_alert(owner, "Max Grenades!")

/// Handles selecting which grenade the xeno wants
/datum/action/ability/activable/xeno/toss_grenade/proc/selectgrenade()
	var/obj/item/explosive/grenade/globadier/grenade_choice = show_radial_menu(owner, owner, GLOB.globadier_images_list, radius = 48)
	if(!grenade_choice)
		return
	xeno_owner.selected_grenade = grenade_choice
	to_chat(xeno_owner, span_info("Grenade Effects: " + grenade_choice.select_message))
	to_chat(xeno_owner, span_info("Mine Effects: " + grenade_choice.mine_message))

// ***************************************
// *********** Acid Grenade
// ***************************************

/obj/item/explosive/grenade/globadier
	name = "acidic grenade"
	desc = "A gross looking glob of acid"
	greyscale_colors = "#81ff92"
	greyscale_config = /datum/greyscale_config/xenogrenade
	det_time = 1 SECONDS
	dangerous = TRUE
	arm_sound = 'sound/voice/alien/yell_alt.ogg'
	///The xenomorph that created this grenade
	var/mob/living/carbon/xenomorph/owner
	///The Mine that this grenade creates
	var/minetype = /obj/structure/xeno/acid_mine
	///What message is displayed when the grenade is selected
	var/select_message = "Detonates in a star pattern, spreading acid which deals damage to those that stay within it."
	var/mine_message = "Detonates in a 3x3, dealing heavy acid damage to those nearby"

/obj/item/explosive/grenade/globadier/prime()
	var/datum/effect_system/smoke_spread/xeno/acid/light/A = new(get_turf(src))
	A.set_up(0.5, src)
	A.start()
	for(var/acid_tile in filled_turfs(get_turf(src), 1, "square", pass_flags_checked = PASS_AIR))
		xenomorph_spray(acid_tile, 5 SECONDS, 40, null, TRUE)
	qdel(src)

/obj/item/explosive/grenade/globadier/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")

///Reset the timer of the grenade when its picked up
/obj/item/explosive/grenade/globadier/attack_hand(mob/living/user)
	if(active)
		var/curtime = timeleft(det_timer)
		deltimer(det_timer)
		det_timer = addtimer(CALLBACK(src, PROC_REF(prime)), min((curtime + GLOBADIER_GRENADE_PICKUP_CD), det_time), TIMER_STOPPABLE)
	. = ..()

///Assigns the xeno_owner to the grenade, for resin grenades
/obj/item/explosive/grenade/globadier/Initialize(mapload, _xeno_owner)
	. = ..()
	owner = _xeno_owner

// ***************************************
// *********** Fire Grenade
// ***************************************

/obj/item/explosive/grenade/globadier/incen
	name = "melting grenade"
	desc = "A swirling mix of lime and grape sparks"
	greyscale_colors = "#9e1dd1"
	det_time = 1.5 SECONDS
	minetype = /obj/structure/xeno/acid_mine/incen_mine
	select_message = "Detonates in a star pattern, spreading long lasting fire."
	mine_message = "Spreads a AOE of fire. Applies shatter every tick of the fire, on top of the damage."


/obj/item/explosive/grenade/globadier/incen/prime()
	flame_radius(0.5, get_turf(src), fire_type = /obj/fire/melting_fire/shattering, burn_intensity = 20, burn_duration = 144, colour = "violet")
	qdel(src)

// ***************************************
// *********** Resin Grenade
// ***************************************

/obj/item/explosive/grenade/globadier/resin
	name = "resin grenade"
	desc = "A rapidly melting ball of xeno taffy"
	greyscale_colors = "#6808e6"
	det_time = 1.5 SECONDS
	minetype = /obj/structure/xeno/acid_mine/resin_mine
	select_message = "Detonates in a star pattern, spreading thin resin, and launching you in your direction, while randomly launching nearby marines."
	mine_message = "Violently throws victims back, when detonated, and spreads thick sticky resin."

/obj/item/explosive/grenade/globadier/resin/prime()
	var/cannotbuild // Used to block resin placement if there is already resin on the tile
	for(var/turf/resin_tile in filled_turfs(get_turf(src), 0.5, "circle", pass_flags_checked = PASS_AIR))
		cannotbuild = FALSE
		if((resin_tile.density || istype(resin_tile, /turf/open/space))) // No structures in space
			continue

		for(var/obj/O in resin_tile.contents)
			if(istype(O, /obj/alien/resin))
				cannotbuild = TRUE

		if(!cannotbuild)
			new /obj/alien/resin/sticky/thin(resin_tile)
	for(var/mob/living/carbon/human/affected AS in cheap_get_humans_near(src,1))
		affected.drop_all_held_items()
		var/throwlocation = affected.loc
		for(var/x in 1 to 2)
			throwlocation = get_step(throwlocation, pick(GLOB.alldirs))
		if(affected.stat == DEAD)
			continue
		affected.throw_at(throwlocation, 6, 1.5, src, TRUE)
	if(get_dist(owner.loc, loc) <= 1)
		var/throwloc = owner.loc
		for(var/x in 1 to 6)
			throwloc = get_step(throwloc, owner.dir)
			owner.throw_at(throwloc, 6, 1.6, src, TRUE)
	qdel(src)

// ***************************************
// *********** Gas Grenade
// ***************************************

/obj/item/explosive/grenade/globadier/gas
	name = "gas grenade"
	desc = "A smoking ball of acid"
	greyscale_colors = "#be340a"
	det_time = 1.5 SECONDS
	minetype = /obj/structure/xeno/acid_mine/neuro_mine
	select_message = "Spreads thin neurotoxin gas over a large area, when detonated."
	mine_message = "Spreads thick neurotoxin gas when detonated, and injects its victim with neurotoxin."

/obj/item/explosive/grenade/globadier/gas/prime()
	var/datum/effect_system/smoke_spread/xeno/neuro/light/A = new(get_turf(src))
	A.set_up(2, src)
	A.start()
	qdel(src)

// ***************************************
// *********** Healing Grenade
// ***************************************

/obj/item/explosive/grenade/globadier/heal
	name = "healing grenade"
	desc = "A shimmering orb of gelatin that glows with life."
	greyscale_colors = "#09ffde"
	det_time = 4 SECONDS
	minetype = /obj/structure/xeno/acid_mine/drain_mine
	select_message = "Detonates and heals nearby xenos, and applies melting to nearby humans."
	mine_message = "Debuffs its victim with a effect that grants life to any xeno that damages the victim"

/obj/item/explosive/grenade/globadier/heal/prime()
	for(var/turf/effect_tile in filled_turfs(get_turf(src), 1, "square", pass_flags_checked = PASS_AIR))
		new /obj/effect/temp_visual/heal(effect_tile)
	for(var/mob/living/carbon/human/nerd in cheap_get_humans_near(src,1))
		nerd.apply_status_effect(STATUS_EFFECT_MELTING, 2)
		nerd.apply_status_effect(STATUS_EFFECT_LIFEDRAIN, 1 SECONDS)
	for(var/mob/living/carbon/xenomorph/xeno AS in cheap_get_xenos_near(src,1))
		var/healamount = (25 + (xeno.recovery_aura * xeno.maxHealth * 0.03))
		HEAL_XENO_DAMAGE(xeno, healamount, FALSE)
		new /obj/effect/temp_visual/telekinesis(get_turf(xeno))
		if(owner.client)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
			personal_statistics.heals++
	qdel(src)

// ***************************************
// *********** Acid Mine
// ***************************************

/datum/action/ability/xeno_action/acid_mine
	name = "Place Mine"
	action_icon_state = "acid_mine"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Place an mine at your location. Its effects depend on your selected grenade"
	cooldown_duration = 5 SECONDS
	ability_cost = 150
	///How many mines the ability can store at max
	var/max_charges = 6
	///Current amount of mines stored
	var/current_charges = 6
	///Recharge time between generating new mines
	var/regen_time = 40 SECONDS
	///A reference to the VREF used to display the current / max charges on the ability
	var/vref = VREF_MUTABLE_ACID_MINES_COUNTER
	///A reference to the VREF used to display the abilites timer
	var/timervref = VREF_MUTABLE_ACID_MINE_TIMER
	///The timer the regen period uses
	var/timer
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_MINE,
	)

///Called every regen time seconds, increments the counter of mines & calls the timer again if there are still less than max mines
/datum/action/ability/xeno_action/acid_mine/proc/regen_mine()
	if(!(current_charges < max_charges))
		return
	current_charges++
	update_button_icon()
	if(current_charges < max_charges) //If we still have less than the total amount of mines, call the timer again to add another mine after the regen time
		timer = addtimer(CALLBACK(src, PROC_REF(regen_mine)), regen_time, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/action/ability/xeno_action/acid_mine/can_use_action(silent, override_flags, selecting)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			owner.balloon_alert(owner, "We can't do that here.")
		return FALSE

	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			owner.balloon_alert(owner, "We must be on weeds!")
		return FALSE

	if(!T.check_alien_construction(owner, silent, /obj/structure/xeno/trap) || !T.check_disallow_alien_fortification(owner, silent))
		return FALSE

/datum/action/ability/xeno_action/acid_mine/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[current_charges]/[max_charges]")
	visual_references[vref] = counter_maptext

	var/mutable_appearance/timer_maptext = mutable_appearance(layer = ACTION_LAYER_MAPTEXT)
	timer_maptext.pixel_x = 16
	timer_maptext.pixel_y = 24
	timer_maptext.maptext = MAPTEXT("[timeleft(timer) ? "[round(timeleft(timer) / 10)]s" : ""]")
	visual_references[timervref] = timer_maptext

/datum/action/ability/xeno_action/acid_mine/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[vref])
	visual_references[vref] = null

	button.cut_overlay(visual_references[timervref])
	visual_references[timervref] = null

/datum/action/ability/xeno_action/acid_mine/update_button_icon()
	button.cut_overlay(visual_references[vref])
	var/mutable_appearance/number = visual_references[vref]
	number.maptext = MAPTEXT("[current_charges]/[max_charges]")
	visual_references[vref] = number
	button.add_overlay(visual_references[vref])

	button.cut_overlay(visual_references[timervref])
	var/mutable_appearance/time = visual_references[timervref]
	time.maptext = MAPTEXT("[timeleft(timer) ? "[round(timeleft(timer) / 10)]s" : ""]")
	visual_references[timervref] = time
	button.add_overlay(visual_references[timervref])
	return ..()

/datum/action/ability/xeno_action/acid_mine/action_activate()
	if(current_charges <= 0)
		owner.balloon_alert(owner, "No Mines!")
		return fail_activate()
	var/turf/T = get_turf(owner)
	new xeno_owner.selected_grenade.minetype(T)
	current_charges--
	playsound(T, SFX_ALIEN_RESIN_BUILD, 25)
	timer = addtimer(CALLBACK(src, PROC_REF(regen_mine)), regen_time, TIMER_UNIQUE|TIMER_STOPPABLE)
	START_PROCESSING(SSprocessing, src)
	update_button_icon()
	succeed_activate()
	add_cooldown()
	GLOB.round_statistics.globadier_mines_placed++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "globadier_mines_placed")

/datum/action/ability/xeno_action/acid_mine/process()
	if(!timeleft(timer))
		STOP_PROCESSING(SSprocessing, src)
		button.cut_overlay(visual_references[timervref])
		return
	button.cut_overlay(visual_references[timervref])
	var/mutable_appearance/time = visual_references[timervref]
	time.maptext = MAPTEXT("[timeleft(timer) ? "[round(timeleft(timer) / 10)]s" : ""]")
	visual_references[timervref] = time
	button.add_overlay(visual_references[timervref])

// ***************************************
// *********** Gas Mine
// ***************************************
/datum/action/ability/xeno_action/acid_mine/gas_mine
	name = "Gas Mine"
	desc = "Place an gas mine at your location"
	ability_cost = 200
	max_charges = 3
	current_charges = 3
	regen_time = 80 SECONDS
	vref = VREF_MUTABLE_GAS_MINES_COUNTER
	timervref = VREF_MUTABLE_GAS_MINE_TIMER
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GAS_MINE,
	)

/datum/action/ability/xeno_action/acid_mine/gas_mine/action_activate()
	if(current_charges <= 0)
		owner.balloon_alert(owner, "No Mines!")
		return fail_activate()
	var/turf/T = get_turf(owner)
	new /obj/structure/xeno/acid_mine/gas_mine(T)
	current_charges--
	playsound(T, SFX_ALIEN_RESIN_BUILD, 25)
	timer = addtimer(CALLBACK(src, PROC_REF(regen_mine)), regen_time, TIMER_UNIQUE|TIMER_STOPPABLE)
	START_PROCESSING(SSprocessing, src)
	update_button_icon()
	succeed_activate()
	add_cooldown()
	GLOB.round_statistics.globadier_mines_placed++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "globadier_mines_placed")

// ***************************************
// *********** Acid Rocket
// ***************************************
#define GLOBADIER_XADAR_PERCENT_HEALTH_PLAS_COST 0.3 // 30%
/datum/action/ability/activable/xeno/acid_rocket
	name = "Acid Rocket"
	action_icon_state = "xadar"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Fire an acid rocket, costing 30% of your current health and plasma, and dealing heavy damage where you aim it."
	cooldown_duration = 2 MINUTES
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_ROCKET,
	)

/datum/action/ability/activable/xeno/acid_rocket/use_ability(atom/target)
	if(!do_after(xeno_owner, 0.8 SECONDS, NONE, xeno_owner, BUSY_ICON_DANGER))
		return fail_activate()

	if(!prob(1))
		playsound(xeno_owner.loc, 'sound/effects/blobattack.ogg', 50, 1)
	else
		playsound(xeno_owner.loc, 'sound/effects/kaboom.ogg', 50, 1)

	var/datum/ammo/rocket/he/xadar/shell = GLOB.ammo_list[/datum/ammo/rocket/he/xadar]

	var/atom/movable/projectile/newshell = new(get_turf(xeno_owner))
	newshell.generate_bullet(shell)
	newshell.def_zone = xeno_owner.get_limbzone_target()

	newshell.fire_at(target, xeno_owner, xeno_owner, newshell.ammo.max_range)
	xeno_owner.adjustBruteLoss(xeno_owner.health * GLOBADIER_XADAR_PERCENT_HEALTH_PLAS_COST, TRUE)
	succeed_activate(xeno_owner.plasma_stored * GLOBADIER_XADAR_PERCENT_HEALTH_PLAS_COST)
	add_cooldown()
	GLOB.round_statistics.globadier_XADAR_fired++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "globadier_XADAR_fired")
