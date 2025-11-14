import { useState } from 'react';
import { Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Stim = {
  name: string;
  desc: string;
  uid: string;
  duration: number;
  allow_dupe: boolean;
};

type ActiveBuffs = {
  active_uid: string;
  decisecondsleft: number;
};

type SupersoldierStimsData = {
  stims: Stim[];
  active_stims: ActiveBuffs[];
  active_stimsets: { [key: string]: string[] };
  max_stims: number;
};

export const SupersoldierStims = (_props) => {
  const { act, data } = useBackend<SupersoldierStimsData>();
  const [activeStimSet, setActiveStimsSet] = useState(
    Object.keys(data.active_stimsets)[0] || '',
  );
  const selected_stimset = data.active_stimsets[activeStimSet] || [];
  // Function to find a stim ref by its UID in data.stims
  const findStimByUID = (stim_uid) => {
    return data.stims.find((stim) => stim.uid === stim_uid);
  };

  return (
    <Window width={950} height={500} title={'Supersoldier Stimulants'}>
      <Window.Content>
        <Button
          fluid
          content="Inject Cocktail"
          color="purple"
          align="center"
          fontSize={2}
          icon="syringe"
          onClick={() => act('cast_sequence', { sequence: activeStimSet })}
        />
        <Stack>
          {selected_stimset.map((stim_uid, index) => {
            const stim = findStimByUID(stim_uid);
            const pos = index + 1; // Convert to 1-indexed for byond

            return (
              <Stack.Item key={stim_uid} width={`${100 / data.max_stims}%`}>
                <Section
                  width="100%"
                  title={stim ? stim.name : 'Errored name'}
                  textAlign="center"
                >
                  <Stack fill justify="space-between">
                    <Stack.Item>
                      <Button
                        icon="arrow-left"
                        align="start"
                        disabled={!selected_stimset.includes(stim_uid)}
                        onClick={() =>
                          act('change_pos', {
                            sequence: activeStimSet,
                            new_pos: pos - 1,
                            old_pos: pos,
                          })
                        }
                      >
                        {index}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        content="Remove"
                        color="red"
                        onClick={() =>
                          act('remove_from_sequence', {
                            sequence: activeStimSet,
                            old_pos: pos,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="arrow-right"
                        disabled={!selected_stimset.includes(stim_uid)}
                        align="end"
                        onClick={() =>
                          act('change_pos', {
                            sequence: activeStimSet,
                            new_pos: pos + 1,
                            old_pos: pos,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            );
          })}
        </Stack>
        <Stack>
          <Stack.Item width={'20%'}>
            <SequenceSelection
              activeStimSet={activeStimSet}
              setActiveStimsSet={setActiveStimsSet}
            />
          </Stack.Item>
          <Stack.Item width={'80%'}>
            <StimList activeStimSet={activeStimSet} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SequenceSelection = (_props) => {
  const { act, data } = useBackend<SupersoldierStimsData>();
  const { activeStimSet, setActiveStimsSet } = _props;
  return (
    <Stack vertical>
      <Stack.Item>
        <Input
          fluid
          placeholder="New Cocktail"
          onChange={(value) => act('new_sequence', { new_name: value })}
        />
      </Stack.Item>
      {Object.keys(data.active_stimsets || {}).map((entryname) => (
        <Stack.Item key={entryname}>
          <Stack fill>
            <Stack.Item grow>
              <Button
                fluid
                fontSize={1.2}
                textAlign="center"
                content={entryname}
                selected={activeStimSet === entryname}
                onClick={() => setActiveStimsSet(entryname)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                icon="trash"
                color="red"
                height={'24px'}
                onClick={() =>
                  act('delete_sequence', {
                    sequence: entryname,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const StimList = (_props) => {
  const { act, data } = useBackend<SupersoldierStimsData>();
  const { activeStimSet, setActiveStimsSet } = _props;
  const activestims = data.active_stimsets[activeStimSet] || [];

  // Helper function to get the lowest duration remaining for a stim in MM:SS format
  const getStimDuration = (stim_uid) => {
    const durations = data.active_stims
      .filter((activeStim) => activeStim.active_uid === stim_uid)
      .map((activeStim) => activeStim.decisecondsleft);
    const minDuration = Math.min(...durations);

    if (minDuration < Infinity) {
      const minutes = Math.floor(minDuration / 600);
      const seconds = Math.floor((minDuration % 600) / 10);
      return `${minutes.toString().padStart(2, '0')}:${seconds
        .toString()
        .padStart(2, '0')}`;
    }
    return null;
  };

  const StimSection = ({ stim }) => {
    const selectedCount = activestims.filter((uid) => uid === stim.uid).length;

    return (
      <Section
        key={stim.uid}
        title={`${stim.name} ${getStimDuration(stim.uid) || ''}${
          selectedCount > 0 ? ` (${selectedCount})` : ''
        }`}
        buttons={
          <>
            <Button content="?" tooltip={stim.desc} />
            <Button
              content="Add to set"
              width="75px"
              selected={selectedCount > 0}
              tooltip={stim.allow_dupe ? 'CAN Duplicate' : 'CAN NOT Duplicate'}
              onClick={() =>
                act('add_to_sequence', {
                  stim: stim.uid,
                  sequence: activeStimSet,
                })
              }
            />
          </>
        }
      />
    );
  };

  return (
    <Stack>
      <Stack.Item width={'50%'}>
        {data.stims
          .filter((_, index) => index % 2 === 0) // Only even indexes
          .map((stim) => (
            <StimSection stim={stim} key={`even-${stim.uid}`} />
          ))}
      </Stack.Item>
      <Stack.Item width={'50%'}>
        {data.stims
          .filter((_, index) => index % 2 !== 0) // Only odd indexes
          .map((stim) => (
            <StimSection stim={stim} key={`odd-${stim.uid}`} />
          ))}
      </Stack.Item>
    </Stack>
  );
};
