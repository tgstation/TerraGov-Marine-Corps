/obj/effect/proc_holder/spell/targeted/inflict_handler
	name = "Inflict Handler"
	desc = "This spell blinds and/or destroys/damages/heals and/or weakens/stuns the target."

	var/amt_knocked_down = 0
	var/amt_knocked_out = 0
	var/amt_stunned = 0

	//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 0
	var/amt_dam_oxy = 0
	var/amt_dam_tox = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/destroys = "none" //can be "none", "gib" or "disintegrate"

/obj/effect/proc_holder/spell/targeted/inflict_handler/cast(list/targets)

	for(var/mob/living/target in targets)
		switch(destroys)
			if("gib")
				target.gib()
			if("gib_brain")
				if(ishuman(target) || ismonkey(target))
					var/mob/living/carbon/C = target
					if(!C.has_brain()) // Their brain is already taken out
						var/obj/item/organ/brain/B = new(C.loc)
						B.transfer_identity(C)
				target.gib()
			if("disintegrate")
				target.dust()

		if(!target)
			continue
		//damage
		if(amt_dam_brute > 0)
			if(amt_dam_fire >= 0)
				target.take_overall_damage(amt_dam_brute,amt_dam_fire)
			else if (amt_dam_fire < 0)
				target.take_overall_damage(amt_dam_brute,0)
				target.heal_overall_damage(0,amt_dam_fire)
		else if(amt_dam_brute < 0)
			if(amt_dam_fire > 0)
				target.take_overall_damage(0,amt_dam_fire)
				target.heal_overall_damage(amt_dam_brute,0)
			else if (amt_dam_fire <= 0)
				target.heal_overall_damage(amt_dam_brute,amt_dam_fire)
		target.adjustToxLoss(amt_dam_tox)
		target.adjustOxyLoss(amt_dam_oxy)
		//disabling
		target.KnockDown(amt_knocked_down)
		target.KnockOut(amt_knocked_out)
		target.Stun(amt_stunned)

		target.blind_eyes(amt_eye_blind, TRUE)
		target.blur_eyes(amt_eye_blurry, TRUE)