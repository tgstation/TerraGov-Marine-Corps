import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Crew = (props) => {
  const { act, data } = useBackend();

  return (
    <Window title="Pod Launcher" width={1000} height={700}>
      <Window.Content>
        <Section title="Supplypod bay">
          <Button
            onClick={() => act('bay', { bay: 1 })}
            disabled={data.bayNumber === 1}
          >
            Bay #1
          </Button>
          <Button
            onClick={() => act('bay', { bay: 2 })}
            disabled={data.bayNumber === 2}
          >
            Bay #2
          </Button>
          <Button
            onClick={() => act('bay', { bay: 3 })}
            disabled={data.bayNumber === 3}
          >
            Bay #3
          </Button>
          <Button
            onClick={() => act('bay', { bay: 4 })}
            disabled={data.bayNumber === 4}
          >
            Bay #4
          </Button>
          <Button
            onClick={() => act('bay', { bay: 5 })}
            disabled={data.bayNumber === 5}
          >
            Bay #5
          </Button>
        </Section>
        <Section title="Teleport to">
          <Button onClick={() => act('teleportCentcom')}>{data.bay}</Button>
          <Button onClick={() => act('teleportBack')} disabled={!data.oldArea}>
            {data.oldArea ? data.oldArea : 'where you were'}
          </Button>
        </Section>
        <Section title="Launch clones">
          <Button onClick={() => act('launchClone')}>Launch Clones</Button>
        </Section>
        <Section title="Launch all at once">
          <Button onClick={() => act('launchOrdered')}>Ordered</Button>
          <Button onClick={() => act('launchRandom')}>Random</Button>
        </Section>
        <Section title="Explosion">
          <Button onClick={() => act('explosionCustom')}>Custom Size</Button>
          <Button onClick={() => act('explosionBus')}>Adminbus</Button>
        </Section>
        <Section title="Damage">
          <Button onClick={() => act('damageCustom')}>Custom Damage</Button>
          <Button onClick={() => act('damageGib')}>Gib</Button>
        </Section>
        <Section title="Damage effects">
          <Button onClick={() => act('effectStun')}>Stun</Button>
          <Button onClick={() => act('effectLimb')}>Delimb</Button>
          <Button onClick={() => act('effectOrgans')}>De-organ</Button>
        </Section>
        <Section title="Movement effects">
          <Button onClick={() => act('effectBluespace')}>Bluespace</Button>
          <Button onClick={() => act('effectStealth')}>Stealth</Button>
          <Button onClick={() => act('effectQuiet')}>Quiet Landing</Button>
          <Button onClick={() => act('effectReverse')}>Reverse Mode</Button>
          <Button onClick={() => act('effectMissile')}>Missile Mode</Button>
          <Button onClick={() => act('effectCircle')}>Any Descent Angle</Button>
          <Button onClick={() => act('effectBurst')}>Machine Gun Mode</Button>
          <Button onClick={() => act('effectTarget')}>Specific Target</Button>
        </Section>
        <Section title="Customization">
          <Button onClick={() => act('effectName')}>Custom Name</Button>
          <Button onClick={() => act('effectAnnounce')}>Alert Ghosts</Button>
        </Section>
        <Section title="Sound">
          <Button onClick={() => act('fallingSound')}>
            Custom Falling Sound
          </Button>
          <Button onClick={() => act('landingSound')}>
            Custom Landing Sound
          </Button>
          <Button onClick={() => act('openingSound')}>
            Custom Opening Sound
          </Button>
          <Button onClick={() => act('leavingSound')}>
            Custom Leaving Sound
          </Button>
          <Button onClick={() => act('soundVolume')}>Admin Sound Volume</Button>
        </Section>
        <Section title="Delay timers">
          <Button onClick={() => act('fallDuration')}>
            Custom Falling Duration
          </Button>
          <Button onClick={() => act('landingDelay')}>
            Custom Landing Time
          </Button>
          <Button onClick={() => act('openingDelay')}>
            Custom Opening Time
          </Button>
          <Button onClick={() => act('departureDelay')}>
            Custom Leaving Time
          </Button>
        </Section>
        <Section title="Style">
          <Button onClick={() => act('styleStandard')}>Standard</Button>
          <Button onClick={() => act('styleBluespace')}>Advanced</Button>
          <Button onClick={() => act('styleSyndie')}>Syndicate</Button>
          <Button onClick={() => act('styleBlue')}>Deathsquad</Button>
          <Button onClick={() => act('styleCult')}>Cult</Button>
          <Button onClick={() => act('styleMissile')}>Missile</Button>
          <Button onClick={() => act('styleSMissile')}>
            Syndicate Missile
          </Button>
          <Button onClick={() => act('styleBox')}>Supply Crate</Button>
          <Button onClick={() => act('styleHONK')}>Honk</Button>
          <Button onClick={() => act('styleFruit')}>Fruit</Button>
          <Button onClick={() => act('styleInvisible')}>Invisible</Button>
          <Button onClick={() => act('styleGondola')}>Gondola</Button>
          <Button onClick={() => act('styleSeeThrough')}>See-Through</Button>
        </Section>
        <Section title={'Action ' + data.numObjects + ' turfs in ' + data.bay}>
          <Button onClick={() => act('refresh')}>Refresh Pod Bay</Button>
          <Button onClick={() => act('giveLauncher')}>Enter Launch Mode</Button>
          <Button onClick={() => act('clearBay')}>Clear Selected Bay</Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
