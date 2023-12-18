import { IndividualData, PerkData, PerkIcon } from './index';
import { useBackend, useLocalState } from '../../backend';
import { LabeledList, Button, Stack, Section, Flex, Box } from '../../components';

export const IndividualPerks = (props, context) => {
  const { act, data } = useBackend<IndividualData>(context);
  const { perks_data } = data;
  const [unlockedPerk, setPurchasedPerk] = useLocalState<PerkData | null>(
    context,
    'unlockedPerk',
    null
  );
  const [selectedPerk, setSelectedPerk] = useLocalState(
    context,
    'selectedPerk',
    perks_data[0]
  );
  perks_data.sort((a, b) => {
    const used_asset_a = a.currently_active;
    const used_asset_b = b.currently_active;
    if (used_asset_a && used_asset_b) return 0;
    if (used_asset_a && !used_asset_b) return -1;
    if (!used_asset_a && used_asset_b) return 1;
    return 0;
  });

  return (
    <Stack>
      <Stack.Item>
        <Stack vertical>
          {perks_data.map((perk) => (
            <Stack.Item key={perk.name}>
              <Button
                width={'180px'}
                onClick={() => setSelectedPerk(perk)}
                color={
                  selectedPerk.name === perk.name
                    ? 'orange'
                    : perk.currently_active > 0
                      ? 'blue'
                      : perk.currently_active < 0
                        ? 'red'
                        : 'grey'
                }>
                <Flex align="center">
                  {!!perk.icon && (
                    <PerkIcon
                      icon={
                        selectedPerk.name === perk.name
                          ? perk.icon + '_red'
                          : perk.icon + '_blue'
                      }
                    />
                  )}
                  {perk.name}
                </Flex>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={
            selectedPerk ? (
              <Box>
                <Flex align="center">
                  <Flex.Item>
                    {
                      <PerkIcon
                        icon={selectedPerk.icon + '_orange'}
                        icon_width={'36px'}
                        icon_height={'36px'}
                      />
                    }
                  </Flex.Item>
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedPerk.name}
                  </Flex.Item>
                  <Flex.Item alight="right" position="end">
                    <Button
                      onClick={() => setPurchasedPerk(selectedPerk)}
                      icon={'check'}>
                      Unlock
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            ) : (
              'No perk selected'
            )
          }>
          <LabeledList>
            <LabeledList.Item label="Name">
              {selectedPerk?.name}
            </LabeledList.Item>
            <LabeledList.Item label="Summary">
              {selectedPerk?.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Cost">
              {selectedPerk?.cost}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
