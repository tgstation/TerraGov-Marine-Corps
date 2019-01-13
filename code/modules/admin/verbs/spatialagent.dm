/client/proc/spatialagent()
    set category = "Debug"
    set name = "Spawn Spatial Agent"
    set desc = "Spawns a Spatial Agent. Useful for debugging."

    if (!holder)
        return

    if (!check_rights(R_DEBUG))
        return

    if(!ticker.current_state != GAME_STATE_PLAYING)
	   	if(alert("Are you sure? This will make the RA process you as a marine!",,"Yes","No") != "Yes")
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
    sa.add_language("English", 1)
    sa.add_language("Sainja", 0)
    sa.add_language("Xenomorph", 0)
    sa.add_language("Hivemind", 0)
    sa.add_language("Russian", 0)
    sa.add_language("Tradeband", 0)
    sa.add_language("Gutter", 0)

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

/mob/living/carbon/human/sa/verb/godmode()
	set name = "Toggle Godmode"
	set desc = "Enable or disable Godmode."
	set category = "Agent"

	status_flags ^= GODMODE
    to_chat(src, "<span class='notice'> God mode is now [status_flags & GODMODE ? "enabled" : "disabled"] </span>")

/mob/living/carbon/human/sa/verb/leave()
    set name = "Teleport Out"
    set desc = "Ghosts you and deletes your mob."
    set category = "Agent"

    ghost()
    qdel(sa)