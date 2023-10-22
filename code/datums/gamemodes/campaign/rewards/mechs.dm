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
