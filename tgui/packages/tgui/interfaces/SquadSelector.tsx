import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SquadSelectorData = {
  active_squads: SquadEntry[];
};

type SquadEntry = {
  name: string;
  id: string;
  desc: string;
  leader: string;
  color: string;
};

export const SquadSelector = (props) => {
  const { act, data } = useBackend<SquadSelectorData>();
  const { active_squads } = data;
  const [selectedSquad, setSelectedSquad] = useState('');

  const selectedSquadEntry = active_squads?.find(
    (i) => i.name === selectedSquad,
  );

  return (
    <Window width={350} height={320}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Stack vertical>
              {active_squads.map((squad) => (
                <Stack.Item key={squad.name}>
                  <Button
                    width={'90px'}
                    onClick={() => setSelectedSquad(squad.name)}
                    backgroundColor={
                      selectedSquad === squad.name ? null : squad.color
                    }
                    selected={selectedSquad === squad.name}
                  >
                    {squad.name}
                    <Box>{squad.leader}</Box>
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Section
                  title={selectedSquadEntry?.name + ' Squad'}
                  width="240px"
                  buttons={
                    <Button
                      onClick={() =>
                        act('join', {
                          squad_id: selectedSquadEntry?.id,
                        })
                      }
                    >
                      Join
                    </Button>
                  }
                >
                  <Stack>
                    <Stack.Item>
                      <Box
                        backgroundColor={selectedSquadEntry?.color}
                        width="20px"
                        height="20px"
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Box mt={0.25}>{selectedSquadEntry?.leader}</Box>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title={'Description'} width="240px">
                  <Box>
                    {selectedSquadEntry?.desc
                      ? selectedSquadEntry.desc
                      : 'No description set'}
                  </Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
