import { useBackend } from '../../backend';
import { Button, Section, LabeledList, Box, Grid } from '../../components';

export const GearCustomization = (props, context) => {
  const { act, data } = useBackend<GearCustomizationData>(context);

  const {
    gearsets,
    gear,
    clothing,
    underwear,
    undershirt,
    backpack,
    gender,
  } = data;

  const slotMapping = {
    11: 'Head',
    9: 'Eyewear',
    10: 'Mouth',
  };

  const bySlot = {};
  for (const item in gearsets) {
    const gear = gearsets[item];
    if (!bySlot[slotMapping[gear.slot]]) {
      bySlot[slotMapping[gear.slot]] = [];
    }
    bySlot[slotMapping[gear.slot]].push(gear);
  }

  const currentPoints = gear.reduce((total, name) =>
    total + gearsets[name].cost, 0);

  return (
    <Section title="Custom Gear" buttons={
      <>
        <Box as="span"
          style={{ "margin-right": "10px" }}>
          Points: {currentPoints} / 5
        </Box>
        <Button
          inline
          color="red"
          content="Clear all"
          onClick={() => act('loadoutclear')} />
      </>
    }>
      <Grid>
        <Grid.Column>
          <Section title={'Head'}>
            <LabeledList>
              {bySlot['Head']?.map(item => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={gear.includes(item.name)}
                    onClick={() => gear.includes(item.name)
                      ? act('loadoutremove', { gear: item.name })
                      : act('loadoutadd', { gear: item.name })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title={'Eyewear'}>
            <LabeledList>
              {bySlot['Eyewear']?.map(item => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name}
                  (${item.cost})`}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={gear.includes(item.name)}
                    onClick={() => gear.includes(item.name)
                      ? act('loadoutremove', { gear: item.name })
                      : act('loadoutadd', { gear: item.name })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title={'Mouth'}>
            <LabeledList>
              {bySlot['Mouth']?.map(item => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={gear.includes(item.name)}
                    onClick={() => gear.includes(item.name)
                      ? act('loadoutremove', { gear: item.name })
                      : act('loadoutadd', { gear: item.name })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title={'Undershirt (select one)'}>
            <LabeledList>
              {clothing['undershirt']?.map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={(undershirt - 1) === idx}
                    onClick={() => act('undershirt', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title={'Underwear (select one)'}>
            <LabeledList>
              {clothing['underwear'][gender]?.map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={(underwear - 1) === idx}
                    onClick={() => act('underwear', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title={'Backpack (select one)'}>
            <LabeledList>
              {clothing['backpack']?.map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={(backpack - 1) === idx}
                    onClick={() => act('backpack', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
    </Section>
  );
};
