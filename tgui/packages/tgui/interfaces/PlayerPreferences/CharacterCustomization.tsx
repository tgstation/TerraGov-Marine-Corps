import { useBackend } from '../../backend';
import { capitalize } from 'common/string';
import { Button, Section, Flex, LabeledList, Box, ColorBox } from '../../components';
import { TextFieldPreference, ToggleFieldPreference, SelectFieldPreference } from './FieldPreferences';
import { ProfilePicture } from './ProfilePicture';

export const CharacterCustomization = (props, context) => {
  const { act, data } = useBackend<CharacterCustomizationData>(context);
  const {
    random_name,
    r_hair,
    g_hair,
    b_hair,
    r_grad,
    g_grad,
    b_grad,
    r_eyes,
    g_eyes,
    b_eyes,
    r_facial,
    g_facial,
    b_facial,
  } = data;

  const rgbToHex = (red, green, blue) => {
    const convert = comp => {
      const hex = comp.toString(16);
      return hex.length === 1 ? `0${hex}` : hex;
    };
    return '#' + convert(red) + convert(green) + convert(blue);
  };
  const genders = ["male", "female", "plural", "neuter"];
  const genderToName = {
    "male": "Male",
    "female": "Female",
    "neuter": "Object",
    "plural": "Other",
  };
  return (
    <>
      <Section title="Profile">
        <Flex>
          <Flex.Item>
            <LabeledList>
              <TextFieldPreference
                label={'Full Name'}
                action={'name_real'}
                value={'real_name'}
                extra={
                  <Box as="span">
                    <Button onClick={() => act('randomize_name')}>
                      Randomize
                    </Button>
                    <Button.Checkbox
                      inline
                      content="Always Random"
                      checked={random_name === 1}
                      onClick={() => act('toggle_always_random')}
                    />
                  </Box>
                }
              />
              <TextFieldPreference label={'Xenomorph'} value={'xeno_name'} />
              <TextFieldPreference
                label={'Synthetic Name'}
                value={'synthetic_name'}
              />
              <TextFieldPreference label={'AI Name'} value={'ai_name'} />
            </LabeledList>
          </Flex.Item>
          <Flex.Item>
            <ProfilePicture />
          </Flex.Item>
        </Flex>
      </Section>
      <Section
        title="Body"
        buttons={
          <Button color="bad" icon="power-off" onClick={() => act('random')}>
            Randomize everything
          </Button>
        }>
        <Flex>
          <Flex.Item>
            <LabeledList>
              <TextFieldPreference label={'Age'} value={'age'} />
              <LabeledList.Item label={'Gender'}>
                {genders.map(thisgender => (
                  <Button.Checkbox
                    inline
                    key={thisgender}
                    content={capitalize(genderToName[thisgender])}
                    checked={data['gender'] === thisgender}
                    onClick={() => act('toggle_gender', { newgender: thisgender })}
                  />
                ))}
              </LabeledList.Item>
              <SelectFieldPreference
                label={'Hair style'}
                value={'h_style'}
                action={'hairstyle'}
              />
              <TextFieldPreference
                label={'Hair Color'}
                value={rgbToHex(r_hair, g_hair, b_hair)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(r_hair, g_hair, b_hair)}
                      mr={1}
                    />
                    <Button icon="edit" onClick={() => act('haircolor')} />
                  </>
                }
              />
              <SelectFieldPreference
                label={'Hair gradient style'}
                value={'grad_style'}
                action={'grad_style'}
              />
              <TextFieldPreference
                label={'Gradient Color'}
                value={rgbToHex(r_grad, g_grad, b_grad)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(r_grad, g_grad, b_grad)}
                      mr={1}
                    />
                    <Button icon="edit" onClick={() => act('grad_color')} />
                  </>
                }
              />
              <TextFieldPreference
                label={'Eye Color'}
                value={rgbToHex(r_eyes, g_eyes, b_eyes)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(r_eyes, g_eyes, b_eyes)}
                      mr={1}
                    />
                    <Button icon="edit" onClick={() => act('eyecolor')} />
                  </>
                }
              />
              <ToggleFieldPreference
                label={'Eye sight'}
                value={'good_eyesight'}
                leftLabel={'Good'}
                rightLabel={'Bad'}
                action={'toggle_eyesight'}
              />
              <SelectFieldPreference
                label={'Facial hair'}
                value={'f_style'}
                action={'facial_style'}
              />
              <TextFieldPreference
                label={'Facial Hair Color'}
                value={rgbToHex(r_facial, g_facial, b_facial)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(
                        r_facial,
                        g_facial,
                        b_facial
                      )}
                      mr={1}
                    />
                    <Button icon="edit" onClick={() => act('facialcolor')} />
                  </>
                }
              />
            </LabeledList>
          </Flex.Item>
          <Flex.Item>
            <LabeledList>
              <SelectFieldPreference
                label={'Species'}
                value={'species'}
                action={'species'}
              />
              <SelectFieldPreference
                label={'Synth type'}
                value={'synthetic_type'}
                action={'synthetic_type'}
              />
              <SelectFieldPreference
                label={'Ethnicity'}
                value={'ethnicity'}
                action={'ethnicity'}
              />
              <SelectFieldPreference
                label={'Citizenship'}
                value={'citizenship'}
                action={'citizenship'}
              />
              <SelectFieldPreference
                label={'Religion'}
                value={'religion'}
                action={'religion'}
              />
            </LabeledList>
          </Flex.Item>
        </Flex>
      </Section>
    </>
  );
};
