/obj/item/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/self_recharge = FALSE // If true, the cell will recharge itself.
	var/charge_amount = 25 // How much power to give, if self_recharge is true.  The number is in absolute cell charge, as it gets divided by CELLRATE later.
	var/last_use = 0 // A tracker for use in self-charging
	var/charge_delay = 0 // How long it takes for the cell to start recharging after last use
	///used to track what set of overlays to use to display charge level
	var/charge_overlay = "cell"
	materials = list(/datum/material/metal = 700, /datum/material/glass = 50)

/obj/item/cell/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is licking the electrodes of the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return (FIRELOSS)

/obj/item/cell/crap
	name = "\improper Nanotrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = 500
	materials = list(/datum/material/metal = 700, /datum/material/glass = 40)

/obj/item/cell/crap/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/cell/secborg
	name = "security borg rechargable D battery"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	materials = list(/datum/material/metal = 700, /datum/material/glass = 40)

/obj/item/cell/secborg/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/cell/apc
	name = "heavy-duty power cell"
	maxcharge = 5000
	materials = list(/datum/material/metal = 700, /datum/material/glass = 50)

/obj/item/cell/high
	name = "high-capacity power cell"
	icon_state = "hcell"
	maxcharge = 10000
	materials = list(/datum/material/metal = 700, /datum/material/glass = 60)

/obj/item/cell/high/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/cell/super
	name = "super-capacity power cell"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(/datum/material/metal = 700, /datum/material/glass = 70)

/obj/item/cell/super/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/cell/hyper
	name = "hyper-capacity power cell"
	icon_state = "hpcell"
	maxcharge = 30000
	materials = list(/datum/material/metal = 700, /datum/material/glass = 80)

/obj/item/cell/hyper/empty/Initialize()
	. = ..()
	charge = 0

/obj/item/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	maxcharge = 30000
	materials = list(/datum/material/metal = 700, /datum/material/glass = 80)
	use()
		return 1

/obj/item/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	icon = 'icons/obj/power.dmi' //'icons/obj/items/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	minor_fault = 1

/obj/item/cell/rtg/small
	name = "recharger cell"
	desc = "This is a miniature radioisotope generator that can fit into APC's, but not laser-based weapory. The needed shielding lowers the maximum capacity significantly."
	icon = 'icons/obj/items/stock_parts.dmi'
	icon_state = "capacitor"
	item_state = "capacitor"
	maxcharge = 2000
	self_recharge = TRUE
	charge_amount = 25
	charge_delay = 2 SECONDS //One hit on a resin thingy every 8 seconds, or one actual wall every 80 seconds.

/obj/item/cell/rtg/plasma_cutter
	name = "plasma cutter cell"
	desc = "You shouldn't be seeing this"
	maxcharge = 7500
	self_recharge = TRUE
	charge_amount = 25
	charge_delay = 2 SECONDS //One hit on a resin thingy every 8 seconds, or one actual wall every 80 seconds.

/obj/item/cell/rtg/large
	name = "large recharger cell"
	desc = "This is a radioisotope generator that can fit into APC's, but not laser-based weapory. It is too hot to be easily stored and cannot be handcharged."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trashmelt"
	item_state = "trashmelt"
	w_class = WEIGHT_CLASS_HUGE
	maxcharge = 5000
	self_recharge = TRUE
	charge_amount = 50
	charge_delay = 2 SECONDS //One hit on a resin thingy every 4 seconds, or one actual wall every 40 seconds.
