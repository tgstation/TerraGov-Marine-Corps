import { Box, Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type EscapePodData = {
  can_launch: BooleanLike;
};

export const EscapePod = (props) => {
  const { act, data } = useBackend<EscapePodData>();
  return (
    <Window title="Escape Pod" width={400} height={140}>
      <Window.Content>
        <Section title="Escape Pod">
          Welcome to Nanotransens least luxurious survival pod! Have a pleasant
          stay!
          <Box width="100%" textAlign="center">
            <Button.Confirm
              m="50"
              disabled={!data.can_launch}
              color="red"
              onClick={() => act('launch')}
            >
              Launch evacuation pod
            </Button.Confirm>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
