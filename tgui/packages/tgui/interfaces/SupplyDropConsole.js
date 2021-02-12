import { useBackend } from '../backend';
import {
  Button,
  Section,
  LabeledList,
  ProgressBar,
  Divider,
  Dropdown,
  NumberInput,
} from '../components';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const SupplyDropConsole = (_props, context) => {
  const { act, data } = useBackend(context);


  const timeLeft = data.next_fire;
  const timeLeftPct = timeLeft / data.launch_cooldown;

  const beacon = data.current_beacon;

  const canFire = (data.current_squad
    && beacon.name
    && data.supplies_count
    && timeLeft === 0);

  return (
    <Window
      width={350}
      height={500}>
      <Window.Content scrollable>
        <Section title="Supply drop">
          <LabeledList>
            <LabeledListItem label={'Current Squad'}>
              {data.squad_lock ? (
                data.squad_lock
              ) : (
                <Dropdown
                  selected={data.current_squad}
                  options={data.squads}
                  onSelected={(e, squad) =>
                    act('select_squad', { select_squad: e })}
                />
              )}
            </LabeledListItem>
            <Divider />
            <LabeledListItem label="X Offset">
              <NumberInput
                value={data.x_offset}
                onChange={(e, value) => act('set_x', { set_x: `${value}` })}
              />
            </LabeledListItem>
            <LabeledListItem label="Y Offset">
              <NumberInput
                value={data.y_offset}
                onChange={(e, value) => act('set_y', { set_y: `${value}` })}
              />
            </LabeledListItem>
          </LabeledList>
          <Divider />
          <Section
            title="Supply pad status"
            buttons={
              <Button
                icon="reload"
                content="Update"
                onClick={() => act('refresh_pad')}
              />
            }>
            {data.supplies_count} item(s) found on the supply pad.
            <Divider />
            {data.current_beacon.name
              ? `Active beacon found at
                (${beacon.x_coords}, ${beacon.y_coords})`
              : 'No beacon detected'}
            <Divider />
            <ProgressBar
              width="100%"
              value={timeLeftPct}
              ranges={{
                good: [-Infinity, 0.33],
                average: [0.33, 0.67],
                bad: [0.67, Infinity],
              }}>
              {Math.ceil(timeLeft / 10)} sec(s)
            </ProgressBar>
          </Section>
          <Button
            disabled={!canFire}
            color="good"
            content="Launch Supply drop"
            onClick={() => act('send_beacon')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
