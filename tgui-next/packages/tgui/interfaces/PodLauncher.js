import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Box, Table } from '../components';

export const Crew = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Section title="Supplypod bay">
        <Button onClick={() => act(ref, 'bay', { bay: 1})} disabled={data.bayNumber===1}>Bay #1</Button>
        <Button onClick={() => act(ref, 'bay', { bay: 2})} disabled={data.bayNumber===2}>Bay #2</Button>
        <Button onClick={() => act(ref, 'bay', { bay: 3})} disabled={data.bayNumber===3}>Bay #3</Button>
        <Button onClick={() => act(ref, 'bay', { bay: 4})} disabled={data.bayNumber===4}>Bay #4</Button>
        <Button onClick={() => act(ref, 'bay', { bay: 5})} disabled={data.bayNumber===5}>Bay #5</Button>
      </Section>
      <Section title="Teleport to">
        <Button onClick={() => act(ref, 'teleportCentcom')}>{data.bay}</Button>
        <Button onClick={() => act(ref, 'teleportBack')} disabled={!data.oldArea}>
          {data.oldArea ? data.oldArea : "where you were"}
        </Button>
      </Section>
      <Section title="Launch clones">
        <Button onClick={() => act(ref, 'launchClone')}>Launch Clones</Button>
      </Section>
      <Section title="Launch all at once">
        <Button onClick={() => act(ref, 'launchOrdered')}>Ordered</Button>
        <Button onClick={() => act(ref, 'launchRandom')}>Random</Button>
      </Section>
      <Section title="Explosion">
        <Button onClick={() => act(ref, 'explosionCustom')}>Custom Size</Button>
        <Button onClick={() => act(ref, 'explosionBus')}>Adminbus</Button>
      </Section>
      <Section title="Damage">
        <Button onClick={() => act(ref, 'damageCustom')}>Custom Damage</Button>
        <Button onClick={() => act(ref, 'damageGib')}>Gib</Button>
      </Section>
      <Section title="Damage effects">
        <Button onClick={() => act(ref, 'effectStun')}>Stun</Button>
        <Button onClick={() => act(ref, 'effectLimb')}>Delimb</Button>
        <Button onClick={() => act(ref, 'effectOrgans')}>De-organ</Button>
      </Section>
      <Section title="Movement effects">
        <Button onClick={() => act(ref, 'effectBluespace')}>Bluespace</Button>
        <Button onClick={() => act(ref, 'effectStealth')}>Stealth</Button>
        <Button onClick={() => act(ref, 'effectQuiet')}>Quiet Landing</Button>
        <Button onClick={() => act(ref, 'effectReverse')}>Reverse Mode</Button>
        <Button onClick={() => act(ref, 'effectMissile')}>Missile Mode</Button>
        <Button onClick={() => act(ref, 'effectCircle')}>Any Descent Angle</Button>
        <Button onClick={() => act(ref, 'effectBurst')}>Machine Gun Mode</Button>
        <Button onClick={() => act(ref, 'effectTarget')}>Specific Target</Button>
      </Section>
      <Section title="Customization">
        <Button onClick={() => act(ref, 'effectName')}>Custom Name</Button>
        <Button onClick={() => act(ref, 'effectAnnounce')}>Alert Ghosts</Button>
      </Section>
      <Section title="Sound">
        <Button onClick={() => act(ref, 'fallingSound')}>Custom Falling Sound</Button>
        <Button onClick={() => act(ref, 'landingSound')}>Custom Landing Sound</Button>
        <Button onClick={() => act(ref, 'openingSound')}>Custom Opening Sound</Button>
        <Button onClick={() => act(ref, 'leavingSound')}>Custom Leaving Sound</Button>
        <Button onClick={() => act(ref, 'soundVolume')}>Admin Sound Volume</Button>
      </Section>
      <Section title="Delay timers">
        <Button onClick={() => act(ref, 'fallDuration')}>Custom Falling Duration</Button>
        <Button onClick={() => act(ref, 'landingDelay')}>Custom Landing Time</Button>
        <Button onClick={() => act(ref, 'openingDelay')}>Custom Opening Time</Button>
        <Button onClick={() => act(ref, 'departureDelay')}>Custom Leaving Time</Button>
      </Section>
      <Section title="Style">
        <Button onClick={() => act(ref, 'styleStandard')}>Standard</Button>
        <Button onClick={() => act(ref, 'styleBluespace')}>Advanced</Button>
        <Button onClick={() => act(ref, 'styleSyndie')}>Syndicate</Button>
        <Button onClick={() => act(ref, 'styleBlue')}>Deathsquad</Button>
        <Button onClick={() => act(ref, 'styleCult')}>Cult</Button>
        <Button onClick={() => act(ref, 'styleMissile')}>Missile</Button>
        <Button onClick={() => act(ref, 'styleSMissile')}>Syndicate Missile</Button>
        <Button onClick={() => act(ref, 'styleBox')}>Supply Crate</Button>
        <Button onClick={() => act(ref, 'styleHONK')}>Honk</Button>
        <Button onClick={() => act(ref, 'styleFruit')}>Fruit</Button>
        <Button onClick={() => act(ref, 'styleInvisible')}>Invisible</Button>
        <Button onClick={() => act(ref, 'styleGondola')}>Gondola</Button>
        <Button onClick={() => act(ref, 'styleSeeThrough')}>See-Through</Button>
      </Section>
      <Section title={"Action " + data.numObjects + " turfs in " + data.bay}>
        <Button onClick={() => act(ref, 'refresh')}>Refresh Pod Bay</Button>
        <Button onClick={() => act(ref, 'giveLauncher')}>Enter Launch Mode</Button>
        <Button onClick={() => act(ref, 'clearBay')}>Clear Selected Bay</Button>
      </Section>
    </Fragment>); };
