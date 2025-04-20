import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const EscapePod = (props) => {
  const { act, data } = useBackend();
  return (
    <Window title="Escape Pod" width={400} height={140}>
      <Window.Content>
        <Section title="Escape Pod">
          Welcome to Nanotransens least luxurious survival pod! Have a pleasant
          stay!
          <Box width="100%" textAlign="center">
            <Button.Confirm
              m="50"
              content="Launch evacuation pod"
              disabled={!data.can_launch}
              color="red"
              onClick={() => act('launch')}
            />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
