/client/verb/spatialagent()
	set category = "Debug"
	set name = "Spawn Spatial Agent"
	set desc = "Spawns a Spatial Agent. Useful for debugging."

	if (!check_rights(R_DEBUG))
		return

	var/T = get_turf(usr)
	var/mob/living/carbon/human/sa/sa = new(T)
	sa.ckey = usr.ckey
	change_view(world.view)
	sa.name = "Spatial Agent"
	sa.real_name = "Spatial Agent"
	sa.voice_name = "Spatial Agent"
	sa.h_style = "Cut Hair"

	var/datum/job/J = new /datum/job/other/spatial_agent
	J.generate_equipment(sa)
	J.generate_entry_conditions(sa)

//Spatial Agent human.
/mob/living/human/sa
	status_flags = CANPUSH

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