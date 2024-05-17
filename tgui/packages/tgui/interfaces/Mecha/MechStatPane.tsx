import { toFixed } from 'common/math';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../../components';
import {OperatorData } from './data';

export const MechStatPane = (props) => {
  const { act, data } = useBackend<OperatorData>();
  const {
    name,
    integrity,
    weapons_safety,
  } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={name}
          buttons={<Button onClick={() => act('changename')}>Rename</Button>}
        />
      </Stack.Item>
      <Stack.Item>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
                value={integrity}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <PowerBar />
            </LabeledList.Item>
            <LabeledList.Item label="Safety">
              <Button
                color={weapons_safety ? 'red' : ''}
                onClick={() => act('toggle_safety')}
              >
                {weapons_safety ? 'Dis' : 'En'}able
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="DNA lock">
          <DNABody />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DNABody = (props) => {
  const { act, data } = useBackend<OperatorData>();
  const { dna_lock } = data;
  if (dna_lock === null) {
    return (
      <LabeledList>
        <LabeledList.Item label="DNA Enzymes">
          <Button onClick={() => act('dna_lock')} icon={'syringe'}>
            Set new DNA key
          </Button>
        </LabeledList.Item>
      </LabeledList>
    );
  } else {
    return (
      <LabeledList>
        <LabeledList.Item label="DNA Enzymes">
          <Button onClick={() => act('dna_lock')} icon={'syringe'}>
            Set new DNA key
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Enzymes">
          <Button onClick={() => act('view_dna')} icon={'list'}>
            View enzyme list
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Reset DNA">
          <Button onClick={() => act('reset_dna')} icon={'ban'}>
            Reset DNA lock
          </Button>
        </LabeledList.Item>
      </LabeledList>
    );
  }
};

const PowerBar = (props) => {
  const { act, data } = useBackend<OperatorData>();
  const { power_level, power_max } = data;
  if (power_max === null) {
    return <Box content={'No Power cell installed!'} />;
  } else {
    return (
      <ProgressBar
        ranges={{
          good: [0.75 * power_max, Infinity],
          average: [0.25 * power_max, 0.75 * power_max],
          bad: [-Infinity, 0.25 * power_max],
        }}
        maxValue={power_max}
        value={power_level}
      />
    );
  }
};
