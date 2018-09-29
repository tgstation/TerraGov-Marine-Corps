//Energy weapons

/*
/obj/item/weapon_cell
	name = "\improper Weapon Power Cell"
	desc = "A specialized high density battery used to power weapons."
	icon_state = "flametank"
	var/default_ammo = /datum/ammo/energy/lasgun
	var/maxcharge = 50
	var/charge = 50
	var/reload_delay
	w_class = 3.0
	var/gun_type = /obj/item/weapon/gun/energy/lasgun/M43*/

/obj/item/ammo_magazine/lasgun
	name = "\improper Lasgun Battery"
	desc = "A specialized high density battery used to power Lasguns."
	var/base_ammo_icon = "m43"
	icon_state = "m43"
	default_ammo = /datum/ammo/energy/lasgun
	max_rounds = 50
	current_rounds = 50
	w_class = 3.0
	gun_type = /obj/item/weapon/gun/energy/lasgun
	caliber = "lasgun"
	flags_magazine = NOFLAGS //Obviously you can't grab bullets from this.

/obj/item/ammo_magazine/lasgun/M43
	name = "\improper M43 lasgun battery"
	desc = "A specialized high density battery used to power the M43 Lasgun."
	base_ammo_icon = "m43"
	icon_state = "m43"
	default_ammo = /datum/ammo/energy/lasgun/M43
	overcharge_ammo = /datum/ammo/energy/lasgun/M43/overcharge
	max_rounds = 50
	current_rounds = 50
	gun_type = /obj/item/weapon/gun/energy/lasgun/M43
	caliber = "M43lasgun"

/obj/item/ammo_magazine/lasgun/M43/New()
	..()
	update_icon()

/obj/item/ammo_magazine/lasgun/M43/emp_act(severity)
	var/amount = round(max_rounds * rand(2,severity) * 0.1)
	current_rounds = max(0,current_rounds - amount)
	update_icon()
	..()

/obj/item/ammo_magazine/lasgun/M43/update_icon()
	if(current_rounds <= 0)
		icon_state = base_ammo_icon + "_0"
	else if(current_rounds > round(max_rounds * 0.75))
		icon_state = base_ammo_icon + "_100"
	else if(current_rounds > round(max_rounds * 0.5))
		icon_state = base_ammo_icon + "_75"
	else if(current_rounds > round(max_rounds * 0.25))
		icon_state = base_ammo_icon + "_50"
	else
		icon_state = base_ammo_icon + "_25"
	//to_chat(world, "<span class='warning'>DEBUG: Lasgun Magazine Icon Update. Icon State: [icon_state] Current Rounds: [current_rounds]</span>")

/obj/item/ammo_magazine/lasgun/M43/highcap// Large battery
	name = "M43 highcap lasgun battery"
	desc = "An advanced, ultrahigh capacity battery used to power the M43 Lasgun; has twice the charge capacity of standard models."
	base_ammo_icon = "m43_e"
	icon_state = "m43_e"
	max_rounds = 100
	current_rounds = 100