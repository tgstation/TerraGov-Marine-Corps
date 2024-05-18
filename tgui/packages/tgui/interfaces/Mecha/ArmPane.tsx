import { toFixed } from 'common/math';

import { useBackend } from '../../backend';
import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../../components';
import { MechWeapon, OperatorData } from './data';

export const ArmPane = (props: { weapon: MechWeapon }) => {
  const { act, data } = useBackend<OperatorData>();
  const { name, desc, integrity, energy_per_use } = props.weapon;
  const { power_level, weapons_safety } = data;
  return (
    <Stack fill vertical>
      <Stack.Item bold color={weapons_safety ? 'red' : ''}>
        {weapons_safety ? 'SAFETY OVERRIDE IN EFFECT' : name}
      </Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <ProgressBar
              ranges={{
                good: [0.75, Infinity],
                average: [0.25, 0.75],
                bad: [-Infinity, 0.25],
              }}
              value={integrity}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              content={'Repair'}
              icon={'wrench'}
              onClick={() =>
                act('equip_act', {
                  ref: props.weapon.ref,
                  gear_action: 'repair',
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item vertical>
        <LabeledList>
          <LabeledList.Item label={'Detach'}>
            <Button
              content={'Detach'}
              onClick={() =>
                act('equip_act', {
                  ref: props.weapon.ref,
                  gear_action: 'detach',
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Energy per use">
            {energy_per_use} energy per use
          </LabeledList.Item>
          <LabeledList.Item label="Uses left">
            {power_level ? toFixed(power_level / energy_per_use) : 0} uses left
          </LabeledList.Item>
          <BallisticStats weapon={props.weapon} />
        </LabeledList>
      </Stack.Item>
      <Stack.Item>
        <Snowflake weapon={props.weapon} />
      </Stack.Item>
      <Stack.Item color={weapons_safety ? 'red' : ''}>{desc}</Stack.Item>
    </Stack>
  );
};

const BallisticStats = (props: { weapon: MechWeapon }) => {
  const { act, data } = useBackend<OperatorData>();
  const {
    isballisticweapon,
    disabledreload,
    projectiles,
    max_magazine,
    projectiles_cache,
    projectiles_cache_max,
    ammo_type,
    ref,
  } = props.weapon;
  if (!isballisticweapon) {
    return null;
  } else {
    return (
      <>
        <LabeledList.Item label="Ammo loaded">
          {projectiles} / {max_magazine}
        </LabeledList.Item>
        {disabledreload ? null : (
          <>
            <LabeledList.Item label="Ammo stored">
              {projectiles_cache} / {projectiles_cache_max}
            </LabeledList.Item>
            <LabeledList.Item label="Reload">
              <Button
                icon={'redo'}
                onClick={() =>
                  act('equip_act', {
                    ref: ref,
                    gear_action: 'reload',
                  })
                }
              >
                Reload
              </Button>
            </LabeledList.Item>
          </>
        )}
        <LabeledList.Item label="Ammo type">{ammo_type}</LabeledList.Item>
      </>
    );
  }
};

const MECHA_SNOWFLAKE_ID_MODE = 'mode_snowflake';

// Handles all the snowflake buttons and whatever
const Snowflake = (props: { weapon: MechWeapon }) => {
  const { snowflake } = props.weapon;
  switch (snowflake['snowflake_id']) {
    case MECHA_SNOWFLAKE_ID_MODE:
      return <SnowflakeMode weapon={props.weapon} />;
    default:
      return null;
  }
};

const SnowflakeMode = (props: { weapon: MechWeapon }) => {
  const { act, data } = useBackend<OperatorData>();
  const { mode, name } = props.weapon.snowflake;
  return (
    <Section label={name}>
      <LabeledList>
        <LabeledList.Item label={'Mode'}>
          <Button
            content={mode}
            onClick={() =>
              act('equip_act', {
                ref: props.weapon.ref,
                gear_action: 'change_mode',
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
