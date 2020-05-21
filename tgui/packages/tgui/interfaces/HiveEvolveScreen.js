import { useBackend } from '../backend';
import { Button, Flex, Section, ProgressBar, Collapsible } from '../components';
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
  const filteredAbilities = ["Rest", "Regurgitate"];
  const abilites = Object
    .values(props.abilites)
    .filter(ability => filteredAbilities.indexOf(ability.name) === -1);
  const lastItem = Object.keys(props.abilites).slice(-1)[0];

  return (
    <Section height={"100%"} title={props.name}>
      <strong>Abilities</strong>
      <span style={{ color: 'grey' }}>{' (hover for details)'}</span>
      <p>
        {props.abilites ? (
          <ul>
            {abilites.map(ability => (
              <li key={ability.name}>
                <Button
                  color="transparent"
                  tooltip={ability.desc}
                  tooltipPosition={(props.lastSection
                    ? "bottom-left"
                    : "bottom-right")}
                  content={ability.name} />
              </li>
            ))}
          </ul>
        ) : "This caste has no abilites"}
      </p>
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
  const evolvesInto = Object.values(evolves_to);

  return (
    <Window resizable>
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
                  disabled={!canEvolve}
                  onClick={() => act('evolve', { path: evolve.type_path })}>
                  Evolve
                </Button>
              )}>
              <CasteView
                name={evolve.name}
                abilites={evolve.abilities}
                lastSection={idx === (evolvesInto.length - 1)}
                canEvolve={canEvolve}
              />
            </Collapsible>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
