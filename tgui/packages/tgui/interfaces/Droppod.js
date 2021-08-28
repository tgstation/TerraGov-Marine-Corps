import { useBackend } from '../backend';
import { Button, Section, LabeledList, NoticeBox, NumberInput, Box } from '../components';
import { Window } from '../layouts';

export const Droppod = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Window
      width={450}
      height={250}>
      <Window.Content scrollable>
        {data.drop_state === 1 ? (
          <PreDeploy />
        ) : (
          <NoticeBox>
            <Box>DROP ACTIVE</Box>
            <Box>DEPLOYMENT UNDERWAY</Box>
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

const PreDeploy = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title={`Welcome, ${data.occupant}`}>
      <LabeledList>
        <LabeledList.Item label="X Coordinate">
          <NumberInput
            value={data.target_x}
            onChange={(e, value) => act('set_x_target', { set_x: `${value}` })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y Coordinate">
          <NumberInput
            value={data.target_y}
            onChange={(e, value) => act('set_y_target', { set_y: `${value}` })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Check drop validity">
          <Button
            content="Check drop point validity"
            color="blue"
            onClick={() => act('check_droppoint')} />
        </LabeledList.Item>
        <LabeledList.Item label="Launching">
          <Button
            content="LAUNCH DROPPOD"
            color="red"
            onClick={() => act('launch')} />
        </LabeledList.Item>
        <LabeledList.Item label="Exit Drop pod">
          <Button
            content="Exit Pod"
            color="green"
            onClick={() => act('exitpod')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
