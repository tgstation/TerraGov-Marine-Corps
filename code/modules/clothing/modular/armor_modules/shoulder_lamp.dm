/** Shoulder lamp module */
/obj/item/armor_module/shoulder_lamp
	icon_state = "shoulder-lamp"
	name = "Lamp Amplifier"
	desc = "A shoulder mounted lamp, with a 4 cell battery pack."

	var/light_amount = 4 /// The amount of light provided

/obj/item/armor_module/shoulder_lamp/on_attach(mob/living/user, obj/item/clothing/suit/modular/armor)
	armor.update_light_mod(light_amount)

/obj/item/armor_module/shoulder_lamp/on_deattach(mob/living/user, obj/item/clothing/suit/modular/armor)
	armor.update_light_mod(light_amount * -1)
