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
	armor = list("melee" = 25, "bullet" = 10, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)