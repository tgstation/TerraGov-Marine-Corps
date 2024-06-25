import { useBackend } from '../backend';
import { Button, Stack } from '../components';
import { Window } from '../layouts';

export type FactionDataList = {
  faction_data_list: FactionData[];
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

  return (
    <Window title={'Campaign Panel'} width={980} height={775}>
      <Window.Content>
        {data.faction_data_list.map((selected_faction) => (
          <Stack>
            <Button icon={'times'} color="red">
              onClick=
              {() => {
                act('set_attrition_points', {
                  target_faction: selected_faction.faction,
                });
              }}
              set attrition test button
            </Button>
          </Stack>
        ))}
      </Window.Content>
    </Window>
  );
};
