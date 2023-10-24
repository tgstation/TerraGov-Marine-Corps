import { useBackend } from '../../backend';
import { Box, Section, Stack, LabeledList, Button, Table } from '../../components';
import { TableCell, TableRow } from '../../components/Table';

export const DrawOrder = (props, context) => {
  const { act, data } = useBackend<DrawOrder>(context);
  const { draw_order = [], quick_equip = [] } = data;
  return (
    <Section title="Draw Order">
      <Stack fill>
        <Stack.Item grow>
          <Section title="Equip Slot Order">
            <Section>
              <Table>
                {draw_order.map((item) => (
                  <TableRow key={item}>
                    <TableCell>{item}</TableCell>
                    <Button
                      icon="arrow-up"
                      onClick={() =>
                        act('equip_slot_equip_position', {
                          direction: 'up',
                          changing_item: item,
                        })
                      }
                    />
                    <Button
                      icon="arrow-down"
                      onClick={() =>
                        act('equip_slot_equip_position', {
                          direction: 'down',
                          changing_item: item,
                        })
                      }
                    />
                  </TableRow>
                ))}
              </Table>
            </Section>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Keybinding Settings">
            <LabeledList>
              {quick_equip.map((equip_slot, index_slot) => (
                <>
                  <Box>Quick equip #{index_slot + 1}</Box>
                  <Button
                    key={equip_slot}
                    content={equip_slot}
                    onClick={() =>
                      act('change_quick_equip', { selection: index_slot + 1 })
                    }
                  />
                </>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
