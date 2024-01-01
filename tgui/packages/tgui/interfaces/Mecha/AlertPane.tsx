import { useBackend } from '../../backend';
import { Box, Button, Stack } from '../../components';
import {
  InternalDamageToDamagedDesc,
  InternalDamageToNormalDesc,
  OperatorData,
} from './data';

export const AlertPane = (props) => {
  const { act, data } = useBackend<OperatorData>();
  const { internal_damage, internal_damage_keys } = data;
  return (
    <Stack fill vertical>
      {Object.keys(internal_damage_keys).map((t) => (
        <Stack.Item key={t}>
          <Stack justify="space-between">
            <Stack.Item>
              <Box
                color={
                  internal_damage & internal_damage_keys[t] ? 'red' : 'green'
                }
              >
                {internal_damage & internal_damage_keys[t]
                  ? InternalDamageToDamagedDesc[t]
                  : InternalDamageToNormalDesc[t]}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() =>
                  act('repair_int_damage', {
                    flag: internal_damage_keys[t],
                  })
                }
                color={'red'}
                disabled={!(internal_damage & internal_damage_keys[t])}
              >
                Repair
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};
