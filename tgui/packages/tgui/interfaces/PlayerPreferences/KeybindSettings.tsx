import { useBackend, useLocalState } from '../../backend';
import { Button, Input, Section, Tabs, LabeledList, Box, Grid, Modal } from '../../components';
import { TextInputModal } from './TextInputModal';

type KeybindSettingCapture = {
  name: string,
  key: string,
}

type KeybindSentenceCapture = {
  name: string,
}

export const KeybindSettings = (props, context) => {
  const { act, data, config } = useBackend<PlayerPreferencesData>(context);
  const {
    all_keybindings,
    is_admin,
  } = data;

  const [
    capture,
    setCapture,
  ] = useLocalState<KeybindSettingCapture>(context, `setCapture`, null);
  const [
    captureSentence,
    setCaptureSentence,
  ] = useLocalState<KeybindSentenceCapture>(
    context, `setCaptureSentence`, null);
  const [
    filter,
    setFilter,
  ] = useLocalState<string>(context, `keybind-filter`, null);

  const filterSearch = (kb:KeybindingsData) =>
    !filter // If we don't have a filter, don't filter
      ? true // Show everything
      : kb
        ?.display_name
        ?.toLowerCase()
        .includes(filter.toLowerCase()); // simple contains search

  const resetButton = (
    <Button
      icon="power-off"
      color="bad"
      onClick={() => act('reset-keybindings')}>
      Reset keybindings
    </Button>
  );

  return (
    <Section
      title="Keybindings"
      buttons={resetButton}>
      {capture && (
        <CaptureKeybinding
          kbName={capture.name}
          currentKey={capture.key}
          onClose={() => setCapture(null)}
        />
      )}
      {captureSentence && (
        <TextInputModal 
          label="Chose a custom sentence"
          button_text="Confirm"
          onSubmit={(input) => {
            act('setCustomSentence', { name: captureSentence.name, sentence: input });
            setCaptureSentence(null);
          }}
          onBack={() => setCaptureSentence(null)}
          areaHeigh="20vh"
          areaWidth="40vw"
        />
      )}
      <Box>
        Search: <Input onInput={(_e, value) => setFilter(value)} />
      </Box>
      <Grid>
        <Grid.Column>
          <Section title="Main">
            {all_keybindings['MOVEMENT']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {all_keybindings['MOB']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {all_keybindings['CLIENT']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {all_keybindings['LIVING']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {all_keybindings['CARBON']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {all_keybindings['MISC']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}
          </Section>
          <Section title="Emotes">
            {all_keybindings['EMOTE']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}
          </Section>
          <Section title="Custom emotes">
            {all_keybindings['CUSTOM_EMOTE']?.filter(filterSearch).map(kb => (
              <CustomSentence
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
                setCaptureSentence={setCaptureSentence}
              />
            ))}
          </Section>
          {is_admin && (
            <Section title="Administration (admin only)">
              {all_keybindings['ADMIN']?.filter(filterSearch).map(kb => (
                <KeybindingPreference
                  key={kb.name}
                  keybind={kb}
                  setCapture={setCapture}
                />
              ))}
            </Section>
          )}
        </Grid.Column>
        <Grid.Column>
          <Section title="Abilities">
            <LabeledList.Item>
              <h3>Human</h3>
            </LabeledList.Item>
            {all_keybindings['HUMAN']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}
            <LabeledList.Item>
              <h3>Xenomorph</h3>
            </LabeledList.Item>
            {all_keybindings['XENO']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}
          </Section>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const KeybindingPreference = (props, context) => {
  const { act, data, config } = useBackend<PlayerPreferencesData>(context);
  const { key_bindings } = data;
  const { keybind, setCapture } = props;
  const current = key_bindings[keybind.name];
  return (
    <LabeledList.Item label={keybind.display_name}>
      {current && (current.map(key => (
        <Button
          key={key}
          inline
          onClick={() => setCapture({ name: keybind.name, key })}>
          {key}
        </Button>
      )))}
      <Button inline onClick={() => setCapture({ name: keybind.name })}>
        [+]
      </Button>
    </LabeledList.Item>
  );
};

const CustomSentence = (props, context) => {
  const { act, data, config } = useBackend<PlayerPreferencesData>(context);
  const { key_bindings, custom_emotes } = data;
  const { keybind, setCaptureSentence, setCapture } = props;
  const current = key_bindings[keybind.name];
  const currentSentence = custom_emotes[keybind.name];
  return (
    <LabeledList.Item label={keybind.display_name}>
      <Button.Checkbox
        inline
        content="Say"
        checked={currentSentence.emote_type === "say"}
        onClick={() => act('setEmoteType', { emote_type: "say", name: keybind.name })}
      />
      <Button.Checkbox
        inline
        content="Me"
        checked={currentSentence.emote_type === "me"}
        onClick={() => act('setEmoteType', { emote_type: "me", name: keybind.name })}
      />
      <Button
        onClick={() => setCaptureSentence({ name: keybind.name })}
        tooltip={currentSentence && currentSentence.sentence}>
        Chose custom sentence
      </Button>
      {current && (current.map(key => (
        <Button
          key={key}
          inline
          onClick={() => setCapture({ name: keybind.name, key })}>
          {key}
        </Button>
      )))}
      <Button inline onClick={() => setCapture({ name: keybind.name })}>
        [+]
      </Button>
    </LabeledList.Item>
  );
};

const CaptureKeybinding = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { onClose, currentKey, kbName } = props;

  const captureKeyPress = e => {
    const alt = e.altKey ? 1 : 0;
    const ctrl = e.ctrlKey ? 1 : 0;
    const shift = e.shiftKey ? 1 : 0;
    const numpad = 95 < e.keyCode && e.keyCode < 112 ? 1 : 0;
    const escPressed = e.keyCode === 27 ? 1 : 0;
    act('keybindings_set', {
      keybinding: kbName,
      old_key: currentKey,
      clear_key: escPressed,
      key: e.key,
      alt: alt,
      ctrl: ctrl,
      shift: shift,
      numpad: numpad,
      key_code: e.keyCode,
    });
    onClose();
  };

  return (
    <Modal
      id="grab-focus"
      width="300px"
      height="200px"
      onKeyUp={e => captureKeyPress(e)}>
      <Box>Press any key or press ESC to clear</Box>
      <Box align="right">
        <Button align="right" onClick={() => onClose()}>
          X
        </Button>
      </Box>
      <script type="application/javascript">
        {"document.getElementById('grab-focus').focus();"}
      </script>
    </Modal>
  );
};
