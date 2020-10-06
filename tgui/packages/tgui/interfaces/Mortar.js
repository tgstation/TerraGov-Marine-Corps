import { useBackend } from '../backend';
import { Box, Button, Section, NumberInput, Flex, LabeledList } from '../components';
import { Window } from '../layouts';

export const Mortar = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    X,
    Y,
    D1,
    D2,
  } = data;
  return (
    <Window
      resizable>
      <Window.Content>
        <Flex direction = "column"  justify = "space-between">
          <Flex.Item>
            <Flex direction = "row" justify = "space-between">
              <Flex.Item>
                LONGITUDE 
              </Flex.Item>
              <Flex.Item>
                LATITUDE
              </Flex.Item>
              <Flex.Item>
                LONGITUDE OFFSET
              </Flex.Item>
              <Flex.Item>
                LATITUDE OFFSET
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item>
            <Flex direction = "row" justify = "space-between">
              <Flex.Item>
                <NumberInput
                  value={X}
                  minValue={0}
                  maxValue={255}
                  width="43px"
                  onChange={(e, value) => act("change_target", {
                  target_x: value, 
                  varname: "targ_x",
                  })}>
                </NumberInput>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={Y}
                  minValue={0}
                  maxValue={255}
                  width="43px"
                  onChange={(e, value) => act("change_target", {
                  target_y: value,
                  varname: "targ_y",
                  })}>
                </NumberInput>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={D1}
                  minValue={0}
                  width="43px"
                  maxValue={10}
                  onChange={(e, value) =>  act("change_target", {
                  dial_one: value,
                  varname: "dial_x",
                  })}>
                </NumberInput>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={D2}
                  minValue={0}
                  maxValue={10}
                  width="43px"
                  onChange={(e, value) => act("change_target",{
                  dial_two: value,
                  varname: "dial_y",
                  })}>
                </NumberInput>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
