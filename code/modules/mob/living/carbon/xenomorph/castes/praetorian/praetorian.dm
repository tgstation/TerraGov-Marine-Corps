/mob/living/carbon/xenomorph/praetorian
	caste_base_type = /mob/living/carbon/xenomorph/praetorian
	name = "Praetorian"
	desc = "A huge, looming beast of an alien."
	icon = 'icons/Xeno/castes/praetorian.dmi'
	icon_state = "Praetorian Walking"
	health = 210
	maxHealth = 210
	plasma_stored = 200
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/praetorian/Bump(atom/A)
	if(!(xeno_flags & XENO_LEAPING) || !throwing || !throw_source || !thrower)
		return ..()
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/human_victim = A
	human_victim.ParalyzeNoChain(0.5 SECONDS)

	to_chat(human_victim, span_highdanger("The [src] tackles us, sending us behind them!"))
	visible_message(span_xenodanger("\The [src] tackles [human_victim], swapping location with them!"), \
		span_xenodanger("We push [human_victim] in our acid trail!"), visible_message_flags = COMBAT_MESSAGE)
	return TRUE
