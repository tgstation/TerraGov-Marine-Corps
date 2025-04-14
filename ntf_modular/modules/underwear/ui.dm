#define ui_inventory_extra "WEST:6,SOUTH+3:11"
#define ui_boxers "WEST:6,SOUTH+4:13"
#define ui_socks "WEST:6,SOUTH+5:15"
#define ui_shirt "WEST:6,SOUTH+6:17"
#define ui_bra "WEST+1:8,SOUTH+4:13"

/// Extra inventory list for underwear
/datum/hud/var/list/extra_inventory = list()

/datum/hud/var/extra_shown = FALSE

/datum/hud/Destroy()
	. = ..()
	QDEL_LIST(extra_inventory)

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style, ui_color, ui_alpha)
	. = ..()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/human/toggle/extra()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.screen_loc = ui_inventory_extra
	using.hud = src
	toggleable_inventory += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "underwear"
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.icon_state = "underwear"
	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_boxers
	inv_box.slot_id = SLOT_UNDERWEAR
	inv_box.hud = src
	extra_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "socks"
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.icon_state = "socks"
	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_socks
	inv_box.slot_id = SLOT_SOCKS
	inv_box.hud = src
	extra_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "shirt"
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.icon_state = "shirt"
	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_shirt
	inv_box.slot_id = SLOT_SHIRT
	inv_box.hud = src
	extra_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "bra"
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.icon_state = "bra"
	inv_box.icon_full = "template"
	inv_box.screen_loc = ui_bra
	inv_box.slot_id = SLOT_BRA
	inv_box.hud = src
	extra_inventory += inv_box

/atom/movable/screen/human/toggle/extra
	name = "Toggle Extra"
	icon_state = "toggle_extra"

/atom/movable/screen/human/toggle/extra/Click()

	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/M = usr.client.eye
			targetmob = M

	if(usr.hud_used.extra_shown && targetmob.hud_used)
		usr.hud_used.extra_shown = FALSE
		usr.client.screen -= targetmob.hud_used.extra_inventory
	else
		usr.hud_used.extra_shown = TRUE
		usr.client.screen += targetmob.hud_used.extra_inventory

	targetmob.hud_used.extra_inventory_update(usr)

/datum/hud/proc/extra_inventory_update()
	return

/datum/hud/human/extra_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used.extra_shown && screenmob.hud_used.inventory_shown && screenmob.hud_used.hud_shown)
		if(H.w_underwear)
			H.w_underwear.screen_loc = ui_boxers
			screenmob.client.screen += H.w_underwear
		if(H.w_socks)
			H.w_socks.screen_loc = ui_socks
			screenmob.client.screen += H.w_socks
		if(H.w_undershirt)
			H.w_undershirt.screen_loc = ui_shirt
			screenmob.client.screen += H.w_undershirt
		if(H.bra)
			H.bra.screen_loc = ui_bra
			screenmob.client.screen += H.bra
	else
		if(H.w_underwear)
			screenmob.client.screen -= H.w_underwear
		if(H.w_socks)
			screenmob.client.screen -= H.w_socks
		if(H.w_undershirt)
			screenmob.client.screen -= H.w_undershirt
		if(H.bra)
			screenmob.client.screen -= H.bra
