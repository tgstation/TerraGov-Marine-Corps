import { useBackend } from '../backend';
import { Button, Section, ProgressBar, Collapsible } from '../components';
import { Window } from '../layouts';


const EvolveProgress = props => (
  <Section
    title={`Evolution progress - ${props.current}/${props.max}`}
    height="100%">
    <ProgressBar
      ranges={{
        good: [0.75, Infinity],
        average: [-Infinity, 0.75],
      }}
      value={props.current / props.max} />
  </Section>
);

const CasteView = props => {
  // These are removed since every caste has them and its just clutter.
  const filteredAbilities = ["Rest", "Regurgitate"];
  const abilites = Object
    .values(props.abilites)
    .filter(ability => filteredAbilities.indexOf(ability.name) === -1);
  const lastItem = Object.keys(props.abilites).slice(-1)[0];

  return (
    <Section title={`${props.name} - Abilities`}>
      {props.abilites ? (
        abilites.map(ability => (
          <Button
            fluid={1}
            key={ability.name}
            color="transparent"
            tooltip={ability.desc}
            tooltipPosition={"bottom"}
            content={ability.name} />
        ))
      ) : "This caste has no abilites"}
    </Section>
  );
};


export const HiveEvolveScreen = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    name,
    evolution,
    abilities,
    evolves_to,
    can_evolve,
  } = data;

  const canEvolve = can_evolve && evolution.current >= evolution.max;
  // Most checks are skipped for shrike and queeen so we except them below.
  const instantEvolveTypes = ["Shrike", "Queen"];
  const evolvesInto = Object.values(evolves_to);

  return (
    <Window
      theme="xeno"
      title="Xenomorph Evolution"
      width={400}
      height={750}>
      <Window.Content scrollable>
        <Section title="Current Evolution">
          <CasteView
            act={act}
            current
            name={name}
            abilites={abilities} />
          <EvolveProgress
            current={evolution.current}
            max={evolution.max} />
        </Section>
        <Section title="Available Evolutions">
          {evolvesInto.map((evolve, idx) => (
            <Collapsible
              key={evolve.type_path}
              title={`${evolve.name} (click for details)`}
              buttons={(
                <Button
                  disabled={!canEvolve
                    && !instantEvolveTypes.includes(evolve.name)}
                  onClick={() => act('evolve', { path: evolve.type_path })}>
                  Evolve
                </Button>
              )}>
              <CasteView
                name={evolve.name}
                abilites={evolve.abilities}
                canEvolve={canEvolve}
              />
            </Collapsible>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
