import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MedScannerData, TempLevels } from './data';
import { PatientAdvice } from './PatientAdvice';
import { PatientBasics } from './PatientBasics';
import { PatientChemicals } from './PatientChemicals';
import { PatientFooter } from './PatientFooter';
import { PatientLimbs } from './PatientLimbs';
import { PatientOrgans } from './PatientOrgans';

export function MedScanner() {
  const { data } = useBackend<MedScannerData>();
  const {
    species,
    has_chemicals,
    limbs_damaged,
    damaged_organs,
    blood_amount,
    regular_blood_amount,
    body_temperature,
    internal_bleeding,
    advice,
    accessible_theme,
  } = data;
  return (
    <Window
      width={520}
      height={620}
      theme={
        accessible_theme
          ? species.is_robotic_species
            ? 'hackerman'
            : 'default'
          : species.is_robotic_species
            ? 'ntos_rusty'
            : 'ntos_healthy'
      }
    >
      <Window.Content scrollable>
        <PatientBasics />
        {!!has_chemicals && <PatientChemicals />}
        {!!limbs_damaged && <PatientLimbs />}
        {!!damaged_organs?.length && <PatientOrgans />}
        {!!(
          blood_amount < regular_blood_amount ||
          internal_bleeding ||
          body_temperature.level !== TempLevels.OK
        ) && <PatientFooter />}
        {!!advice && <PatientAdvice />}
      </Window.Content>
    </Window>
  );
}
