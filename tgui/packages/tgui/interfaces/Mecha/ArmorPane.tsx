import { classes } from 'common/react';

import { useBackend } from '../../backend';
import { Box, Button, Stack } from '../../components';
import { OperatorData } from './data';

export const ArmorPane = (props) => {
  const { act, data } = useBackend<OperatorData>();
  const { mech_equipment } = data;
  return (
    <Stack fill vertical justify="space-evenly" align="center">
      {mech_equipment['armor'].map((module, i) => (
        <Stack.Item key={i}>
          <Stack vertical align="center">
            <Stack.Item bold>{module.protect_name}</Stack.Item>
            <Stack.Item>
              <Box
                className={classes(['mechaarmor76x76', module.iconstate_name])}
                style={{
                  transform: 'scale(0.8)',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content={'Detach'}
                onClick={() =>
                  act('equip_act', {
                    ref: module.ref,
                    gear_action: 'detach',
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};
