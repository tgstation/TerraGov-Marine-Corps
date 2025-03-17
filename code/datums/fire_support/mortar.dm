/datum/fire_support/mortar
	name = "Mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_HE_MORTAR
	scatter_range = 8
	impact_quantity = 5
	cooldown_duration = 20 SECONDS
	uses = 6
	icon_state = "he_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, high explosive inbound!"
	initiate_title = "Rhino-1"
	initiate_sound = 'sound/weapons/guns/misc/mortar_travel.ogg'
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/tgmc_mortar
	start_visual = null
	start_sound = 'sound/weapons/guns/misc/mortar_long_whistle.ogg'

/datum/fire_support/mortar/do_impact(turf/target_turf)
	explosion(target_turf, 0, 2, 3, 5, 2, explosion_cause="mortar fire support")

/datum/fire_support/mortar/som
	fire_support_type = FIRESUPPORT_TYPE_HE_MORTAR_SOM
	initiate_title = "Guardian-1"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_mortar

/datum/fire_support/mortar/incendiary
	name = "Incendiary mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_INCENDIARY_MORTAR
	uses = 3
	icon_state = "incendiary_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, incendiary inbound!"

/datum/fire_support/mortar/incendiary/do_impact(turf/target_turf)
	explosion(target_turf, weak_impact_range = 4, flame_range = 5, throw_range = 0, explosion_cause="incen mortar fire support")
	playsound(target_turf, 'sound/weapons/guns/fire/flamethrower2.ogg', 35)

/datum/fire_support/mortar/incendiary/som
	fire_support_type = FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM
	initiate_title = "Guardian-1"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_mortar

/datum/fire_support/mortar/smoke
	name = "Smoke mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_SMOKE_MORTAR
	impact_quantity = 3
	uses = 2
	icon_state = "smoke_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, smoke inbound!"
	///smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke grenade will encompass
	var/smokeradius = 6
	///The duration of the smoke
	var/smoke_duration = 11

/datum/fire_support/mortar/smoke/do_impact(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(target_turf, SFX_EXPLOSION_SMALL, 50)
	playsound(target_turf, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(smokeradius, target_turf, smoke_duration)
	smoke.start()

/datum/fire_support/mortar/smoke/som
	fire_support_type = FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM
	initiate_title = "Guardian-1"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_mortar

/datum/fire_support/mortar/smoke/acid
	name = "Acid smoke mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR
	uses = 2
	icon_state = "acid_smoke_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, acid smoke inbound!"
	smoketype = /datum/effect_system/smoke_spread/xeno/acid/opaque
	smokeradius = 5

/datum/fire_support/mortar/smoke/satrapine
	name = "Satrapine mortar barrage"
	fire_support_type = FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR
	uses = 2
	icon_state = "satrapine_mortar"
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR BARRAGE INCOMING."
	initiate_screen_message = "Coordinates confirmed, satrapine inbound!"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_mortar
	smoketype = /datum/effect_system/smoke_spread/satrapine
	smokeradius = 5
