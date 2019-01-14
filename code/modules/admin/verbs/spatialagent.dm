/client/verb/spatialagent()
	set category = "Debug"
	set name = "Spawn Spatial Agent"
	set desc = "Spawns a Spatial Agent. Useful for debugging."

	if (!check_rights(R_DEBUG))
		return

	var/T = get_turf(usr)
	var/mob/living/carbon/human/sa/sa = new(T)
	sa.ckey = usr.ckey
	sa.name = "Spatial Agent"
	sa.real_name = "Spatial Agent"
	sa.voice_name = "Spatial Agent"
	sa.h_style = "Cut Hair"

	var/datum/job/J = new /datum/job/other/spatial_agent
	J.generate_equipment(sa)

	//Languages.
	sa.add_language("English")
	sa.add_language("Sainja")
	sa.add_language("Xenomorph")
	sa.add_language("Hivemind")
	sa.add_language("Russian")
	sa.add_language("Tradeband")
	sa.add_language("Gutter")

//Spatial Agent human.
/mob/living/human/sa
	status_flags = GODMODE|CANPUSH

//Verbs.
/mob/living/carbon/human/sa/verb/sarejuv()
	set name = "Rejuvenate"
	set desc = "Restores your health."
	set category = "Agent"
	set popup_menu = 0

	revive()

/mob/living/carbon/human/sa/verb/leave()
	set name = "Teleport Out"
	set desc = "Ghosts you and deletes your mob."
	set category = "Agent"

	ghost()
	qdel(src)