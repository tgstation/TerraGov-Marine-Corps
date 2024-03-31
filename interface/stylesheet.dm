/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// !!!!!!!!!!HEY LISTEN!!!!!!!!!!!!!!!!!!!!!!!!
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// If you modify this file you ALSO need to modify code/modules/goonchat/browserAssets/browserOutput.css and browserOutput_white.css
// BUT you have to use PX font sizes with are on a x8 scale of these font sizes
// Sample font-size: DM: 8 CSS: 64px

/client/script = {"<style>
body					{text-shadow:0 0 10px #fff, 0 0 20px #fff, 0 0 30px #e60073, 0 0 40px #e60073, 0 0 50px #e60073, 0 0 60px #e60073, 0 0 70px #e60073;	word-wrap: break-word; overflow-x: hidden; overflow-y: scroll; color: #c9c1ba; font-size: 16px; font-family: "Pterra";}

h1, h2, h3, h4, h5, h6	{color: #c9c1ba;	font-family: Pterra;}

em						{font-style: normal;	font-weight: bold; font-family: Pterra;}

a:link						{color: #ae83cb;	font-weight: bold;}

.motd					{color: #638500;	font-family: Pterra;}
.motd h1, .motd h2, .motd h3, .motd h4, .motd h5, .motd h6
	{color: #638500;	text-decoration: underline;}
.motd a, .motd a:link, .motd a:visited, .motd a:active, .motd a:hover
	{color: #638500;}
h1.alert, h2.alert	{color: #c9c1ba;font-family: Pterra, TrueType;}
.italics				{					font-style: italic;}

.bold					{					font-weight: bold;}

.prefix					{					font-weight: bold;}

.ooc					{color: #c5c5c5;	font-weight: bold; font-family: Pterra;}
.adminobserverooc		{color: #cca300;	font-weight: bold; font-family: Pterra;}
.adminooc				{color: #4972bc;	font-weight: bold;}

.adminsay				{color:	#FF4500;	font-weight: bold;}
.admin					{color: #386aff;	font-weight: bold;}

.name					{					font-weight: bold;}

.say					{font-family: Pterra;}
.deadsay				{color: #e2c1ff}
.binarysay				{color: #20c20e;	background-color: #000000;	display: block;}
.binarysay a			{color: #00ff00;}
.binarysay a:active, .binarysay a:visited {color: #88ff88;}
.radio					{color: #1ecc43;}
.sciradio				{color: #c68cfa;}
.comradio				{color: #5177ff;}
.secradio				{color: #dd3535;}
.medradio				{color: #57b8f0;}
.engradio				{color: #f37746;}
.suppradio				{color: #b88646;}
.servradio				{color: #6ca729;}
.syndradio				{color: #8f4a4b;}
.centcomradio			{color: #2681a5;}
.aiprivradio			{color: #d65d95;}
.redteamradio			{color: #ff4444;}
.blueteamradio			{color: #3434fd;}


.yell					{					font-weight: bold;}

.alert					{color: #d82020;}

.emote					{color: #b1bb9f;}

.crit					{color: #c71d76;}
.userdanger				{color: #c71d76;	font-weight: bold;	font-size: 120%;}
.danger					{color: #b9322b;	font-weight: bold;}
.warning				{color: #bb4e28;						font-size: 75%;}
.boldwarning			{color: #bb4e28;	font-weight: bold}
.announce				{color: #c51e1e;	font-weight: bold;}
.boldannounce			{color: #c51e1e;	font-weight: bold;}
.greenannounce			{color: #059223;	font-weight: bold;}
.rose					{color: #e7bed8;}
.love					{color: #e7bed8;	font-size: 75%;}
.info					{color: #a9a5b6;						font-size: 75%;}
.biginfo					{color: #a9a5b6;}
.notice					{color: #f1d669;}
.boldnotice				{color: #f1d669;	font-weight: bold;}
.hear					{color: #6685f5;	font-style: italic;}
.adminnotice			{color: #6685f5;}
.adminhelp				{color: #ff0000;	font-weight: bold;}
.unconscious			{color: #c9c1ba;	font-weight: bold;}
.suicide				{color: #ff5050;	font-style: italic;}
.green					{color: #80b077;}
.red					{color: #b84d47;}
.blue					{color: #6a8cb7;}
.purple					{color: #967aaf;}
.nicegreen				{color: #9bccd0;}
.cult					{color: #960000;}
.cultlarge				{color: #960000;	font-weight: bold;	font-size: 3;}
.narsie					{color: #960000;	font-weight: bold;	font-size: 12;}
.narsiesmall			{color: #960000;	font-weight: bold;	font-size: 6;}
.colossus				{color: #7F282A;	font-size: 5;}
.hierophant				{color: #660099;	font-weight: bold;	font-style: italic;}
.hierophant_warning		{color: #660099;	font-style: italic;}
.purple					{color: #5e2d79;}
.holoparasite			{color: #35333a;}

.revennotice			{color: #1d2953;}
.revenboldnotice		{color: #1d2953;	font-weight: bold;}
.revenbignotice			{color: #1d2953;	font-weight: bold;	font-size: 3;}
.revenminor				{color: #823abb}
.revenwarning			{color: #760fbb;	font-style: italic;}
.revendanger			{color: #760fbb;	font-weight: bold;	font-size: 3;}

.deconversion_message	{color: #5000A0;	font-size: 3;	font-style: italic;}

.ghostalert				{color: #5c00e6;	font-style: italic;	font-weight: bold;}

.alien					{color: #543354;}
.noticealien			{color: #00c000;}
.alertalien				{color: #00c000;	font-weight: bold;}
.changeling				{color: #800080;	font-style: italic;}

.spider					{color: #4d004d;}

.interface				{color: #330033;}

.sans					{font-family: "Comic Sans MS", cursive, sans-serif;}
.papyrus				{font-family: "Papyrus", cursive, sans-serif;}
.robot					{font-family: "Courier New", cursive, sans-serif;}


.human					{font-family: "Honoka Mincho", Pterra;}
.elf					{font-family: "Dauphin", cursive, Pterra;}
.dwarf					{font-family: "MasonAlternate", Pterra;}
.sandspeak				{font-family: "Arabolical", Pterra;}
.delf					{font-family: "Dauphin", Pterra;}
.hellspeak				{font-family: "Nosfer", Pterra;}
.undead					{font-family: "FriskyVampire", Pterra;}
.orc					{font-family: "Thief by The Riddler", Pterra;}
.beast					{font-family: "Thief by The Riddler", Pterra;}

.torture				{color: #42ff20}

.command_headset		{font-weight: bold;	font-size: 3;}
.small					{font-size: 50%;}
.smallyell				{font-size: 70%;font-family: Pterra;}
.big					{font-size: 120%;}
.reallybig				{font-size: 180%;}
.extremelybig			{font-size: 220%;}
.greentext				{color: #00FF00;}
.redtext				{color: #FF0000;}
.clown					{color: #FF69Bf;	font-size: 3;	font-family: "Comic Sans MS", cursive, sans-serif;	font-weight: bold;}
.his_grace				{color: #15D512;	font-family: "Courier New", cursive, sans-serif;	font-style: italic;}
.hypnophrase			{color: #3bb5d3;	font-weight: bold;	animation: hypnocolor 1500ms infinite;}
	@keyframes hypnocolor {
		0%		{color: #0d0d0d;}
		25%		{color: #410194;}
		50%		{color: #7f17d8;}
		75%		{color: #410194;}
		100%	{color: #3bb5d3;}
}

.phobia			{color: #dd0000;	font-weight: bold;	animation: phobia 750ms infinite;}
	@keyframes phobia {
		0%		{color: #0d0d0d;}
		50%		{color: #dd0000;}
		100%	{color: #0d0d0d;}
}

.icon					{height: 1em;	width: auto;}

.memo					{color: #638500;	text-align: center;}
.memoedit				{text-align: center;	font-size: 2;}
.abductor				{color: #800080;	font-style: italic;}
.mind_control			{color: #A00D6F;	font-size: 3;	font-weight: bold;	font-style: italic;}
.slime					{color: #00CED1;}
.drone					{color: #848482;}
.monkey					{color: #975032;}
.swarmer				{color: #2C75FF;}
.resonate				{color: #298F85;}

.monkeyhive				{color: #774704;}
.monkeylead				{color: #774704;	font-size: 2;}
</style>"}
