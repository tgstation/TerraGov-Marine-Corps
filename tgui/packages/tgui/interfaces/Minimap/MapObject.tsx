import { Box, Icon, Stack } from '../../components';
import { useLocalState } from '../../backend';
import { MinimapObjectProp, icon_size } from './Types';



export const MinimapObject = (props: MinimapObjectProp, context) => {
  
  const {
    objectdata,
    ...rest
  } = props;

  const [selectedName, setSelectedName] = useLocalState(context, "selected_name", null);

  return (
    <Box
      className="Minimap__Object"
      width="10%"
      {...rest}
      position="absolute"
      left={`${objectdata.coordinate.x+icon_size/2}px`}
      top={`${objectdata.coordinate.y+icon_size}px`}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Box
            as="span"
            className="Minimap__Object_Icon"
            position="absolute"
            backgroundColor="white"
            width={`${icon_size}px`}
            height={`${icon_size}px`}
          />
        </Stack.Item>
        <Stack.Item ml={`${icon_size}px`} mt={`${icon_size}px`}>
          <Box
            position="absolute"
            px={1}
            py={1}
            className={`Minimap__InfoBox${
              selectedName === objectdata.name? "--detailed" : ""}`}
          >
            <Stack>
              {selectedName === objectdata.name && (
                <Stack.Item>
                  <Icon name={objectdata.image} />
                </Stack.Item>
              )}
            </Stack>
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
