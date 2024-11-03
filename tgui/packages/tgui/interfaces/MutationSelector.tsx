import { useBackend } from '../backend';
import {
  Button,
  Collapsible,
  Flex,
  ProgressBar,
  Section,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type Upgrade = {
  name: string;
  desc: string;
  owned: boolean;
};

type BiomassData = {
  biomass: number;
  cost: number;
};

type SurvivalMutationData = {
  survival_mutations: Upgrade[];
  shell_chambers: number;
  biomass: number;
  cost: number;
};

type AttackMutationData = {
  attack_mutations: Upgrade[];
  spur_chambers: number;
  biomass: number;
  cost: number;
};

type UtilityMutationData = {
  utility_mutations: Upgrade[];
  veil_chambers: number;
  biomass: number;
  cost: number;
};

export const MutationSelector = (_props: any) => {
  return (
    <Window theme="xeno" width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Biomass" key="Biomass">
          <BiomassBar />
        </Section>
        <SurvivalMutationSection />
        <AttackMutationSection />
        <UtilityMutationSection />
      </Window.Content>
    </Window>
  );
};

const BiomassBar = (_props: any) => {
  const { data } = useBackend<BiomassData>();
  const { biomass, cost } = data;

  return (
    <Tooltip content={`Costs ${cost} biomass to buy an upgrade!`}>
      <Flex mb={1}>
        <Flex.Item grow>
          <ProgressBar color="green" value={biomass / 100}>
            {`${biomass} / 100 `}
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const SurvivalMutationSection = (_props: any) => {
  const { act, data } = useBackend<SurvivalMutationData>();
  const { survival_mutations, shell_chambers, cost, biomass } = data;

  return (
    <Section
      title={`Survival | Shell Chambers: ${shell_chambers}/3`}
      key="Survival"
    >
      <Collapsible title={`Survival Mutations`}>
        {survival_mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy (${cost})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
                disabled={cost > biomass || shell_chambers === 0}
                selected={mutation.owned}
              />
            }
          >
            <Flex direction="column-reverse" align={'left'}>
              {mutation.desc}
            </Flex>
          </Section>
        ))}
      </Collapsible>
    </Section>
  );
};

const AttackMutationSection = (_props: any) => {
  const { act, data } = useBackend<AttackMutationData>();
  const { attack_mutations, spur_chambers, cost, biomass } = data;

  return (
    <Section title={`Attack | Spur Chambers: ${spur_chambers}/3`} key="Attack">
      <Collapsible title={`Attack Mutations`}>
        {attack_mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy (${cost})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
                disabled={cost > biomass || spur_chambers === 0}
                selected={mutation.owned}
              />
            }
          >
            <Flex direction="column-reverse" align={'left'}>
              {mutation.desc}
            </Flex>
          </Section>
        ))}
      </Collapsible>
    </Section>
  );
};

const UtilityMutationSection = (_props: any) => {
  const { act, data } = useBackend<UtilityMutationData>();
  const { utility_mutations, veil_chambers, cost, biomass } = data;

  return (
    <Section
      title={`Utility | Veil Chambers: ${veil_chambers}/3`}
      key="Utility"
    >
      <Collapsible title={`Utility Mutations`}>
        {utility_mutations.map((mutation) => (
          <Section
            title={`${mutation.name}`}
            mb={1}
            key={mutation.name}
            buttons={
              <Button
                content={`Buy (${cost})`}
                key={mutation.name}
                onClick={() => act('purchase', { upgrade_name: mutation.name })}
                disabled={cost > biomass || veil_chambers === 0}
                selected={mutation.owned}
              />
            }
          >
            <Flex direction="column-reverse" align={'left'}>
              {mutation.desc}
            </Flex>
          </Section>
        ))}
      </Collapsible>
    </Section>
  );
};
