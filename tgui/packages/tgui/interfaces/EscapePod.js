import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const EscapePod = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable>
      <Window.Content>
        <Section title="Escape Pod">
          Welcome to Nanotransens least luxurious survival pod!
          Have a pleasant stay!
          <Box
            width="100%"
            textAlign="center">
            <Button.Confirm
              m="50"
              content="Launch evacuation pod"
              disabled={data.can_launch}
              color="red"
              onClick={() => act('launch')} />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
