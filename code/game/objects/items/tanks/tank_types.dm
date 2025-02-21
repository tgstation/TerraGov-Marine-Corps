/* Types of tanks!
* Contains:
*		Oxygen
*		Anesthetic
*		Air
*		Phoron
*		Emergency Oxygen
*/

/*
* Oxygen
*/
/obj/item/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	gas_type = GAS_TYPE_OXYGEN



/obj/item/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"


/*
* Anesthetic
*/
/obj/item/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	worn_icon_state = "anesthetic"
	gas_type = GAS_TYPE_N2O


/*
* Air
*/
/obj/item/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "oxygen"


/*
* Phoron
*/
/obj/item/tank/phoron
	name = "phoron tank"
	desc = "Contains dangerous phoron. Do not inhale. Warning: extremely flammable."
	icon_state = "phoron"
	atom_flags = CONDUCT
	equip_slot_flags = NONE	//they have no straps!



/*
* Emergency Oxygen
*/
/obj/item/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	force = 4
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 2 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)
	gas_type = GAS_TYPE_OXYGEN
	pressure = 3*ONE_ATMOSPHERE
	pressure_full = 3*ONE_ATMOSPHERE


/obj/item/tank/emergency_oxygen/examine(mob/user)
	. = ..()
	if(pressure < 50 && loc==user)
		. += span_danger("The meter on [src] indicates you are almost out of air!")
		SEND_SOUND(user, sound('sound/effects/alert.ogg'))

/obj/item/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6
	pressure = 5*ONE_ATMOSPHERE
	pressure_full = 5*ONE_ATMOSPHERE

/obj/item/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	volume = 10
	pressure = 5*ONE_ATMOSPHERE
	pressure_full = 5*ONE_ATMOSPHERE

/*
* Nitrogen
*/
/obj/item/tank/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon_state = "oxygen_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	gas_type = GAS_TYPE_NITROGEN

