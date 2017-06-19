
#define POSSIBLE_DREAM_TOPICS list( \
"a military vessel","a wound","a familiar face","a friend","a flare","a military officer","a politician", \
"whispering","deep space","a medic","an FTL engine","alarm","an ally","darkness", \
"dim light","a scientist","a great leader","a catastrophe","desertion","a mistake","ice","freezing","warning lights", \
"a helmet","mandibles","an abandoned station","a colony","monsters","air","a morgue","a military bridge","blinking lights", \
"a blue light","an abandoned colony","USCM","blood","a bandage","fear","a stiff corpse","military fleet", \
"loyalty","space","a crash","loneliness","suffocation","a fall","heat","flames","ice","cigarettes","falling","a buzzer","a PDA", \
"snow","searing heat","calamity","the dead","a rifle", \
"a knife","a distress beacon","a pistol","a spider","empty space","claws", \
"acid","jaws","a meeting","welding","the vents","being trapped","a survivor", \
"a power loader","cyrostasis","a meeting room","an engineer","a severed head","a motion scanner","a dropship","a uniform", \
"a ruined station","fire","a smokey room","a voice","the cold","dimness","an operating table","teeth","flowers","graves", \
"a synthetic man","meat","a planet","the U.P.P.","Weyland Yutani","tools" \
)

mob/living/carbon/proc/dream()
	dreaming = 1

	spawn(0)
		for(var/i = rand(1,4),i > 0, i--)
			src << "<span class='notice'><i>... [pick(POSSIBLE_DREAM_TOPICS)] ...</i></span>"
			sleep(rand(40,70))
			if(knocked_out <= 0)
				dreaming = 0
				return 0
		dreaming = 0
		return 1

mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()

mob/living/carbon/var/dreaming = 0
