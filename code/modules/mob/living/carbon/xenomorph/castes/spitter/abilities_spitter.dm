// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line
	name = "Spray Acid"
	desc = "Spray a line of dangerous acid at your target."
	ability_cost = 250
	cooldown_duration = 30 SECONDS

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
	var/turflist = getline(xeno_owner, target)
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

		acid_splat_turf(TF)

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

/datum/action/ability/activable/xeno/scatter_spit/use_ability(atom/target)
	if(!do_after(xeno_owner, 0.5 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	//Shoot at the thing
	playsound(xeno_owner.loc, 'sound/effects/blobattack.ogg', 50, 1)

	var/datum/ammo/xeno/acid/heavy/scatter/scatter_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/scatter]

	var/obj/projectile/newspit = new /obj/projectile(get_turf(xeno_owner))
	newspit.generate_bullet(scatter_spit, scatter_spit.damage * SPIT_UPGRADE_BONUS(xeno_owner))
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
#define GLOBADIER_GRENADE_REGEN_COOLDOWN 10 SECONDS
#define GLOBADIER_GRENADE_THROW_RANGE 8
#define GLOBADIER_GRENADE_THROW_SPEED 2
//Grenade Defines, for the radial menu
#define ACID_GRENADE /obj/item/explosive/grenade/globadier
#define FIRE_GRENADE /obj/item/explosive/grenade/globadier/incen
#define RESIN_GRENADE /obj/item/explosive/grenade/globadier/resin
//List of all images used for grenades, in the radial selection menu
GLOBAL_LIST_INIT(globadier_images_list, list(
	ACID_GRENADE = image('icons/xeno/effects.dmi', icon_state = "acid"),
	FIRE_GRENADE = image('icons/effects/fire.dmi', icon_state = "purple_3"),
	RESIN_GRENADE = image('icons/xeno/effects.dmi', icon_state = "sticky"),
))

/datum/action/ability/activable/xeno/toss_grenade
	name = "Toss Grenade"
	action_icon_state = "glob_grenade"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Toss a biological grenade at your target. Has various effects depending on selection, right click to select which grenade to use. Stores up to 5 uses."
	var/current_grenades = 5
	var/max_grenades = 5
	var/selected_grenade = /obj/item/explosive/grenade/globadier
	cooldown_duration = 2 SECONDS
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOSS_GRENADE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_PICK_GRENADE,
	)

/datum/action/ability/activable/xeno/toss_grenade/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[current_grenades]/[max_grenades]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER] = counter_maptext

/datum/action/ability/activable/xeno/toss_grenade/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER])
	visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER] = null

/datum/action/ability/activable/xeno/toss_grenade/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER]
	number.maptext = MAPTEXT("[current_grenades]/[max_grenades]")
	visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER] = number
	button.add_overlay(visual_references[VREF_MUTABLE_GLOB_GRENADES_COUNTER])
	return ..()

//Handle automatic regeneration of grenades, every GLOBADIER_GRENADE_REGEN_COOLDOWN seconds
/datum/action/ability/activable/xeno/toss_grenade/proc/regen_grenade()
	if(current_grenades < max_grenades)
		current_grenades++
		update_button_icon()
		if(current_grenades < max_grenades) //If we still have less than the total amount of grenades, call the timer again to add another grenade in 10s
			addtimer(CALLBACK(src, PROC_REF(regen_grenade)), GLOBADIER_GRENADE_REGEN_COOLDOWN, TIMER_UNIQUE)

/datum/action/ability/activable/xeno/toss_grenade/use_ability(atom/target)
	if(current_grenades <= 0)
		owner.balloon_alert(owner, "No Grenades!")
		return fail_activate()
	var/obj/item/explosive/grenade/globadier/nade = new selected_grenade(owner.loc)
	nade.activate(owner)
	nade.throw_at(target,GLOBADIER_GRENADE_THROW_RANGE,GLOBADIER_GRENADE_THROW_SPEED)
	owner.visible_message(span_xenowarning("\The [owner] throws something towards \the [target]!"), \
	span_xenowarning("We throw a grenade towards \the [target]!"))
	current_grenades--
	addtimer(CALLBACK(src, PROC_REF(regen_grenade)), GLOBADIER_GRENADE_REGEN_COOLDOWN, TIMER_UNIQUE)
	update_button_icon()
	succeed_activate()
	add_cooldown()

// Handles selecting which grenade the xeno wants
/datum/action/ability/activable/xeno/toss_grenade/alternate_action_activate()
	var/grenade_choice = show_radial_menu(owner, owner, GLOB.globadier_images_list, radius = 48)
	if(!grenade_choice)
		return
	selected_grenade = grenade_choice

// ***************************************
// *********** Acid Grenade
// ***************************************

/obj/item/explosive/grenade/globadier
	name = "Acidic Grenade"
	desc = "A gross looking glob of acid"
	greyscale_colors = "#81ff92"
	greyscale_config = /datum/greyscale_config/xenogrenade
	det_time = 2 SECONDS
	dangerous = TRUE
	arm_sound = 'sound/voice/alien/yell_alt.ogg'
	var/acid_damage = 40

/obj/item/explosive/grenade/globadier/prime()
	for(var/acid_tile in filled_turfs(get_turf(src), 0.5, "circle", air_pass = TRUE))
		new /obj/effect/temp_visual/acid_splatter(acid_tile)
		new /obj/effect/xenomorph/spray(acid_tile, 5 SECONDS, acid_damage)
	qdel(src)

/obj/item/explosive/grenade/globadier/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")

// ***************************************
// *********** Fire Grenade
// ***************************************
/obj/item/explosive/grenade/globadier/incen
	name = "Melting Grenade"
	desc = "A swirling mix of acid and purple sparks"
	greyscale_colors = "#9e1dd1"


/obj/item/explosive/grenade/globadier/incen/prime()
	flame_radius(0.5, get_turf(src), fire_type = /obj/fire/melting_fire, burn_intensity = 20, burn_duration = 72, colour = "purple")
	qdel(src)

// ***************************************
// *********** Resin Grenade
// ***************************************
/obj/item/explosive/grenade/globadier/resin
	name = "Resin Grenade"
	desc = "A rapidly melting ball of xeno taffy"
	greyscale_colors = "#6808e6"


/obj/item/explosive/grenade/globadier/resin/prime()
	for(var/resin_tile in filled_turfs(get_turf(src), 0.5, "circle", air_pass = TRUE))
		new /obj/alien/resin/sticky/thin(resin_tile)
	qdel(src)

// ***************************************
// *********** Acid Mine
// ***************************************
/datum/action/ability/xeno_action/acid_mine
	name = "Acid Mine"
	action_icon_state = "acid_mine"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Place an acid mine at your location"
	cooldown_duration = 5 SECONDS
	ability_cost = 150
	var/mine_type = /obj/structure/xeno/acid_mine
	var/max_charges = 5
	var/current_charges = 5
var/regen_time = 90 SECONDS
	var/vref = VREF_MUTABLE_ACID_MINES_COUNTER
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_MINE,
	)

/datum/action/ability/xeno_action/acid_mine/proc/regen_mine()
	if(current_charges < max_charges)
		current_charges++
		update_button_icon()
		if(current_charges < max_charges) //If we still have less than the total amount of mines, call the timer again to add another mine after the regen time
			addtimer(CALLBACK(src, PROC_REF(regen_mine)), regen_time, TIMER_UNIQUE)

/datum/action/ability/xeno_action/acid_mine/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, span_warning("We can't do that here."))
		return FALSE

	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			to_chat(owner, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
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

/datum/action/ability/xeno_action/acid_mine/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[vref])
	visual_references[vref] = null

/datum/action/ability/xeno_action/acid_mine/update_button_icon()
	button.cut_overlay(visual_references[vref])
	var/mutable_appearance/number = visual_references[vref]
	number.maptext = MAPTEXT("[current_charges]/[max_charges]")
	visual_references[vref] = number
	button.add_overlay(visual_references[vref])
	return ..()

/datum/action/ability/xeno_action/acid_mine/action_activate()
	if(current_charges <= 0)
		owner.balloon_alert(owner, "No Mines!")
		return fail_activate()
	var/turf/T = get_turf(owner)
	new mine_type(T)
	current_charges--
	playsound(T, SFX_ALIEN_RESIN_BUILD, 25)
	addtimer(CALLBACK(src, PROC_REF(regen_mine)), regen_time, TIMER_UNIQUE)
	update_button_icon()
	succeed_activate()

// ***************************************
// *********** Gas Mine
// ***************************************
/datum/action/ability/xeno_action/acid_mine/gas_mine
	name = "Gas Mine"
	desc = "Place an gas mine at your location"
	cooldown_duration = 5 SECONDS
	ability_cost = 200
	mine_type = /obj/structure/xeno/acid_mine/gas_mine
	max_charges = 2
	current_charges = 2
	regen_time = 2 MINUTES
	vref = VREF_MUTABLE_GAS_MINES_COUNTER
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GAS_MINE,
	)

// ***************************************
// *********** Acid Rocket
// ***************************************

/datum/action/ability/activable/xeno/acid_rocket
	name = "Acid Rocket"
	action_icon_state = "xadar"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	desc = "Fire an acid rocket, costing 30% of your current health and plasma, and dealing heavy damage where you aim it."
	cooldown_duration = 1 MINUTES
	ability_cost = 400
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_ROCKET,
	)
