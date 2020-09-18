
#define POSSIBLE_DREAM_TOPICS list( \
"a military vessel","a wound","a familiar face","a friend","a flare","a military officer","a politician","screaming","a grenade", \
"whispering","deep space","a medic","an FTL engine","alarm","an ally","darkness","a limp body","a crowd","a knife","a war cry", \
"dim light","a scientist","a great leader","a catastrophe","desertion","a mistake","ice","freezing","warning lights", \
"a helmet","mandibles","an abandoned station","a colony","monsters","air","a morgue","a military bridge","blinking lights", \
"a blue light","an abandoned colony","TGMC","blood","a bandage","fear","a stiff corpse","military fleet","a cloud of smoke", \
"loyalty","space","a crash","loneliness","suffocation","a fall","heat","flames","ice","cigarettes","falling","a buzzer","a PDA", \
"snow","searing heat","calamity","the dead","a rifle","a handgun","an inner jaw","a static","an exoskeleton","a visor", \
"a knife","a distress beacon","a pistol","a spider","empty space","claws","a drop pod","a squad","a platoon","outgunned", \
"acid","jaws","a meeting","welding","the vents","being trapped","a survivor","an alien","a moth","being cornered","outnumbered", \
"a power loader","cyrostasis","a meeting room","an engineer","a severed head","a motion scanner","a dropship","a uniform", \
"a ruined station","fire","a smokey room","a voice","the cold","dimness","an operating table","teeth","flowers","graves", \
"a synthetic person","meat","a planet","the USL","Nanotrasen","tools","a mercenary","a promise","betrayal","acid","unbearable pain" \
)

mob/living/carbon/proc/dream()
	dreaming = 1

	spawn(0)
		for(var/i = rand(1,4),i > 0, i--)
			to_chat(src, "<span class='notice'><i>... [pick(POSSIBLE_DREAM_TOPICS)] ...</i></span>")
			sleep(rand(40,70))
			if(!IsUnconscious())
				dreaming = 0
				return 0
		dreaming = 0
		return 1

mob/living/carbon/proc/handle_dreams()
	if(client && !dreaming && prob(5))
		dream()

mob/living/carbon/var/dreaming = 0
