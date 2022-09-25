import { useBackend, useLocalState } from '../backend';
import { capitalize } from 'common/string';
import { classes } from 'common/react';
import {
  Button,
  Section,
  Box,
  Modal,
  Divider,
  Tabs,
  Stack,
  ByondUi,
  ColorBox,
  Collapsible,
  Input,
  LabeledList,
} from '../components';
import { Window } from '../layouts';
// tivi todo split this file
const tabs = ['Mecha Assembly', 'Weapons'];
const partdefinetofluff = {
  'CHEST': 'Torso',
  'HEAD': 'Head',
  'L_ARM': 'Left Arm',
  'R_ARM': 'Right arm',
  'LEG': 'Legs',
};
const MECHA_UTILITY = "mecha_utility";
const MECHA_POWER = "mecha_power";
const MECHA_ARMOR = "mecha_armor";

type MechVendData = {
  mech_view: string;
  colors: ColorData;
  visor_colors: ColorData;
  equip_max: MaxEquip;
  selected_primary: SimpleStringList;
  selected_secondary: SimpleStringList;
  selected_visor: string;
  selected_variants: SimpleStringList;
  selected_name: string;
  current_stats: MechStatData,
  all_equipment: AllEquipment,
  selected_equipment: SelectedEquip,
};

type MaxEquip = {
  [key: string]: number;
};

type AllEquipment = {
  weapons: MechWeapon[];
  ammo: MechAmmo[];
  armor: MechArmor[];
  utility: MechUtility[];
  power: MechPower[],
};

type MechWeapon = {
  type: string;
  name: string;
  desc: string;
  icon_state: string;
  health: number;
  firerate: number;
  burst_count: number;
  scatter: number;
  slowdown: number;
  damage: number|null,
  armor_pierce: number|null,
  projectiles: number|null,
  cache_max: number|null,
  ammo_type: string|null,
};

type MechAmmo = {
  type: string;
  name: string;
  icon_state: string;
  ammo_count: string;
  ammo_type: string|null,
};

type MechArmor = {
  type: string;
  name: string;
  desc: string;
  slowdown: number;
};

type MechUtility = {
  type: string;
  name: string;
  desc: string;
  energy_drain: number;
};

type MechPower = {
  type: string;
  name: string;
  desc: string;
};

type SelectedEquip = {
  mecha_l_arm: string;
  mecha_r_arm: string;
  mecha_utility: string[],
  mecha_power: string[],
  mecha_armor: string[],
};

type MechStatData = {
  accuracy: number;
  light_mod: number;
  left_scatter: number;
  right_scatter: number;
  health: number;
  slowdown: number;
  armor: string[],
  power_max: number,
};

type BodypartPickerData = {
  displayingpart: string;
};

type ColorDisplayData = {
  shown_colors: string;
};

type ColorData = {
  [key: string]: SimpleStringList;
};

type SimpleStringList = {
  [key: string]: string;
};

export const MechVendor = (props, context) => {
  const [showDesc, setShowDesc] = useLocalState<MechWeapon | null>(
    context,
    'showDesc',
    null
  );
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    tabs[0]
  );

  return (
    <Window title={'Mecha Assembler'}>
      {showDesc ? (
        <Modal width="500px">
          <Section title={showDesc.name} buttons={<Button content="Dismiss" onClick={() => setShowDesc(null)} />}>
            <Stack>
              <Stack.Item>
                <Box
                  className={classes(['mech_builder64x32', showDesc.icon_state])}
                  ml={5}
                  mr={20}
                  mt={3}
                  mb={9}
                  style={{
                    'transform': 'scale(3) translate(20%, 20%)',
                  }}
                />
                <LabeledList>
                  <LabeledList.Item label={"Max Integrity"}>
                    {showDesc.health}
                  </LabeledList.Item>
                  <LabeledList.Item label={"Fire rate"}>
                    {showDesc.firerate*10} per second
                  </LabeledList.Item>
                  {showDesc.burst_count? <LabeledList.Item label={"Burst amount"}>{showDesc.burst_count}</LabeledList.Item>
                    : null}
                  {showDesc.damage? <LabeledList.Item label={"Damage"}>{showDesc.damage}</LabeledList.Item>
                    : null}
                  {showDesc.armor_pierce ? <LabeledList.Item label={"Piercing"}>{showDesc.armor_pierce}</LabeledList.Item>
                    : null}
                  {showDesc.projectiles? <LabeledList.Item label={"Magazine size"}>{showDesc.projectiles}</LabeledList.Item>
                    : null}
                  {showDesc.cache_max? <LabeledList.Item label={"Ammo storage size"}>{showDesc.cache_max}</LabeledList.Item>
                    : null}
                  {showDesc.scatter? <LabeledList.Item label={"Scatter"}>{showDesc.scatter}°</LabeledList.Item>
                    : null}
                  <LabeledList.Item label={"Slowdown"}>{showDesc.slowdown}</LabeledList.Item>
                </LabeledList>
              </Stack.Item>
              <Stack.Item>
                <Box ml={-38}>{showDesc.desc + (showDesc.ammo_type ? " Loaded with: " + showDesc.ammo_type + ".": "")}</Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Modal>
      ) : null}
      <Window.Content>
        <Section lineHeight={1.75} textAlign="center">
          <Tabs fluid >
            {tabs.map((tabname) => {
              return (
                <Tabs.Tab
                  key={tabname}
                  selected={tabname === selectedTab}
                  fontSize="130%"
                  onClick={() => setSelectedTab(tabname)}>
                  {tabname}
                </Tabs.Tab>
              );
            })}
          </Tabs>
          <Divider />
        </Section>
        <PanelContent />
      </Window.Content>
    </Window>
  );
};

const ColorDisplayRow = (props: ColorDisplayData, context) => {
  const { shown_colors } = props;
  let splitted = shown_colors.split('#').map((item) => '#' + item);
  splitted.shift();
  return (
    <Stack>
      {splitted.map((color, i) => (
        <Stack.Item key={i}>
          <ColorBox mr={0.5} mb={0.5} color={color} width={2} height={2} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const BodypartPicker = (props: BodypartPickerData, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const { displayingpart } = props;
  const {
    selected_primary,
    selected_secondary,
    selected_visor,
    selected_variants,
  } = data;

  const [selectedBodypart, setSelectedBodypart] = useLocalState(
    context,
    'selectedBodypart',
    'none'
  );
  return (
    <Section
      fill
      title={
        selected_variants[displayingpart]
        + ' '
        + partdefinetofluff[displayingpart]
      }>
      <Button
        content="Select"
        fluid
        textAlign={'center'}
        mb={1}
        fontSize="110%"
        selected={displayingpart === selectedBodypart}
        onClick={() => setSelectedBodypart(displayingpart)}
      />
      <ColorDisplayRow shown_colors={selected_primary[displayingpart]} />
      <ColorDisplayRow shown_colors={selected_secondary[displayingpart]} />
      {displayingpart === 'HEAD' ? (
        <ColorDisplayRow shown_colors={selected_visor} />
      ) : null}
    </Section>
  );
};

const MechAssembly = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const {
    mech_view,
    selected_variants,
    selected_name,
    current_stats,
    all_equipment,
    selected_equipment,
  } = data;
  const [selectedBodypart, setSelectedBodypart] = useLocalState(
    context,
    'selectedBodypart',
    'none'
  );

  const left_weapon = all_equipment.weapons
    .find(o => o.type === selected_equipment.mecha_l_arm);
  const right_weapon = all_equipment.weapons
    .find(o => o.type === selected_equipment.mecha_r_arm);

  const left_weapon_scatter = right_weapon ? right_weapon.scatter : 0;
  const right_weapon_scatter = right_weapon ? right_weapon.scatter : 0;

  return (
    <Stack>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <BodypartPicker displayingpart="R_ARM" />
          </Stack.Item>
          <Stack.Item>
            <BodypartPicker displayingpart="CHEST" />
          </Stack.Item>
          <Stack.Item>
            <Input
              fluid
              placeholder={'Mech name'}
              value={selected_name}
              onChange={(e, value) => act('set_name', { new_name: value })}
            />
          </Stack.Item>
          <Stack.Item>
            <Section title={"Mech parameters"}>
              <Collapsible color={"transparent"} title={"Integrity: " + current_stats.health}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"L scatter angle: " + (current_stats.left_scatter + left_weapon_scatter) + "°"}>
                <Box maxWidth={"160px"}>Scatter angle for left arm.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"R scatter angle: " + (current_stats.right_scatter + right_weapon_scatter) + "°"}>
                <Box maxWidth={"160px"}>Scatter angle for right arm.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Slowdown: " + current_stats.slowdown}>
                <Box maxWidth={"160px"}>Determines how fast mecha is compared to base.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Extra Accuracy: " + (current_stats.accuracy*100) + "%"}>
                <Box maxWidth={"160px"}>Determines likeliness of mecha to hit at long ranges.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Power capacity: " + current_stats.power_max}>
                <Box maxWidth={"160px"}>Determines maximum mecha power.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Light range: " + current_stats.light_mod}>
                <Box maxWidth={"160px"}>Light strength.</Box>
              </Collapsible>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <BodypartPicker displayingpart="HEAD" />
          </Stack.Item>
          <Stack.Item>
            <ByondUi
              height="230px"
              width="250px"
              params={{
                id: mech_view,
                zoom: 5,
                type: 'map',
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              content="Recon"
              fluid
              icon={'khanda'}
              textAlign={'center'}
              fontSize="120%"
              selected={selected_variants[selectedBodypart] === 'Recon'}
              onClick={() =>
                act('set_bodypart', {
                  bodypart: selectedBodypart,
                  new_bodytype: 'Recon',
                })}
            />
            <Button
              content="Assault"
              fluid
              icon={'fist-raised'}
              textAlign={'center'}
              fontSize="120%"
              selected={selected_variants[selectedBodypart] === 'Assault'}
              onClick={() =>
                act('set_bodypart', {
                  bodypart: selectedBodypart,
                  new_bodytype: 'Assault',
                })}
            />
            <Button
              content="Vanguard"
              fluid
              icon={'shield-alt'}
              textAlign={'center'}
              fontSize="120%"
              selected={selected_variants[selectedBodypart] === 'Vanguard'}
              onClick={() =>
                act('set_bodypart', {
                  bodypart: selectedBodypart,
                  new_bodytype: 'Vanguard',
                })}
            />
            <Button
              content="ASSEMBLE"
              fluid
              mt={2}
              color={'red'}
              textAlign={'center'}
              fontSize="170%"
              onClick={() => act('assemble')}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <BodypartPicker displayingpart="L_ARM" />
          </Stack.Item>
          <Stack.Item>
            <BodypartPicker displayingpart="LEG" />
          </Stack.Item>
          <Stack.Item>
            <Section title={"Mech armor"}>
              <Collapsible color={"transparent"} title={"Melee Armor: " + current_stats.armor["melee"] + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bullet Armor: " + current_stats.armor["melee"] + "%"}>
                <Box maxWidth={"160px"}>Bullet protection.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Laser Armor: " + current_stats.armor["laser"] + "%"}>
                <Box maxWidth={"160px"}>Laser protection.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Energy Armor: " + current_stats.armor["energy"] + "%"}>
                <Box maxWidth={"160px"}>Protection against SOM weapons.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bomb Armor: " + current_stats.armor["bomb"] + "%"}>
                <Box maxWidth={"160px"}>Explosion protection.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bio Armor: " + current_stats.armor["bio"] + "%"}>
                <Box maxWidth={"160px"}>Protection against chemical attacks.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Fire Armor: " + current_stats.armor["fire"] + "%"}>
                <Box maxWidth={"160px"}>Protection against incendiary weapons.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Acid Armor: " + current_stats.armor["acid"] + "%"}>
                <Box maxWidth={"160px"}>Xeno acid protection.</Box>
              </Collapsible>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <ColorSelector type={'primary'} listtoshow={data.colors} />
          </Stack.Item>
          <Stack.Item>
            <ColorSelector type={'secondary'} listtoshow={data.colors} />
          </Stack.Item>
          <Stack.Item>
            <ColorSelector type={'visor'} listtoshow={data.visor_colors} />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const ColorSelector = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const {
    selected_primary,
    selected_secondary,
    selected_visor,
  } = data;
  const { type, listtoshow } = props;
  const [selectedBodypart, setSelectedBodypart] = useLocalState(
    context,
    'selectedBodypart',
    'none'
  );
  return (
    <Section title={capitalize(type) + ' colors'}>
      {Object.keys(listtoshow).map((title) => (
        <Collapsible ml={1} minWidth={23} key={title} title={title}>
          {Object.keys(listtoshow[title]).map((palette) => (
            <Stack justify="space-between" key={palette} fill>
              <Stack.Item>
                <Button
                  content={palette}
                  textAlign={'center'}
                  mt={0.5}
                  selected={
                    listtoshow[title][palette] === selected_visor
                    || ((listtoshow[title][palette]
                      === selected_primary[selectedBodypart])
                      && type === 'primary')
                    || ((listtoshow[title][palette]
                      === selected_secondary[selectedBodypart])
                      && type === 'secondary')
                  }
                  onClick={() =>
                    act('set_' + type, {
                      bodypart: selectedBodypart,
                      new_color: palette,
                    })}
                />
              </Stack.Item>
              <Stack.Item>
                <ColorDisplayRow shown_colors={listtoshow[title][palette]} />
              </Stack.Item>
            </Stack>
          ))}
        </Collapsible>
      ))}
    </Section>
  );
};

const SelectedEquipment = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const {
    equip_max,
    all_equipment,
    selected_equipment,
  } = data;
  const [showDesc, setShowDesc] = useLocalState<MechWeapon | null>(
    context,
    'showDesc',
    null
  );
  const selected_left = all_equipment.weapons
    .find(o => o.type === selected_equipment.mecha_l_arm);
  const selected_right = all_equipment.weapons
    .find(o => o.type === selected_equipment.mecha_r_arm);

  let utility_modules = selected_equipment.mecha_utility
    .map(type => all_equipment.utility.find(o => o.type === type))
    .filter((x): x is MechUtility => x !== undefined);

  const power_modules = selected_equipment.mecha_power
    .map(type => all_equipment.power.find(o => o.type === type))
    .filter((x): x is MechPower => x !== undefined);

  const armor_modules = selected_equipment.mecha_armor
    .map(type => all_equipment.armor.find(o => o.type === type))
    .filter((x): x is MechArmor => x !== undefined);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Section title={selected_left ? selected_left.name.split(" ")[0] : "None"} width={"145px"} buttons={
              <Button icon="minus" color="red" onClick={() => act('remove_weapon', { is_right_weapon: 0 })} />
            }>
              <Box
                className={classes(['mech_builder64x32', selected_left ? selected_left.icon_state : "assaultrifle"])}
                ml={3}
                mt={3}
                mb={4}
                style={{
                  'transform': 'scale(2) translate(10%, 10%)',
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={selected_right ? selected_right.name.split(" ")[0] : "None"} width={"145px"} buttons={
              <Button icon="minus" color="red" onClick={() => act('remove_weapon', { is_right_weapon: 1 })} />
            }>
              <Box
                className={classes(['mech_builder64x32', selected_right ? selected_right.icon_state : "assaultrifle"])}
                ml={3}
                mt={3}
                mb={4}
                style={{
                  'transform': 'scale(2) translate(10%, 10%)',
                }}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section maxWidth={"300px"} title={"Utility (" + utility_modules.length + "/" + equip_max[MECHA_UTILITY] + ")"} >
          {utility_modules.map(module => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={(
                <Button icon="minus" color="red" onClick={() => act('remove_utility', { type: module.type })} />
              )}>
              <Section title={"Description"}>
                {module.desc} Has an energy drain of {module.energy_drain}.
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section maxWidth={"300px"} title={"Power (" + power_modules.length + "/" + equip_max[MECHA_POWER] + ")"}>
          {power_modules.map(module => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={(
                <Button icon="minus" color="red" onClick={() => act('remove_power', { type: module.type })} />
              )}>
              <Section title={"Description"}>
                {module.desc}
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section maxWidth={"300px"} title={"Armor (" + armor_modules.length + "/" + equip_max[MECHA_ARMOR] + ")"}>
          {armor_modules.map(module => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={(
                <Button icon="minus" color="red" onClick={() => act('remove_armor', { type: module.type })} />
              )}>
              <Section title={"Description"}>
                {module.desc} Has an slowdown drain of {module.slowdown}.
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const WeaponModuleList = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const { listtoshow } = props;
  const [showDesc, setShowDesc] = useLocalState<MechWeapon | null>(
    context,
    'showDesc',
    null
  );
  const {
    all_equipment,
    selected_equipment,
  } = data;
  return (
    <Section title={"Weapon modules"}>
      {listtoshow.map(module => {
        const ammoobject = all_equipment.ammo
          .find(o => o.ammo_type === module.ammo_type);
        return (
          <Collapsible
            key={module.type}
            title={module.name}
            buttons={(
              <>
                <Button
                  selected={module.type === selected_equipment.mecha_l_arm}
                  onClick={() => act('add_weapon', { type: module.type, is_right_weapon: 0 })}>
                  Left
                </Button>
                <Button
                  selected={module.type === selected_equipment.mecha_r_arm}
                  onClick={() => act('add_weapon', { type: module.type, is_right_weapon: 1 })}>
                  Right
                </Button>
                <Button
                  icon="question"
                  onClick={() => setShowDesc(module)} />
              </>
            )}>
            <Section title={ammoobject ? ammoobject.name : "No ammo available"}>
              {ammoobject ? (
                <Stack>
                  <Stack.Item>
                    <Stack vertical>
                      <Stack.Item>
                        <Box className={classes(['mech_ammo32x32', ammoobject.icon_state])} ml={1.5} mt={1.5} mb={3} style={{ 'transform': 'scale(2) translate(10%, 10%)' }} />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          mr={1.5}
                          ml={1.5}
                          content="Vend"
                          onClick={() => act('vend_ammo', { type: ammoobject.type })} />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    Contains: {ammoobject.ammo_count}
                    x {ammoobject.ammo_type}
                  </Stack.Item>
                </Stack>)
                : null }
            </Section>
          </Collapsible>
        );
      })}
    </Section>
  );
};

const MechWeapons = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const [showDesc, setShowDesc] = useLocalState<MechWeapon | null>(
    context,
    'showDesc',
    null
  );
  const {
    all_equipment,
    selected_equipment,
    equip_max,
  } = data;
  const midway = Math.ceil(all_equipment.weapons.length/2);
  const firstweapons = all_equipment.weapons.slice(0, midway);
  const secondweapons= all_equipment.weapons.slice(midway);
  return (
    <Stack>
      <Stack.Item>
        <SelectedEquipment />
      </Stack.Item>
      <Stack.Item>
        <WeaponModuleList listtoshow={firstweapons} />
      </Stack.Item>
      <Stack.Item>
        <WeaponModuleList listtoshow={secondweapons} />
      </Stack.Item>
      <Stack.Item>
        <Section title={"Power modules"}>
          {all_equipment.power.map(module => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={(
                <Button
                  disabled={selected_equipment.mecha_power.length
                    >= equip_max[MECHA_POWER]}
                  onClick={() => act('add_power', { type: module.type })}>
                  Add
                </Button>
              )}>
              <Section title={"Ammo"}>
                {module.desc}
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={"Armor modules"}>
          {all_equipment.armor.map(module => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={(
                <Button
                  disabled={selected_equipment.mecha_armor.length
                    >= equip_max[MECHA_ARMOR]}
                  onClick={() => act('add_armor', { type: module.type })}>
                  Add
                </Button>
              )}>
              <Section title={"Description"}>
                {module.desc}
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title={"Utility modules"}>
          {all_equipment.utility.map(module => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={(
                <Button
                  disabled={selected_equipment.mecha_utility.length
                    >= equip_max[MECHA_UTILITY]}
                  onClick={() => act('add_utility', { type: module.type })}>
                  Add
                </Button>
              )}>
              <Section title={"Description"}>
                {module.desc}
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const PanelContent = (props, context) => {
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    tabs[0]
  );
  {
    switch (selectedTab) {
      case 'Mecha Assembly':
        return <MechAssembly />;
      case 'Weapons':
        return <MechWeapons />;
      default:
        return null;
    }
  }
};
