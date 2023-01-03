//Combat boosters
/obj/item/stimulant
	icon = 'icons/obj/items/syringe.dmi'
	icon_state = ""
	w_class = 2
	///The status effect to apply on use
	var/datum/status_effect/stimulant/stim_type
	///How long to apply the effect for
	var/stim_duration = 120 SECONDS
	///The message to play to the user on use
	var/stim_message = ""

/obj/item/stimulant/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.has_status_effect(stim_type))
		var/datum/status_effect/stimulant = human_user.has_status_effect(stim_type)
		stimulant.duration += stim_duration
		human_user.balloon_alert(human_user, "refreshed!")
		return
	else
		human_user.apply_status_effect(stim_type, stim_duration)
		human_user.balloon_alert(human_user, stim_message)
	qdel(src)

/obj/item/stimulant/drop
	name = "drop booster"
	desc = "Drop pushes the user into a heightened state of neural activity, greatly improving hand eye co-ordination but making them more sensitive to pain. Also known to cause severe paranoia and hallucinations, at higher doses."
	icon_state = "drop"
	stim_type = STATUS_EFFECT_STIMULANT_DROP
	stim_message = "You can suddenly feel everything!"

/obj/item/stimulant/exile
	name = "exile booster"
	desc = "Exile inhibits several key receptors in the brain, triggering a state of extreme aggression and dumbness to pain, allowing the user to continue operating with the most greivous of injuries. Exile does not actually prevent any damage however, and can gradually lead to neural degeneration."
	icon_state = "exile"
	stim_type = STATUS_EFFECT_STIMULANT_EXILE
	stim_message = "You feel the urge for violence!"

/obj/item/stimulant/crash
	name = "crash booster"
	desc = "Crash hyperstimulates the users nervous system and triggers a rapid metabolic acceleration. This serves to boost the users agility, although it also makes user notoriously twitchy, and can strain the heart."
	icon_state = "crash"
	stim_type = STATUS_EFFECT_STIMULANT_CRASH
	stim_message = "You feel the need for speed!"
