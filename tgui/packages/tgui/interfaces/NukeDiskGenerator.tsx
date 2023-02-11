import { useBackend } from '../backend';
import { AnimatedNumber, Button, Box, NoticeBox, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type NukeDiskGeneratorData = {
  progress: number;
  progress_max: number;
  time_left: number;
  time_max: number;
  message: string;
  log: string[];
};

export const NukeDiskGenerator = (props, context) => {
  const { data } = useBackend<NukeDiskGeneratorData>(context);
  return (
    <Window width={450} height={450}>
      <Window.Content scrollable>
        <GenerationProcess />
      </Window.Content>
    </Window>
  );
};

const GenerationProcess = (props, context) => {
  const { act, data } = useBackend<NukeDiskGeneratorData>(context);
  const { progress, progress_max, time_left, time_max, message, log } = data;
  return (
    <>
      <Section title={'Status'}>
        <Box width="100%">
          <NoticeBox>{data.message}</NoticeBox>
        </Box>
        <LabeledList>
          <LabeledList.Item label="Progress">
            <ProgressBar
              value={data.progress / data.progress_max}
              ranges={{
                good: [1, Infinity],
                default: [-Infinity, 1],
              }}>
              <AnimatedNumber
                value={Math.round((data.progress / data.progress_max) * 100)}
              />
              %
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Time left">
            <ProgressBar value={data.time_left / data.time_max}>
              <AnimatedNumber value={data.time_left} />s
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Run program">
            <Button content="Start" onClick={() => act('run_program')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title={'Log'}>
        {data.log.map((logText) => (
          <Box>{logText}</Box>
        ))}
      </Section>
    </>
  );
};
