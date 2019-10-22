import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Button, LabeledList, NoticeBox, ProgressBar, Section, Box } from '../components';

export const MarineSelector = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <NoticeBox>Choose your equipment:</NoticeBox>
      {data.show_points && (
        <Box>Your Remaining Points: {data.current_m_points}</Box>
      )}
      <Section>
        <Box inline color="white">white = mandatory</Box>
        <Box inline color="orange">orange = recommended</Box>
      </Section>

      <LabeledList>
        {data.displayed_records.map(display_record => (
          <LabeledList.Item color={display_record.prod_color}>
            <Button
              disabled={!display_record.prod_available}
              onClick={() => act(ref, 'vend', {vend: display_record.prod_index})}>
              {display_record.prod_name}
            </Button>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Fragment>)};
