import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const MarineCasship = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={600}
      height={500}
      theme="ntos">
      <Window.Content scrollable>
        {data.plane_state === 0 ? (
          <EnginesOff />
        ) : (
          <NormalOperation />
        )}
      </Window.Content>
    </Window>
  );
};

const EnginesOff = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <Section
        title="Ship Status">
        {data.ship_status}
      </Section>
      <Section title="Engine Control">
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Spool Engines"
            onClick={() => act("toggle_engines")}
            disabled={data.fuel_left <= 0} />
        </Box>
        <Box
          content="Fuel capacity:"
          width="100%"
          textAlign="center">
          <NoticeBox>Fuel level {data.fuel_left/data.fuel_max *100}%</NoticeBox>
        </Box>
      </Section>
    </>
  );
};

const NormalOperation = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <Section title="Ship Status">
        <NoticeBox>{data.ship_status}</NoticeBox>
        <NoticeBox>{data.active_lasers} Active Lasers Detected</NoticeBox>
        <NoticeBox>Fuel level</NoticeBox>
        <ProgressBar
          ranges={{
            good: [0.5, Infinity],
            average: [-Infinity, 0.25],
          }}
          value={(data.fuel_left/data.fuel_max)} />
      </Section>
      <Section title="Weapons">
        {data.all_weapons.length > 0 ? (
          data.all_weapons.map(equipment => (
            <Box
              key={equipment.id}>
              <Button
                onClick={() => act(
                  'change_weapon',
                  { selection: equipment.eqp_tag }
                )}
                disabled={equipment.eqp_tag === data.active_weapon_tag}>
                {equipment.name}
              </Button>
            </Box>
          ))
        ) : (
          <Box>No equipment installed.</Box>
        )}
      </Section>
      {data.active_weapon_name ? (
        <Section
          title={"Weapon Selected: "+data.active_weapon_name}
          buttons={
            <Button onClick={() => act('deselect')}>
              Deselect
            </Button>
          }>
          {!data.active_weapon_ammo_name ? (
            <Box color="bad">No ammo loaded</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Ammo loaded">
                {data.active_weapon_ammo_name}
              </LabeledList.Item>
              <LabeledList.Item label="Ammo count">
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0, 0.5],
                    bad: [-Infinity, 0],
                  }}
                  value={data.active_weapon_ammo
                  / data.active_weapon_max_ammo}
                  content={data.active_weapon_ammo
                  +" / "
                  +data.active_weapon_max_ammo} />
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      ) : (
        <Section title="No active equipment." />
      )}
      <Section title="Piloting control">
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Launch plane"
            onClick={() => act(
              'launch')}
            disabled={data.plane_state === 3} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Land plane"
            onClick={() => act(
              'land')}
            disabled={data.plane_state !== 3} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Disable Engines"
            onClick={() => act("toggle_engines")}
            disabled={data.plane_state !== 2} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Begin Firemission"
            onClick={() => act("deploy")}
            disabled={data.plane_state !== 3} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content={"Strafe Direction: "+data.attackdir}
            onClick={() => act('cycle_attackdir')} />
        </Box>
      </Section>
    </>
  );
};
