import { Box, Icon, Section, Stack, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  COLOR_BRUTE,
  COLOR_BURN,
  COLOR_ZEBRA_BG,
  ROUNDED_BORDER,
  SPACING_PIXELS,
} from './constants';
import { LimbStatuses, LimbTypes, MedScannerData } from './data';
import { getLimbNameColor, getLimbTypeColor } from './helpers';
import { MedConditionalBox, MedConditionalIcon } from './MedConditional';

export function PatientLimbs() {
  let row_transparency = 0;
  const { data } = useBackend<MedScannerData>();
  const { limb_data_lists = {}, species, accessible_theme } = data;
  return (
    <Section title="Limbs Damaged">
      <Stack vertical fill>
        <Stack height="20px" mb="-4px">
          <Stack.Item basis="80px" />
          <Stack.Item basis="50px" bold color={COLOR_BRUTE}>
            Brute
          </Stack.Item>
          <Stack.Item bold color={COLOR_BURN}>
            Burn
          </Stack.Item>
          <Stack.Item grow textAlign="right" color="grey" nowrap>
            <Icon name="droplet" inline bold px={SPACING_PIXELS} />
            {'= Bleeding '}
            {'{ } = Untreated'}
          </Stack.Item>
        </Stack>
        {Object.values(limb_data_lists).map((limb) => (
          <Stack
            key={limb.name}
            fill
            py="2.5px"
            backgroundColor={row_transparency++ % 2 === 0 ? COLOR_ZEBRA_BG : ''}
            style={ROUNDED_BORDER}
            my="-2px"
          >
            <Stack.Item
              basis="80px"
              pl="2.5px"
              bold={limb.brute + limb.burn !== 0 || limb.missing}
              textColor={
                limb.missing
                  ? 'grey'
                  : getLimbNameColor(
                      limb.brute,
                      limb.burn,
                      limb.max_damage,
                      species.is_robotic_species,
                      limb.limb_type,
                    )
              }
            >
              {limb.name[0].toUpperCase() + limb.name.slice(1)}
            </Stack.Item>
            {limb.missing ? (
              <Tooltip
                content={
                  species.is_robotic_species
                    ? 'Missing limbs on robotic patients can be fixed easily through a robotic cradle. Head reattachment can only be done through surgical intervention.'
                    : 'Missing limbs can only be fixed through surgical intervention. Head reattachment is only possible for combat robots and synthetics. Only printed limbs work as a replacement.'
                }
              >
                <Stack.Item color="grey">Missing</Stack.Item>
              </Tooltip>
            ) : (
              <>
                <Stack.Item>
                  <Tooltip
                    content={
                      limb.limb_type === LimbTypes.Robotic
                        ? 'Limb denting. Can be welded with a blowtorch or nanopaste.'
                        : limb.bandaged
                          ? 'Treated wounds will slowly heal on their own, or can be healed faster with chemicals.'
                          : 'Untreated physical trauma. Can be bandaged with gauze or advanced trauma kits.'
                    }
                  >
                    <Box
                      inline
                      width="50px"
                      color={limb.brute > 0 ? COLOR_BRUTE : 'white'}
                    >
                      {limb.bandaged ? `${limb.brute}` : `{${limb.brute}}`}
                    </Box>
                  </Tooltip>
                  <Box inline width={SPACING_PIXELS} />
                  <Tooltip
                    content={
                      limb.limb_type === LimbTypes.Robotic
                        ? 'Wire scorching. Can be repaired with a cable coil or nanopaste.'
                        : limb.salved
                          ? 'Salved burns will slowly heal on their own, or can be healed faster with chemicals.'
                          : 'Unsalved burns. Can be salved with ointment or advanced burn kits.'
                    }
                  >
                    <Box
                      inline
                      width="40px"
                      color={limb.burn > 0 ? COLOR_BURN : 'white'}
                    >
                      {limb.salved ? `${limb.burn}` : `{${limb.burn}}`}
                    </Box>
                  </Tooltip>
                </Stack.Item>
                <Stack.Item>
                  <MedConditionalIcon
                    condition={limb.bleeding}
                    name="droplet"
                    color="red"
                    tooltip="Bleeding can be stopped with gauze or an advanced trauma kit."
                  />
                  <MedConditionalBox
                    condition={limb.limb_status}
                    color={
                      limb.limb_status !== LimbStatuses.Fracture
                        ? 'lime'
                        : 'white'
                    }
                    tooltip={
                      (limb.limb_status !== LimbStatuses.Fracture
                        ? limb.limb_status === LimbStatuses.Stabilized
                          ? "This fracture is stabilized by the patient's armor, suppressing most of its symptoms. If their armor is removed, it'll stop being stabilized."
                          : 'This fracture is stabilized by a splint, suppressing most of its symptoms. If this limb sustains damage, the splint might come off.'
                        : 'Use a splint to stabilize it. An unsplinted head, chest or groin will cause organ damage when the patient moves. Unsplinted arms or legs will frequently give out.') +
                      ' It can be fully treated with surgery or cryo treatment.'
                    }
                  >
                    [{limb.limb_status}]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.limb_type}
                    color={getLimbTypeColor(
                      limb.limb_type || LimbTypes.Normal,
                      !!species.is_robotic_species,
                      accessible_theme,
                    )}
                    tooltip={
                      limb.limb_type === LimbTypes.Robotic
                        ? 'Robotic limbs are only fixed by welding or cable coils.'
                        : 'Biotic limbs take more damage, but can be fixed through normal methods.'
                    }
                  >
                    [{limb.limb_type}]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.implants}
                    tooltip="Use tweezers to remove the implants. Risk of brute damage and internal bleeding if left untreated."
                  >
                    [Implant x{limb.implants}]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.open_incision}
                    color="red"
                    tooltip="Open surgical incisions can usually be closed by a cautery depending on the stage of the surgery. Risk of infection if left untreated."
                  >
                    [Open Incision]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.infected}
                    color="olive"
                    tooltip="Infected limbs can be treated with spaceacillin. Risk of necrosis if left untreated."
                  >
                    [Infected]
                  </MedConditionalBox>
                  <MedConditionalBox
                    condition={limb.necrotized}
                    color="brown"
                    tooltip="Necrotized arms or legs cause random dropping of items or falling over, respectively. Organ damage will occur if on the head, chest or groin. Treated by surgery."
                  >
                    [Necrosis]
                  </MedConditionalBox>
                </Stack.Item>
              </>
            )}
          </Stack>
        ))}
      </Stack>
    </Section>
  );
}
