import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import {
  equipTabs,
  MECHA_ARMOR,
  MECHA_POWER,
  MECHA_UTILITY,
  MechArmor,
  MechPower,
  MechUtility,
  MechVendData,
} from './data';

const SelectedEquipment = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { equip_max, all_equipment, selected_equipment } = data;
  const selected_left = all_equipment.weapons.find(
    (o) => o.type === selected_equipment.mecha_l_arm,
  );
  const selected_right = all_equipment.weapons.find(
    (o) => o.type === selected_equipment.mecha_r_arm,
  );

  const selected_left_back = all_equipment.back_weapons.find(
    (o) => o.type === selected_equipment.mecha_l_back,
  );
  const selected_right_back = all_equipment.back_weapons.find(
    (o) => o.type === selected_equipment.mecha_r_back,
  );

  let utility_modules = selected_equipment.mecha_utility
    .map((type) => all_equipment.utility.find((o) => o.type === type))
    .filter((x): x is MechUtility => x !== undefined);

  const power_modules = selected_equipment.mecha_power
    .map((type) => all_equipment.power.find((o) => o.type === type))
    .filter((x): x is MechPower => x !== undefined);

  const armor_modules = selected_equipment.mecha_armor
    .map((type) => all_equipment.armor.find((o) => o.type === type))
    .filter((x): x is MechArmor => x !== undefined);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack>
          <Stack.Item>
            <Section
              title={selected_left ? selected_left.name.split(' ')[0] : 'None'}
              width={'145px'}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() =>
                    act('remove_weapon', { is_right_weapon: 0, back_slot: 0 })
                  }
                />
              }
            >
              <Box
                className={classes([
                  'mech_builder64x32',
                  selected_left ? selected_left.icon_state : 'assaultrifle',
                ])}
                ml={3}
                mt={3}
                mb={4}
                style={{
                  transform: 'scale(2) translate(10%, 10%)',
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title={
                selected_right ? selected_right.name.split(' ')[0] : 'None'
              }
              width={'145px'}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() =>
                    act('remove_weapon', { is_right_weapon: 1, back_slot: 0 })
                  }
                />
              }
            >
              <Box
                className={classes([
                  'mech_builder64x32',
                  selected_right ? selected_right.icon_state : 'assaultrifle',
                ])}
                ml={3}
                mt={3}
                mb={4}
                style={{
                  transform: 'scale(2) translate(10%, 10%)',
                }}
              />
            </Section>
          </Stack.Item>
        </Stack>
        <Stack>
          <Stack.Item>
            <Section
              title={
                selected_left_back
                  ? selected_left_back.name.split(' ')[0]
                  : 'None'
              }
              width={'145px'}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() =>
                    act('remove_weapon', { is_right_weapon: 0, back_slot: 1 })
                  }
                />
              }
            >
              <Box
                className={classes([
                  'mech_builder64x32',
                  selected_left_back
                    ? selected_left_back.icon_state
                    : 'assaultrifle',
                ])}
                ml={3}
                mt={3}
                mb={4}
                style={{
                  transform: 'scale(2) translate(10%, 10%)',
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title={
                selected_right_back
                  ? selected_right_back.name.split(' ')[0]
                  : 'None'
              }
              width={'145px'}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() =>
                    act('remove_weapon', { is_right_weapon: 1, back_slot: 1 })
                  }
                />
              }
            >
              <Box
                className={classes([
                  'mech_builder64x32',
                  selected_right_back
                    ? selected_right_back.icon_state
                    : 'assaultrifle',
                ])}
                ml={3}
                mt={3}
                mb={4}
                style={{
                  transform: 'scale(2) translate(10%, 10%)',
                }}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          maxWidth={'300px'}
          title={
            'Utility (' +
            utility_modules.length +
            '/' +
            equip_max[MECHA_UTILITY] +
            ')'
          }
        >
          {utility_modules.map((module) => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() => act('remove_utility', { type: module.type })}
                />
              }
            >
              <Section title={'Description'}>
                {module.desc} Has an energy drain of {module.energy_drain}.
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          maxWidth={'300px'}
          title={
            'Power (' +
            power_modules.length +
            '/' +
            equip_max[MECHA_POWER] +
            ')'
          }
        >
          {power_modules.map((module) => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() => act('remove_power', { type: module.type })}
                />
              }
            >
              <Section title={'Description'}>{module.desc}</Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          maxWidth={'300px'}
          title={
            'Armor (' +
            armor_modules.length +
            '/' +
            equip_max[MECHA_ARMOR] +
            ')'
          }
        >
          {armor_modules.map((module) => (
            <Collapsible
              key={module.type}
              title={module.name}
              buttons={
                <Button
                  icon="minus"
                  color="red"
                  onClick={() => act('remove_armor', { type: module.type })}
                />
              }
            >
              <Section title={'Description'}>
                {module.desc} Has an slowdown drain of {module.slowdown}.
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const EquipPanelContent = (props) => {
  const { equipmentTab, setShowDesc } = props;
  {
    switch (equipmentTab) {
      case 'Weapons':
        return <WeaponsTab setShowDesc={setShowDesc} />;
      case 'Power':
        return <PowerTab />;
      case 'Armor':
        return <ArmorTab />;
      case 'Utility':
        return <UtilityTab />;
      default:
        return null;
    }
  }
};

const WeaponsTab = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { weapons, back_weapons } = data.all_equipment;
  const { setShowDesc } = props;
  return (
    <Stack.Item grow>
      <Stack fill>
        <Stack.Item grow>
          <WeaponModuleList listtoshow={weapons} setShowDesc={setShowDesc} />
        </Stack.Item>
        <Stack.Item grow>
          <WeaponModuleList
            listtoshow={back_weapons}
            setShowDesc={setShowDesc}
            useback
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const PowerTab = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { all_equipment, selected_equipment, equip_max } = data;
  return (
    <Stack.Item>
      <Section>
        {all_equipment.power.map((module) => (
          <Collapsible
            key={module.type}
            title={module.name}
            buttons={
              <Button
                disabled={
                  selected_equipment.mecha_power.length >=
                  equip_max[MECHA_POWER]
                }
                onClick={() => act('add_power', { type: module.type })}
              >
                Add
              </Button>
            }
          >
            <Section title={'Description'}>{module.desc}</Section>
          </Collapsible>
        ))}
      </Section>
    </Stack.Item>
  );
};

const ArmorTab = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { all_equipment, selected_equipment, equip_max } = data;
  return (
    <Stack.Item>
      <Section>
        {all_equipment.armor.map((module) => (
          <Collapsible
            key={module.type}
            title={module.name}
            buttons={
              <Button
                disabled={
                  selected_equipment.mecha_armor.length >=
                  equip_max[MECHA_ARMOR]
                }
                onClick={() => act('add_armor', { type: module.type })}
              >
                Add
              </Button>
            }
          >
            <Section title={'Description'}>{module.desc}</Section>
          </Collapsible>
        ))}
      </Section>
    </Stack.Item>
  );
};

const UtilityTab = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { all_equipment, selected_equipment, equip_max } = data;
  return (
    <Stack.Item>
      <Section>
        {all_equipment.utility.map((module) => (
          <Collapsible
            key={module.type}
            title={module.name}
            buttons={
              <Button
                disabled={
                  selected_equipment.mecha_utility.length >=
                  equip_max[MECHA_UTILITY]
                }
                onClick={() => act('add_utility', { type: module.type })}
              >
                Add
              </Button>
            }
          >
            <Section title={'Description'}>{module.desc}</Section>
          </Collapsible>
        ))}
      </Section>
    </Stack.Item>
  );
};

const WeaponModuleList = (props) => {
  const { act, data } = useBackend<MechVendData>();
  const { listtoshow, setShowDesc, useback } = props;
  const { all_equipment, selected_equipment } = data;
  const rightequip = useback
    ? selected_equipment.mecha_r_back
    : selected_equipment.mecha_r_arm;
  const leftequip = useback
    ? selected_equipment.mecha_l_back
    : selected_equipment.mecha_l_arm;
  return (
    <Section>
      {listtoshow.map((module) => {
        const ammoobject = all_equipment.ammo.find(
          (o) => o.ammo_type === module.ammo_type,
        );
        return (
          <Collapsible
            key={module.type}
            title={module.name}
            icon={useback ? 'person' : 'hand'}
            buttons={
              <>
                <Button
                  selected={module.type === leftequip}
                  onClick={() =>
                    act('add_weapon', { type: module.type, is_right_weapon: 0 })
                  }
                >
                  Left
                </Button>
                <Button
                  selected={module.type === rightequip}
                  onClick={() =>
                    act('add_weapon', { type: module.type, is_right_weapon: 1 })
                  }
                >
                  Right
                </Button>
                <Button icon="question" onClick={() => setShowDesc(module)} />
              </>
            }
          >
            <Section title={ammoobject ? ammoobject.name : 'No ammo available'}>
              {ammoobject ? (
                <Stack>
                  <Stack.Item>
                    <Stack vertical>
                      <Stack.Item>
                        <Box
                          className={classes([
                            'mech_ammo32x32',
                            ammoobject.icon_state,
                          ])}
                          ml={1.5}
                          mt={1.5}
                          mb={3}
                          style={{
                            transform: 'scale(2) translate(10%, 10%)',
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          mr={1.5}
                          ml={1.5}
                          content="Vend"
                          onClick={() =>
                            act('vend_ammo', { type: ammoobject.type })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    Contains: {ammoobject.ammo_count}x {ammoobject.ammo_type}
                  </Stack.Item>
                </Stack>
              ) : null}
            </Section>
          </Collapsible>
        );
      })}
    </Section>
  );
};

export const MechWeapons = (props) => {
  const [equipmentTab, setequipmentTab] = useState(equipTabs[0]);
  const { setShowDesc } = props;
  return (
    <Stack fill>
      <Stack.Item>
        <SelectedEquipment />
      </Stack.Item>
      <Stack.Item grow>
        <Section lineHeight={1.75} fontSize={'13px'}>
          <Tabs fluid>
            {equipTabs.map((tabname) => {
              return (
                <Tabs.Tab
                  key={tabname}
                  selected={tabname === equipmentTab}
                  fontSize="130%"
                  onClick={() => setequipmentTab(tabname)}
                >
                  {tabname}
                </Tabs.Tab>
              );
            })}
          </Tabs>
          <Divider />
          <EquipPanelContent
            equipmentTab={equipmentTab}
            setShowDesc={setShowDesc}
          />
        </Section>
      </Stack.Item>
    </Stack>
  );
};
