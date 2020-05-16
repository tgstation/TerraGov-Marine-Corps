import { useBackend } from '../backend';
import { Button, Flex, Section, ProgressBar } from '../components';
import { Window } from '../layouts';


const EvolveProgress = props => (
  <Section title="Progress" height="100%">
    Evolve: {props.current}/{props.max}
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
  const evolveButton = (
    <Button
      disabled={!props.canEvolve}
      onClick={() => props.act('evolve', props.caste_type)}>
      Evolve
    </Button>
  );

  return (
    <Section height={"100%"} title={props.name} buttons={!props.current
      && evolveButton}>
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
  const canEvolve = data.evolution.current >= data.evolution.max;
  const evolvesInto = Object.values(data.evolves_to);
  return (
    <Window theme={"xeno"} resizable>
      <Window.Content scrollable>
        <Section title="Xenomorph Evolution">
          <Flex>
            <Flex.Item m={1} grow={2}>
              <CasteView
                act={act}
                current
                name={data.name}
                abilites={data.abilities} />
            </Flex.Item>
            <Flex.Item m={1} grow={1} >
              <EvolveProgress
                current={data.evolution.current}
                max={data.evolution.max}
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Available Evolutions">
          <Flex grow={1}>
            {evolvesInto.map((evolve, idx) => (
              <Flex.Item key={evolve.type_path} m={"3px"} grow={1} >
                <CasteView
                  act={() => act('evolve', { path: evolve.type_path })}
                  name={evolve.name}
                  abilites={evolve.abilities}
                  lastSection={idx === (evolvesInto.length - 1)}
                  canEvolve={canEvolve} />
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
