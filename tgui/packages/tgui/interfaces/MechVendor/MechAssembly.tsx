import { useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Collapsible,
  ColorBox,
  Icon,
  Input,
  Modal,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import {
  BodypartPickerData,
  ColorDisplayData,
  MechVendData,
  partdefinetofluff,
} from './data';

function tryAssemble(setFailReason) {
  const { act, data } = useBackend<MechVendData>();
  const { selected_equipment, max_weight, weight } = data;
  let reasons: string[] = [];
  if (!selected_equipment.mecha_power.length) {
    reasons.push('Mecha power source is missing.');
  }
  if (weight > max_weight) {
    reasons.push('Mecha exceeds maximum weight limit.');
  }
  if (
    !selected_equipment.mecha_l_arm &&
    !selected_equipment.mecha_r_arm &&
    !selected_equipment.mecha_l_back &&
    !selected_equipment.mecha_r_back
  ) {
    reasons.push('Weapons missing.');
  }

  if (reasons.length > 0) {
    setFailReason(reasons.join('\n'));
  } else {
    act('assemble');
  }
}
const ColorDisplayRow = (props: ColorDisplayData) => {
  const { shown_colors, name, action } = props;
  let splitted = shown_colors.split('#').map((item) => '#' + item);
  splitted.shift();
  return (
    <Button color="transparent" tooltip={name} onClick={action}>
      {splitted.map((color, i) => (
        <ColorBox
          mt={0.5}
          mb={-0.5}
          mx={0}
          key={i}
          color={color}
          width={2}
          height={2}
        />
      ))}
    </Button>
  );
};

const BodypartPicker = (props: BodypartPickerData) => {
  const { act, data } = useBackend<MechVendData>();
  const { displayingpart, selectedBodypart, setSelectedBodypart } = props;
  const {
    selected_primary,
    selected_secondary,
    selected_visor,
    selected_variants,
    colors,
    visor_colors,
  } = data;

  const primaryKey = Object.keys(colors).reduce((acc, type) => {
    const key = Object.keys(colors[type]).find(
      (key) => colors[type][key] === selected_primary[displayingpart],
    );
    return key || acc;
  }, '');

  const secondaryKey = Object.keys(colors).reduce((acc, type) => {
    const key = Object.keys(colors[type]).find(
      (key) => colors[type][key] === selected_secondary[displayingpart],
    );
    return key || acc;
  }, '');

  const visorKey = Object.keys(visor_colors).reduce((acc, type) => {
    const key = Object.keys(visor_colors[type]).find(
      (key) => visor_colors[type][key] === selected_visor,
    );
    return key || acc;
  }, '');

  return (
    <Section
      fill
      title={
        selected_variants[displayingpart] +
        ' ' +
        partdefinetofluff[displayingpart]
      }
      textAlign="center"
    >
      <Stack vertical>
        <Stack.Item mt={0}>
          <Button
            content="Select"
            fluid
            textAlign={'center'}
            mb={1}
            fontSize="110%"
            selected={displayingpart === selectedBodypart}
            onClick={() => setSelectedBodypart(displayingpart)}
          />
        </Stack.Item>
        <Stack.Item mt={0}>
          <ColorDisplayRow
            shown_colors={selected_primary[displayingpart]}
            name={primaryKey}
          />
          {displayingpart === 'HEAD' && (
            <>
              <Tooltip content="Visor color" position="left">
                <Icon size={2} name="glasses" />
              </Tooltip>
              <ColorDisplayRow shown_colors={selected_visor} name={visorKey} />
            </>
          )}
        </Stack.Item>
        <Stack.Item mt={0}>
          <ColorDisplayRow
            shown_colors={selected_secondary[displayingpart]}
            name={secondaryKey}
          />
          {displayingpart === 'HEAD' && (
            <Button
              icon="rotate"
              width="105px"
              height="26px"
              fontSize="120%"
              mr={1}
              style={{
                transform: 'translateY(-15%)', // mt doesnt work
              }}
              onClick={() => act('rotate_doll')}
            >
              Rotate
            </Button>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const MechAssembly = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const {
    mech_view,
    selected_variants,
    selected_name,
    current_stats,
    all_equipment,
    selected_equipment,
    cooldown_left,
    selected_primary,
    selected_secondary,
    colors,
  } = data;
  const [selectedBodypart, setSelectedBodypart] = useState('HEAD');
  const [failReason, setFailReason] = useState('');

  const left_weapon = all_equipment.weapons.find(
    (o) => o.type === selected_equipment.mecha_l_arm,
  );
  const right_weapon = all_equipment.weapons.find(
    (o) => o.type === selected_equipment.mecha_r_arm,
  );
  const primaryKey = Object.keys(colors).reduce((acc, type) => {
    const key = Object.keys(colors[type]).find(
      (key) => colors[type][key] === selected_primary[selectedBodypart],
    );
    return key || acc;
  }, '');

  const secondaryKey = Object.keys(colors).reduce((acc, type) => {
    const key = Object.keys(colors[type]).find(
      (key) => colors[type][key] === selected_secondary[selectedBodypart],
    );
    return key || acc;
  }, '');

  const left_weapon_scatter = left_weapon ? left_weapon.scatter : 0;
  const right_weapon_scatter = right_weapon ? right_weapon.scatter : 0;
  return (
    <>
      {failReason && (
        <Modal align="center" position="relative" width="300px" left="200px">
          <Box mb={2}>
            {failReason.split('\n').map((reason, index) => (
              <Box key={index}>{reason}</Box>
            ))}
          </Box>
          <Button onClick={() => setFailReason('')}>Close</Button>
        </Modal>
      )}
      <Stack fill>
        <Stack.Item>
          <Stack vertical maxWidth={'166px'}>
            <Stack.Item>
              <BodypartPicker
                displayingpart="R_ARM"
                selectedBodypart={selectedBodypart}
                setSelectedBodypart={setSelectedBodypart}
              />
            </Stack.Item>
            <Stack.Item>
              <BodypartPicker
                displayingpart="CHEST"
                selectedBodypart={selectedBodypart}
                setSelectedBodypart={setSelectedBodypart}
              />
            </Stack.Item>
            <Stack.Item>
              <Input
                fluid
                placeholder={'Mech name'}
                value={selected_name}
                onChange={(value) => act('set_name', { new_name: value })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                fluid
                onClick={() =>
                  act('set_all', {
                    new_primary: primaryKey,
                    new_secondary: secondaryKey,
                  })
                }
              >
                Apply this pallette to all
              </Button.Confirm>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <BodypartPicker
                displayingpart="HEAD"
                selectedBodypart={selectedBodypart}
                setSelectedBodypart={setSelectedBodypart}
              />
            </Stack.Item>
            <Stack.Item>
              <ByondUi
                height="230px"
                width="250px"
                params={{
                  id: mech_view,
                  zoom: 3,
                  type: 'map',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon={'fist-raised'}
                textAlign={'center'}
                fontSize="120%"
                selected={selected_variants[selectedBodypart] === 'Medium'}
                onClick={() =>
                  act('set_bodypart', {
                    bodypart: selectedBodypart,
                    new_bodytype: 'Medium',
                  })
                }
              >
                Medium
              </Button>
              <Button
                content={
                  cooldown_left
                    ? `BUSY (${formatTime(cooldown_left, 'short')})`
                    : 'ASSEMBLE'
                }
                disabled={cooldown_left && cooldown_left > 0}
                fluid
                mt={2}
                color={'red'}
                textAlign={'center'}
                fontSize="170%"
                onClick={() => tryAssemble(setFailReason)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical maxWidth={'166px'}>
            <Stack.Item>
              <BodypartPicker
                displayingpart="L_ARM"
                selectedBodypart={selectedBodypart}
                setSelectedBodypart={setSelectedBodypart}
              />
            </Stack.Item>
            <Stack.Item>
              <BodypartPicker
                displayingpart="LEG"
                selectedBodypart={selectedBodypart}
                setSelectedBodypart={setSelectedBodypart}
              />
            </Stack.Item>
            <Stack.Item>
              <Section title={'Mech parameters'}>
                <Tooltip
                  content="Determines maximum integrity of the chest."
                  position="right"
                >
                  <Box maxWidth={'160px'} mt={0}>
                    <Icon name="shield" />
                    Integrity: {current_stats.health}
                  </Box>
                </Tooltip>
                <Tooltip content="Scatter angle for left arm." position="right">
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="angle-double-right" />L scatter:{' '}
                    {current_stats.left_scatter + left_weapon_scatter}°
                  </Box>
                </Tooltip>
                <Tooltip
                  content="Scatter angle for right arm."
                  position="right"
                >
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="angle-double-left" />R scatter:{' '}
                    {current_stats.right_scatter + right_weapon_scatter}°
                  </Box>
                </Tooltip>
                <Tooltip
                  content="Determines how fast mecha is compared to base."
                  position="right"
                >
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="running" />
                    Slowdown: {current_stats.slowdown}
                  </Box>
                </Tooltip>
                <Tooltip
                  content="Determines likeliness of mecha to hit at long ranges."
                  position="right"
                >
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="bullseye" />
                    Accuracy: {Math.floor(current_stats.accuracy * 100)}%
                  </Box>
                </Tooltip>
                <Tooltip
                  content="Determines maximum mecha power."
                  position="right"
                >
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="battery" />
                    Power cap: {current_stats.power_max}
                  </Box>
                </Tooltip>
                <Tooltip
                  content="Determines passive mech power generation."
                  position="right"
                >
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="charging-station" />
                    Power gen: {current_stats.power_gen}
                  </Box>
                </Tooltip>
                <Tooltip content="Light strength." position="right">
                  <Box maxWidth={'160px'} mt={1}>
                    <Icon name="lightbulb" />
                    Light range: {current_stats.light_mod}
                  </Box>
                </Tooltip>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item grow overflowY="auto">
              <ColorSelector
                type={'primary'}
                listtoshow={data.colors}
                selectedBodypart={selectedBodypart}
                setSelectedBodypart={setSelectedBodypart}
              />
            </Stack.Item>
            <Stack.Item grow overflowY="auto">
              <ColorSelector
                type={'secondary'}
                listtoshow={data.colors}
                selectedBodypart={selectedBodypart}
              />
            </Stack.Item>
            {selectedBodypart === 'HEAD' && (
              <Stack.Item grow maxWidth={'130px'} overflowY="auto">
                <ColorSelector
                  type={'visor'}
                  listtoshow={data.visor_colors}
                  selectedBodypart={selectedBodypart}
                />
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
};

const ColorSelector = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { type, listtoshow, selectedBodypart } = props;
  return (
    <Section title={capitalize(type)} align="center">
      {Object.keys(listtoshow).map((title) => (
        <Collapsible align="left" ml={1} key={title} title={title}>
          <Stack justify="space-between" vertical fill>
            {Object.keys(listtoshow[title]).map((palette) => (
              <Stack.Item key={palette} my={0}>
                <ColorDisplayRow
                  shown_colors={listtoshow[title][palette]}
                  name={palette}
                  action={() =>
                    act('set_' + type, {
                      bodypart: selectedBodypart,
                      new_color: palette,
                    })
                  }
                />
              </Stack.Item>
            ))}
          </Stack>
        </Collapsible>
      ))}
    </Section>
  );
};
