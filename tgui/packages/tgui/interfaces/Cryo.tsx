import {
  AnimatedNumber,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
];

type ReagentEntry = {
  name: string;
  volume: number;
};

type OccupantData = {
  name: string;
  stat: string;
  statstate: string;
  health: number;
  maxHealth: number;
  minHealth: number;
  bruteLoss: number;
  oxyLoss: number;
  toxLoss: number;
  fireLoss: number;
  bodyTemperature: number;
  temperaturestatus: string;
};

type CryoProps = {
  isOperating: BooleanLike;
  autoEject: BooleanLike;
  occupant: OccupantData;
  cellTemperature: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: ReagentEntry[];
};

export const Cryo = () => {
  const { act, data } = useBackend<CryoProps>();
  const {
    isOperating,
    autoEject,
    occupant,
    cellTemperature,
    isBeakerLoaded,
    beakerContents,
  } = data;
  return (
    <Window width={400} height={550}>
      <Window.Content scrollable>
        <Section title="Occupant">
          <LabeledList>
            <LabeledList.Item label="Occupant">
              {occupant.name || 'No Occupant'}
            </LabeledList.Item>
            {!!occupant && (
              <>
                <LabeledList.Item label="State" color={occupant.statstate}>
                  {occupant.stat}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Temperature"
                  color={occupant.temperaturestatus}
                >
                  <AnimatedNumber value={occupant.bodyTemperature} />
                  {' K'}
                </LabeledList.Item>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    value={occupant.health / occupant.maxHealth}
                    color={occupant.health > 0 ? 'good' : 'average'}
                  >
                    <AnimatedNumber value={occupant.health} />
                  </ProgressBar>
                </LabeledList.Item>
                {damageTypes.map((damageType) => (
                  <LabeledList.Item
                    key={damageType.label}
                    label={damageType.label}
                  >
                    <ProgressBar value={occupant[damageType.type] / 100}>
                      <AnimatedNumber value={occupant[damageType.type]} />
                    </ProgressBar>
                  </LabeledList.Item>
                ))}
              </>
            )}
          </LabeledList>
        </Section>
        <Section title="Cell">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                onClick={() => act('power')}
                selected={isOperating}
              >
                {isOperating ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber value={cellTemperature} /> K
            </LabeledList.Item>
            <LabeledList.Item label="Door">
              <Button
                icon="eject"
                disabled={!occupant}
                onClick={() => act('eject')}
              >
                Eject Patient
              </Button>
              <Button
                icon={autoEject ? 'sign-out-alt' : 'sign-in-alt'}
                onClick={() => act('autoeject')}
              >
                {autoEject ? 'Auto' : 'Manual'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Beaker"
          buttons={
            <Button
              icon="eject"
              disabled={!isBeakerLoaded}
              onClick={() => act('ejectbeaker')}
            >
              Eject
            </Button>
          }
        >
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
