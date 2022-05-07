// Radios use a large variety of predefined frequencies.

//say based modes like binary are in living/say.dm

#define RADIO_CHANNEL_COMMON "Common"
#define RADIO_CHANNEL_COMMON_REBEL "Common Rebel"
#define RADIO_CHANNEL_SOM "Common SOM"
#define RADIO_KEY_COMMON ";"

#define RADIO_CHANNEL_REQUISITIONS "Requisitions"
#define RADIO_CHANNEL_REQUISITIONS_REBEL "Requisitions Rebel"
#define RADIO_KEY_REQUISITIONS "u"
#define RADIO_TOKEN_REQUISITIONS ":u"

#define RADIO_CHANNEL_ENGINEERING "Engineering"
#define RADIO_CHANNEL_ENGINEERING_REBEL "Engineering Rebel"
#define RADIO_CHANNEL_ENGINEERING_SOM "Engineering SOM"
#define RADIO_KEY_ENGINEERING "e"
#define RADIO_TOKEN_ENGINEERING ":e"

#define RADIO_CHANNEL_MEDICAL "Medical"
#define RADIO_CHANNEL_MEDICAL_REBEL "Medical Rebel"
#define RADIO_CHANNEL_MEDICAL_SOM "Medical SOM"
#define RADIO_KEY_MEDICAL "m"
#define RADIO_TOKEN_MEDICAL ":m"

#define RADIO_CHANNEL_COMMAND "Command"
#define RADIO_CHANNEL_COMMAND_REBEL "Command Rebel"
#define RADIO_CHANNEL_COMMAND_SOM "Command SOM"
#define RADIO_KEY_COMMAND "v"
#define RADIO_TOKEN_COMMAND ":v"

#define RADIO_CHANNEL_CAS "Fire support"
#define RADIO_CHANNEL_CAS_REBEL "Fire support Rebel"
#define RADIO_KEY_CAS "s"
#define RADIO_TOKEN_CAS ":s" //s for support

#define RADIO_CHANNEL_ALPHA "Alpha"
#define RADIO_CHANNEL_ALPHA_REBEL "Alpha Rebel"
#define RADIO_CHANNEL_ZULU "Zulu"
#define RADIO_KEY_ALPHA "q"
#define RADIO_TOKEN_ALPHA ":q"

#define RADIO_CHANNEL_BRAVO "Bravo"
#define RADIO_CHANNEL_BRAVO_REBEL "Bravo Rebel"
#define RADIO_CHANNEL_YANKEE "Yankee"
#define RADIO_KEY_BRAVO "b"
#define RADIO_TOKEN_BRAVO ":b"

#define RADIO_CHANNEL_CHARLIE "Charlie"
#define RADIO_CHANNEL_CHARLIE_REBEL "Charlie Rebel"
#define RADIO_CHANNEL_XRAY "Xray"
#define RADIO_KEY_CHARLIE "c"
#define RADIO_TOKEN_CHARLIE ":c"

#define RADIO_CHANNEL_DELTA "Delta"
#define RADIO_CHANNEL_DELTA_REBEL "Delta Rebel"
#define RADIO_CHANNEL_WHISKEY "Whiskey"
#define RADIO_KEY_DELTA "d"
#define RADIO_TOKEN_DELTA ":d"


#define RADIO_CHANNEL_COLONIST "Colonist"
#define RADIO_CHANNEL_PMC "NT PMC"
#define RADIO_CHANNEL_USL "USL"
#define RADIO_CHANNEL_DEATHSQUAD "Deathsquad"
#define RADIO_CHANNEL_IMPERIAL "Imperial"
#define RADIO_CHANNEL_SECTOID "Alien"
#define RADIO_CHANNEL_ECHO "Echo"
#define RADIO_CHANNEL_DS1 "Alamo"
#define RADIO_CHANNEL_DS2 "Normandy"


#define MIN_FREE_FREQ 1201 // -------------------------------------------------
// Frequencies are always odd numbers and range from 1201 to 1599.

//SOM squads
#define FREQ_COMMAND_SOM 1235
#define FREQ_MEDICAL_SOM 1237
#define FREQ_ENGINEERING_SOM 1239

#define FREQ_ZULU 1241
#define FREQ_YANKEE 1243
#define FREQ_XRAY 1245
#define FREQ_WHISKEY 1247

#define MIN_ERT_FREQ 1331
#define FREQ_PMC 1331
#define FREQ_COLONIST 1335
#define FREQ_USL 1337
#define FREQ_DEATHSQUAD 1339
#define FREQ_IMPERIAL 1341
#define FREQ_SOM 1343
#define FREQ_SECTOID 1347
#define FREQ_ECHO 1349
#define MAX_ERT_FREQ 1349

#define FREQ_COMMAND 1353
#define FREQ_MEDICAL 1355
#define FREQ_ENGINEERING 1357
#define FREQ_CAS 1359
#define FREQ_REQUISITIONS 1354

#define FREQ_ALPHA 1361
#define FREQ_BRAVO 1363
#define FREQ_CHARLIE 1365
#define FREQ_DELTA 1367
#define FREQ_AI 1369

#define FREQ_COMMAND_REBEL 1371
#define FREQ_MEDICAL_REBEL 1373
#define FREQ_ENGINEERING_REBEL 1375
#define FREQ_CAS_REBEL 1377
#define FREQ_REQUISITIONS_REBEL 1379

#define FREQ_ALPHA_REBEL 1381
#define FREQ_BRAVO_REBEL 1383
#define FREQ_CHARLIE_REBEL 1385
#define FREQ_DELTA_REBEL 1387

#define FREQ_AI_REBEL 1389

#define FREQ_STATUS_DISPLAYS 1435

#define FREQ_COMMON 1437
#define FREQ_COMMON_REBEL 1439

#define MIN_FREQ 1441 // ------------------------------------------------------
// Only the 1441 to 1489 range is freely available for general conversation.
// This represents 1/8th of the available spectrum.

#define FREQ_DROPSHIP_1 1441
#define FREQ_DROPSHIP_2 1443

#define FREQ_ELECTROPACK 1449
#define FREQ_SIGNALER 1457  // the default for new signalers

#define FREQ_CIV_GENERAL 1469


#define MAX_FREQ 1489 // ------------------------------------------------------


#define MAX_FREE_FREQ 1599 // -------------------------------------------------



// Transmission types.
#define TRANSMISSION_WIRE 0  // some sort of wired connection, not used
#define TRANSMISSION_RADIO 1  // electromagnetic radiation (default)
#define TRANSMISSION_SUBSPACE 2  // subspace transmission (headsets only)
#define TRANSMISSION_SUPERSPACE 3  // reaches independent (CentCom) radios only

// Filter types, used as an optimization to avoid unnecessary proc calls.
#define RADIO_TO_AIRALARM "to_airalarm"
#define RADIO_FROM_AIRALARM "from_airalarm"
#define RADIO_SIGNALER "signaler"
#define RADIO_ATMOSIA "atmosia"
#define RADIO_AIRLOCK "airlock"
#define RADIO_MAGNETS "magnets"
#define RADIO_NAVBEACONS "navebeacons"
#define RADIO_MULEBOT "mulebot"

#define DEFAULT_SIGNALER_CODE 30
