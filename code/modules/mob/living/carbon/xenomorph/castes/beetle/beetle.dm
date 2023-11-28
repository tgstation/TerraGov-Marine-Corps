/mob/living/carbon/xenomorph/beetle
	caste_base_type = /mob/living/carbon/xenomorph/beetle
	name = "Beetle"
	desc = "A bulky, six-legged alien with a horn. Its carapace seems quite durable."
	icon = 'icons/Xeno/castes/beetle.dmi'
	icon_state = "Beetle Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -2

/mob/living/carbon/xenomorph/beetle/Bump(atom/A)
	if(!throwing || !throw_source || !thrower)
		return ..()
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	var/extra_dmg = xeno_caste.melee_damage * xeno_melee_damage_modifier * 0.5 // 50% dmg reduction
	H.attack_alien_harm(src, extra_dmg, FALSE, TRUE, FALSE, TRUE) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, H, rand(1, 2)) //This is where we blast our target
	target_turf = get_step_rand(target_turf) //Scatter
	H.throw_at(get_turf(target_turf), 4, 5, H)
	H.Paralyze(2 SECONDS)
