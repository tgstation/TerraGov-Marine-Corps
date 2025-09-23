import { useState } from 'react';
import {
  Box,
  Button,
  ColorBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TextFieldPreference } from './FieldPreferences';

export const FlavorCustomization = (props) => {
  const { act, data } = useBackend<FlavorCustomizationData>();
  const {
    slot,
    xeno_edible_jelly_name,
    r_jelly,
    g_jelly,
    b_jelly,
    xeno_edible_jelly_desc,
    xeno_edible_jelly_flavors,
  } = data;
  const [xenoJellyDesc, setXenoJellyDesc] = useState(xeno_edible_jelly_desc);
  const [xenoJellyFlav, setXenoJellyFlav] = useState(xeno_edible_jelly_flavors);
  const rgbToHex = (red, green, blue) => {
    const convert = (comp) => {
      const hex = comp.toString(16);
      return hex.length === 1 ? `0${hex}` : hex;
    };
    return '#' + convert(red) + convert(green) + convert(blue);
  };
  return (
    <Section title="Flavor information">
      <Section title="Edible Jelly Options">
        <p>
          Options for spicing up the food you as a xenomorph can provide the
          hosts!
        </p>
        <p> Jelly names are limited to 26 characters.</p>
        <Stack>
          <Stack.Item grow>
            <TextFieldPreference
              label={'Jelly Name'}
              action={'xeno_edible_jelly_name'}
              value={'xeno_edible_jelly_name'}
            />
          </Stack.Item>
          <Stack.Item grow>
            <TextFieldPreference
              label={'Jelly Color'}
              value={rgbToHex(r_jelly, g_jelly, b_jelly)}
              noAction
              extra={
                <>
                  <ColorBox
                    color={rgbToHex(r_jelly, g_jelly, b_jelly)}
                    mr={1}
                  />
                  <Button
                    icon="edit"
                    onClick={() => act('xeno_edible_jelly_colors')}
                  />
                </>
              }
            />
          </Stack.Item>
        </Stack>
        <br />
        <Stack>
          <Stack.Item grow>
            <Section
              title="Jelly Description"
              buttons={
                <Box>
                  <Button
                    icon="save"
                    disabled={xenoJellyDesc === xeno_edible_jelly_desc}
                    onClick={() =>
                      act('xeno_edible_jelly_desc', { xenoJellyDesc })
                    }
                  >
                    Save
                  </Button>
                  <Button
                    icon="times"
                    onClick={() => setXenoJellyDesc(xeno_edible_jelly_desc)}
                  >
                    Reset
                  </Button>
                </Box>
              }
            >
              <TextArea
                height="100px"
                width="200px"
                maxLength={1024}
                value={xenoJellyDesc}
                onChange={(value) => setXenoJellyDesc(value)}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Jelly Flavors. Separate with commas."
              buttons={
                <Box>
                  <Button
                    icon="eye"
                    onClick={() => act('xeno_edible_jelly_preview')}
                  >
                    Test
                  </Button>
                  <Button
                    icon="save"
                    disabled={xenoJellyFlav === xeno_edible_jelly_flavors}
                    onClick={() =>
                      act('xeno_edible_jelly_flavors', { xenoJellyFlav })
                    }
                  >
                    Save
                  </Button>
                  <Button
                    icon="times"
                    onClick={() => setXenoJellyFlav(xeno_edible_jelly_flavors)}
                  >
                    Reset
                  </Button>
                </Box>
              }
            >
              <TextArea
                height="100px"
                width="200px"
                maxLength={256}
                value={xenoJellyFlav}
                onChange={(value) => setXenoJellyFlav(value)}
              />
            </Section>
          </Stack.Item>
        </Stack>
        <Stack>
          <Stack.Item grow>
            Jelly descriptions are limited to 1024 characters.
          </Stack.Item>
          <Stack.Item grow>
            Limit of 6 flavors, with 256 characers total.
          </Stack.Item>
        </Stack>
      </Section>
    </Section>
  );
};
