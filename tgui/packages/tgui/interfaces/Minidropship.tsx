import { Box, Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EquipmentData = {
  name: string;
  eqp_tag: number;
  is_weapon: BooleanLike;
  is_interactable: BooleanLike;
};

type MiniDropshipProps = {
  fly_state: string;
  take_off_locked: BooleanLike;
  return_to_ship_locked: BooleanLike;
  equipment_data: EquipmentData[];
};

export const Minidropship = (_props) => {
  const { act, data } = useBackend<MiniDropshipProps>();
  const { fly_state, take_off_locked, return_to_ship_locked, equipment_data } =
    data;
  return (
    <Window width={220} height={340} title={'Navigation'}>
      <Window.Content scrollable>
        <Section title={`Fly state - ${fly_state}`}>
          <Button disabled={take_off_locked} onClick={() => act('take_off')}>
            Take off
          </Button>
          <Button onClick={() => act('toggle_shutters')}>
            Toggle shutters
          </Button>
          <Button
            disabled={return_to_ship_locked}
            onClick={() => act('return_to_ship')}
          >
            Return to ship
          </Button>
          <Button onClick={() => act('toggle_nvg')}>
            Toggle night vision mode
          </Button>
        </Section>
        <Section title="Equipment Installed">
          {equipment_data.length > 0 ? (
            equipment_data.map((equipment) => (
              <Box key={equipment.eqp_tag}>
                <Button
                  onClick={() =>
                    act('equip_interact', { equip_interact: equipment.eqp_tag })
                  }
                  disabled={!equipment.is_interactable}
                >
                  {equipment.name}
                </Button>
              </Box>
            ))
          ) : (
            <Box>No equipment installed.</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
