import {
  Box,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  COUNTER_MAX_SIZE,
  SPACING_PIXELS,
  TEMP_LEVELS_TO_DATA,
} from './constants';
import { BloodColors, MedScannerData, TempLevels } from './data';
import { getBloodColor } from './helpers';
import { MedBoxedTag } from './MedBoxedTag';
import { MedCounter } from './MedCounter';

export function PatientFooter() {
  const { data } = useBackend<MedScannerData>();
  const {
    dead,
    blood_amount,
    regular_blood_amount,
    blood_type,
    body_temperature,
    internal_bleeding,
    pulse,
    total_unknown_implants,
    infection,
    total_flow_rate,
  } = data;
  const bloodColors = getBloodColor(
    blood_amount,
    regular_blood_amount,
    internal_bleeding,
  );
  const tempData = TEMP_LEVELS_TO_DATA[body_temperature.level];
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label="Blood Volume"
          tooltip="Bloodloss causes symptoms that start as suffocation and pain, but get significantly worse as more blood is lost. Blood can be restored by eating and taking Isotonic solution."
        >
          <Icon
            name={total_flow_rate ? 'arrow-down' : 'arrow-up'}
            mr={SPACING_PIXELS}
            color={
              bloodColors.background === BloodColors.FineBG
                ? 'white'
                : bloodColors.background
            }
          />
          <Box
            mr={SPACING_PIXELS}
            inline
            color={
              bloodColors.background === BloodColors.FineBG
                ? 'white'
                : bloodColors.background
            }
            bold={bloodColors.background !== BloodColors.FineBG ? true : false}
          >
            {Math.trunc((blood_amount / regular_blood_amount) * 100)}%
          </Box>
          <MedCounter
            current={Math.trunc(blood_amount)}
            max={Math.trunc(regular_blood_amount)}
            units={`cl${total_flow_rate ? ` (${total_flow_rate}cl/2s)` : ''}`}
            currentColor={bloodColors.darker}
            maxColor={bloodColors.darker}
            currentSize={COUNTER_MAX_SIZE}
            mr={SPACING_PIXELS}
          />
          <MedBoxedTag
            mr={SPACING_PIXELS}
            textColor={bloodColors.foreground}
            backgroundColor={bloodColors.background}
          >
            {blood_type}
          </MedBoxedTag>
          {!!internal_bleeding && (
            <MedBoxedTag textColor="white" backgroundColor="red">
              INT. BLEEDING
            </MedBoxedTag>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Body Temperature" color={tempData.background}>
          <Box inline bold={body_temperature.level !== TempLevels.OK}>
            {body_temperature.current}
          </Box>
          {!!(body_temperature.level !== TempLevels.OK) && (
            <MedBoxedTag
              ml={SPACING_PIXELS}
              backgroundColor={tempData.background}
              textColor={tempData.foreground}
            >
              {tempData.tag}
            </MedBoxedTag>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Pulse">{pulse}</LabeledList.Item>
      </LabeledList>
      {!!infection && (
        <NoticeBox color="orange" mt="8px" mb="0px">
          {infection}
        </NoticeBox>
      )}
      {!!total_unknown_implants && (
        <NoticeBox color="orange" mt="8px" mb="0px">
          There {total_unknown_implants !== 1 ? 'are' : 'is'}{' '}
          {total_unknown_implants} unknown implant
          {total_unknown_implants !== 1 ? 's' : ''} detected within the patient.
        </NoticeBox>
      )}
    </Section>
  );
}
