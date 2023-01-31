import { useBackend } from '../backend';
import { AnimatedNumber, Button, LabeledList, ProgressBar, Section, Box } from '../components';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
];

export const Sleeper = () => {
  return (
    <Window width={550} height={870}>
      <Window.Content scrollable>
        <SleeperContent />
      </Window.Content>
    </Window>
  );
};

const SleeperContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { hasOccupant, occupant, chemicals, amounts, stasis, filter} = data;
  return (
    <>
      <Section title="Occupant">
        <LabeledList>
          <LabeledList.Item label="Occupant">
            {occupant.name || 'No Occupant'}
          </LabeledList.Item>
          {!!hasOccupant && (
            <>
              <LabeledList.Item label="State" color={occupant.statstate}>
                {occupant.stat}
              </LabeledList.Item>
              <LabeledList.Item
                label="Temperature"
                color={occupant.temperaturestatus}>
                <AnimatedNumber value={occupant.bodyTemperature} />
                {' K'}
              </LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  value={occupant.health / occupant.maxHealth}
                  color={occupant.health > 0 ? 'good' : 'average'}>
                  <AnimatedNumber value={occupant.health} />
                </ProgressBar>
              </LabeledList.Item>
              {damageTypes.map((damageType) => (
                <LabeledList.Item key={damageType.id} label={damageType.label}>
                  <ProgressBar value={occupant[damageType.type] / 100}>
                    <AnimatedNumber value={occupant[damageType.type]} />
                  </ProgressBar>
                </LabeledList.Item>
              ))}
            </>
          )}
        </LabeledList>
      </Section>
      {!!hasOccupant && (
        <Section title="Functions">
          <Button
            onClick={() => act('toggle_filter')}
            content="Toggle dialysis"
            color={filter ? "green" : "red"}
          />
          <Button
            onClick={() => act('toggle_stasis')}
            content="Toggle cryostasis"
            color={stasis ? "green" : "red"}
          />
          <Button
              icon="eject"
              onClick={() => act('eject')}
              content="Eject patient"
          />
        </Section>)}
      {!!hasOccupant && (
        <Section title="Chemicals">
          <LabeledList>
            {chemicals.map((chemical) => (
              <>
                <LabeledList.Item label={chemical.title}>
                  <Box>
                    <ProgressBar
                      value={chemical.amount / 20}
                      color={chemical.threshold > chemical.amount ? 'good' : 'bad'}>
                      <AnimatedNumber value={chemical.amount} />/20u
                    </ProgressBar>
                  </Box>
                  <Box mt={1}>
                    {amounts.map((a, i) => (
                      <Button
                        key={i}
                        content={a + "u"}
                        onClick={() => act('inject', {
                          chempath: chemical.path,
                          amount: a
                        })}
                      />
                    ))}
                  </Box>
                </LabeledList.Item>
              </>
            ))}
          </LabeledList>
        </Section>
      )}
    </>
  );
};
