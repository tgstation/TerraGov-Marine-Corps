/mob/living/carbon/hellhound/gib()
	..(null,1)

/mob/living/carbon/hellhound/dust()
	..("dust-m")

/mob/living/carbon/hellhound/death(gibbed)
	emote("roar")
	..(gibbed,"lets out a horrible roar as it collapses and stops moving...")
