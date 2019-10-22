import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';

export const MarineSelector = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <NoticeBox>Choose your equipment:</NoticeBox>
      {(data.show_points > 0) && (
        <NoticeBox>Your Remaining Points: {data.current_m_points}</NoticeBox>
      )}
      <Section>
        <Box color="white">white = mandatory</Box>
        <Box color="orange">orange = recommended</Box>
      </Section>

      {data.displayed_records.map(display_record => (
        <Box color={display_record.prod_color} key={display_record.id}>
          {(display_record.prod_color) ? (
            <Button
              disabled={!display_record.prod_available}
              onClick={() => act(ref, 'vend', {vend: display_record.prod_index})}>
              {display_record.prod_name}
            </Button>
          ) : (
            <NoticeBox>{display_record.prod_name}</NoticeBox>
          )}
        </Box>
      ))}
    </Fragment>); };
