import { useBackend } from "../backend";
import { Box, Button, Flex, Section } from "../components";
import { Window } from "../layouts";

type Upgrade = {
  name: string;
  desc: string;
};
type UpgradeCategories = {
  category: string;
  upgrades: Upgrade[];
};

type MutationData = {
  shell_chambers: number;
  spur_chambers: number;
  veil_chambers: number;
  biomass: number;
  cost: number;
  upgrades: UpgradeCategories[];
};

export const MutationSelector = (props) => {
  const { act, data } = useBackend<MutationData>();
  const {
    shell_chambers,
    spur_chambers,
    veil_chambers,
    biomass,
    cost,
    upgrades,
  } = data;

  return (
    <Window width={400} height={650}>
      <Window.Content>
        <Section title={`Biomass: ${biomass}/100`} align={"center"}>
          <Flex direction="column-reverse" align={"center"}>
            Shell Chambers: {shell_chambers}
          </Flex>
          <Flex direction="column-reverse" align={"center"}>
            Spur Chambers: {spur_chambers}
          </Flex>

          <Flex direction="column-reverse" align={"center"}>
            Veil Chambers: {veil_chambers}
          </Flex>
        </Section>
        {upgrades.map((upgrade_category) => (
          <Section
            title={`${upgrade_category.category} - ${cost}`}
            key={upgrade_category.category}
          >
            {upgrade_category.upgrades.map((upgrade) => (
              <Box key={upgrade_category.category}>
                <Button
                  content={upgrade.name}
                  key={upgrade.name}
                  onClick={() => act("purchase", { type: upgrade.name })}
                />
                <Flex direction="column-reverse" align={"left"}>
                  {upgrade.desc}
                </Flex>
              </Box>
            ))}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
