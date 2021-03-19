import { useBackend } from '../backend';
import { Button, Section, LabeledList, ProgressBar, Divider, NumberInput } from '../components';
import { Window } from '../layouts';

export const Minidropship = (_props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
    width={350}
    height={350}>
      <Window.Content scrollable>
        <Section title={`Fly state - ${data.fly_state}`}>
          <Button
            content="Take off"
            disabled={data.take_off_locked}
            onClick={() => act('take_off')} />
          <Button
            content="Return to ship"
            disabled={data.return_to_ship_locked}
            onClick={() => act('return_to_ship')} />
        </Section>
        <Section title={`Fuel left - ${data.fuel_left}/${data.fuel_max}`}>
          <ProgressBar
          ranges={{
          good: [0.50, Infinity],
          average: [0.25, 0.50],
          bad: [-Infinity, 0.25],
          }}
          value={data.fuel_left/data.fuel_max} />
        </Section>
      </Window.Content>
    </Window>
  );
};
