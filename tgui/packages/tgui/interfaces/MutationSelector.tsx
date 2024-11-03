import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  ProgressBar,
  Section,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const bar_text_width = 10.25;

type Upgrade = {
  name: string;
  desc: string;
};

type MutationData = {
  shell_chambers: number;
  spur_chambers: number;
  veil_chambers: number;
  biomass: number;
  cost: number;
  survival_mutations: Upgrade[];
  attack_mutations: Upgrade[];
  utility_mutations: Upgrade[];
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

export const MutationSelector = (props) => {
  const { act, data } = useBackend<MutationData>();
  const {
    shell_chambers,
    spur_chambers,
    veil_chambers,
    biomass,
    cost,
    survival_mutations,
    attack_mutations,
    utility_mutations,
  } = data;

  return (
    <Window width={700} height={810}>
      <Window.Content>
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
      {survival_mutations.map((mutation) => (
        <Box mb={3} key={mutation.name}>
          <Button
            content={`${mutation.name}`}
            key={mutation.name}
            onClick={() => act('purchase', { upgrade_name: mutation.name })}
            disabled={cost > biomass || shell_chambers === 0}
          />
          <Flex direction="column-reverse" align={'left'}>
            {mutation.desc}
          </Flex>
        </Box>
      ))}
    </Section>
  );
};

const AttackMutationSection = (_props: any) => {
  const { act, data } = useBackend<AttackMutationData>();
  const { attack_mutations, spur_chambers, cost, biomass } = data;

  return (
    <Section title={`Attack | Spur Chambers: ${spur_chambers}/3`} key="Attack">
      {attack_mutations.map((mutation) => (
        <Box mb={3} key={mutation.name}>
          <Button
            content={`${mutation.name}`}
            key={mutation.name}
            onClick={() => act('purchase', { upgrade_name: mutation.name })}
            disabled={cost > biomass || spur_chambers === 0}
          />
          <Flex direction="column-reverse" align={'left'}>
            {mutation.desc}
          </Flex>
        </Box>
      ))}
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
      {utility_mutations.map((mutation) => (
        <Box mb={3} key={mutation.name}>
          <Button
            content={`${mutation.name}`}
            key={mutation.name}
            onClick={() => act('purchase', { upgrade_name: mutation.name })}
            disabled={cost > biomass || veil_chambers === 0}
          />
          <Flex direction="column-reverse" align={'left'}>
            {mutation.desc}
          </Flex>
        </Box>
      ))}
    </Section>
  );
};
