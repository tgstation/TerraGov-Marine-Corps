/datum/campaign_asset/mech
	name = "Medium combat mech"
	desc = "One medium combat mech"
	detailed_desc = "Your battalion has been assigned a single Assault medium combat mech. The Assault mech features balanced armor and mobility, allowing it to keep up with infantry movements while still offering significant resilience. It is considered the general work horse combat mech."
	ui_icon = "medium_mech"
	uses = 1
	var/obj/effect/landmark/campaign/mech_spawner/spawner_type = /obj/effect/landmark/campaign/mech_spawner

/datum/campaign_asset/mech/activated_effect()
	for(var/obj/effect/landmark/campaign/mech_spawner/faction_spawner AS in GLOB.campaign_mech_spawners[faction.faction])
		if(faction_spawner.type == spawner_type)
			faction_spawner.spawn_mech()
			playsound(faction_spawner,'sound/effects/phasein.ogg', 80, FALSE)
			return

/datum/campaign_asset/mech/light
	name = "Light combat mech"
	desc = "One light combat mech"
	detailed_desc = "Your battalion has been assigned a single Recon light combat mech. The Recon mech is lightly armored but very nimble and is still capable of carrying a full suite of weapons. Commonly used for scouting, screening and flanking manoeuvres."
	ui_icon = "light_mech"
	spawner_type = /obj/effect/landmark/campaign/mech_spawner/light

/datum/campaign_asset/mech/heavy
	name = "Heavy combat mech"
	desc = "One heavy combat mech"
	detailed_desc = "Your battalion has been assigned a single Vanguard heavy combat mech. The Vanguard has extreme durability and offensive capability. Able to wade through the thickest of fighting with ease, it is the galaxy's premier frontline combat mech, although its speed and maneuverability are somewhat lackluster."
	ui_icon = "heavy_mech"
	spawner_type = /obj/effect/landmark/campaign/mech_spawner/heavy

/datum/campaign_asset/mech/som
	spawner_type = /obj/effect/landmark/campaign/mech_spawner/som

/datum/campaign_asset/mech/light/som
	spawner_type = /obj/effect/landmark/campaign/mech_spawner/som/light

/datum/campaign_asset/mech/heavy/som
	spawner_type = /obj/effect/landmark/campaign/mech_spawner/som/heavy

//mech spawn points
/obj/effect/landmark/campaign/mech_spawner
	name = "tgmc med mech spawner"
	icon_state = "mech"
	///Faction associated with this spawner
	var/faction = FACTION_TERRAGOV
	///Colours to paint mechs from this spawner
	var/list/colors = list(ARMOR_PALETTE_SPACE_CADET, ARMOR_PALETTE_GREYISH_TURQUOISE)
	///Colours to paint mech heads from this spawner for better visual clarity
	var/list/head_colors = list(ARMOR_PALETTE_STORM, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_SYNDIE_GREEN)
	///Mech type for this spawner
	var/obj/vehicle/sealed/mecha/combat/greyscale/mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/assault/noskill

/obj/effect/landmark/campaign/mech_spawner/Initialize(mapload)
	. = ..()
	GLOB.campaign_mech_spawners[faction] += list(src)

/obj/effect/landmark/campaign/mech_spawner/Destroy()
	GLOB.campaign_mech_spawners[faction] -= src
	return ..()

///Creates and sets up the mech
/obj/effect/landmark/campaign/mech_spawner/proc/spawn_mech()
	var/obj/vehicle/sealed/mecha/combat/greyscale/new_mech = new mech_type(loc)
	for(var/i in new_mech.limbs)
		var/datum/mech_limb/limb = new_mech.limbs[i]
		limb.update_colors(arglist(istype(limb, /datum/mech_limb/head) ? head_colors : colors))
	new_mech.update_icon()
	return new_mech

/obj/effect/landmark/campaign/mech_spawner/heavy
	name = "tgmc heavy mech spawner"
	icon_state = "mech_heavy"
	head_colors = list(ARMOR_PALETTE_RED, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_SYNDIE_GREEN)
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/mech_spawner/light
	name = "tgmc light mech spawner"
	icon_state = "mech_light"
	head_colors = list(ARMOR_PALETTE_SPACE_CADET, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_SYNDIE_GREEN)
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill

/obj/effect/landmark/campaign/mech_spawner/som
	name = "som med mech spawner"
	faction = FACTION_SOM
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_ANGELIC)
	head_colors = list(ARMOR_PALETTE_ANGELIC, ARMOR_PALETTE_GREY, VISOR_PALETTE_SYNDIE_GREEN)

/obj/effect/landmark/campaign/mech_spawner/som/heavy
	name = "som heavy mech spawner"
	icon_state = "mech_heavy"
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_MAGENTA)
	head_colors = list(ARMOR_PALETTE_MAGENTA, ARMOR_PALETTE_GRAPE, VISOR_PALETTE_ELITE_ORANGE)
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/mech_spawner/som/light
	name = "som light mech spawner"
	icon_state = "mech_light"
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_BLACK)
	head_colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_BLACK, VISOR_PALETTE_SYNDIE_GREEN)
	mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill
