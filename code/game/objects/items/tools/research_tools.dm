// Tools used for research
/obj/item/tool/research
	///Skill type needed to use the tool
	var/skill_type = SKILL_MEDICAL
	///Skill level needed to use the tool
	var/skill_threshold = SKILL_MEDICAL_EXPERT

/obj/item/tool/research/xeno_analyzer
	name = "xenolinguistic analyzer"
	desc = "A tool translating communications with some alien species. Can be used to befriend Newt."
	icon = 'icons/obj/items/implants.dmi'
	icon_state = "implantcase-b"

/obj/item/tool/research/excavation_tool
	name = "subterrain scanner and excavator"
	desc = "A tool for locating and uncovering underground resources. Use \"unique action\" when near an excavation site."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "alien_drill"

/obj/item/tool/research/excavation_tool/unique_action(mob/user)
	. = ..()
	if(user.skills.getRating(skill_type) < skill_threshold)
		balloon_alert(user, "not skilled enough!")
		return

	if(!do_after(user, 10 SECONDS, NONE, user.loc, BUSY_ICON_FRIENDLY, null, PROGRESS_BRASS))
		return

	var/spawner_located = FALSE
	for(var/obj/effect/landmark/excavation_site_spawner/spawner_to_check AS in SSexcavation.active_spawners)
		if(get_dist(user, spawner_to_check) < 3)
			say(span_notice("<b>Excavation site found, escavating...</b>"))
			SSexcavation.excavate_site(spawner_to_check)
			spawner_located = TRUE

	if (!spawner_located)
		say(span_notice("<b>No excavation site found at location. Try moving closer to the nearest one on your map.</b>"))
