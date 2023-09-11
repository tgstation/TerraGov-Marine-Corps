import { Stack, Box, Button, TextArea } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

type SquadManagerData = {
  active_squads: SquadData[];
};

type SquadData = {
  name: string;
  leader: string;
  color: string;
};

export const SquadManager = (props, context) => {
  const { act, data } = useBackend<SquadManagerData>(context);
  const { active_squads } = data;
  const [squadName, setSquadName] = useLocalState<string>(
    context,
    'squadName',
    'New Squad'
  );
  const [squadColor, setSquadColor] = useLocalState<string>(
    context,
    'squadColor',
    '#FFF'
  );

  return (
    <Window width={350} height={320}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Stack vertical>
              {active_squads.map((squad) => (
                <Stack.Item key={squad.name}>
                  <Box
                    backgroundColor={squad.color}
                    height={'120%'}
                    pt={0.5}
                    pl={1}
                    width={'90px'}>
                    {squad.name}
                    <Box contents={squad.leader} />
                  </Box>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <TextArea
                      autoFocus
                      content={squadName}
                      placeholder={'New name'}
                      onChange={(e, value) => setSquadName(value)}
                      width="180px"
                      height="20px"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() =>
                        act('create_squad', {
                          name: squadName,
                          color: squadColor,
                        })
                      }>
                      Create
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <TextArea
                      content={squadColor}
                      placeholder={'New color'}
                      onChange={(e, value) => setSquadColor(value)}
                      width="180px"
                      height="20px"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Box
                      backgroundColor={squadColor}
                      width="50px"
                      height="20px"
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <TextArea
                  fluid
                  placeholder="Set Description for squad"
                  onChange={(e, value) =>
                    act('change_desc', {
                      new_desc: value,
                    })
                  }
                  width="180px"
                  height="200px"
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
