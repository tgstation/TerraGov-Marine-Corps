import { useBackend, useLocalState } from '../backend';
import { capitalize } from 'common/string';
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
} from '../components';
import { Window } from '../layouts';

const tabs = ['Mecha Assembly', 'Weapons'];
const partdefinetofluff = {
  'CHEST': 'Torso',
  'HEAD': 'Head',
  'L_ARM': 'Left Arm',
  'R_ARM': 'Right arm',
  'LEG': 'Legs',
};

type MechVendData = {
  mech_view: string;
  mech_view_east: string;
  mech_view_west: string;
  colors: ColorData;
  visor_colors: ColorData;
  bodypart_names: string[];
  selected_primary: SimpleStringList;
  selected_secondary: SimpleStringList;
  selected_visor: string;
  selected_variants: SimpleStringList;
  selected_name: string;
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
  const { act, data } = useBackend<MechVendData>(context);

  const {
    mech_view,
    colors,
    visor_colors,
    bodypart_names,
    selected_primary,
    selected_secondary,
    selected_visor,
    selected_variants,
    selected_name,
  } = data;

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', null); // tivi todo keep or del

  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    tabs[0]
  );

  return (
    <Window title={'Mecha Assembler'}>
      {showDesc ? ( // tivi todo for weapons
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button content="Dismiss" onClick={() => setShowDesc(null)} />
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
  const { act, data } = useBackend<MechVendData>(context);
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
    mech_view,
    colors,
    visor_colors,
    bodypart_names,
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
// tivi todo make mech name choosable?

const MechAssembly = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);
  const {
    mech_view,
    mech_view_east,
    mech_view_west,
    colors,
    visor_colors,
    bodypart_names,
    selected_primary,
    selected_secondary,
    selected_visor,
    selected_variants,
    selected_name,
  } = data;
  const [selectedBodypart, setSelectedBodypart] = useLocalState(
    context,
    'selectedBodypart',
    'none'
  );

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
              <Collapsible color={"transparent"} title={"Integrity: " + 2}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"L scatter angle: " + 2}>
                <Box maxWidth={"160px"}>Scatter angle for left arm.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"R scatter angle: " + 2}>
                <Box maxWidth={"160px"}>Scatter angle for right arm.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Slowdown: " + 2}>
                <Box maxWidth={"160px"}>Determines how fast mecha is compared to base.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Accuracy: " + 2}>
                <Box maxWidth={"160px"}>Determines likeliness of mecha to hit at long ranges.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bomb Armor: " + 2}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Light range: " + 2}>
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
              fontSize="150%"
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
              <Collapsible color={"transparent"} title={"Melee Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bullet Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Laser Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Energy Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bomb Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Bio Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Fire Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
              </Collapsible>
              <Collapsible color={"transparent"} title={"Acid Armor: " + 2 + "%"}>
                <Box maxWidth={"160px"}>Determines maximum integrity of mecha.</Box>
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
  // tivi todo prop type
  const {
    mech_view,
    colors,
    visor_colors,
    bodypart_names,
    selected_primary,
    selected_secondary,
    selected_visor,
    selected_variants,
    selected_name,
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
// tivi todo make mech name choosable?


const MechWeapons = (props, context) => {
  const { act, data } = useBackend<MechVendData>(context);

  const [showDesc, setShowDesc] = useLocalState<String | null>(
    context,
    'showDesc',
    null
  );

  return <Section title={'You are currently assembling your mech'} />;
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
