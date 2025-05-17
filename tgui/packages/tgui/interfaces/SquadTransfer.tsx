import { useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SquadSelectorData = {
  active_squads?: SquadEntry[];
  active_requests?: string[];
};

type SquadEntry = {
  name: string;
  id: string;
  color: string;
  members?: string[];
};

export const SquadTransfer = (props) => {
  const { act, data } = useBackend<SquadSelectorData>();
  const { active_squads } = data;
  const [selectedSquad, setSelectedSquad] = useState('');
  const [selectedMember, setSelectedMember] = useState('');

  const selectedSquadEntry = active_squads?.find(
    (i) => i.name === selectedSquad,
  );

  return (
    <Window width={380} height={360}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Section title={'Transfer from'} width={'120px'}>
              <Stack vertical>
                {active_squads?.map((squad) => (
                  <Stack.Item key={squad.name}>
                    <Button
                      width={'110px'}
                      onClick={() => setSelectedSquad(squad.name)}
                      backgroundColor={
                        selectedSquad === squad.name ? null : squad.color
                      }
                      selected={selectedSquad === squad.name}
                    >
                      {squad.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={'Transfered'} width={'120px'}>
              <Stack vertical>
                {selectedSquadEntry?.members
                  ? Object.keys(selectedSquadEntry.members).map((name) => (
                      <Stack.Item key={name}>
                        <Button
                          width={'110px'}
                          onClick={() => setSelectedMember(name)}
                          selected={selectedMember === name}
                        >
                          {name}
                        </Button>
                      </Stack.Item>
                    ))
                  : null}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={'Transfer to'} width={'120px'}>
              <Stack vertical>
                {active_squads?.map((squad) => (
                  <Stack.Item key={squad.name}>
                    <Button
                      width={'110px'}
                      onClick={() =>
                        act('transfer', {
                          transfer_target:
                            selectedSquadEntry?.members?.[selectedMember],
                          squad_id: squad?.id,
                        })
                      }
                      backgroundColor={
                        selectedSquad === squad.name ? null : squad.color
                      }
                      disabled={selectedSquad === squad.name}
                    >
                      {squad.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
