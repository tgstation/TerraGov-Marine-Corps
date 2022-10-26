import { useLocalState } from '../../backend';
import { classes } from 'common/react';
import {
  Button,
  Section,
  Box,
  Modal,
  Divider,
  Tabs,
  Stack,
  LabeledList,
} from '../../components';
import { Window } from '../../layouts';
import { MechAssembly } from './MechAssembly';
import { MechWeapons } from './MechWeapons';
import { tabs, MechWeapon } from './data';

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
                  {showDesc.burst_amount? <LabeledList.Item label={"Burst count"}>{showDesc.burst_amount}</LabeledList.Item>
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
