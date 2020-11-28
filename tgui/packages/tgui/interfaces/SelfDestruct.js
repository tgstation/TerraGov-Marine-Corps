import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Box } from '../components';
import { Window } from '../layouts';

export const SelfDestruct = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="STATUS:">
            {data.dest_status === 0 && (
              <span className="idle">DISARMED</span>
            ) || data.dest_status === 1 && (
              <span className="average">AWAITING INPUT</span>
            ) || data.dest_status === 2 && (
              <span className="good">ARMED</span>
            ) || (
              <span className="bad">ERROR</span>
            )}
          </LabeledList.Item>
        </LabeledList>
        <Box>
          {data.dest_status === 1 && (
            <Button
              icon="exclamation-triangle"
              content="ACTIVATE SYSTEM"
              color="yellow"
              onClick={() => act("dest_start")} />
          ) || data.dest_status === 2 && (
            <Fragment>
              <Button
                icon="exclamation-triangle"
                content="INITIATE"
                color="red"
                onClick={() => act("dest_trigger")} />
              <Button
                icon="exclamation-triangle"
                content="CANCEL"
                color="yellow"
                onClick={() => act("dest_cancel")} />
            </Fragment>
          ) || (
            <span className="bad">ERROR</span>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};
