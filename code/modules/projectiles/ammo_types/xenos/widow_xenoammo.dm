/*
//================================================
					Widow Ammo Types
//================================================
*/

/datum/ammo/xeno/web
	icon_state = "web_spit"
	sound_hit = "snap"
	sound_bounce = "alien_resin_build3"
	damage_type = STAMINA
	bullet_color = COLOR_PURPLE
	ammo_behavior_flags = AMMO_SKIPS_ALIENS
	ping = null
	armor_type = BIO
	accurate_range = 15
	max_range = 15
	///For how long the victim will be blinded
	var/hit_eye_blind = 1
	///How long the victim will be snared for
	var/hit_immobilize = 2 SECONDS
	///How long the victim will be KO'd
	var/hit_paralyze = 2 SECONDS
	///List for bodyparts that upon being hit cause the target to become weakened
	var/list/paralyze_list = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	///List for bodyparts that upon being hit cause the target to become ensnared
	var/list/snare_list = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)

/datum/ammo/xeno/web/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	. = ..()
	if(!ishuman(target_mob))
		return
	playsound(get_turf(target_mob), sound(get_sfx("snap")), 30, falloff = 5)
	var/mob/living/carbon/human/human_victim = target_mob
	if(proj.def_zone == BODY_ZONE_HEAD)
		human_victim.blind_eyes(hit_eye_blind)
		human_victim.balloon_alert(human_victim, "The web blinds you!")
	else if(proj.def_zone in paralyze_list)
		human_victim.apply_effect(hit_paralyze, EFFECT_PARALYZE)
		human_victim.balloon_alert(human_victim, "The web knocks you down!")
	else if(proj.def_zone in snare_list)
		human_victim.Immobilize(hit_immobilize, TRUE)
		human_victim.balloon_alert(human_victim, "The web snares you!")

/datum/ammo/xeno/leash_ball
	icon_state = "widow_snareball"
	damage_type = STAMINA
	ammo_behavior_flags = AMMO_SKIPS_ALIENS | AMMO_TARGET_TURF
	bullet_color = COLOR_PURPLE
	ping = null
	damage = 0
	armor_type = BIO
	shell_speed = 1.5
	accurate_range = 8
	max_range = 8

/datum/ammo/xeno/leash_ball/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_leashball(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/leash_ball/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_mob)
	drop_leashball(target_turf.density ? proj.loc : target_turf, proj.firer)

/datum/ammo/xeno/leash_ball/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_obj)
	if(target_turf.density || (target_obj.density && !(target_obj.allow_pass_flags & PASS_PROJECTILE)))
		target_turf = get_turf(proj)
	drop_leashball(target_turf.density ? proj.loc : target_turf, proj.firer)

/datum/ammo/xeno/leash_ball/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_leashball(target_turf.density ? proj.loc : target_turf)

/// This spawns a leash ball and checks if the turf is dense before doing so
/datum/ammo/xeno/leash_ball/proc/drop_leashball(turf/target_turf)
	new /obj/structure/xeno/aoe_leash(get_turf(target_turf), hivenumber)
