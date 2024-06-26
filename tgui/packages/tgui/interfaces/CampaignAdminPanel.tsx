import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export type FactionDataList = {
  faction_data: FactionData[];
};

export type FactionData = {
  faction: string;
  active_attrition: number;
  total_attrition: number;
  faction_leader: string;
  victory_points: number;
  available_missions: string[];
  assets: string[];
};

export const CampaignAdminPanel = (props) => {
  const { act, data } = useBackend<FactionDataList>();

  if (!data || !data.faction_data) return 'loading...';
  return (
    <Window title={'Campaign Panel'} width={980} height={775}>
      <Window.Content>
        {data.faction_data.map((selected_faction) => (
          <Section key={selected_faction.faction}>
            <Stack vertical>
              <Stack.Item>{selected_faction.faction}</Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('set_attrition_points', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Set active Attrition
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('add_attrition_points', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Add total Attrition
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('set_leader', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Set faction leader
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('set_victory_points', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Add Victory Points
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('add_mission', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Add mission
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  onClick={() => {
                    act('add_asset', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Add Asset
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
