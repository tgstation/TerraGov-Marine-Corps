import {
  Button,
  Collapsible,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SelectionEntry = {
  name: string;
  desc: string;
  type: string;
  isselected: boolean;
};

type AmmoData = {
  name: string;
  type: string;
  current: number;
  max: number;
};

type VehicleSupplyData = {
  vehicles: SelectionEntry[];
  primaryWeapons: SelectionEntry[];
  secondaryWeapons: SelectionEntry[];
  driverModules: SelectionEntry[];
  gunnerModules: SelectionEntry[];

  primaryammotypes?: AmmoData[];
  secondarymmotypes?: AmmoData[];

  elevator: string;
  elevator_dir: string;
};

export const VehicleSupply = (props) => {
  const { act, data } = useBackend<VehicleSupplyData>();
  const {
    vehicles,
    primaryWeapons,
    secondaryWeapons,
    driverModules,
    gunnerModules,
    primaryammotypes,
    secondarymmotypes,
    elevator,
    elevator_dir,
  } = data;
  return (
    <Window width={1250} height={600}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Section title={'Primary weapons'} width="400px">
                  {primaryWeapons?.map((primary) => (
                    <Collapsible
                      key={primary.name}
                      title={primary.name}
                      open
                      buttons={
                        <Button
                          onClick={() =>
                            act('setprimary', { type: primary.type })
                          }
                          icon="check"
                          content="Select"
                          selected={primary.isselected}
                        />
                      }
                    >
                      {!primary.isselected
                        ? null
                        : primaryammotypes?.map((ammotype) => (
                            <Slider
                              key={ammotype.name}
                              animated
                              unit={ammotype.name}
                              minValue={0}
                              maxValue={ammotype.max}
                              stepPixelSize={20}
                              onChange={(e, value) =>
                                act('set_ammo_primary', {
                                  type: ammotype.type,
                                  new_value: value,
                                })
                              }
                              value={ammotype.current}
                            />
                          ))}
                    </Collapsible>
                  ))}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title={'Secondary weapons'} width="400px">
                  {secondaryWeapons?.map((secondary) => (
                    <Collapsible
                      key={secondary.name}
                      title={secondary.name}
                      open
                      buttons={
                        <Button
                          onClick={() =>
                            act('setsecondary', { type: secondary.type })
                          }
                          icon="check"
                          content="Select"
                          selected={secondary.isselected}
                        />
                      }
                    >
                      {!secondary.isselected
                        ? null
                        : secondarymmotypes?.map((ammotype) => (
                            <Slider
                              key={ammotype.name}
                              animated
                              unit={ammotype.name}
                              minValue={0}
                              maxValue={ammotype.max}
                              stepPixelSize={20}
                              onChange={(e, value) =>
                                act('set_ammo_secondary', {
                                  type: ammotype.type,
                                  new_value: value,
                                })
                              }
                              value={ammotype.current}
                            />
                          ))}
                    </Collapsible>
                  ))}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              width="400px"
              height="40px"
              align="center"
              fontSize={2}
              color="red"
              content={elevator}
              icon={
                elevator_dir === 'store'
                  ? elevator_dir
                  : 'angle-double-' + elevator_dir
              }
              onClick={() => act('send')}
            />
            {vehicles?.map((veh) => (
              <Section
                width="400px"
                key={veh.name}
                title={veh.name}
                buttons={
                  <Button
                    onClick={() => act('setvehicle', { type: veh.type })}
                    icon="check"
                    content="Select"
                    selected={veh.isselected}
                  />
                }
              >
                {veh.desc}
              </Section>
            ))}
          </Stack.Item>
          <Stack.Item>
            <Section title={'Driver Module'} width="400px">
              {driverModules?.map((module) => (
                <Section
                  key={module.name}
                  title={module.name}
                  buttons={
                    <Button
                      onClick={() =>
                        act('set_driver_mod', { type: module.type })
                      }
                      icon="check"
                      content="Select"
                      selected={module.isselected}
                    />
                  }
                >
                  {module.desc}
                </Section>
              ))}
            </Section>
            <Section title={'Gunner Module'} width="400px">
              {gunnerModules?.map((module) => (
                <Section
                  key={module.name}
                  title={module.name}
                  buttons={
                    <Button
                      onClick={() =>
                        act('set_gunner_mod', { type: module.type })
                      }
                      icon="check"
                      content="Select"
                      selected={module.isselected}
                    />
                  }
                >
                  {module.desc}
                </Section>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
