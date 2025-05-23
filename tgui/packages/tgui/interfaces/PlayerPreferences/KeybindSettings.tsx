import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ButtonKeybind } from './ButtonKeybind';
import { TextInputModal } from './TextInputModal';

const KEY_MODS = {
  SHIFT: true,
  ALT: true,
  CONTROL: true,
};

export const KeybindSettings = (props) => {
  const { act, data } = useBackend<KeybindSettingData>();
  const { all_keybindings, is_admin } = data;
  const [captureSentence, setCaptureSentence] =
    useState<KeybindSentenceCapture | null>(null);
  const [filter, setFilter] = useState<string | null>(null);

  const filterSearch = (kb: KeybindingsData) =>
    !filter // If we don't have a filter, don't filter
      ? true // Show everything
      : kb?.display_name?.toLowerCase().includes(filter.toLowerCase()); // simple contains search

  const resetButton = (
    <Button
      icon="power-off"
      color="bad"
      onClick={() => act('reset-keybindings')}
    >
      Reset keybindings
    </Button>
  );

  return (
    <Section title="Keybindings" buttons={resetButton}>
      {captureSentence && (
        <TextInputModal
          label="Choose a custom sentence"
          button_text="Confirm"
          onSubmit={(input) => {
            act('setCustomSentence', {
              name: captureSentence.name,
              sentence: input,
            });
            setCaptureSentence(null);
          }}
          onBack={() => setCaptureSentence(null)}
          areaHeigh="20vh"
          areaWidth="40vw"
        />
      )}
      <Box>
        <Input
          autoFocus
          expensive
          placeholder="Search..."
          onChange={setFilter}
        />
      </Box>
      <Stack>
        <Stack.Item grow>
          <Section title="Main">
            {all_keybindings['MOVEMENT']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            {all_keybindings['COMMUNICATION']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            {all_keybindings['MOB']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}

            {all_keybindings['CLIENT']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}

            {all_keybindings['LIVING']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}

            {all_keybindings['CARBON']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}

            {all_keybindings['MISC']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
          </Section>
          <Section title="Emotes">
            {all_keybindings['EMOTE']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
          </Section>
          <Section title="Custom emotes">
            {all_keybindings['CUSTOM_EMOTE']
              ?.filter(filterSearch)
              .map((kb) => (
                <CustomSentence
                  key={kb.name}
                  keybind={kb}
                  setCaptureSentence={setCaptureSentence}
                />
              ))}
          </Section>
          {!!is_admin && (
            <Section title="Administration (admin only)">
              {all_keybindings['ADMIN']
                ?.filter(filterSearch)
                .map((kb) => (
                  <KeybindingPreference key={kb.name} keybind={kb} />
                ))}
            </Section>
          )}
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Abilities">
            <LabeledList.Item>
              <h3>Human</h3>
            </LabeledList.Item>
            {all_keybindings['HUMAN']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            <LabeledList.Item>
              <h3>Xenomorph</h3>
            </LabeledList.Item>
            {all_keybindings['XENO']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            <LabeledList.Item>
              <h3>Psionic</h3>
            </LabeledList.Item>
            {all_keybindings['PSIONIC']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            <LabeledList.Item>
              <h3>Items</h3>
            </LabeledList.Item>
            {all_keybindings['WEAPON']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            <LabeledList.Item>
              <h3>Items</h3>
            </LabeledList.Item>
            {all_keybindings['ITEM']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            <LabeledList.Item>
              <h3>Mecha</h3>
            </LabeledList.Item>
            {all_keybindings['MECHA']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
            <LabeledList.Item>
              <h3>Cyberware</h3>
            </LabeledList.Item>
            {all_keybindings['CYBERWARE']
              ?.filter(filterSearch)
              .map((kb) => <KeybindingPreference key={kb.name} keybind={kb} />)}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const KeybindingPreference = (props) => {
  const { act, data } = useBackend<KeybindPreferenceData>();
  const { key_bindings } = data;
  const { keybind } = props;
  const current = key_bindings[keybind.name];
  return (
    <LabeledList.Item label={keybind.display_name}>
      {current &&
        current.map((key) => (
          <ButtonKeybind
            color="transparent"
            key={key}
            content={key}
            onFinish={(keysDown) => {
              const mods = keysDown.filter((k) => KEY_MODS[k]);
              const keys = keysDown.filter((k) => !KEY_MODS[k]);
              if (keys.length === 0) {
                if (mods.length >= 0) {
                  keys.push(mods.pop());
                }
              }
              act('set_keybind', {
                keybind_name: keybind.name,
                old_key: key,
                key_mods: mods,
                key: keys.length === 0 ? false : keys[0],
              });
            }}
          />
        ))}
      <ButtonKeybind
        icon="plus"
        color="transparent"
        onFinish={(keysDown) => {
          const mods = keysDown.filter((k) => KEY_MODS[k]);
          const keys = keysDown.filter((k) => !KEY_MODS[k]);
          if (keys.length === 0) {
            if (mods.length >= 0) {
              keys.push(mods.pop());
            } else return;
          }
          act('set_keybind', {
            keybind_name: keybind.name,
            key_mods: mods,
            key: keys[0],
          });
        }}
      />
      <Button
        content="Clear"
        onClick={() =>
          act('clear_keybind', {
            keybinding: keybind.name,
          })
        }
      />
    </LabeledList.Item>
  );
};

const CustomSentence = (props) => {
  const { act, data } = useBackend<KeybindPreferenceData>();
  const { key_bindings, custom_emotes } = data;
  const { keybind, setCaptureSentence } = props;
  const current = key_bindings[keybind.name];
  const currentSentence = custom_emotes[keybind.name];
  return (
    <LabeledList.Item label={keybind.display_name}>
      <Button.Checkbox
        inline
        content="Say"
        checked={currentSentence.emote_type === 'say'}
        onClick={() =>
          act('setEmoteType', { emote_type: 'say', name: keybind.name })
        }
      />
      <Button.Checkbox
        inline
        content="Me"
        checked={currentSentence.emote_type === 'me'}
        onClick={() =>
          act('setEmoteType', { emote_type: 'me', name: keybind.name })
        }
      />
      <Button
        onClick={() => setCaptureSentence({ name: keybind.name })}
        tooltip={currentSentence && currentSentence.sentence}
      >
        Choose a custom sentence
      </Button>
      {current &&
        current.map((key) => (
          <ButtonKeybind
            color="transparent"
            key={key}
            content={key}
            onFinish={(keysDown) => {
              const mods = keysDown.filter((k) => KEY_MODS[k]);
              const keys = keysDown.filter((k) => !KEY_MODS[k]);
              if (keys.length === 0) {
                if (mods.length >= 0) {
                  keys.push(mods.pop());
                }
              }
              act('set_keybind', {
                keybind_name: keybind.name,
                old_key: key,
                key_mods: mods,
                key: keys.length === 0 ? false : keys[0],
              });
            }}
          />
        ))}
      <ButtonKeybind
        icon="plus"
        color="transparent"
        onFinish={(keysDown) => {
          const mods = keysDown.filter((k) => KEY_MODS[k]);
          const keys = keysDown.filter((k) => !KEY_MODS[k]);
          if (keys.length === 0) {
            if (mods.length >= 0) {
              keys.push(mods.pop());
            } else return;
          }
          act('set_keybind', {
            keybind_name: keybind.name,
            key_mods: mods,
            key: keys[0],
          });
        }}
      />
      <Button
        content="Clear"
        onClick={() =>
          act('clear_keybind', {
            keybinding: keybind.name,
          })
        }
      />
    </LabeledList.Item>
  );
};
