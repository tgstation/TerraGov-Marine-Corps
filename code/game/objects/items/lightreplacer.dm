
// Light Replacer (LR)
//
// ABOUT THE DEVICE
//
// This is a device supposedly to be used by Janitors and Janitor Cyborgs which will
// allow them to easily replace lights. This was mostly designed for Janitor Cyborgs since
// they don't have hands or a way to replace lightbulbs.
//
// HOW IT WORKS
//
// You attack a light fixture with it, if the light fixture is broken it will replace the
// light fixture with a working light; the broken light is then placed on the floor for the
// user to then pickup with a trash bag. If it's empty then it will just place a light in the fixture.
//
// HOW TO REFILL THE DEVICE
//
// It will need to be manually refilled with lights.
// If it's part of a robot module, it will charge when the Robot is inside a Recharge Station.

/obj/item/lightreplacer

	name = "light replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."

	icon = 'icons/obj/janitor.dmi'
	icon_state = "lightreplacer0"
	item_state = "electronic"

	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT

	w_class = WEIGHT_CLASS_SMALL

	var/max_uses = 50
	var/uses = 0
	var/failmsg = ""
	var/charge = 1

/obj/item/lightreplacer/Initialize()
	. = ..()
	uses = max_uses
	failmsg = "The [name]'s refill light blinks red."

/obj/item/lightreplacer/examine(mob/user)
	. = ..()
	. += "It has [uses] lights remaining."

/obj/item/lightreplacer/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(uses >= max_uses)
			to_chat(user, "<span class='warning'>[src] is full.")
			return

		if(!G.use(1))
			to_chat(user, span_warning("You need one sheet of glass to replace lights."))
			return

		AddUses(5)
		to_chat(user, span_notice("You insert a piece of glass into \the [src]. You have [uses] lights remaining."))

	else if(istype(I, /obj/item/light_bulb))
		var/obj/item/light_bulb/L = I
		if(L.status)
			to_chat(user, "You need a working light.")
			return

		if(uses >= max_uses)
			to_chat(user, "<span class='warning'>[src] is full.")
			return

		AddUses(1)
		to_chat(user, "You insert \the [L] into \the [src]. You have [uses] lights remaining.")
		user.drop_held_item()
		qdel(L)


/obj/item/lightreplacer/attack_self(mob/user)
	to_chat(usr, "It has [uses] lights remaining.")


/obj/item/lightreplacer/proc/Use(mob/user)

	playsound(src.loc, 'sound/machines/click.ogg', 25, 1)
	AddUses(-1)
	return 1

// Negative numbers will subtract
/obj/item/lightreplacer/proc/AddUses(amount = 1)
	uses = min(max(uses + amount, 0), max_uses)

/obj/item/lightreplacer/proc/Charge(mob/user)
	charge += 1
	if(charge > 7)
		AddUses(1)
		charge = 1

/obj/item/lightreplacer/proc/ReplaceLight(obj/machinery/light/target, mob/living/U)

	if(target.status != LIGHT_OK)
		if(CanUse(U))
			if(!Use(U)) return
			to_chat(U, span_notice("You replace the [target.fitting] with the [src]."))

			if(target.status != LIGHT_EMPTY)

				var/obj/item/light_bulb/L1 = new target.light_type(target.loc)
				L1.status = target.status
				L1.rigged = target.rigged
				L1.brightness = target.brightness
				L1.switchcount = target.switchcount
				target.switchcount = 0
				L1.update()

				target.status = LIGHT_EMPTY
				target.update()

			var/obj/item/light_bulb/L2 = new target.light_type()

			target.status = L2.status
			target.switchcount = L2.switchcount
			target.brightness = L2.brightness
			target.light_on = target.has_power()
			target.update()
			qdel(L2)

			if(target.light_on && target.rigged)
				target.explode()
			return

		else
			to_chat(U, failmsg)
			return
	else
		to_chat(U, "There is a working [target.fitting] already inserted.")
		return

//Can you use it?

/obj/item/lightreplacer/proc/CanUse(mob/living/user)
	//Not sure what else to check for. Maybe if clumsy?
	if(uses > 0)
		return 1
	else
		return 0

