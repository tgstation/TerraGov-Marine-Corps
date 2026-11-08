import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  COLOR_BRUTE,
  COLOR_BURN,
  REVIVABLE_STATES_TO_COLORS,
} from './constants';
import { MedScannerData } from './data';
import { MedDamageType } from './MedDamageType';

/** The most basic info: name, species, health, damage, revivability and hugged state */
export function PatientBasics() {
  const { data } = useBackend<MedScannerData>();
  const {
    patient,
    species,
    dead,
    health,
    max_health,
    crit_threshold,
    dead_threshold,
    total_brute,
    total_burn,
    total_tox,
    total_oxy,
    total_clone,
    hugged,
    revivable_status,
    revivable_reason,
    ssd,
    accessible_theme,
  } = data;
  return (
    <Section
      title={`${species.name}: ${patient}`}
      buttons={
        <Button
          icon="info"
          tooltip="For information on something, hover over it - nearly every element has a tooltip. Additionally, situational advice will appear under Treatment Advice."
          color="transparent"
          mt={
            // with the "hackerman" theme, the buttons have this ugly outline that messes with the section titlebar, let's fix that
            accessible_theme && species.is_robotic_species ? '-5px' : '0px'
          }
        >
          Information
        </Button>
      }
    >
      {!!hugged && (
        <NoticeBox danger>
          Patient has been implanted with an alien embryo!
        </NoticeBox>
      )}
      {!!ssd && <NoticeBox>{ssd}</NoticeBox>}
      <LabeledList>
        <LabeledList.Item
          label="Health"
          tooltip={`
            How healthy the patient is.${
              !!species.is_robotic_species &&
              ` If the patient's health dips below ${crit_threshold}%, they enter critical condition and suffocate rapidly.`
            }
            If the patient's health hits ${(dead_threshold / max_health) * 100}%, they die.
          `}
        >
          {health >= 0 ? (
            <ProgressBar
              value={health / max_health}
              ranges={{
                good: [0.4, Infinity],
                average: [0.2, 0.4],
                bad: [-Infinity, 0.2],
              }}
            />
          ) : (
            <ProgressBar value={1 + health / max_health} color="bad" bold>
              {Math.trunc((health / max_health) * 100)}%
            </ProgressBar>
          )}
        </LabeledList.Item>
        {!!dead && (
          <LabeledList.Item label="Revivable">
            <Box color={REVIVABLE_STATES_TO_COLORS[revivable_status]} bold>
              {revivable_status}
              {!!revivable_reason && ` (${revivable_reason})`}
            </Box>
          </LabeledList.Item>
        )}
        <LabeledList.Item
          label="Damage"
          tooltip="Unique damage types. Each one has a tooltip describing how it is sustained, and possible treatments."
        >
          <MedDamageType
            name="Brute"
            color={COLOR_BRUTE}
            damage={total_brute}
            tooltip={
              species.is_robotic_species
                ? 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Repaired with a blowtorch or robotic cradle.'
                : 'Brute. Sustained from sources of physical trauma such as melee combat, firefights, etc. Treated with Bicaridine or advanced trauma kits.'
            }
            noPadding
          />
          <MedDamageType
            name="Burn"
            color={COLOR_BURN}
            damage={total_burn}
            tooltip={
              species.is_robotic_species
                ? 'Burn. Sustained from sources of burning such as energy weapons, acid, fire, etc. Repaired with cable coils or a robotic cradle.'
                : 'Burn. Sustained from sources of burning such as overheating, energy weapons, acid, fire, etc. Treated with Kelotane or advanced burn kits.'
            }
          />
          {!species.is_robotic_species && (
            <>
              <MedDamageType
                name="Tox"
                color="green"
                damage={total_tox}
                tooltip="Toxin. Sustained from chemicals or organ damage. Treated with Dylovene."
              />
              <MedDamageType
                name="Oxy"
                color="blue"
                damage={total_oxy}
                tooltip="Oxyloss. Sustained from being in critical condition, organ damage or extreme exhaustion. Treated with CPR, Dexalin/Dexalin Plus or decreases on its own if the patient isn't in critical condition."
              />
            </>
          )}
          {!species.is_synthetic && (
            <MedDamageType
              name={species.is_combat_robot ? 'Integrity' : 'Clone'}
              color="teal"
              damage={total_clone}
              tooltip={
                species.is_robotic_species
                  ? 'Integrity Damage. Sustained from xenomorph psychic draining. Treated with a robotic cradle.'
                  : 'Cloneloss. Sustained from xenomorph psychic draining or special chemicals. Treated with cryogenics or sleep.'
              }
            />
          )}
          {!!species.is_robotic_species && (
            <>
              <MedDamageType
                name="Tox"
                tooltip="Robotic species cannot build up toxins."
                disabled
              />
              <MedDamageType
                name="Oxy"
                tooltip="Robotic species do not suffocate."
                disabled
              />
              {!!species.is_synthetic && (
                <MedDamageType
                  name="Clone"
                  tooltip="Synthetics do not suffer cellular damage or long term integrity loss."
                  disabled
                />
              )}
            </>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}
