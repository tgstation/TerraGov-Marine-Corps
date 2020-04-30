import { useBackend } from '../backend';
import { Button, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';

export const PortableVendor = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content scrollable>
        {(data.show_points > 0) && (
          <NoticeBox>Points: {data.current_points}/{data.max_points}</NoticeBox>
        )}
        {data.displayed_records.map(display_record => (
          <Section key={display_record.id}>
            {display_record.prod_color ? (
              <Button
                disabled={!display_record.prod_available}
                onClick={() => act(
                  'vend',
                  { vend: display_record.prod_index })}>
                {display_record.prod_name}
              </Button>
            ) : (
              <Box>{display_record.prod_name}</Box>
            )}
            {display_record.prod_desc && (
              <Box>{display_record.prod_desc}</Box>
            )}

          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
