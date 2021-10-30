GLOBAL_LIST_INIT(dream_topics, list(
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
))

/mob/living/carbon/proc/dream()
	if(!dream_amounts)
		dream_amounts = rand(1,5)
	if(!IsUnconscious())
		dream_amounts = 0
		return FALSE
	to_chat(src, span_notice("<i>... [pick(GLOB.dream_topics)] ...</i>"))
	addtimer(CALLBACK(src, .proc/dream), rand(4 SECONDS, 7 SECONDS))
	dream_amounts--
	return TRUE

/mob/living/carbon/proc/handle_dreams()
	if(client && !dream_amounts && prob(5))
		dream()

///amount of dreams left to go
/mob/living/carbon/var/dream_amounts = 0
