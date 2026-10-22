/obj/item/disk
	name = "disk"
	icon = 'icons/obj/items/disk.dmi'
	icon_state = "datadisk0"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/id_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/id_right.dmi',
	)
	worn_icon_state = "card-id"


/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/disk_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/disk_right.dmi',
	)
	worn_icon_state = null
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = RESIST_ALL

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	GLOB.nuke_disk_list += src

/obj/item/disk/nuclear/Destroy()
	GLOB.nuke_disk_list -= src
	return ..()


/obj/item/disk/nuclear/red
	name = "red nuclear authentication disk"
	icon_state = "datadisk7"


/obj/item/disk/nuclear/green
	name = "green nuclear authentication disk"
	icon_state = "botanydisk"


/obj/item/disk/nuclear/blue
	name = "blue nuclear authentication disk"
	icon_state = "datadisk0"


///zcrash point buy that lets a singular synthetic shoot guns
/obj/item/disk/illegal_synth_firmware
	name = "illegal synth firmware"
	desc = "Utilizing a vulnerability to do with overuse of the number four, this hacked firmware allows for \
	 Synthetic members of the TGMC to bypass their programmed safety locks and fire guns. Useless to non-synthetics."
	icon_state = "datadisk7"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/disk_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/disk_right.dmi',
	)
	worn_icon_state = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/disk/illegal_synth_firmware/attack(mob/living/M, mob/living/user)
	. = ..()
	if(.)
		return
	if(!istype(M, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/target = M
	allow_synthetic_gun_use(target, user)

/obj/item/disk/illegal_synth_firmware/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!istype(user, /mob/living/carbon/human))
		return
	allow_synthetic_gun_use(user, user)

/obj/item/disk/illegal_synth_firmware/proc/allow_synthetic_gun_use(mob/living/carbon/human/target, mob/user)
	if(!issynth(target))
		balloon_alert(user, "not a synthetic!")
		return FALSE
	if(HAS_TRAIT(target, TRAIT_SYNTH_CAN_FIRE_GUNS))
		balloon_alert(user, "already hacked!")
		return FALSE
	ADD_TRAIT(target, TRAIT_SYNTH_CAN_FIRE_GUNS, REF(src))
	target.set_skills(target.skills.setRating(combat = SKILL_COMBAT_DEFAULT))
	playsound(target, 'sound/machines/warning-buzzer.ogg', 50)
	target.visible_message(span_danger("[user] uses [src] to hack [target]!"), span_danger("SYSTEM TAMPERING DETECTED. SAFETY PROTOCOLS OFFLINE."))
	qdel(src)
	return TRUE
