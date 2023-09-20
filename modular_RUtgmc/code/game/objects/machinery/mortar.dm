/obj/item/mortar_kit/knee
	name = "\improper TA-10 knee mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 50mm shells on anything it's aimed at, typically best known as a 'Knee' mortar. Cannot be actually fired from your kneecaps, so it needs to be set down first to fire. Has a light payload, but an extremely high rate of fire."
	icon = 'modular_RUtgmc/icons/Marine/mortar.dmi'
	icon_state = "knee_mortar"
	max_integrity = 250
	w_class = WEIGHT_CLASS_NORMAL
	deployable_item = /obj/machinery/deployable/mortar/knee

/obj/machinery/deployable/mortar/knee
	offset_per_turfs = 12
	fire_sound = 'modular_RUtgmc/sound/weapons/guns/fire/kneemortar_fire.ogg'
	fall_sound = 'modular_RUtgmc/sound/weapons/guns/misc/kneemortar_whistle.ogg'
	minimum_range = 5
	allowed_shells = list(
		/obj/item/mortal_shell/knee,
		/obj/item/mortal_shell/flare,
	)

	cool_off_time = 4 SECONDS
	reload_time = 0.5 SECONDS
	fire_delay = 0.5 SECONDS
	max_spread = 6

/obj/item/mortal_shell/knee
	name = "\improper 50mm high explosive mortar shell"
	desc = "An 50mm mortar shell, loaded with a high explosive charge."
	icon = 'modular_RUtgmc/icons/Marine/mortar.dmi'
	icon_state = "knee_mortar_he"
	w_class = WEIGHT_CLASS_TINY
	ammo_type = /datum/ammo/mortar/knee
