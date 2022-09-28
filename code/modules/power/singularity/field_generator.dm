/obj/machinery/field/generator
	name = "field generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	max_integrity = 500
	//100% immune to lasers and energy projectiles since it absorbs their energy.
	soft_armor = list(MELEE = 25, BULLET = 10, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, "rad" = 0, FIRE = 50, ACID = 70)
