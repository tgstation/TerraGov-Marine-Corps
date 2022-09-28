import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, NoticeBox, Section } from '../components';
import { KEY_DOWN, KEY_ENTER, KEY_LEFT, KEY_RIGHT, KEY_SPACE, KEY_UP, KEY_W, KEY_D, KEY_S, KEY_A, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6 } from '../../common/keycodes';
import { Window } from '../layouts';

type CasData = {
  plane_state: number
  plane_mode: string
  fuel_left: number
  fuel_max: number
  ship_status: string
  attackdir: string
  all_weapons: CasWeapon[]
  active_lasers: number
  active_weapon_tag: number
  active_weapon_name: string | null
  active_weapon_ammo: number | null
  active_weapon_max_ammo: number | null
  active_weapon_ammo_name: string | null
}

type CasWeapon = {
  name: string
  ammo: number
  eqp_tag: number
}

export const MarineCasship = (props, context) => {
  const { act, data } = useBackend<CasData>(context);
  return (
    <Window
      width={600}
      height={500}
      theme="ntos">
      <Window.Content
        scrollable
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER) {
            act('toggle_engines');
          }
          if (keyCode === KEY_SPACE) {
            act('launch');
          }
          if (keyCode === KEY_1) {
            act('change_weapon', { selection: 1 });
          }
          if (keyCode === KEY_2) {
            act('change_weapon', { selection: 2 });
          }
          if (keyCode === KEY_3) {
            act('change_weapon', { selection: 3 });
          }
          if (keyCode === KEY_4) {
            act('change_weapon', { selection: 4 });
          }
          if (keyCode === KEY_5) {
            act('change_weapon', { selection: 5 });
          }
          if (keyCode === KEY_6) {
            act('deselect');
          }
          if (data.plane_state !== 0) {
            let newdir = 0;
            switch (keyCode) {
              case KEY_UP:
              case KEY_W:
                newdir = 1;
                break;
              case KEY_DOWN:
              case KEY_S:
                newdir = 2;
                break;
              case KEY_RIGHT:
              case KEY_D:
                newdir = 4;
                break;
              case KEY_LEFT:
              case KEY_A:
                newdir = 8;
                break;
              default:
                return;
            }
            act('cycle_attackdir', { newdir: newdir });
          }
        }}>
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
  const { act, data } = useBackend<CasData>(context);
  const {
    ship_status,
    fuel_left,
    fuel_max,
  } = data;
  return (
    <>
      <Section
        title="Ship Status">
        {ship_status}
      </Section>
      <Section title="Engine Control">
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Spool Engines"
            onClick={() => act("toggle_engines")}
            disabled={fuel_left <= 0} />
        </Box>
        <Box
          content="Fuel capacity:"
          width="100%"
          textAlign="center">
          <NoticeBox>Fuel level {fuel_left/fuel_max *100}%</NoticeBox>
        </Box>
      </Section>
    </>
  );
};

const NormalOperation = (props, context) => {
  const { act, data } = useBackend<CasData>(context);
  const {
    plane_state,
    plane_mode,
    ship_status,
    attackdir,
    active_lasers,
    fuel_left,
    fuel_max,
    all_weapons,
    active_weapon_name,
    active_weapon_ammo,
    active_weapon_max_ammo,
    active_weapon_ammo_name,
    active_weapon_tag,
  } = data;
  return (
    <>
      <Section title="Ship Status">
        <NoticeBox>{ship_status}</NoticeBox>
        <NoticeBox>{active_lasers} Active Lasers Detected</NoticeBox>
        <NoticeBox>Fuel level</NoticeBox>
        <ProgressBar
          ranges={{
            good: [0.5, Infinity],
            average: [-Infinity, 0.25],
          }}
          value={(fuel_left/fuel_max)} />
      </Section>
      <Section title="Weapons">
        {all_weapons.length > 0 ? (
          all_weapons.map(equipment => (
            <Box
              key={equipment.eqp_tag}>
              <Button
                onClick={() => act(
                  'change_weapon',
                  { selection: equipment.eqp_tag }
                )}
                disabled={equipment.eqp_tag === active_weapon_tag}>
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
          title={"Weapon Selected: "+active_weapon_name}
          buttons={
            <Button onClick={() => act('deselect')}>
              Deselect
            </Button>
          }>
          {active_weapon_ammo === null || active_weapon_max_ammo === null ? (
            <Box color="bad">No ammo loaded</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Ammo loaded">
                {active_weapon_ammo_name}
              </LabeledList.Item>
              <LabeledList.Item label="Ammo count">
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0, 0.5],
                    bad: [-Infinity, 0],
                  }}
                  value={active_weapon_ammo
                  / active_weapon_max_ammo}
                  content={active_weapon_ammo
                  +" / "
                  +active_weapon_max_ammo} />
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
            disabled={plane_state === 3 || plane_mode !== "idle"} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Land plane"
            onClick={() => act(
              'land')}
            disabled={plane_state !== 3 || plane_mode !== "idle"} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Disable Engines"
            onClick={() => act("toggle_engines")}
            disabled={plane_state !== 2} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="Begin Firemission"
            onClick={() => act("deploy")}
            disabled={plane_state !== 3} />
        </Box>
        <Box
          width="100%"
          textAlign="center">
          <Button
            content={"Strafe Direction: "+attackdir}
            onClick={() => act('cycle_attackdir')} />
        </Box>
      </Section>
    </>
  );
};
