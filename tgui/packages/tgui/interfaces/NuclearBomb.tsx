import { useBackend } from '../backend';
import { AnimatedNumber, Button, Box, NoticeBox, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type NuclearBombData = {
  status: string;
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

export const NuclearBomb = (props, context) => {
  const { data } = useBackend<NuclearBombData>(context);
  return (
    <Window width={450} height={450}>
      <Window.Content scrollable>
        <NuclearBombContent />
      </Window.Content>
    </Window>
  );
};

const NuclearBombContent = (props, context) => {
  const { act, data } = useBackend<NuclearBombData>(context);
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
  } = data;
  return (
    <>
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
              }}>
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
      {has_auth ? (
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
      ) : null}
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
    </>
  );
};
