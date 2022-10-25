/client/script = {"<style>
html, body {
	padding: 0;
	margin: 0;
	height: 100%;
	color: #000000;
}
body {
	background: #fff;
    font-family: Verdana, sans-serif;
    font-size: 9pt;
    line-height: 1.2;
	overflow-x: hidden;
	overflow-y: scroll;
	word-wrap: break-word;
}

em {
	font-style: normal;
	font-weight: bold;
}

img {
	margin: 0;
	padding: 0;
	line-height: 1;
	-ms-interpolation-mode: nearest-neighbor;
	image-rendering: pixelated;
}
img.icon {
	height: 1em;
	min-height: 16px;
	width: auto;
	vertical-align: bottom;
}


.r:before {
	content: 'x';
}
.r {
	display: inline-block;
	min-width: 0.5em;
	font-size: 0.7em;
	padding: 0.2em 0.3em;
	line-height: 1;
	color: white;
	text-align: center;
	white-space: nowrap;
	vertical-align: middle;
	background-color: crimson;
	border-radius: 10px;
}

a {color: #0000ff;}
a.visited {color: #ff00ff;}
a:visited {color: #ff00ff;}
a.popt {text-decoration: none;}


.bold, .name, .prefix, .ooc, .looc, .adminooc, .admin, .medal, .yell {font-weight: bold;}

.italic, .italics,  .emote {font-style: italic;}

.highlight {background: yellow;}

.motd					{color: #638500;	font-family: Verdana, sans-serif;}
.motd h1, .motd h2, .motd h3, .motd h4, .motd h5, .motd h6
	{color: #638500;	text-decoration: underline;}
.motd a, .motd a:link, .motd a:visited, .motd a:active, .motd a:hover
	{color: #638500;}
.tip					{color: #a000c4;	font-weight: bold;}

.prefix					{					font-weight: bold;}

.ooc					{					font-weight: bold;}
.colorooc				{color: #002eb8;	font-weight: bold;}
.looc					{color: #6699CC;	font-weight: bold;}
.hostooc				{color: #000000;	font-weight: bold;}
.projleadooc			{color: #800080;	font-weight: bold;}
.headcoderooc			{color: #000064;	font-weight: bold;}
.headminooc				{color: #640000;	font-weight: bold;}
.headmentorooc			{color: #004100;	font-weight: bold;}
.adminooc				{color: #b4001e;	font-weight: bold;}
.trialminooc			{color: #f03200;	font-weight: bold;}
.candiminooc			{color: #ff5a1e;	font-weight: bold;}
.mentorooc				{color: #008000;	font-weight: bold;}
.maintainerooc			{color: #1e4cd6;	font-weight: bold;}
.contributorooc			{color: #0064ff;	font-weight: bold;}
.otherooc				{color: #643200;	font-weight: bold;}

.msay					{color: #775c40;	font-weight: bold;}
.adminmsay				{color: #66411e;	font-weight: bold;}
.headminmsay			{color: #402A14;	font-weight: bold;}

.admin					{color: #386aff;	font-weight: bold;}
.asay					{color: #9611D4;	font-weight: bold;}
.headminasay			{color: #5A0A7F;	font-weight: bold;}
.boldannounce			{color: #ff0000;	font-weight: bold;}

.staffpmout				{color: red;	font-weight: bold;}
.staffpmin				{color: blue;	font-weight: bold;}

.adminnotice			{color: #0000ff;}
.adminhelp              {color: #ff0000;    font-weight: bold;}

.name					{					font-weight: bold;}

.say					{}
.deadsay				{color: #5c00e6;}
.radio					{color: #4E4E4E;}
.deptradio				{color: #993399;}
.comradio				{color: #004080;}
.syndradio				{color: #6D3F40;}
.centradio				{color: #5C5C8A;}
.airadio				{color: #FF00FF;}

.casradio				{color: #A30000;}
.engradio				{color: #A66300;}
.medradio				{color: #008160;}
.sciradio				{color: #993399;}
.supradio				{color: #5F4519;}

.alpharadio				{color: #EA0000;}
.bravoradio				{color: #C68610;}
.charlieradio			{color: #AA55AA;}
.deltaradio				{color: #007FCF;}

.zuluradio				{color: #FF6A00;}
.yankeeradio			{color: #009999;}
.xrayradio				{color: #008000;}
.whiskeyradio			{color: #CC00CC;}

.thetaradio				{color: #ffce50;}
.omegaradio				{color: #4c8929;}
.gammaradio				{color: #90e6ff;}
.sigmaradio				{color: #ff0000;}

.binarysay    			{color: #20c20e; background-color: #000000; display: block;}
.binarysay a  			{color: #00ff00;}
.binarysay a:active, .binarysay a:visited {color: #88ff88;}

.alert					{color: #ff0000;}
h1.alert, h2.alert		{color: #000000;}

.emote					{					font-style: italic;}
.selecteddna			{color: #FFFFFF; 	background-color: #001B1B}

.singing				{font-family: "Trebuchet MS", cursive, sans-serif; font-style: italic;}

.attack					{color: #ff0000;}
.moderate				{color: #CC0000;}
.disarm					{color: #990000;}
.passive				{color: #660000;}

.scanner			{color: #ff0000;}
.scannerb			{color: #ff0000;	font-weight: bold;}
.scannerburn	{color: #ffa500;}
.scannerburnb	{color: #ffa500;	font-weight: bold;}
.rose					{color: #ff5050;}
.info					{color: #0000CC;}
.debuginfo				{color: #493D26;	font-style: italic;}
.notice					{color: #000099;}
.xenonotice				{color: #2a623d;}
.boldnotice				{color: #000099;	font-weight: bold;}
.warning				{color: #ff0000;	font-style: italic;}
.xenowarning			{color: #2a623d;	font-style: italic;}
.userdanger				{color: #ff0000;	font-weight: bold;	font-size: 3em;}
.danger					{color: #ff0000;	font-weight: bold;}
.xenodanger				{color: #2a623d;	font-weight: bold;}
.avoidharm				{color:	#72a0e5;	font-weight: bold;}
.highdanger				{color: #ff0000;	font-weight: bold; font-size: 1.5em;}
.xenohighdanger			{color: #2a623d; 	font-weight: bold; font-size: 1.5em;}
.xenoannounce           {color: #1a472a;    font-family: book-antiqua; font-weight: bold; font-style: italic; font-size: 1.5em;}

.alien					{color: #543354;}
.newscaster				{color: #800000;}

.role_header			{color: #db0000;	display: block; text-align: center; font-weight: bold; font-family: trebuchet-ms; font-size: 1.5em;}
.role_body				{color: #000099;	display: block; text-align: center;}

.round_setup			{color: #db0000;		font-family: impact; font-size: 1.25em;}
.round_header			{color: #db0000; 	display: block; text-align: center; font-family: courier; font-weight: bold; font-size: 2em;}
.round_body				{color: #001427; 	display: block; text-align: center; font-family: trebuchet-ms; font-weight: bold; font-size: 1.5em;}
.event_announcement		{color: #600d48; 	font-family: arial-narrow; font-weight: bold; font-size: 1.5em;}

.centerbold				{				 	text-align: center; font-weight: bold;}

.rough					{font-family: trebuchet-ms, cursive, sans-serif;}
.say_quote				{font-family: Georgia, Verdana, sans-serif;}
.command_headset		{font-weight: bold; font-size: 18px;}
.robot					{font-family: "Courier New", cursive, sans-serif;}


.green					{color: #29b245;}
.nicegreen				{color: #14a833;}
.shadowling				{color: #3b2769;}
.cult					{color: #960000;}
.cultlarge				{color: #960000; font-weight: bold; font-size: 3;}
.narsie					{color: #960000; font-weight: bold; font-size: 15;}
.narsiesmall			{color: #960000; font-weight: bold; font-size: 6;}
.colossus				{color: #7F282A; font-size: 5;}
.hierophant				{color: #660099; font-weight: bold; font-style: italic;}
.hierophant_warning		{color: #660099; font-style: italic;}
.purple					{color: #5e2d79;}
.holoparasite			{color: #35333a;}

.revennotice			{color: #1d2953;}
.revenboldnotice		{color: #1d2953;	font-weight: bold;}
.revenbignotice			{color: #1d2953;	font-weight: bold; font-size: 3;}
.revenminor				{color: #823abb}
.revenwarning			{color: #760fbb;	font-style: italic;}
.revendanger			{color: #760fbb;	font-weight: bold; font-size: 3;}
.umbra					{color: #5000A0;}
.umbra_emphasis			{color: #5000A0;	font-weight: bold;	font-style: italic;}
.umbra_large			{color: #5000A0; font-size: 3; font-weight: bold; font-style: italic;}

.deconversion_message	{color: #5000A0; font-size: 3; font-style: italic;}

.interface				{color: #330033;}

.connectionClosed, .fatalError {background: red; color: white; padding: 5px;}
.connectionClosed.restored {background: green;}
.internal.boldnshit {color: blue; font-weight: bold;}

.text-normal {font-weight: normal; font-style: normal;}
.hidden {display: none; visibility: hidden;}
</style>"}
