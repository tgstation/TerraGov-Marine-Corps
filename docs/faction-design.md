
## About

The point of this document is to outline the server's current and future intended design.

The current design section should be updated by contributors of pull requests which significantly affect balance or add new features. This will serve as a useful overview for new players and code contributors to understand the existing differences between the factions and a high-level overview of gameplay.

The future design section should be mainly updated by maintainers as a central location for their vision for the server. This gives direction for code contributors to build their PRs on and gives players insight into what to look forward to.

The main USP of TGMC is: “asymmetrical team deathmatch PvP gameplay with a high degree of QoL”.

## Current Design

### Visual

- Xenomorphs - arachnid/dinosaur mix.
- TG Marines - highly flamboyant armour design and accessorising similar to Destiny, or dressed in modern military attire if preferred. Ballistic, incendiary and explosive weaponry with a modern design, as well as futuristic laser weaponry.
- Sons of Mars - orange mirrored helmets, dark orange accent colour on black armoured suits. High-tech volkite weaponry.

### Gameplay

The two main factions Xenomorphs and TG Marines have assymetrical combat. This means whilst there may be a few distinct exceptions in their gameplay, they each have unique strengths, weaknesses and other differences.

#### Xenomorphs

Xenos have 4 tiers of playable castes. Tier 1-3 have decreasing amounts of availability to players as they move up the tiers. The tiers more or less increase the combat prowess of the player with increasing tiers. They also serve to funnel some players into the weaker roles that they typically wouldn't play by having a player cap based off of total players on the team. Tier 4 allows only one playable per caste and typically comes with minimum player requirements.

Xenos gain maturity over time, progressing from Young to Mature to Elder to Ancient to Primordial. At each stage their stats improve, and for some castes their abilities improve as well e.g. Widows have a greater max amount of spiderlings.

The 4 main tiers are supplemented by a minion tier that consists of AI xenomorphs. This tier serves as cannon fodder to provide a low enough challenge to new and low skill marine players to learn the basics.

Xenos can persistently identify themselves through a simple phrase or word, e.g. `Mature Runner (Cucumber)`, as well as through selection of a female TTS voice.

**Strengths**
- More suited to hit-and-run attacks, due to their better information gathering (X-ray and darkvision) and high movement speed (especially on weeds).
- Combat castes are well-suited to go deep behind enemy lines to pick off stragglers or destroy structures.
- Excels in caves as this prevents Orbital Strikes, Close Air Support, the Tadpole and marine radio communication.
- Many castes are decent in melee range thanks to bump attacks and faster movement speed for dodging (especially on weeds). And a few castes are very good at melee combat.
	- Marines on the other hand *do* have a lot of tools which are very strong in melee (e.g. Vali, powerfist, rocket sledge, point-blank shotgun blasts, etc) but their slower movement holds them back some.
- A large number of reliable combat engagement tools (e.g. Queen's Screech, King's Scattering Roar, Defiler's Emit Neurogas, Boiler's Bombard, etc) for initiating team fights.
	- Marines on the other hand have some (e.g. tgas nade, tgas minirocket, tgas RR shell) but they require more accuracy or have lower AOE, though they do have greater AOE damage.
- Respawn timer is much shorter than a marines.
	- Marines on the other hand *can* recover their dead bodies to revive those, heavily reducing their time spent dead. But if their body isn't recovered it's a much longer respawn timer.
- Minimal long-term resource limitations to continue successful heavy combat (just recovery pheromones and resting weeds needed mainly).
	- Marines on the other hand are dependent on ammo and equipment supplies. They have to coordinate with others to resupply after sustained combat, unless they take a small combat performance hit to always bring an ammo box with them.

#### TG Marines

Marines have a variety of different roles, broadly categorised as infantry, engineers, medical staff, command and pilots. The vast majority of infantry are Marines, who are aided by Squad Leaders who are able to use useful AOE buffs.

**Strengths**
- Better suited to defend areas thanks to barricades, razorfoam, automated turrets, machine gun emplacements, mortars and railguns. Their defensive structures especially are far superior to xeno equivalents.
- Excels in corridors as it means less directions they can be attacked from, and a better chance of getting shots on-target.
- Very strong in ranged combat as they have guns.
- If their dead bodies can be recovered, they can be revived.
- Tadpoles and Drop Pods give marines a lot of powerful mobility. It can be used to sneakily reach strategic objectives, or to transport/evacuate/reinforce areas as needed.
- Short-term resource management (i.e. ammo inside weaponry) for most marines isn't a concern as they only need 5-10 seconds to reload generally after every few minute or two in combat.
	- Xenos on the other hand have to constantly manage their resources carefully to be effective (e.g. plasma for most, spiderlings for Widows, rage for Ravagers, blood for Gorgers, etc). This often leads to needing a 2:1 ratio or higher of downtime compared to combat.
- Healing is generally quick, can be interrupted to rejoin combat quickly and can be done solo for most injuries.
	- Xenos on the other hand have to rest for long periods to heal usually and it takes a few seconds to unrest which means they can be attacked by marines before being able to get up. It's also dependent on weeds being available (especially rest weeds) created by Drone tree castes and healing is slow without recovery pheromones.
- Well-suited to siege areas thanks to Orbital Strikes, Close Air Support, plasma cutters, explosives and incendiary weaponry. Can clear large areas in one shot, or quickly delete any single tile in less than a second.
	- Xenos on the other hand have difficulty sieging unless there are large areas infront for Boiler's Bombard and Crusher's Charge.
- Less dependent on unique roles staying alive. Only a few medics, engineers and a pilot are needed, the rest being marines can work just fine.
	- Xenos on the other hand are dependent on a variety of castes staying alive. Drone tree for construction, Sentinel tree for ranged/sieging capabilities, Runner and Defender trees for close quarters combat, plus Rulers for pheromones and evolution.
- Less dependent on individual player skill. As there are much more marines than xenos, unless they sabotage the group then skilled players can average out the less skilled ones.
	- Xenos on the other hand depend on skilled players as there are much less of them, and it's especially needed for the Ruler roles.
- Greater benefit for getting kills. Xeno corpses when recovered can be converted into req points for top-tier equipment, killing particular castes can totally disrupt xenos' ability to function well as a team (see "dependence on unique roles staying alive") and it neuters the xeno's snowball mechanic (maturity and evolution are reset).
	- Xenos on the other hand gain psy points for purchasing beneficial structures and Primordial evolution, however xenos have to accumulate a lot more corpses for this.
- Easier to respec if needed. Marines can pick up a new weapon, get equipment sent down or briefly head shipside to swap to a whole new set of equipment.
	- Xenos on the other hand  to devolve one or more tiers then wait to evolve one or more tiers, which takes a lot of time.
- On Nuclear War: Marines losing control of their most important map area (FOB) is not too impactful as they also have a Tadpole for moving troops and can call an ERT for example.
	- Xenos on the other hand must defend their resin silo using their relatively weaker defensive structures, and losing it can make it very difficult to comeback from. It's so impactful that it's often the primary win condition, rather than collecting all nuke disks and using the nuclear bomb.

#### Similarities

- Both have mechanics intended to reduce their individual effectiveness if they take heavy damage during sustained combat (sunder for xenos, fractures for marines).
- Both have snowball mechanics (they get stronger over the course of the round if they're winning). Evolution, maturity and structures for xenos, req points for marines.
- Neither have catch-up mechanics (getting stronger if losing).

### Round flow

Both Xenos and marines should start on equal footing and have similar area control at the beginning of the round and additionally have lightly “biased” areas (Areas where there is an advantage for the defending side eg corridors for marines and caves for xenos) around the objective for both factions. This serves to preserve a challenge throughout the round while allowing both sides immediate strategic flexibility.

The round is divided into 2 phases: prep phase and combat phase. The swap of these is signified by the opening of shutters.

#### Xenomorphs

**Prep Phase**

Drone tree castes focus on construction, in particular mazing around disks (if the gamemode is Nuclear War), chokepoints, near Landing Zones and at their resin silo. Non-Drone tree castes focus on destroying obstacles that are beneficial to marines (e.g. windows) and ones which can hamper movement or mazing (e.g. window frames, boxes etc). Castes with the Corrosive Acid ability also melt walls to allow better hit-and-run attacks from multiple angles, and to prevent being cornered into a dead end.

**Combat Phase**

Everyone with the ability to emit pheromones does so, and the Queen selects leaders to emit their pheromones too. Most Drone tree castes keep the battlefield weeded and build wall cover as their first priorities, as well as keeping the team healed and plasma

#### TG Marines

**Prep Phase**

Marines obtain all the equipment they're going to keep on their body, whatever else they're going to bring with them, and anything else that they want to bring on the Alamo or Tadpole.

**Combat Phase**

TBA

### Respawning and progression

#### Xenomorphs

Respawning is handled by having a set amount of larva for marines (see crash). Upon death the larva will be temporarily disabled for 10 minutes. Prospective xeno players can play as a minion while waiting.

A currently pending respawn timer can be reduced by 1 minute by psy-draining a dead human, which also gives some psy points and gives them clone damage. Alternatively you may cocoon them for a much larger psy point generation over time that however extends their revival timer.

Xenos will progress through tiers by passively gaining evolution points. This will happen slowly over time (slower than now). Note: no maturity.

Xenos are able to switch between castes on a long cooldown (15 minutes). This is intended to prevent players from being locked into very situational castes without wanting to do so, for example playing ravager during a siege.

#### TG Marines

TBA

### Construction

#### Xenomorphs

Construction is the main form of progression for xenos. All purchasable improvements that provide benefit to the entire hive should have a physical representation. This aims to provide something to fight around/towards. See old school RTSes like C&C. (Long term consideration, add distance-based buffs for building closer to enemies)

Building will cost either tactical or strategic psy points. Strategic psy points are usable by all T4 xenos, and tactical by all xenos that can build. Strategic psy points include major impact purchases such as silos, primordial, etc, while tactical is lower impact such as turrets, special walls, etc.
Possible upgrades can include things like faster maturity, more slots, turrets, etc.

Builder roles can also build defensive structures such as walls and doors in order to provide a defensive line.

#### TG Marines

TBA

### Combat

#### Xenomorphs

Xenomorphs main attacking method is through melee, with the specialized exception of the sentinel line of castes, which trades tankiness for ranged ability.

Xenos should be able to both attack and defend from their current position at any given point in the round. Xenos primary engagement is skirmish-style where they will engage for a short period before retreating to recover plasma and health.

Sundering is a mechanic to ensure that xenos do not pressure marines 24/7 without consequences. To heal sunder, xenos can be healed by other xenos, or even faster, go to a structure that heals sunder.

**Abilities**

Xenomorph abilities are primarily very selfish, and aim to give the user more creative ways to synergise with the rest of their kit and provide situational benefits in combat. An exception are teamwork oriented castes such as drone. The use of these abilities is limited by plasma. Plasma should typically be enough for a brief engagement before they are forced to retreat again, and serves to stop the xeno from constantly attacking over and over with no reprieve.

Abilities are tied to progression using “Primordial” - these are abilities where after staying alive for a certain time unlocks a capstone ability.

Abilities should aim to be (in order):
1) Fun to use
2) Have a form of counterplay i.e. marines cannot be vulnerable at all times with no method of preventing it
3) Not aim to reduce marine player agency through e.g. stuns longer than short periods.
4) Synergise with either:
	- Other xenos (regardless of caste)
	- The rest of the users toolkit (see #1)
5) Be visually and auditorily appealing (see #1)

#### TG Marines

TBA

### Skill Level

#### Xenomorphs

Generally due to how players work they will progress through the tiers naturally as their skill increases e.g. a new player will die a lot as a Runner before surviving long enough to play a little as Hunter.
#### TG Marines

As there are a lot more players in this faction (around ~3x the amount of player xenos) and a vast majority of them being the Marine role the skill floor is very low. The numerous skilled players can carry less skilled players to average out the team capability. The skill ceiling remains high however.

## Future Design

### Gameplay

#### Xenomorphs

**Rework 1 ideas:**

- Allow low skill xenos as well?). There should always be an acceptable minimum of these AIs that scales with pop (ratio TBD)
- on TTS should hivemind play as well? and if yes can it be made so admins crack down on the ooc in ic
- Garrison (Tivi, pending map)
- Maturity removal, primo stay on maturity system
- Upping Minion spawn rate
- Xeno TTS (Tivi)
- Splitting psy points into tactical/strategic
- Make minions playable while in queue
- Adding a dedicated "become minion" button to make it easier for new players to become one
- Crash style respawn system (change psy drain and silos too)
- Sunder healing nerf, add sundering heal building (tac points)
- Skill levels should also also be reflected in the design of the castes, needing a high amount of skill (both floor and ceiling ideally) to play well as the tier increases.
- Low skill xenos playing as minions?
- There should always be an acceptable minimum of these AI minions that scales with pop (ratio TBD).

### Round flow

#### Xenomorphs

- During the combat phase all roles should directly or indirectly be able to fight in this phase.
- During the prep phase there needs to be some form of entertainment (Survs are excluded as a bad idea). Temp fix: xenos may swap castes on a long timer.

### Respawning and progression

#### Xenomorphs

- Respawning is handled by having a set amount of larva for marines (see crash). Upon death the larva will be temporarily disabled for 10 minutes. Prospective xeno players can play as a minion while waiting.
- A currently pending respawn timer can be reduced by 1 minute by psy-draining a dead human, which also gives some psy points and gives them clone damage. Alternatively you may cocoon them for a much larger psy point generation over time that however extends their revival timer.
- Xenos will progress through tiers by passively gaining evolution points. This will happen slowly over time (slower than now). Note: no maturity.
- Xenos are able to switch between castes on a long cooldown (15 minutes). This is intended to prevent players from being locked into very situational castes without wanting to do so, for example playing ravager during a siege.

### Construction

#### Xenomorphs

- Do we need more types of defensive structures? e.g. very expensive but durable wall
- what to do with miner/gen corruption, likely want miners to be capable for both. Discuss with grayson
