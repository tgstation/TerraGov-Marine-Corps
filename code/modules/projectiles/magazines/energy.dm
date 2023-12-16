//Energy weapons

/obj/item/cell/lasgun
	name = "\improper lasgun Battery"
	desc = "A specialized high density battery used to power lasguns."
	icon = 'icons/obj/items/ammo.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/ammo_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/ammo_right.dmi',
		)
	icon_state = "m43"
	item_state = null
	maxcharge = 600 ///Changed due to the fact some maps and ERTs spawn with the child, the lasrifle. Charges on guns changed accordingly.
	w_class = WEIGHT_CLASS_NORMAL
	icon_state_mini = "mag_cell"
	charge_overlay = "m43"
	var/reload_delay = 0
	///Magazine flags.
	var/flags_magazine_features = MAGAZINE_REFUND_IN_CHAMBER
	///if the magazine has a special overlay associated with it, i.e. extended mags etc
	var/bonus_overlay = null

/obj/item/cell/lasgun/M43
	name = "\improper M43 lasgun battery"
	desc = "A specialized high density battery used to power the M43 lasgun."
	charge_overlay = "m43"
	icon_state = "m43"

/obj/item/cell/lasgun/M43/highcap// Large battery
	name = "\improper M43 highcap lasgun battery"
	desc = "An advanced, ultrahigh capacity battery used to power the M43 lasgun; has sixty percent more charge capacity than standard laspacks."
	charge_overlay = "m43_e"
	icon_state = "m43_e"
	maxcharge = 1600

/obj/item/cell/lasgun/pulse
	name = "\improper M19C4 pulse battery"
	desc = "An advanced, ultrahigh capacity battery used to power the M19C4 pulse rifle system; Uses pulse-based energy rather than laser energy, massively increasing its firepower. It can also recharge on its own."
	charge_overlay = "pulse"
	icon_state = "pulse"
	maxcharge = 2000 // 100 shots.
	self_recharge = TRUE
	charge_amount = 25 // 10%, 1 shot
	charge_delay = 2 SECONDS

/obj/item/cell/lasgun/plasma
	name = "\improper WML plasma battery"
	desc = "A plasma containment cell produced by the Kongjian corporation. It doesn't seem to have an expiry date."
	charge_overlay = "plasma"
	icon_state = "plasma"
	icon_state_mini = "mag_plasma"
	maxcharge = 1000

/obj/item/cell/lasgun/M43/practice
	name = "\improper M43-P lasgun battery"
	desc = "A specialized high density battery used to power the M43-P practice lasgun. It lacks any potential to harm someone, but it has the ability to recharge."
	self_recharge = TRUE
	charge_amount = 25 // 10%, 2 shots
	charge_delay = 2 SECONDS

/obj/item/cell/lasgun/lasrifle
	name = "\improper Terra Experimental standard battery"
	desc = "A specialized high density battery used to power most standard marine laser guns. It is simply known as the TE power cell."
	charge_overlay = "te"
	icon_state = "te"
	icon_state_mini = "mag_cell_te"
	maxcharge = 600
/obj/item/cell/lasgun/lasrifle/recharger
	name = "\improper Terra Experimental recharger battery"
	desc = "A prototype high density battery reverse-engineered from captured Volkite equipment. Due to developmental constraints and less than stellar jury-rigging, as well as space taken up by the recharger component, it boasts sub-par capacity."
	icon_state = "ter"
	maxcharge = 450
	self_recharge = TRUE
	charge_amount = 12 //balanced around recharging 1 standard laser rifle shot per second
	charge_delay = 1 SECONDS
/obj/item/cell/lasgun/fob_sentry/cell
	maxcharge = INFINITY

//volkite

/obj/item/cell/lasgun/volkite
	name = "\improper volkite energy cell"
	desc = "A specialized high density battery used to power volkite weaponry."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "volkite"
	maxcharge = 1440
	w_class = WEIGHT_CLASS_NORMAL
	icon_state_mini = "mag_cell"
	charge_overlay = "volkite"
	reload_delay = 0

/obj/item/cell/lasgun/volkite/small
	name = "\improper compact volkite energy cell"
	desc = "A specialized compact battery used to power the smallest volkite weaponry."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "volkite_small"
	maxcharge = 540
	w_class = WEIGHT_CLASS_SMALL
	icon_state_mini = "mag_cell"

/obj/item/cell/lasgun/volkite/turret
	name = "\improper volkite nuclear energy cell"
	desc = "A nuclear powered battery designed for certain heavy SOM machinery like sentries. Slowly charges over time."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "volkite_turret"
	maxcharge = 1800
	w_class = WEIGHT_CLASS_NORMAL
	icon_state_mini = "mag_cell"
	charge_overlay = "volkite_big"
	reload_delay = 0
	self_recharge = TRUE
	charge_amount = 24
	charge_delay = 2 SECONDS

/obj/item/cell/lasgun/volkite/powerpack
	name = "\improper M-70 powerpack"
	desc = "A heavy reinforced backpack with an array of ultradensity energy cells, linked to a miniature radioisotope thermoelectric generator for continuous power generation. Used to power the largest man portable volkite weaponry. Click drag cells to the powerpack to recharge."
	icon = 'icons/obj/items/storage/storage.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/backpacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/backpacks_right.dmi',
	)
	icon_state = "volkite_powerpack"
	charge_overlay = null
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	flags_magazine_features = MAGAZINE_REFUND_IN_CHAMBER|MAGAZINE_WORN
	w_class = WEIGHT_CLASS_HUGE
	slowdown = 0.2
	maxcharge = 3000
	self_recharge = TRUE
	charge_amount = 100
	charge_delay = 2 SECONDS
	light_range = 0.1
	light_power = 0.1
	light_color = LIGHT_COLOR_ORANGE

/obj/item/cell/lasgun/volkite/powerpack/Initialize(mapload)
	. = ..()
	turn_light(null, TRUE)

/obj/item/cell/lasgun/volkite/powerpack/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	set_light_on(toggle_on)

/obj/item/cell/lasgun/volkite/powerpack/apply_custom(mutable_appearance/standing, inhands, icon_used, state_used)
	. = ..()
	var/mutable_appearance/emissive_overlay = emissive_appearance(icon_used, "[state_used]_emissive")
	standing.overlays.Add(emissive_overlay)

///Handles draining power from the powerpack, returns the value of the charge drained to MouseDrop where it's added to the cell.
/obj/item/cell/lasgun/volkite/powerpack/proc/use_charge(mob/user, amount = 0, mention_charge = TRUE)
	var/warning = ""
	if(amount > charge)
		playsound(src, 'sound/machines/buzz-two.ogg', 25, 1)
		if(charge)
			warning = "[src]'s powerpack recharge unit buzzes a warning, its battery only having enough power to partially recharge the cell for [charge] amount."
		else
			warning = "[src]'s powerpack recharge unit buzzes a warning, as its battery is completely depleted of charge."
	else
		playsound(src, 'sound/machines/ping.ogg', 25, 1)
		warning = "[src]'s powerpack recharge unit cheerfully pings as it successfully recharges the cell."
	. = min(charge, amount)
	charge -= .
	if(mention_charge)
		to_chat(user, span_notice("[warning]<b>Charge Remaining: [charge]/[maxcharge]</b>"))
	update_icon()

/obj/item/cell/lasgun/volkite/powerpack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/weapon/gun) && loc == user)
		var/obj/item/weapon/gun/gun = I
		if(!CHECK_BITFIELD(gun.reciever_flags, AMMO_RECIEVER_MAGAZINES))
			return
		gun.reload(src, user)
		return

	if(!istype(I, /obj/item/cell))
		return
	if(I != user.r_hand && I != user.l_hand)
		to_chat(user, span_warning("[I] must be in your hand to do that."))
		return
	var/obj/item/cell/D = I
	var/charge_difference = D.maxcharge - D.charge
	if(charge_difference) //If the cell has less than max charge, recharge it.
		var/charge_used = use_charge(user, charge_difference) //consume an appropriate amount of charge
		D.charge += charge_used //Recharge the cell battery with the lower of the difference between its present and max cap, or the remaining charge
		D.update_icon()
	else
		to_chat(user, span_warning("This cell is already at maximum charge!"))

/obj/item/cell/lasgun/volkite/powerpack/marine
	name = "\improper TE powerpack"
	desc = "A recently developed mass produced side pouch which charges any TE technological achievement."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "lasgun_pouch"
	charge_overlay = "lasgun_cell"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_POCKET
	flags_magazine_features = MAGAZINE_REFUND_IN_CHAMBER|MAGAZINE_WORN
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 0
	maxcharge = 2400
	self_recharge = FALSE
