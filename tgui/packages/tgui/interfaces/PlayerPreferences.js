import { useBackend, useLocalState } from '../backend';
import {
  Button, Input, Section, Flex, Tabs, LabeledList, Dropdown, TextArea,
  Box, Grid, Modal, ColorBox, ByondUi,
} from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

const DEBUG_ENABLED = false;

export const PlayerPreferences = (props, context) => {
  const { act, data, config } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'selectedTabIndex', 1);

  let affectsSave = false;
  let CurrentTab = CharacterCustomization;
  switch (tabIndex) {
    case 1:
      CurrentTab = CharacterCustomization;
      affectsSave = true;
      break;
    case 2:
      CurrentTab = GearCustomization;
      affectsSave = true;
      break;
    case 3:
      CurrentTab = JobPreferences;
      affectsSave = true;
      break;
    case 4:
      CurrentTab = GameSettings;
      break;
    case 5:
      CurrentTab = KeybindSetting;
      break;
    case 99:
      CurrentTab = DEBUG_ENABLED ? DebugPanel : CurrentTab;
      break;
    default:
  }

  // I dont like this shit, but it doesn't matter in the end
  // i'd rather massage the data in js than byond.
  const slotNames = Object.values(data.save_slot_names).map(
    name => name.split(' ')[0]
  );

  const saveSlots = new Array(10).fill(1).map((_, idx) => (
    <Button
      key={idx + 1}
      selected={idx + 1 === data.slot}
      onClick={() => act('changeslot', { changeslot: idx + 1 })}>
      {slotNames[idx] || `Character ${idx + 1}`}
    </Button>
  ));

  return (
    <Window
      width={1140}
      height={650}>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item>
            <NavigationSelector tabIndex={tabIndex} onTabChange={setTabIndex} />
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            {affectsSave ? (
              <Section title="Save slot" buttons={saveSlots}>
                <CurrentTab />
              </Section>
            ) : (
              <CurrentTab />
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const CharacterCustomization = (props, context) => {
  const { act, data, config } = useBackend(context);
  const [characterDesc, setCharacterDesc] = useLocalState(
    context,
    'characterDesc' + data.slot,
    data.flavor_text
  );
  const [medicalDesc, setMedicalDesc] = useLocalState(
    context,
    'medicalDesc' + data.slot,
    data.med_record
  );
  const [employmentDesc, setEmploymentDesc] = useLocalState(
    context,
    'employmentDesc' + data.slot,
    data.gen_record
  );
  const [securityDesc, setSecurityDesc] = useLocalState(
    context,
    'securityDesc' + data.slot,
    data.sec_record
  );
  const [exploitsDesc, setExploitsDesc] = useLocalState(
    context,
    'exploitsDesc' + data.slot,
    data.exploit_record
  );

  const rgbToHex = (red, green, blue) => {
    const convert = comp => {
      const hex = comp.toString(16);
      return hex.length === 1 ? `0${hex}` : hex;
    };
    return '#' + convert(red) + convert(green) + convert(blue);
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
                  <span>
                    <Button onClick={() => act('randomize_name')}>
                      Randomize
                    </Button>
                    <Button.Checkbox
                      inline
                      content="Always Random"
                      checked={data.random_name === 1}
                      onClick={() => act('toggle_always_random')}
                    />
                  </span>
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
            Randomize appearance
          </Button>
        }>
        <Flex>
          <Flex.Item>
            <LabeledList>
              <TextFieldPreference label={'Age'} value={'age'} />
              <ToggleFieldPreference
                label={'Gender'}
                value="gender"
                leftLabel={'Male'}
                leftValue="male"
                rightValue="female"
                rightLabel={'Female'}
                action={'toggle_gender'}
              />
              <TextFieldPreference
                label={'Hair Color'}
                value={rgbToHex(data.r_hair, data.g_hair, data.b_hair)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(data.r_hair, data.g_hair, data.b_hair)}
                      mr={1}
                    />
                    <Button icon="edit" onClick={() => act('haircolor')} />
                  </>
                }
              />
              <SelectFieldPreference
                label={'Hair style'}
                value={'h_style'}
                action={'hairstyle'}
                options={'hairstyles'}
              />
              <TextFieldPreference
                label={'Eye Color'}
                value={rgbToHex(data.r_eyes, data.g_eyes, data.b_eyes)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(data.r_eyes, data.g_eyes, data.b_eyes)}
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
                action={'facialstyle'}
                options={'facialhair'}
              />
              <TextFieldPreference
                label={'Facial Hair Color'}
                value={rgbToHex(data.r_facial, data.g_facial, data.b_facial)}
                noAction
                extra={
                  <>
                    <ColorBox
                      color={rgbToHex(
                        data.r_facial,
                        data.g_facial,
                        data.b_facial
                      )}
                      mr={1}
                    />
                    <Button icon="edit" onClick={() => act('facialcolor')} />
                  </>
                }
              />
              <SelectFieldPreference
                label={'Body type'}
                value={'body_type'}
                options={'bodytypes'}
              />
            </LabeledList>
          </Flex.Item>
          <Flex.Item>
            <LabeledList>
              <SelectFieldPreference
                label={'Species'}
                value={'species'}
                options={'all_species'}
              />
              <SelectFieldPreference
                label={'Synth type'}
                value={'synthetic_type'}
                options={'synth_types'}
              />
              <SelectFieldPreference
                label={'Ethnicity'}
                value={'ethnicity'}
                options={'ethnicities'}
              />
              <SelectFieldPreference
                label={'Citizenship'}
                value={'citizenship'}
                options={'citizenships'}
              />
              <SelectFieldPreference
                label={'Religion'}
                value={'religion'}
                options={'religions'}
              />
              <SelectFieldPreference
                label={'Corporate Relations'}
                value={'nanotrasen_relation'}
                action={'corporation'}
                options={'corporate_relations'}
              />
            </LabeledList>
          </Flex.Item>
        </Flex>
      </Section>
      <Section title="Background information">
        <Section
          title="Character Description"
          buttons={
            <Box>
              <Button
                icon="save"
                disabled={characterDesc === data.flavor_text}
                onClick={() => act('flavor_text', { characterDesc })}>
                Save
              </Button>
              <Button
                icon="times"
                onClick={() => setCharacterDesc(data.flavor_text)}>
                Reset
              </Button>
            </Box>
          }>
          <TextArea
            key="character"
            height="100px"
            value={characterDesc}
            onChange={(e, value) => setCharacterDesc(value)}
          />
        </Section>

        <Grid>
          <Grid.Column>
            <Section
              title="Medical Records"
              buttons={
                <Box>
                  <Button
                    icon="save"
                    disabled={medicalDesc === data.med_record}
                    onClick={() => act('med_record', { medicalDesc })}>
                    Save
                  </Button>
                  <Button
                    icon="times"
                    onClick={() => setMedicalDesc(data.med_record)}>
                    Reset
                  </Button>
                </Box>
              }>
              <TextArea
                height="100px"
                maxLength={1024}
                value={medicalDesc}
                onChange={(e, value) => setMedicalDesc(value)}
              />
            </Section>
          </Grid.Column>
          <Grid.Column>
            <Section
              title="Employment Records"
              buttons={
                <Box>
                  <Button
                    icon="save"
                    disabled={employmentDesc === data.gen_record}
                    onClick={() => act('gen_record', { employmentDesc })}>
                    Save
                  </Button>
                  <Button
                    icon="times"
                    onClick={() => setEmploymentDesc(data.gen_record)}>
                    Reset
                  </Button>
                </Box>
              }>
              <TextArea
                height="100px"
                maxLength={1024}
                value={employmentDesc}
                onChange={(e, value) => setEmploymentDesc(value)}
              />
            </Section>
          </Grid.Column>
        </Grid>
        <Grid>
          <Grid.Column>
            <Section
              title="Security Records"
              buttons={
                <Box>
                  <Button
                    icon="save"
                    disabled={securityDesc === data.sec_record}
                    onClick={() => act('sec_record', { securityDesc })}>
                    Save
                  </Button>
                  <Button
                    icon="times"
                    onClick={() => setSecurityDesc(data.sec_record)}>
                    Reset
                  </Button>
                </Box>
              }>
              <TextArea
                height="100px"
                maxLength={1024}
                value={securityDesc}
                onChange={(e, value) => setSecurityDesc(value)}
              />
            </Section>
          </Grid.Column>
          <Grid.Column>
            <Section
              title="Exploit Records"
              buttons={
                <Box>
                  <Button
                    icon="save"
                    disabled={exploitsDesc === data.exploit_record}
                    onClick={() => act('exploit_record', { exploitsDesc })}>
                    Save
                  </Button>
                  <Button
                    icon="times"
                    onClick={() => setExploitsDesc(data.exploit_record)}>
                    Reset
                  </Button>
                </Box>
              }>
              <TextArea
                height="100px"
                maxLength={1024}
                value={exploitsDesc}
                onChange={(e, value) => setExploitsDesc(value)}
              />
            </Section>
          </Grid.Column>
        </Grid>
      </Section>
    </>
  );
};

const ProfilePicture = (props, context) => {
  const { act, data, config } = useBackend(context);
  return (
    <ByondUi
      style={{ width: '400px', height: '100px' }}
      params={{
        id: 'player_pref_map',
        parent: config.window,
        type: 'map',
        zoom: 3,
      }}
    />
  );
};

const TextFieldPreference = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { label, value, action, extra, onFocus, noAction } = props;
  const itemLabel = label || value;

  const handler = noAction ? () => {} : act;

  return (
    <LabeledList.Item label={itemLabel}>
      <Input
        placeholder={data[value] || ''}
        value={data[value] || value}
        onChange={(e, newValue) =>
          !onFocus && handler(action || value, { newValue })}
      />
      {extra ? extra : null}
    </LabeledList.Item>
  );
};
const SelectFieldPreference = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { label, value, options, action } = props;
  const itemLabel = label || value;
  let parsedOptions = Object.values(data[options] || options);
  if (Array.isArray(options)) {
    parsedOptions = options;
  } else if (typeof data[options] === 'object') {
    parsedOptions = Object.values(data[options]);
  }

  return (
    <LabeledList.Item label={itemLabel}>
      <Dropdown
        width="95%"
        options={parsedOptions}
        selected={data[value]}
        onSelected={newValue => act(action || value, { newValue })}
      />
    </LabeledList.Item>
  );
};

const ToggleFieldPreference = (props, context) => {
  const { act, data, config } = useBackend(context);
  const {
    label,
    value,
    leftValue = 1,
    leftLabel = 'True',
    rightValue = 0,
    rightLabel = 'False',
    action,
  } = props;
  const itemLabel = label || value;

  let labelLeft = leftLabel || leftValue;
  let labelRight = rightLabel || rightValue;

  return (
    <LabeledList.Item label={itemLabel}>
      <Button.Checkbox
        inline
        content={labelLeft}
        checked={data[value] === leftValue}
        onClick={() => act(action)}
      />
      <Button.Checkbox
        inline
        content={labelRight}
        checked={data[value] === rightValue}
        onClick={() => act(action)}
      />
    </LabeledList.Item>
  );
};

const JobPreferences = (props, context) => {
  const { act, data, config } = useBackend(context);
  const [shownDescription, setShownDescription] = useLocalState(
    context,
    'shown-desc',
    null
  );

  const xenoJobs = ['Hive Leader', 'Xenomorph'];
  const commandRoles = [
    'Captain',
    'Field Commander',
    'Staff Officer',
    'Pilot Officer',
    'Synthetic',
    'AI',
  ];
  const supportRoles = [
    'Chief Ship Engineer',
    'Ship Technician',
    'Requisitions Officer',
    'Chief Medical Officer',
    'Medical Officer',
  ];
  const marineJobs = [
    'Squad Marine',
    'Squad Engineer',
    'Squad Corpsman',
    'Squad Leader',
  ];
  const flavourJobs = ['Corporate Liaison', 'Medical Researcher'];

  const JobList = ({ name, jobs }) => (
    <Section title={name}>
      <LabeledList>
        {jobs.map(job => (
          <JobPreference
            key={job}
            job={job}
            setShownDescription={setShownDescription}
          />
        ))}
      </LabeledList>
    </Section>
  );

  return (
    <Section
      title="Job Preferences"
      buttons={
        <Button color="bad" icon="power-off" onClick={() => act('jobreset')}>
          Reset everything!
        </Button>
      }>
      {shownDescription && (
        <Modal width="500px" min-height="300px">
          <Box dangerouslySetInnerHTML={{ __html: shownDescription }} />
          <Box align="right">
            <Button align="right" onClick={() => setShownDescription(false)}>
              X
            </Button>
          </Box>
        </Modal>
      )}
      <Grid>
        <Grid.Column>
          <JobList name="Command Jobs" jobs={commandRoles} />
        </Grid.Column>
        <Grid.Column>
          <JobList name="Support Jobs" jobs={supportRoles} />
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <JobList name="Xenomorph Jobs" jobs={xenoJobs} />
        </Grid.Column>
        <Grid.Column>
          <JobList name="Flavour Jobs" jobs={flavourJobs} />
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <JobList name="Marine Jobs" jobs={marineJobs} />
        </Grid.Column>
        <Grid.Column>
          <Section title="Other settings">
            <Flex direction="column" height="100%">
              <Flex.Item>
                <h4>If failed to qualify for job</h4>
                <Button.Checkbox
                  inline
                  content={'Take a random job'}
                  checked={data.alternate_option === 0}
                  onClick={() => act('jobalternative', { newValue: 0 })}
                />
                <Button.Checkbox
                  inline
                  content={`Spawn as ${data.overflow_job}`}
                  checked={data.alternate_option === 1}
                  onClick={() => act('jobalternative', { newValue: 1 })}
                />
                <Button.Checkbox
                  inline
                  content={'Return to lobby'}
                  checked={data.alternate_option === 2}
                  onClick={() => act('jobalternative', { newValue: 2 })}
                />
              </Flex.Item>
              <Flex.Item>
                <h4>Preferred Squad</h4>
                {Object.values(data.squads).map(squad => (
                  <Button.Checkbox
                    key={squad}
                    inline
                    content={squad}
                    checked={data.preferred_squad === squad}
                    onClick={() => act('squad', { newValue: squad })}
                  />
                ))}
              </Flex.Item>
              <Flex.Item>
                <h4>Occupational choices</h4>
                {Object.keys(data.special_occupations).map((special, idx) => (
                  <>
                    <Button.Checkbox
                      key={data.special_occupations[special]}
                      inline
                      content={special}
                      checked={
                        data.special_occupation
                        & data.special_occupations[special]
                      }
                      onClick={() =>
                        act('be_special', {
                          flag: data.special_occupations[special],
                        })}
                    />
                    {idx === 1 && <br />}
                  </>
                ))}
              </Flex.Item>
            </Flex>
          </Section>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const JobPreference = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { job, setShownDescription } = props;
  const jobData = data.jobs[job];
  const preference = data.job_preferences[job];

  if (jobData.banned) {
    return (
      <LabeledList.Item label={job}>
        <Box align="right">
          <Button.Checkbox
            inline
            icon="ban"
            color="bad"
            content={'Banned from Role'}
            onClick={() => act('bancheck', { role: job })}
          />
        </Box>
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList.Item label={job}>
      <Box align="right">
        <Button.Checkbox
          inline
          content={'High'}
          checked={preference === 3}
          onClick={() => act('jobselect', { job, level: 3 })}
        />
        <Button.Checkbox
          inline
          content={'Medium'}
          checked={preference === 2}
          onClick={() => act('jobselect', { job, level: 2 })}
        />
        <Button.Checkbox
          inline
          content={'Low'}
          checked={preference === 1}
          onClick={() => act('jobselect', { job, level: 1 })}
        />
        <Button.Checkbox
          inline
          content={'Never'}
          checked={!preference}
          onClick={() => act('jobselect', { job, level: 0 })}
        />
        {jobData.description && (
          <Button
            content="?"
            onClick={() => setShownDescription(jobData.description)}
          />
        )}
      </Box>
    </LabeledList.Item>
  );
};

const GameSettings = (props, context) => {
  const { act, data, config } = useBackend(context);
  return (
    <Section title="Game Settings">
      <Grid>
        <Grid.Column>
          <Section title="Window settings">
            <LabeledList>
              <ToggleFieldPreference
                label="Window flashing"
                value="windowflashing"
                action="windowflashing"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Focus Chat"
                value="focus_chat"
                action="focus_chat"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Tooltips"
                value="tooltips"
                action="tooltips"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
              <TextFieldPreference label={'FPS'} value={'clientfps'} />
              <ToggleFieldPreference
                label="Auto Fit viewport"
                value="auto_fit_viewport"
                action="auto_fit_viewport"
                leftLabel={'Enabled'}
                rightLabel={'Disabled'}
              />
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="Message settings">
            <LabeledList>
              <ToggleFieldPreference
                label="Runechat bubbles"
                value="chat_on_map"
                action="chat_on_map"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <TextFieldPreference
                label="Runechat message limit"
                value="max_chat_length"
              />
              <ToggleFieldPreference
                label="Show non-mob runechat"
                value="see_chat_non_mob"
                action="see_chat_non_mob"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show emotes in runechat"
                value="see_rc_emotes"
                action="see_rc_emotes"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show typing indicator"
                value="show_typing"
                action="show_typing"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />

              <ToggleFieldPreference
                label="Show self combat messages"
                value="mute_self_combat_messages"
                action="mute_self_combat_messages"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
              <ToggleFieldPreference
                label="Show others combat messages"
                value="mute_others_combat_messages"
                action="mute_others_combat_messages"
                leftValue={1}
                leftLabel={'Enabled'}
                rightValue={0}
                rightLabel={'Disabled'}
              />
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title="UI settings">
            <LabeledList>
              <SelectFieldPreference
                label={'UI Style'}
                value={'ui_style'}
                options={'ui_styles'}
                action={'ui'}
              />
              <TextFieldPreference
                label={'UI Color'}
                value={'ui_style_color'}
                noAction
                extra={
                  <>
                    <ColorBox color={data.ui_style_color} mr={1} />
                    <Button icon="edit" onClick={() => act('uicolor')} />
                  </>
                }
              />
              <TextFieldPreference
                label={'UI Alpha'}
                value={'ui_style_alpha'}
                action={'uialpha'}
              />
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column />
      </Grid>
    </Section>
  );
};

const KeybindSetting = (props, context) => {
  const { act, data, config } = useBackend(context);
  const [capture, setCapture] = useLocalState(context, `setCapture`, false);
  const [filter, setFilter] = useLocalState(context, `keybind-filter`, false);

  const filterSearch = kb =>
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
    <Section title="Keybindings" buttons={resetButton}>
      {capture && (
        <CaptureKeybinding
          kbName={capture.name}
          currentKey={capture.key}
          onClose={() => setCapture(false)}
        />
      )}
      <Box>
        Search: <Input onInput={(_e, value) => setFilter(value)} />
      </Box>
      <Grid>
        <Grid.Column>
          <Section title="Main">
            {data.all_keybindings['MOVEMENT']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {data.all_keybindings['MOB']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {data.all_keybindings['CLIENT']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {data.all_keybindings['LIVING']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {data.all_keybindings['CARBON']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}

            {data.all_keybindings['MISC']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}
          </Section>
          {data.is_admin && (
            <Section title="Administration (admin only)">
              {data.all_keybindings['ADMIN']?.filter(filterSearch).map(kb => (
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
            {data.all_keybindings['HUMAN']?.filter(filterSearch).map(kb => (
              <KeybindingPreference
                key={kb.name}
                keybind={kb}
                setCapture={setCapture}
              />
            ))}
            <LabeledList.Item>
              <h3>Xenomorph</h3>
            </LabeledList.Item>
            {data.all_keybindings['XENO']?.filter(filterSearch).map(kb => (
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
  const { act, data, config } = useBackend(context);
  const { keybind, setCapture } = props;
  const current = data.key_bindings[keybind.name];
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

const NavigationSelector = (props, context) => {
  const { tabIndex, onTabChange } = props;
  return (
    <Tabs vertical>
      <Tabs.Tab selected={tabIndex === 1} onClick={() => onTabChange(1)}>
        Character Customization
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 2} onClick={() => onTabChange(2)}>
        Gear Customization
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 3} onClick={() => onTabChange(3)}>
        Job Preferences
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 4} onClick={() => onTabChange(4)}>
        Game Settings
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 5} onClick={() => onTabChange(5)}>
        Keybindings
      </Tabs.Tab>
      {DEBUG_ENABLED && (
        <Tabs.Tab selected={tabIndex === 99} onClick={() => onTabChange(99)}>
          Show Debug
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const GearCustomization = (props, context) => {
  const { act, data, config } = useBackend(context);

  const slotMapping = {
    11: 'Head',
    9: 'Eyewear',
    10: 'Mouth',
  };

  const bySlot = {};
  for (const item in data.gearsets) {
    const gear = data.gearsets[item];
    if (!bySlot[slotMapping[gear.slot]]) {
      bySlot[slotMapping[gear.slot]] = [];
    }
    bySlot[slotMapping[gear.slot]].push(gear);
  }

  const currentPoints = data.gear.reduce((total, name) =>
    total + data.gearsets[name].cost, 0);

  return (
    <Section title="Custom Gear" buttons={
      <>
        <span
          style={{ "margin-right": "10px" }}>
          Points: {currentPoints} / 5
        </span>
        <Button
          inline
          color="red"
          content="Clear all"
          onClick={() => act('loadoutclear')} />
      </>
    }>
      <Grid>
        <Grid.Column>
          <Section title={'Head'}>
            <LabeledList>
              {bySlot['Head'].map(item => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={data.gear.includes(item.name)}
                    onClick={() => data.gear.includes(item.name)
                      ? act('loadoutremove', { gear: item.name })
                      : act('loadoutadd', { gear: item.name })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title={'Eyewear'}>
            <LabeledList>
              {bySlot['Eyewear'].map(item => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name}
                  (${item.cost})`}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={data.gear.includes(item.name)}
                    onClick={() => data.gear.includes(item.name)
                      ? act('loadoutremove', { gear: item.name })
                      : act('loadoutadd', { gear: item.name })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title={'Mouth'}>
            <LabeledList>
              {bySlot['Mouth'].map(item => (
                <LabeledList.Item
                  key={item.name}
                  label={`${item.name} (${item.cost})`}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={data.gear.includes(item.name)}
                    onClick={() => data.gear.includes(item.name)
                      ? act('loadoutremove', { gear: item.name })
                      : act('loadoutadd', { gear: item.name })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title={'Undershirt (select one)'}>
            <LabeledList>
              {data.clothing['undershirt'].map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={(data.undershirt - 1) === idx}
                    onClick={() => act('undershirt', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
      <Grid>
        <Grid.Column>
          <Section title={'Underwear (select one)'}>
            <LabeledList>
              {data.clothing['underwear'][data.gender].map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={(data.underwear - 1) === idx}
                    onClick={() => act('underwear', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title={'Backpack (select one)'}>
            <LabeledList>
              {data.clothing['backpack'].map((item, idx) => (
                <LabeledList.Item key={item} label={item}>
                  <Button.Checkbox
                    inline
                    content={'Equipped'}
                    checked={(data.backpack - 1) === idx}
                    onClick={() => act('backpack', { newValue: item })}
                  />
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

// const SaveSlotSelection = (props, context) => {
//   const { saveIndex, setSaveIndex } = props;
//   return (
//     <Tabs vertical>
//       <Tabs.Tab selected={saveIndex === 1} onClick={() => setSaveIndex(1)}>
//         Slot1
//       </Tabs.Tab>
//       <Tabs.Tab selected={saveIndex === 2} onClick={() => setSaveIndex(2)}>
//         Slot2
//       </Tabs.Tab>

//       <Tabs.Tab selected={saveIndex === 3} onClick={() => setSaveIndex(3)}>
//         Slot3
//       </Tabs.Tab>
//     </Tabs>
//   );
// };

const DebugPanel = (props, context) => {
  const { act, data, config } = useBackend(context);
  return (
    <div>
      <Section title="act">{JSON.stringify(act, null, 2)}</Section>
      <Section title="data">{JSON.stringify(data, null, 2)}</Section>
      <Section title="config">{JSON.stringify(config, null, 2)}</Section>
    </div>
  );
};
