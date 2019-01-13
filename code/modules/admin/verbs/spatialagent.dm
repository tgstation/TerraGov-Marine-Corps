/client/verb/spatialagent()
    set category = "Debug"
    set name = "Spawn Spatial Agent"
    set desc = "Spawns a Spatial Agent. Useful for debugging."

    if (!check_rights(R_DEBUG))
        return

    if(ticker.current_state == 1)
	    to_chat(usr, "\red The round hasn't started yet!")
	    return

    var/T = get_turf(usr)
    var/mob/living/carbon/human/sa/sa = new(T)
    sa.anchored = 1
    sa.ckey = usr.ckey
    sa.name = "Spatial Agent"
    sa.real_name = "Spatial Agent"
    sa.voice_name = "Spatial Agent"
    sa.h_style = "Cut Hair"
    
	sa.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_commander/sa(sa), WEAR_BODY)
	sa.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/sa(sa), WEAR_FEET)
	sa.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/officer/chief/sa(sa), WEAR_HANDS)
	sa.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sa(sa), WEAR_EYES)
    sa.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(sa), WEAR_BACK)
    sa.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(sa), WEAR_WAIST)

    //Get the ID name sorted.
    var/obj/item/weapon/card/id/centcom/sa/id = new/obj/item/weapon/card/id/centcom/sa(sa)
    id.registered_name = sa.real_name
	id.assignment = "Spatial Agent"
	id.name = "[id.assignment]"
	sa.equip_to_slot_or_del(id, slot_wear_id)
	sa.update_inv_wear_id()

    //Languages.
    sa.add_language("English", 1)
    sa.add_language("Sainja", 0)
    sa.add_language("Xenomorph", 0)
    sa.add_language("Hivemind", 0)
    sa.add_language("Russian", 0)
    sa.add_language("Tradeband", 0)
    sa.add_language("Gutter", 0)

    //Skills.
    sa.mind.skills = /datum/skills/spatial_agent


//Spatial Agent human.
/mob/living/human/sa
        status_flags = GODMODE|CANPUSH

//Verbs.
/mob/living/carbon/human/sa/verb/sarejuv()
	set name = "Rejuvenate"
	set desc = "Restores your health."
	set category = "Agent"
	set popup_menu = 0

    src.revive()

/mob/living/carbon/human/sa/verb/godmode()
	set name = "Toggle Godmode"
	set desc = "Enable or disable Godmode."
	set category = "Agent"

	status_flags ^= GODMODE
    src << span("notice", "God mode is now [status_flags & GODMODE ? "enabled" : "disabled"]")

/mob/living/carbon/human/sa/verb/leave()
    set name = "Teleport Out"
    set desc = "Ghosts you and deletes your mob."
    set category = "Agent"

    ghost()
    qdel(sa)