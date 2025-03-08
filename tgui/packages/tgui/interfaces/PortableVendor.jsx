import { Box, Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PortableVendor = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={600} height={700}>
      <Window.Content scrollable>
        {data.show_points > 0 && (
          <ProgressBar
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
            value={data.current_points / data.max_points}
          >
            {data.current_points + '/' + data.max_points}
          </ProgressBar>
        )}
        {data.displayed_records.map((display_record) => (
          <Section key={display_record.id}>
            {display_record.prod_color ? (
              <Button
                disabled={!display_record.prod_available}
                onClick={() => act('vend', { vend: display_record.prod_index })}
              >
                {display_record.prod_name}
              </Button>
            ) : (
              <Box>{display_record.prod_name}</Box>
            )}
            {display_record.prod_desc && <Box>{display_record.prod_desc}</Box>}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
