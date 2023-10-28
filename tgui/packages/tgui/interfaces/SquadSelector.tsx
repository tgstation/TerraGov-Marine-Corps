import { Stack, Box, Button, Section } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

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

export const SquadSelector = (props, context) => {
  const { act, data } = useBackend<SquadSelectorData>(context);
  const { active_squads } = data;
  const [selectedSquad, setSelectedSquad] = useLocalState<string>(
    context,
    'selectedSquad',
    ''
  );

  const selectedSquadEntry = active_squads?.find(
    (i) => i.name === selectedSquad
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
                    selected={selectedSquad === squad.name}>
                    {squad.name}
                    <Box contents={squad.leader} />
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
                      }>
                      Join
                    </Button>
                  }>
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
