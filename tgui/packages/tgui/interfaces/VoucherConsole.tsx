import { Box, Button, NoticeBox, Section, Slider, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
type VoucherConsoleData = {
  faction: string;
  supply_points_available: number;
  supply_points_to_issue: number;
  supply_points_max: number;
  dropship_points_available: number;
  dropship_points_to_issue: number;
  dropship_points_max: number;
};
export const VoucherConsole = (props) => {
  const { act, data } = useBackend<VoucherConsoleData>();
  const {
    faction,
    supply_points_available,
    supply_points_to_issue,
    supply_points_max,
    dropship_points_available,
    dropship_points_to_issue,
    dropship_points_max,
  } = data;
  return (
    <Window title={faction + ' Voucher Console'} width={450} height={250}>
      <Window.Content>
        <Section title="Issue Voucher">
          <Stack fill vertical>
            <Stack.Item>
              <NoticeBox>
                Supply points available:{supply_points_available}
              </NoticeBox>
              <Slider
                key={'Supply Points'}
                animated
                unit={'Points'}
                minValue={0}
                maxValue={supply_points_max}
                stepPixelSize={450 / supply_points_max}
                onChange={(e, value) =>
                  act('set_supply_points', {
                    new_value: value,
                  })
                }
                value={supply_points_to_issue}
              />
            </Stack.Item>
            <Stack.Item>
              <NoticeBox>
                Dropship points available:{dropship_points_available}
              </NoticeBox>
              <Slider
                key={'Dropship Points'}
                animated
                unit={'Points'}
                minValue={0}
                maxValue={dropship_points_max}
                stepPixelSize={450 / dropship_points_max}
                onChange={(e, value) =>
                  act('set_dropship_points', {
                    new_value: value,
                  })
                }
                value={dropship_points_to_issue}
              />
            </Stack.Item>
            <Stack.Item>
              <Box width="100%" textAlign="center">
                <Button disabled={false} onClick={() => act('issue')}>
                  Issue Voucher
                </Button>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
