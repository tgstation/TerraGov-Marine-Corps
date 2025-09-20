import {
  Button,
  Collapsible,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const EvolveProgress = (props) => (
  <Section
    title={`Evolution progress - ${props.current}/${props.max}`}
    height="100%"
  >
    <ProgressBar
      ranges={{
        good: [0.75, Infinity],
        average: [-Infinity, 0.75],
      }}
      value={props.current ? props.current / props.max : 0}
    />
  </Section>
);

const CasteView = (props) => {
  // These are removed since every caste has them and its just clutter.
  const filteredAbilities = ['Rest', 'Regurgitate'];
  const abilities = Object.values(props.abilities).filter(
    (ability: XenoAbility) => filteredAbilities.indexOf(ability.name) === -1,
  ) as XenoAbility[];

  return (
    <Section title={`${props.name} - Abilities`}>
      {props.abilities
        ? abilities.map((ability) => (
            <Button
              fluid
              key={ability.name}
              color="transparent"
              tooltip={ability.desc}
              tooltipPosition={'bottom'}
              content={ability.name}
            />
          ))
        : 'This caste has no abilities'}
    </Section>
  );
};

export const HiveEvolveScreen = (props) => {
  const { act, data } = useBackend();

  const {
    name,
    evolution,
    abilities,
    evolves_to,
    can_evolve,
    bypass_evolution_checks,
  } = data as ByondData;

  const canEvolve = can_evolve && evolution.current >= evolution.max;
  const bypassEvolution = can_evolve && bypass_evolution_checks;
  // Most checks are skipped for shrike and queen so we except them below.
  const evolvesInto = Object.values(evolves_to);

  return (
    <Window theme="xeno" title="Xenomorph Evolution" width={400} height={750}>
      <Window.Content scrollable>
        <Section title="Current Evolution">
          <CasteView act={act} current name={name} abilities={abilities} />
          <EvolveProgress current={evolution.current} max={evolution.max} />
        </Section>
        <Section title="Available Evolutions">
          {evolvesInto.map((evolve, idx) => (
            <Collapsible
              key={evolve.type_path}
              title={`${evolve.name} (click for details)`}
              buttons={
                <Button
                  disabled={
                    !canEvolve && !evolve.instant_evolve && !bypassEvolution
                  }
                  onClick={() => act('evolve', { path: evolve.type_path })}
                >
                  Evolve
                </Button>
              }
            >
              <CasteView
                name={evolve.name}
                abilities={evolve.abilities}
                canEvolve={canEvolve}
              />
            </Collapsible>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

type ByondData = {
  name: string;
  evolution: {
    current: number;
    max: number;
  };
  abilities: XenoAbility[];
  evolves_to: EvolveCaste[];
  can_evolve: boolean;
  bypass_evolution_checks: boolean;
};

type EvolveCaste = {
  type_path: string;
  name: string;
  abilities: XenoAbility[];
  instant_evolve: boolean;
};

type XenoAbility = {
  name: string;
  desc: string;
};
