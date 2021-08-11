/// explode target headset dealing head brain and eye damage
/datum/smite/headset_explosion
	name = "Headset Explosion"

/datum/smite/headset_explosion/effect(client/user, mob/living/carbon/human/target)
	. = ..()
	
	if(!ishuman(target))
		to_chat(user, span_warning("Target does not have ears. Aborting."), confidential = TRUE)
		return
	if(target.wear_ear == null)
		to_chat(user, span_warning("Target does not have a headset. Aborting."), confidential = TRUE)
		return

	var/datum/limb/L = target.get_limb("head")
	if(tgui_alert(usr, "Blow [target]'s head off with the explosion?", "Explosion Strength", list("Yes", "No")) != "No")
		L.take_damage_limb(100) //extra damage makes subsequent explosion always decap

	to_chat(target, span_userdanger("Your headset buzzes and violently explodes in your face!"))
	playsound(target, 'sound/effects/explosion_small1.ogg', 50, 1)
	target.ex_act(EXPLODE_LIGHT)
	L.take_damage_limb(rand(25, 45)) //a headset explosion without head damage would be weird
	L.fracture()
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	E.take_damage(rand(13, 32))
	target.adjustBrainLoss(rand(25, 41))
	qdel(target.wear_ear)
