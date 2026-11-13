import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EquipmentData = {
  id: string;
  eqp_tag: string;
  name: string;
  is_interactable: BooleanLike;
};

type TargetData = {
  target_tag: string;
  target_name: string;
};

type CasData = {
  display_used_weapon: number;
  equipment_data: EquipmentData[];
  selected_eqp: string;
  selected_eqp_ammo_name: string;
  selected_eqp_ammo_amt: number;
  selected_eqp_max_ammo_amt: number;
  targets_data: TargetData[];
  shuttle_mode: BooleanLike;
};

export const CAS = (props) => {
  const { act, data } = useBackend<CasData>();
  const { display_used_weapon, equipment_data } = data;
  return (
    <Window>
      <Window.Content scrollable>
        {display_used_weapon ? (
          <FiringMode />
        ) : (
          <WeaponSelection equipment_data={equipment_data} />
        )}
      </Window.Content>
    </Window>
  );
};

const WeaponSelection = ({ equipment_data }) => {
  const { act } = useBackend();
  return (
    <Section title="Equipment Installed">
      {equipment_data.length > 0 ? (
        equipment_data.map((equipment) => (
          <Box key={equipment.id}>
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
  );
};

const FiringMode = (props) => {
  const { act, data } = useBackend<CasData>();
  const {
    selected_eqp,
    selected_eqp_ammo_name,
    selected_eqp_ammo_amt,
    selected_eqp_max_ammo_amt,
    targets_data,
    shuttle_mode,
  } = data;
  return (
    <>
      <Section
        title={'Weapon Selected: ' + selected_eqp}
        buttons={<Button onClick={() => act('deselect')}>Deselect</Button>}
      >
        {!selected_eqp_ammo_name ? (
          <Box color="bad">No ammo loaded</Box>
        ) : (
          <LabeledList>
            <LabeledList.Item label="Ammo loaded">
              {selected_eqp_ammo_name}
            </LabeledList.Item>
            <LabeledList.Item label="Ammo count">
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0, 0.5],
                  bad: [-Infinity, 0],
                }}
                value={selected_eqp_ammo_amt / selected_eqp_max_ammo_amt}
              >
                {selected_eqp_ammo_amt + ' / ' + selected_eqp_max_ammo_amt}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
      <Section title="Available Targets">
        {targets_data.length > 0 ? (
          targets_data.map((target) => (
            <Box key={target.target_tag}>
              <Button
                disabled={!shuttle_mode}
                onClick={() =>
                  act('open_fire', { open_fire: target.target_tag })
                }
              >
                {target.target_name}
              </Button>
            </Box>
          ))
        ) : (
          <Box>No laser targets detected.</Box>
        )}
      </Section>
    </>
  );
};
