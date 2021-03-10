/obj/item/clothing/suit/storage/marine/harness/boomvest
	name = "\improper Tactical Explosive Vest"
	desc = "Obviously someone just strapped a bomb to a marine harness and called it tactical. The light has been removed, and its switch used as the detonator <span class='notice'> Control-Click to set a warcry.</span> <span class='warning'>This harness has no light, toggling it will detonate the vest!</span>"
	icon_state = "boom_vest"
	flags_item_map_variant = NONE
	flags_armor_features = NONE
	var/bomb_message = ""

//boom
/obj/item/clothing/suit/storage/marine/harness/boomvest/attack_self(mob/user)
	user.say("[bomb_message]!!")
	explosion(loc, light_impact_range = 8, small_animation = TRUE)
	qdel(src)

//Gets a warcry to scream on Control Click
/obj/item/clothing/suit/storage/marine/harness/boomvest/CtrlClick(mob/user)
	var/new_bomb_message = input(user, "Select Warcry", "Warcry", "") as text|null
	bomb_message = new_bomb_message