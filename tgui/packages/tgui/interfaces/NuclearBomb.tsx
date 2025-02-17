import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type NuclearBombData = {
  status: string;
  current_site: string;
  nuke_ineligible_site: string[];
  time: number;
  time_left: number;
  timer_enabled: boolean;
  has_auth: boolean;
  safety: boolean;
  anchor: boolean;
  red: boolean;
  green: boolean;
  blue: boolean;
};

export const NuclearBomb = (props) => {
  const { data } = useBackend<NuclearBombData>();
  return (
    <Window width={450} height={580}>
      <Window.Content>
        <NuclearBombContent />
      </Window.Content>
    </Window>
  );
};

const NuclearBombContent = (props) => {
  const { act, data } = useBackend<NuclearBombData>();
  const {
    status,
    time,
    time_left,
    timer_enabled,
    has_auth,
    safety,
    anchor,
    red,
    green,
    blue,
    current_site,
    nuke_ineligible_site,
  } = data;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title={'Status display'}>
          <Box width="100%">
            <NoticeBox>{status}</NoticeBox>
          </Box>
          <LabeledList>
            <LabeledList.Item label="Time left">
              <ProgressBar
                value={time_left / time}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.2, 0.6],
                  bad: [-Infinity, 0.2],
                }}
              >
                <AnimatedNumber value={time_left} />s
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Timer">
              <Button
                content={timer_enabled ? 'ACTIVATED' : 'DEACTIVATED'}
                onClick={() => act('toggle_timer')}
                disabled={!has_auth || safety || !anchor}
                color={timer_enabled ? 'green' : 'red'}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      {has_auth ? (
        <Stack.Item>
          <Section title={'Settings'}>
            <LabeledList>
              <LabeledList.Item label="Time">
                <Button
                  content="-10"
                  onClick={() =>
                    act('change_time', {
                      seconds: -10,
                    })
                  }
                  disabled={timer_enabled}
                />
                <Button
                  content="-5"
                  onClick={() =>
                    act('change_time', {
                      seconds: -5,
                    })
                  }
                  disabled={timer_enabled}
                />
                <AnimatedNumber value={data.time} />
                <Button
                  content="+5"
                  onClick={() =>
                    act('change_time', {
                      seconds: 5,
                    })
                  }
                  disabled={timer_enabled}
                />
                <Button
                  content="+10"
                  onClick={() =>
                    act('change_time', {
                      seconds: 10,
                    })
                  }
                  disabled={timer_enabled}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Safety">
                <Button
                  content={safety ? 'Enabled' : 'Disabled'}
                  onClick={() => act('toggle_safety')}
                  color={safety ? 'green' : 'red'}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Anchor">
                <Button
                  content={anchor ? 'Engaged' : 'Off'}
                  onClick={() => act('toggle_anchor')}
                  color={anchor ? 'green' : 'red'}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      ) : null}
      <Stack.Item>
        <Section title={'Input area'}>
          <LabeledList.Item label="Red Auth. Disk">
            <Button
              content={!red ? 'INSERT' : 'EJECT'}
              onClick={() =>
                act('toggle_disk', {
                  disktype: 'red',
                })
              }
              color={!red ? 'green' : 'red'}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Green Auth. Disk">
            <Button
              content={!green ? 'INSERT' : 'EJECT'}
              onClick={() =>
                act('toggle_disk', {
                  disktype: 'green',
                })
              }
              color={!green ? 'green' : 'red'}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Blue Auth. Disk">
            <Button
              content={!blue ? 'INSERT' : 'EJECT'}
              onClick={() =>
                act('toggle_disk', {
                  disktype: 'blue',
                })
              }
              color={!blue ? 'green' : 'red'}
            />
          </LabeledList.Item>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title={'Ineligible detonation sites'} fill>
          <Stack vertical fill>
            <Stack.Item>
              <NoticeBox
                color={
                  nuke_ineligible_site.includes(current_site) ? 'red' : 'green'
                }
              >
                You are at {current_site}
              </NoticeBox>
            </Stack.Item>
            <Stack.Item grow basis={0} overflow="auto">
              <NoticeBox color="blue">
                {nuke_ineligible_site.map((nuke_ineligible_site) => (
                  <Box key={nuke_ineligible_site} p={'8px'}>
                    {nuke_ineligible_site}
                  </Box>
                ))}
              </NoticeBox>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
