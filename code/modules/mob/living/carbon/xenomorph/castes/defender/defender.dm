/mob/living/carbon/xenomorph/defender
	caste_base_type = /mob/living/carbon/xenomorph/defender
	name = "Defender"
	desc = "A alien with an armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Defender Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pull_speed = -2

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/defender/handle_special_state()
	if(fortify)
		icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Fortify"
		return TRUE
	if(crest_defense)
		icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Crest"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/defender/handle_special_wound_states(severity)
	. = ..()
	if(fortify)
		return "defender_wounded_fortify"
	if(crest_defense)
		return "defender_wounded_crest_[severity]"

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/defender/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && fortify) //No longer conscious.
		var/datum/action/xeno_action/fortify/FT = actions_by_path[/datum/action/xeno_action/fortify]
		FT.set_fortify(FALSE) //Fortify prevents dragging due to the anchor component.


// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/defender/Bump(atom/A)
	if(!throwing || !throw_source || !thrower)
		return ..()
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	var/extra_dmg = xeno_caste.melee_damage * xeno_melee_damage_modifier * 0.5 // 50% dmg reduction
	H.attack_alien_harm(src, extra_dmg, FALSE, TRUE, FALSE, TRUE) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, H, rand(1, 2)) //This is where we blast our target
	target_turf = get_step_rand(target_turf) //Scatter
	H.throw_at(get_turf(target_turf), 4, 70, H)
	H.Paralyze(40)


/mob/living/carbon/xenomorph/defender/lay_down()
	if(fortify) // Ensure the defender isn't fortified while laid down
		to_chat(src, span_warning("You can't do that right now."))
		return
	return ..()

/mob/living/carbon/xenomorph/defender/bullet_act(obj/projectile/proj)
	var/soft_armor_value = soft_armor.getRating("bullet")
	var/ammo_type = proj.ammo
	var/shot_from = proj.shot_from
	. = ..()
	if(proj.ammo.damage_type != BRUTE || !fortify || soft_armor_value < 100)
		return

	var/ricochet_angle = 360 - Get_Angle(proj.firer, loc)
	// Check for the neightbour tile
	var/rico_dir_check
	switch(ricochet_angle)
		if(-INFINITY to 45)
			rico_dir_check = EAST
		if(46 to 135)
			rico_dir_check = ricochet_angle > 90 ? SOUTH : NORTH
		if(136 to 225)
			rico_dir_check = ricochet_angle > 180 ? WEST : EAST
		if(126 to 315)
			rico_dir_check = ricochet_angle > 270 ? NORTH : SOUTH
		if(316 to INFINITY)
			rico_dir_check = WEST

	var/turf/next_turf = get_step(loc, rico_dir_check)
	if(next_turf.density)
		ricochet_angle += 180

	var/obj/projectile/new_proj = new(next_turf)
	new_proj.generate_bullet(ammo_type)
	new_proj.iff_signal = NONE
	new_proj.fire_at(null, src, shot_from, new_proj.proj_max_range, new_proj.projectile_speed, ricochet_angle, suppress_light = TRUE)
