import { useBackend } from '../../backend';
import { Button, Section, LabeledList, Box, Stack } from '../../components';

export const GearCustomization = (props, context) => {
  const { act, data } = useBackend<GearCustomizationData>(context);

  const { gearsets, gear, clothing, underwear, undershirt, backpack, gender } =
    data;

  // These correspond to the gear slot and you need to update them if the defines change
  const slotMapping = {
    10: 'Head',
    8: 'Eyewear',
    9: 'Mouth',
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
    0
  );

  return (
    <Section
      title="Custom Gear"
      buttons={
        <>
          <Box as="span" style={{ 'margin-right': '10px' }}>
            Points: {currentPoints} / 5
          </Box>
          <Button
            inline
            color="red"
            content="Clear all"
            onClick={() => act('loadoutclear')}
          />
        </>
      }>
      <Stack>
        <Stack.Item grow>
          <Section title={'Head'}>
            <LabeledList>
              {bySlot['Head']?.map((item) => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}>
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
                  (${item.cost})`}>
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
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section title={'Mouth'}>
            <LabeledList>
              {bySlot['Mouth']?.map((item) => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}>
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
          <Section title={'Undershirt (select one)'}>
            <LabeledList>
              {clothing['undershirt'][gender]?.map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={undershirt - 1 === idx}
                    onClick={() => act('undershirt', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section title={'Underwear (select one)'}>
            <LabeledList>
              {clothing['underwear'][gender]?.map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={underwear - 1 === idx}
                    onClick={() => act('underwear', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
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
