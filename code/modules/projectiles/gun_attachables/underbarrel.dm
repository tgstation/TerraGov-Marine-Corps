/obj/item/attachable/verticalgrip
	name = "vertical grip"
	desc = "A custom-built improved foregrip for better accuracy, moderately faster aimed movement speed, less recoil, and less scatter when wielded especially during burst fire. \nHowever, it also increases weapon size, slightly increases wield delay and makes unwielded fire more cumbersome."
	icon_state = "verticalgrip"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	wield_delay_mod = 0.2 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -3
	burst_scatter_mod = -1
	accuracy_unwielded_mod = -0.05
	scatter_unwielded_mod = 3
	aim_speed_mod = -0.1
	aim_mode_movement_mult = -0.2

/obj/item/attachable/angledgrip
	name = "angled grip"
	desc = "A custom-built improved foregrip for less recoil, and faster wielding time. \nHowever, it also increases weapon size, and slightly hinders unwielded firing."
	icon_state = "angledgrip"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	wield_delay_mod = -0.3 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	recoil_mod = -1
	scatter_mod = 2
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 1

/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to stabilize the weapon when burst firing or moving, especially while shooting one-handed. Greatly reduces movement penalties to accuracy. Significantly reduces burst scatter, recoil and general scatter. By increasing accuracy while moving, it let you move faster when taking aim."
	icon_state = "gyro"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	slot = ATTACHMENT_SLOT_UNDER
	scatter_mod = -1
	recoil_mod = -2
	movement_acc_penalty_mod = -2
	accuracy_unwielded_mod = 0.1
	scatter_unwielded_mod = -2
	recoil_unwielded_mod = -1
	aim_mode_movement_mult = -0.5

/obj/item/attachable/lasersight
	name = "laser sight"
	desc = "A laser sight placed under the barrel. Significantly increases one-handed accuracy and significantly reduces unwielded penalties to accuracy."
	icon_state = "lasersight"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 17
	pixel_shift_y = 17
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.15

/obj/item/attachable/burstfire_assembly
	name = "burst fire assembly"
	desc = "A mechanism re-assembly kit that allows for automatic fire, or more shots per burst if the weapon already has the ability. \nIncreases scatter and decreases accuracy."
	icon_state = "rapidfire"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	slot = ATTACHMENT_SLOT_UNDER
	burst_mod = 2
	burst_scatter_mod = 1
	burst_accuracy_mod = -0.1

/obj/item/attachable/autosniperbarrel
	name = "auto sniper barrel"
	icon_state = "t81barrel"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_UNDER
	attach_features_flags = NONE
	pixel_shift_x = 7
	pixel_shift_y = 14
	accuracy_mod = 0
	scatter_mod = -1
