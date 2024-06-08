//Cell field charger

/obj/machinery/vending/lasgun
	name = "\improper Terra Experimental cell field charger"
	desc = "An automated power cell dispenser and charger. Used to recharge energy weapon power cells, including in the field. Has an internal battery that charges off the power grid when wrenched down."
	icon_state = "lascharger"
	icon_vend = "lascharger-vend"
	icon_deny = "lascharger-deny"
	wrenchable = TRUE
	drag_delay = FALSE
	anchored = FALSE
	idle_power_usage = 1
	active_power_usage = 50
	machine_current_charge = 50000 //integrated battery for recharging energy weapons. Normally 10000.
	machine_max_charge = 50000
	product_slogans = "Static Shock!;Power cell running low? Recharge here!;Need a charge?;Power up!;Electrifying!;Empower yourself!"
	products = list(
		/obj/item/cell/lasgun/lasrifle = 10, /obj/item/cell/lasgun/volkite/powerpack/marine = 2,
	)

	prices = list()

/obj/machinery/vending/lasgun/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/vending/lasgun/update_icon_state()
	. = ..()
	if(machine_max_charge)
		switch(machine_current_charge / max(1,machine_max_charge))
			if(0.7 to 1)
				icon_state = "lascharger"
			if(0.51 to 0.75)
				icon_state = "lascharger_75"
			if(0.26 to 0.50)
				icon_state = "lascharger_50"
			if(0.01 to 0.25)
				icon_state = "lascharger_25"
			if(0)
				icon_state = "lascharger_0"

/obj/machinery/vending/lasgun/examine(mob/user)
	. = ..()
	. += "Internal battery charge: <b>[machine_current_charge]</b>/<b>[machine_max_charge]</b>"