/obj/item/deploy_capsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/item/capsules.dmi'
	w_class = WEIGHT_CLASS_TINY
	///The id we use to fetch the template datum
	var/template_id = "shelter_alpha"
	///The template datum we use to load the shelter
	var/datum/map_template/capsule/template
	///If true, this capsule is active and will deploy the area if conditions are met.
	var/active = FALSE
	///Will this capsule yeet mobs back once the area is deployed?
	var/yeet_back = TRUE

/obj/item/deploy_capsule/proc/get_template()
	if(template)
		return
	template = SSmapping.capsule_templates[template_id] //todo
	if(!template)
		WARNING("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/deploy_capsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

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
	if(active)
		return FALSE

	loc.visible_message(span_warning("[src] begins to shake. Stand back!"))
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(expand), user), 5 SECONDS)
	return TRUE

/obj/item/deploy_capsule/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(!active || user.next_move > world.time)
		return
	if(user.throw_item(target))
		user.changeNext_move(CLICK_CD_THROWING)

/// Expands the capsule into a full shelter, placing the template at the item's location (NOT triggerer's location)
/obj/item/deploy_capsule/proc/expand(mob/triggerer)
	if(QDELETED(src))
		return

	var/turf/deploy_location = get_turf(src)
	var/status = template.check_deploy(deploy_location, src, get_ignore_flags())
	if(status != SHELTER_DEPLOY_ALLOWED)
		fail_feedback(status)
		active = FALSE
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

		did_not_stand_back.Paralyze(3 SECONDS)
		did_not_stand_back.Knockdown(6 SECONDS)
		did_not_stand_back.safe_throw_at(get_edge_target_turf(did_not_stand_back, dir_to_center), throw_dist, 3, force = MOVE_FORCE_VERY_STRONG)

//Non-default pods

/obj/item/deploy_capsule/luxury
	name = "luxury bluespace shelter capsule"
	desc = "An exorbitantly expensive luxury suite stored within a pocket of bluespace."
	template_id = "capsule_1"

/obj/item/deploy_capsule/luxuryelite
	name = "luxury elite bar capsule"
	desc = "A luxury bar in a capsule. Bartender required and not included."
	template_id = "shelter_charlie"

/obj/item/deploy_capsule/bathroom
	name = "emergency relief capsule"
	desc = "Provides vital emergency support to employees who are caught short in the field."
	template_id = "shelter_toilet"
