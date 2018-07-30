/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "Odysseus"
	icon_state = "odysseus"
	initial_icon = "odysseus"
	step_in = 2
	max_temperature = 15000
	health = 120
	wreckage = /obj/effect/decal/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	var/builtin_hud_user = 0


	moved_inside(var/mob/living/carbon/human/H as mob)
		if(..())
			if(H.glasses && istype(H.glasses, /obj/item/clothing/glasses/hud))
				occupant_message("<span class='warning'>Your [H.glasses] prevent you from using the built-in medical hud.</span>")
			else
				var/datum/mob_hud/medical/advanced/A = huds[MOB_HUD_MEDICAL_ADVANCED]
				A.add_hud_to(H)
				builtin_hud_user = 1
			return 1
		else
			return 0

	go_out()
		if(ishuman(occupant) && builtin_hud_user)
			var/mob/living/carbon/human/H = occupant
			var/datum/mob_hud/medical/advanced/A = huds[MOB_HUD_MEDICAL_ADVANCED]
			A.remove_hud_from(H)
		..()



/obj/mecha/medical/odysseus/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/sleeper
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/sleeper
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	ME.attach(src)