/obj/item/deploy_capsule
	name = "mystery capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/items/capsules.dmi'
	w_class = WEIGHT_CLASS_TINY
	///The id we use to fetch the template datum
	var/template_id = "shelter_alpha"
	///The template datum we use to load the shelter
	var/datum/map_template/capsule/template
	///If true, this capsule is primed and will deploy the area if conditions are met.
	var/primed = FALSE
	///Will this capsule yeet mobs back once the area is deployed?
	var/yeet_back = TRUE

/obj/item/deploy_capsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	return ..()

/obj/item/deploy_capsule/examine(mob/user)
	. = ..()
	get_template()
	. += "This capsule has the [template.name] stored."
	. += template.description

/obj/item/deploy_capsule/interact(mob/living/user)
	. = ..()
	if(.)
		return .

	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(primed)
		return FALSE

	loc.visible_message(span_warning("[src] begins to shake. Stand back!"))
	var/expand_time = rand(3 SECONDS, 5 SECONDS)
	Shake(duration = expand_time)
	primed = TRUE
	addtimer(CALLBACK(src, PROC_REF(expand), user), 5 SECONDS)
	return TRUE

/obj/item/deploy_capsule/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(!primed || user.next_move > world.time)
		return
	if(user.throw_item(target))
		user.changeNext_move(CLICK_CD_THROWING)

///Gets the correct template for this capsule
/obj/item/deploy_capsule/proc/get_template()
	if(template)
		return
	template = SSmapping.capsule_templates[template_id]
	if(!template)
		WARNING("Shelter template ([template_id]) not found!")
		qdel(src)

/// Expands the capsule into a full shelter, placing the template at the item's location (NOT triggerer's location)
/obj/item/deploy_capsule/proc/expand(mob/triggerer)
	if(QDELETED(src))
		return

	var/turf/deploy_location = get_turf(src)
	var/status = template.check_deploy(deploy_location, src, get_ignore_flags())
	if(status != SHELTER_DEPLOY_ALLOWED)
		fail_feedback(status)
		primed = FALSE
		return

	if(yeet_back)
		yote_nearby(deploy_location)
	template.load(deploy_location, centered = TRUE)
	playsound(src, 'sound/effects/phasein.ogg', 100, TRUE)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	playsound(loc, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(floor((template.width + template.height) * 0.5), loc, 2)
	smoke.start()
	qdel(src)

/// Returns a bitfield used to ignore some checks in template.check_deploy()
/obj/item/deploy_capsule/proc/get_ignore_flags()
	return NONE

///Returns a message including the reason why it couldn't be deployed
/obj/item/deploy_capsule/proc/fail_feedback(status)
	switch(status)
		if(SHELTER_DEPLOY_BAD_AREA)
			loc.visible_message(span_warning("[src] will not function in this area."))
		if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS, SHELTER_DEPLOY_OUTSIDE_MAP, SHELTER_DEPLOY_BANNED_OBJECTS)
			loc.visible_message(span_warning("[src] doesn't have room to deploy! You need to clear a [template.width]x[template.height] area!"))

/// Throws any mobs near the deployed location away from the item / shelter
/// Does some math to make closer mobs get thrown further
/obj/item/deploy_capsule/proc/yote_nearby(turf/deploy_location)
	var/width = template.width
	var/height = template.height
	var/base_x_throw_distance = ceil(width / 2)
	var/base_y_throw_distance = ceil(height / 2)
	for(var/mob/living/did_not_stand_back in range(loc, "[width]x[height]"))
		var/dir_to_center = get_dir(deploy_location, did_not_stand_back) || pick(GLOB.alldirs)
		// Aiming to throw the target just enough to get them out of the range of the shelter
		// IE: Stronger if they're closer, weaker if they're further away
		var/throw_dist = 0
		var/x_component = abs(did_not_stand_back.x - deploy_location.x)
		var/y_component = abs(did_not_stand_back.y - deploy_location.y)
		if(ISDIAGONALDIR(dir_to_center))
			throw_dist = ceil(sqrt(base_x_throw_distance ** 2 + base_y_throw_distance ** 2) - (sqrt(x_component ** 2 + y_component ** 2)))
		else if(dir_to_center & (NORTH|SOUTH))
			throw_dist = base_y_throw_distance - y_component + 1
		else if(dir_to_center & (EAST|WEST))
			throw_dist = base_x_throw_distance - x_component + 1

		if(!isxeno(did_not_stand_back))
			did_not_stand_back.Paralyze(2 SECONDS)
		did_not_stand_back.safe_throw_at(get_edge_target_turf(did_not_stand_back, dir_to_center), throw_dist, 3, force = MOVE_FORCE_OVERPOWERING)

//Non-default pods

/obj/item/deploy_capsule/barricade
	name = "barricade fort capsule"
	desc = "A basic barricade fort in a convenient capsule form. Requires a 5x5 open area to deploy."
	template_id = "barricade_capsule"

/obj/item/deploy_capsule/barricade/get_ignore_flags()
	return CAPSULE_IGNORE_ANCHORED_OBJECTS
