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
	var/hit_weaken = 2 SECONDS
	///List for bodyparts that upon being hit cause the target to become weakened
	var/list/weaken_list = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	///List for bodyparts that upon being hit cause the target to become ensnared
	var/list/snare_list = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)

/datum/ammo/xeno/web/on_hit_mob(mob/victim, obj/projectile/proj)
	. = ..()
	if(!ishuman(victim))
		return
	playsound(get_turf(victim), sound(get_sfx("snap")), 30, falloff = 5)
	var/mob/living/carbon/human/human_victim = victim
	if(proj.def_zone == BODY_ZONE_HEAD)
		human_victim.blind_eyes(hit_eye_blind)
		human_victim.balloon_alert(human_victim, "The web blinds you!")
	else if(proj.def_zone in weaken_list)
		human_victim.apply_effect(hit_weaken, WEAKEN)
		human_victim.balloon_alert(human_victim, "The web knocks you down!")
	else if(proj.def_zone in snare_list)
		human_victim.Immobilize(hit_immobilize, TRUE)
		human_victim.balloon_alert(human_victim, "The web snares you!")

/datum/ammo/xeno/leash_ball
	icon_state = "widow_snareball"
	ping = "ping_x"
	damage_type = STAMINA
	ammo_behavior_flags = AMMO_SKIPS_ALIENS | AMMO_TARGET_TURF
	bullet_color = COLOR_PURPLE
	ping = null
	damage = 0
	armor_type = BIO
	shell_speed = 1.5
	accurate_range = 8
	max_range = 8

/datum/ammo/xeno/leash_ball/on_hit_turf(turf/T, obj/projectile/proj)
	drop_leashball(T.density ? proj.loc : T)

/datum/ammo/xeno/leash_ball/on_hit_mob(mob/victim, obj/projectile/proj)
	var/turf/T = get_turf(victim)
	drop_leashball(T.density ? proj.loc : T, proj.firer)

/datum/ammo/xeno/leash_ball/on_hit_obj(obj/O, obj/projectile/proj)
	var/turf/T = get_turf(O)
	if(T.density || (O.density && !(O.allow_pass_flags & PASS_PROJECTILE)))
		T = get_turf(proj)
	drop_leashball(T.density ? proj.loc : T, proj.firer)

/datum/ammo/xeno/leash_ball/do_at_max_range(turf/T, obj/projectile/proj)
	drop_leashball(T.density ? proj.loc : T)

/// This spawns a leash ball and checks if the turf is dense before doing so
/datum/ammo/xeno/leash_ball/proc/drop_leashball(turf/T)
	new /obj/structure/xeno/aoe_leash(get_turf(T), hivenumber)
