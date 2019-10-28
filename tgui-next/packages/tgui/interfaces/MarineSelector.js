import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, NoticeBox, Section, Box } from '../components';
import { map } from 'common/fp';

export const MarineSelector = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section title={"Choose your equipment: "+((!!data.show_points) && data.current_m_points + " Points Remaining.")}>
      <Section level={2}>
        <Box color="white">white = essential</Box>
        <Box color="orange">orange = recommended</Box>
      </Section>

      {map((entry, category_name) => {
        return (
          entry.length > 0 && (
            <Section
              title={category_name + ((data.cats[category_name] > 0) ? (
                " - Choices Remaining: "+data.cats[category_name]
              ) : "")}
              key={category_name}
              level={2}>
              {entry.map(display_record => (
                <Box key={display_record.id}>
                  <Button
                    disabled={!display_record.prod_available}
                    onClick={() => act(ref, 'vend', {vend: display_record.prod_index})}
                    selected={display_record.prod_color === "white"}>
                    <Box color={display_record.prod_color} bold={1}>
                      {display_record.prod_name}
                    </Box>
                  </Button>
                </Box>
              ))}
            </Section>
          ));
      })(data.displayed_records)}
    </Section>); };
