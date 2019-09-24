//Energy weapons

/obj/item/cell/lasgun
	name = "\improper Lasgun Battery"
	desc = "A specialized high density battery used to power Lasguns."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "m43"
	maxcharge = 1000
	w_class = WEIGHT_CLASS_NORMAL
	var/base_ammo_icon = "m43"
	var/gun_type = /obj/item/weapon/gun/energy/lasgun
	var/reload_delay = 0

/obj/item/cell/lasgun/M43
	name = "\improper M43 lasgun battery"
	desc = "A specialized high density battery used to power the M43 Lasgun."
	base_ammo_icon = "m43"
	icon_state = "m43"
	gun_type = /obj/item/weapon/gun/energy/lasgun/M43

/obj/item/cell/lasgun/M43/highcap// Large battery
	name = "\improper M43 highcap lasgun battery"
	desc = "An advanced, ultrahigh capacity battery used to power the M43 Lasgun; has sixty percent more charge capacity than standard laspacks."
	base_ammo_icon = "m43_e"
	icon_state = "m43_e"
	maxcharge = 1600


/obj/item/cell/lasgun/M43/Initialize()
	. = ..()
	update_icon()

/obj/item/cell/lasgun/M43/update_icon()
	var/remaining = CEILING((charge / max(maxcharge, 1)) * 100, 25)
	icon_state = "[base_ammo_icon]_[remaining]"

/obj/item/cell/lasgun/update_icon()
	return FALSE

