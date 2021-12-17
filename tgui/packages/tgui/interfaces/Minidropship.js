import { useBackend } from '../backend';
import { Button, Section, Box } from '../components';
import { Window } from '../layouts';

export const Minidropship = (_props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={220}
      height={340}
      title={"Navigation"}>
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
          <Button
            content="Toggle night vision mode"
            onClick={() => act('toggle_nvg')} />
        </Section>
        <WeaponSelection />
      </Window.Content>
    </Window>
  );
};

const WeaponSelection = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section title="Equipment Installed">
      {data.equipment_data.length > 0 ? (
        data.equipment_data.map(equipment => (
          <Box
            key={equipment.id}>
            <Button
              onClick={() => act(
                'equip_interact',
                { equip_interact: equipment.eqp_tag }
              )}
              disabled={!equipment.is_interactable}>
              {equipment.name}
            </Button>
          </Box>
        ))
      ) : (
        <Box>No equipment installed.</Box>
      )}
    </Section>
  );
};
