import { useBackend } from '../backend';
import { Button, Box, Section, Stack, NoticeBox, ProgressBar } from '../components';
import { Window } from '../layouts';

export const NtAccessTerminal = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    message,
    progress,
    time_left,
    flavor_text,
    running,
    segment_time,
    color,
  } = data;
  return (
    <Window title="NanoTrasen security override" width={450} height={250}>
      <Window.Content>
        <Section title="Run Program">
          <Stack fill vertical>
            <Stack.Item>
              <NoticeBox>{flavor_text}</NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Box width="100%" textAlign="center">
                Overall Progress:
                <ProgressBar value={progress} color={color} />
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box width="100%" textAlign="center">
                {running ? (
                  <NoticeBox danger>
                    <Box>
                      Time left: {time_left} s
                      <ProgressBar
                        minValue={0}
                        MaxValue={segment_time}
                        value={(time_left / segment_time) * 10}
                      />
                    </Box>
                    <Box>{message}</Box>
                  </NoticeBox>
                ) : (
                  <NoticeBox>{message}</NoticeBox>
                )}
                <Button disabled={running} onClick={() => act('run_program')}>
                  Run Program
                </Button>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
