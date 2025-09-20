import { Box, Button, ProgressBar, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DisplayedRecord = {
  id: string;
  prod_name: string;
  prod_desc: string;
  prod_color: string;
  prod_available: BooleanLike;
  prod_index: number;
};

type PortableVendorData = {
  show_points: number;
  current_points: number;
  max_points: number;
  displayed_records: DisplayedRecord[];
};

export const PortableVendor = (props) => {
  const { act, data } = useBackend<PortableVendorData>();
  const { show_points, current_points, max_points, displayed_records } = data;
  return (
    <Window width={600} height={700}>
      <Window.Content scrollable>
        {show_points > 0 && (
          <ProgressBar
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
            value={current_points / max_points}
          >
            {current_points + '/' + max_points}
          </ProgressBar>
        )}
        {displayed_records.map((display_record) => (
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
