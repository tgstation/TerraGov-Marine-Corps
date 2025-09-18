/obj/effect/ai_node/spawner/zombie
	name = "tunnel"
	desc = "It reeks of rotten flesh and has stains of old blood and scratches."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "hole"
	invisibility = 0
	resistance_flags = UNACIDABLE|PLASMACUTTER_IMMUNE|PROJECTILE_IMMUNE
	spawntypes = list(
		/mob/living/carbon/human/species/zombie/ai/patrol = 80,
		/mob/living/carbon/human/species/zombie/ai/fast/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/tank/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/smoker/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/strong/patrol = 5,
	)
	spawnamount = 1
	spawndelay = 8 SECONDS
	maxamount = 15
	mob_decrement_signals = list(COMSIG_QDELETING)

/obj/effect/ai_node/spawner/zombie/Initialize(mapload)
	. = ..()
	GLOB.zombie_spawners += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "zombie_spawner"))

/obj/effect/ai_node/spawner/zombie/Destroy()
	. = ..()
	GLOB.zombie_spawners -= src
	SSminimaps.remove_marker(src)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ZOMBIE_TUNNEL_DESTROYED)

/obj/effect/ai_node/spawner/zombie/plastique_act()
	playsound(loc, 'sound/effects/meteorimpact.ogg', 35, 1)
	qdel(src)

/obj/effect/ai_node/spawner/zombie/examine(mob/user)
	. = ..()
	. += span_notice("It seems like you could collapse it with a plastique explosive.")
