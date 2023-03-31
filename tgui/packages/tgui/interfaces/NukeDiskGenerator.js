import { useBackend } from '../backend';
import { Button, Box, Section, Stack, NoticeBox, ProgressBar } from '../components';
import { Window } from '../layouts';

export const NukeDiskGenerator = (props, context) => {
  const { act, data } = useBackend(context);
  const { message, progress, time_left, flavor_text, running, generate_time } = data;
  return (
    <Window title="Nuke Disk Generator" width={450} height={200}>
      <Window.Content>
        <Section title="Run Program">
          <Stack fill vertical>
            <Stack.Item>
              <NoticeBox>{flavor_text}</NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Box width="100%" textAlign="center">
                Current Progress: {progress} %
                {running ? (
                  <NoticeBox>
                    <Box>
                      Time left: {time_left} s
                      <ProgressBar
                        minValue={0}
                        MaxValue={generate_time}
                        value={time_left/generate_time} />
                    </Box>
                    <Box>{message}</Box>
                  </NoticeBox>
                ) : (
                  <NoticeBox>
                    {message}
                  </NoticeBox>
                )}
                <Button
                  disabled={running}
                  onClick={() => act('run_program')}>
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
