import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Flex, Section } from '../components';
import { Window } from '../layouts';

type DoorDisplayData = {
  id: string;
  has_flash: boolean;
  has_shutters: boolean;
  shutter_state: boolean;
  door_state: boolean;
};

export const DoorDisplay = (props, context) => {
  const { act, data } = useBackend<DoorDisplayData>(context);
  return (
    <Window width={200} height={150} title="Cell Control">
		<Window.Content>
		<Section textAlign="center" title={data.id}>
			<Flex direction="column">
			<Flex.Item>
				<Button
					width="100%"
					content={data.door_state ? "Close Door" : "Open Door"}
					color={!data.door_state ? "good" : "bad"}
					onClick={() => act('door', {state: (!data.door_state)})}
				/>
			</Flex.Item>
			{data.has_shutters ? <>
			<Flex.Item>
				<Button
					width="100%"
					content={data.shutter_state ? "Close Shutters" : "Open Shutters"}
					color={!data.shutter_state ? "good" : "bad"}
					onClick={() => act('shutter', {state: (!data.shutter_state)})}
				/>
			</Flex.Item>
			</> : null}
			{data.has_flash ? <FlashControl/> : null}
			</Flex>
		</Section>
      </Window.Content>
    </Window>
  );
};

const FlashControl = (props, context) => {
  const { act, data } = useBackend<DoorDisplayData>(context);
  const { ship_status, fuel_left, fuel_max } = data;
  return (
    <>
        <Box textAlign="center">
          <Button
            content="Activate Flash"
			width="100%"
			color="average"
            onClick={() => act('flash')}
            disabled={false}
          />
        </Box>
    </>
  );
};
