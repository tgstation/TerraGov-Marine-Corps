import { useBackend } from '../backend';
import { Button, Section, Box } from '../components';
import { map } from 'common/collections';
import { Window } from '../layouts';

export const MarineSelector = (props, context) => {
  const { act, data } = useBackend(context);

  const points = data.show_points
    ? `: ${data.current_m_points} Points Remaining.`
    : '';

  return (
    <Window>
      <Window.Content scrollable>
        <Section title={`Choose your equipment${points}`}>
          <Section level={2}>
            <Box color="white">white = essential</Box>
            <Box color="orange">orange = recommended</Box>
          </Section>

          {map((entry, category_name) => {
            return (
              entry.length > 0 && data.cats[category_name] > 0 && (
                <Section
                  title={category_name + ((data.cats[category_name] > 0) ? (
                    " - Choices Remaining: "+data.cats[category_name]
                  ) : "")}
                  key={category_name}
                  level={2}>
                  {entry.map(display_record => {
                    return (
                      <Box key={display_record.id}>
                        <Button
                          disabled={!display_record.prod_available}
                          onClick={() => act(
                            'vend',
                            { vend: display_record.prod_index })}
                          selected={display_record.prod_color === "white"}>
                          <Box color={display_record.prod_color} bold={1}>
                            {display_record.prod_name}
                          </Box>
                        </Button>
                      </Box>
                    ); }
                  )}
                </Section>
              ));
          })(data.displayed_records)}
        </Section>
      </Window.Content>
    </Window>
  );
};
