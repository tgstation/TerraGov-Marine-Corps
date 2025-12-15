import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const GearCustomization = (props) => {
  const { act, data } = useBackend<GearCustomizationData>();

  const { gearsets, gear, clothing, backpack, physique_used } = data;
  // These correspond to the gear slot and you need to update them if the defines change
  const slotMapping = {
    10: 'Head',
    8: 'Eyewear',
    9: 'Mouth',
    16: 'Phones',
    17: 'Other',
  };

  const bySlot = {};
  for (const item in gearsets) {
    const gear = gearsets[item];
    if (!bySlot[slotMapping[gear.slot]]) {
      bySlot[slotMapping[gear.slot]] = [];
    }
    bySlot[slotMapping[gear.slot]].push(gear);
  }

  const currentPoints = gear.reduce(
    (total, name) => total + gearsets[name].cost,
    0,
  );

  return (
    <Section
      title="Custom Gear"
      buttons={
        <>
          <Box as="span" style={{ marginRight: '10px' }}>
            Points: {currentPoints} / 5
          </Box>
          <Button
            inline
            color="red"
            content="Clear all"
            onClick={() => act('loadoutclear')}
          />
        </>
      }
    >
      <Stack>
        <Stack.Item grow>
          <Section title={'Head'}>
            <LabeledList>
              {bySlot['Head']?.map((item) => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}
                >
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={gear.includes(item.name)}
                    onClick={() =>
                      gear.includes(item.name)
                        ? act('loadoutremove', { gear: item.name })
                        : act('loadoutadd', { gear: item.name })
                    }
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title={'Eyewear'}>
            <LabeledList>
              {bySlot['Eyewear']?.map((item) => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name}
                  (${item.cost})`}
                >
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={gear.includes(item.name)}
                    onClick={() =>
                      gear.includes(item.name)
                        ? act('loadoutremove', { gear: item.name })
                        : act('loadoutadd', { gear: item.name })
                    }
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
          <Stack.Item grow>
            <Section title={'Other'}>
              <LabeledList>
                {bySlot['Other']?.map((item) => (
                  <LabeledList.Item
                    key={item.name}
                    label={`${item.name}
                  (${item.cost})`}
                  >
                    <Button.Checkbox
                      inline
                      content={'Equipped'}
                      checked={gear.includes(item.name)}
                      onClick={() =>
                        gear.includes(item.name)
                          ? act('loadoutremove', { gear: item.name })
                          : act('loadoutadd', { gear: item.name })
                      }
                    />
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section title={'Mouth'}>
            <LabeledList>
              {bySlot['Mouth']?.map((item) => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}
                >
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={gear.includes(item.name)}
                    onClick={() =>
                      gear.includes(item.name)
                        ? act('loadoutremove', { gear: item.name })
                        : act('loadoutadd', { gear: item.name })
                    }
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
          <Stack.Item grow>
            <Section title={'Phones'}>
              <LabeledList>
                {bySlot['Phones']?.map((item) => (
                  <LabeledList.Item
                    key={item.name}
                    label={`${item.name} (${item.cost})`}
                  >
                    <Button.Checkbox
                      inline
                      content={'Equipped'}
                      checked={gear.includes(item.name)}
                      onClick={() =>
                        gear.includes(item.name)
                          ? act('loadoutremove', { gear: item.name })
                          : act('loadoutadd', { gear: item.name })
                      }
                    />
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section title={'Backpack (select one)'}>
            <LabeledList>
              {clothing['backpack']?.map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={backpack - 1 === idx}
                    onClick={() => act('backpack', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
