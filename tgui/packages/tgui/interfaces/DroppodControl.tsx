import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
type DropControlData = {
  pods: number;
};

export const DroppodControl = (props) => {
  const { act, data } = useBackend<DropControlData>();
  return (
    <Window width={450} height={250}>
      <Window.Content scrollable>
        <Section title="Launch Control">
          <Button
            content="Relink current pods"
            color="blue"
            onClick={() => act('relink')}
          />
          <Button
            content="LAUNCH ALL PODS"
            color="red"
            onClick={() => act('launchall')}
          />
        </Section>
        <Box> {`Currently ${data.pods} connected pods.`}</Box>
      </Window.Content>
    </Window>
  );
};
