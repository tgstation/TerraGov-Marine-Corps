import { Button, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
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
    <Window title={'Campaign Panel'} width={840} height={450}>
      <Window.Content>
        <Stack>
          {data.faction_data.map((selected_faction) => (
            <Section mr={3} key={selected_faction.faction}>
              <Stack vertical>
                <Stack.Item fontSize="150%" bold>
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
                    tooltip={`Sets the team's attrition for the current mission.`}
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
                    tooltip={`Adds to the team's total attrition pool.`}
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
                    tooltip={`
                      Allows you to set (or unset) a faction leader.
                      Cancel the input to simply remove the leader.
                    `}
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
                    tooltip={`
                      Manually adds a mission to the team's available missions. THERE ARE NO SAFETY CHECKS HERE.
                      Make sure what you are adding is actually valid.
                    `}
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
                    tooltip={`
                      Manually adds an asset. THERE ARE NO SAFETY CHECKS HERE.
                      Make sure what you are adding is actually valid.
                    `}
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
          <Section>
            <Stack vertical>
              <Stack.Item fontSize="150%" bold>
                Campaign Buttons
              </Stack.Item>
              <Stack.Item mt={2}>
                <Button
                  tooltip={`
                    Triggers autobalance to run.
                    This can be forced, to not give players a choice.
                  `}
                  mt={1}
                  onClick={() => {
                    act('autobalance');
                  }}
                >
                  Trigger Autobalance
                </Button>
              </Stack.Item>
              <Stack.Item mt={2}>
                <Button
                  tooltip={`
                    Forcefully shuffles the teams.
                    Shuffles all living and dead players to the available factions.
                  `}
                  mt={1}
                  onClick={() => {
                    act('shuffle_teams');
                  }}
                >
                  Shuffle teams
                </Button>
              </Stack.Item>
              <Stack.Item mt={2}>
                <Button
                  tooltip={`
                    This pauses or resumes the PRE-GAME mission start timer.
                    Time can be edited when resuming.
                  `}
                  mt={1}
                  onClick={() => {
                    act('mission_start_timer');
                  }}
                >
                  Start/Stop Mission START timer
                </Button>
              </Stack.Item>
              <Stack.Item mt={2}>
                <Button
                  tooltip={`
                    This pauses or resumes the actual mission timer.
                    Generally missions CANNOT complete without an active timer.
                  `}
                  mt={1}
                  onClick={() => {
                    act('mission_timer');
                  }}
                >
                  Start/Stop Mission timer
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
