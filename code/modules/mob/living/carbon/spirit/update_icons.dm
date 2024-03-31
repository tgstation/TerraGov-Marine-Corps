
/mob/living/carbon/spirit/regenerate_icons()
	if(!..())
		update_body_parts()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_back()
		update_transform()

//update whether our head item appears on our hud.
/mob/living/carbon/spirit/update_hud_head(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_head
		client.screen += I

//update whether our mask item appears on our hud.
/mob/living/carbon/spirit/update_hud_wear_mask(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_mask
		client.screen += I

//update whether our neck item appears on our hud.
/mob/living/carbon/spirit/update_hud_neck(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_neck
		client.screen += I

//update whether our back item appears on our hud.
/mob/living/carbon/spirit/update_hud_back(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_back
		client.screen += I
