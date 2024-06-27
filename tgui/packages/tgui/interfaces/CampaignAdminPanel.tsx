import { useBackend } from '../backend';
import { Button, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

export type FactionDataList = {
  faction_data: FactionData[];
  vp_max: number;
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
    <Window title={'Campaign Panel'} width={480} height={900}>
      <Window.Content>
        {data.faction_data.map((selected_faction) => (
          <Section key={selected_faction.faction}>
            <Stack vertical>
              <Stack.Item fontSize="150%" bold={1}>
                {selected_faction.faction}
              </Stack.Item>
              <Stack.Item mt={2}>
                Active Attrition:
                <ProgressBar
                  mt={0.5}
                  color="green"
                  value={
                    selected_faction.active_attrition /
                    (selected_faction.total_attrition +
                      selected_faction.active_attrition)
                  }
                >
                  {selected_faction.active_attrition} /
                  {selected_faction.total_attrition +
                    selected_faction.active_attrition}
                </ProgressBar>
                <Button
                  mt={1}
                  onClick={() => {
                    act('set_attrition_points', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Set active Attrition
                </Button>
              </Stack.Item>
              <Stack.Item mt={2}>
                <Section>
                  Total Attrition: {selected_faction.total_attrition}
                </Section>
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
              <Stack.Item mt={2}>
                <Section>
                  Faction Leader: {selected_faction.faction_leader}
                </Section>
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
              <Stack.Item mt={2}>
                Victory Points:
                <ProgressBar
                  mt={0.5}
                  color="green"
                  value={selected_faction.victory_points / data.vp_max}
                >
                  {selected_faction.victory_points} /{data.vp_max}
                </ProgressBar>
                <Button
                  mt={1}
                  onClick={() => {
                    act('set_victory_points', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Add Victory Points
                </Button>
              </Stack.Item>
              <Stack.Item mt={2}>
                <Button
                  mt={1}
                  onClick={() => {
                    act('add_mission', {
                      target_faction: selected_faction.faction,
                    });
                  }}
                >
                  Add mission
                </Button>
              </Stack.Item>
              <Stack.Item mt={2}>
                <Button
                  mt={1}
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
