import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const CAS = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content scrollable>
        {data.screen_mode === 0 && (
          <WeaponSelection />
        )}
        {data.screen_mode === 1 && (
          <FiringMode />
        )}
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

const FiringMode = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Fragment>
      <Section
        title={"Weapon Selected: "+data.selected_eqp}
        buttons={
          <Button onClick={() => act('deselect')}>
            Deselect
          </Button>
        }>
        {!data.selected_eqp_ammo_name ? (
          <Box color="bad">No ammo loaded</Box>
        ) : (
          <LabeledList>
            <LabeledList.Item label="Ammo loaded">
              {data.selected_eqp_ammo_name}
            </LabeledList.Item>
            <LabeledList.Item label="Ammo count">
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0, 0.5],
                  bad: [-Infinity, 0],
                }}
                value={data.selected_eqp_ammo_amt
                  / data.selected_eqp_max_ammo_amt}
                content={data.selected_eqp_ammo_amt
                  +" / "
                  +data.selected_eqp_max_ammo_amt} />
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
      <Section title="Available Targets">
        {data.targets_data.length > 0 ? (
          data.targets_data.map(target => (
            <Box key={target.id}>
              <Button
                disabled={!data.shuttle_mode}
                onClick={() => act(
                  'open_fire',
                  { open_fire: target.target_tag }
                )}>
                {target.target_name}
              </Button>
            </Box>
          ))
        ) : (
          <Box>No laser targets detected.</Box>
        )}
      </Section>
    </Fragment>
  );
};
