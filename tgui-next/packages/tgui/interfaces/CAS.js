import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, Icon, LabeledList, ProgressBar, Section } from '../components';

export const CAS = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      {data.screen_mode === 0 && (
        <Section title="Equipment Installed">
          {data.equipment_data.length > 0 ? (
            data.equipment_data.map(equipment => (
              <Box
                key={equipment.id}>
                <Button
                  onClick={() => act(ref, 'equip_interact', {equip_interact: equipment.eqp_tag})}
                  disabled={!equipment.is_interactable}>
                  {equipment.name}
                </Button>
              </Box>
            ))
          ) : (
            <Box>No equipment installed.</Box>
          )}
        </Section>
      )}
      {data.screen_mode === 1 && (
        <Fragment>
          <Section
            title={"Weapon Selected: "+data.selected_eqp}
            buttons={
              <Button onClick={() => act(ref, 'deselect')}>
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
                    color={data.selected_eqp_ammo_status}
                    value={data.selected_eqp_ammo_amt / data.selected_eqp_max_ammo_amt}
                    content={data.selected_eqp_ammo_amt+ " / " +data.selected_eqp_max_ammo_amt} />
                </LabeledList.Item>
              </LabeledList>
            )}
          </Section>
          <Section title="Available Targets">
            {data.targets_data.length > 0 ? (
              data.targets_data.map(target => (
                <Box key={target.id}>
                  <Button
                    disabled={data.shuttle_mode === 'idle'}
                    onClick={() => act(ref, 'open_fire', {open_fire: target.target_tag})}>
                    {target.target_name}
                  </Button>
                </Box>
              ))
            ) : (
              <Box>No laser targets detected.</Box>
            )}
          </Section>
        </Fragment>
      )}
    </Fragment>
  ); };
