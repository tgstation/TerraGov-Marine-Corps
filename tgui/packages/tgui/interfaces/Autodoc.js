import { useBackend } from '../backend';
import { AnimatedNumber, Button, LabeledList, ProgressBar, Section, Box, NoticeBox} from '../components';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
];

export const Autodoc = () => {
  return (
    <Window width={500} height={700}>
      <Window.Content scrollable>
        <AutodocContent />
      </Window.Content>
    </Window>
  );
};

const AutodocContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { hasOccupant, occupant, locked, notice, auto, queue, surgery} = data
  return (
    <>
      <Section title="Settings">
        <Button
          content="Lock console"
          onClick={() => act('locktoggle')}
          color={locked ? "green" : "red"}>
        </Button>
        <Button
          content="Notifications"
          onClick={() => act('noticetoggle')}
          color={notice ? "green" : "red"}>
        </Button>
        <Button
          content="Automatic mode"
          onClick={() => act('automatictoggle')}
          disabled={surgery}
          color={auto ? "green" : "red"}>
        </Button>
      </Section>
      <Section title="Occupant">
        <LabeledList>
          <LabeledList.Item label="Occupant">
            {occupant.name || 'No Occupant'}
          </LabeledList.Item>
          {!!hasOccupant && (
            <>
              <LabeledList.Item label="State" color={occupant.statstate}>
                {occupant.stat}
              </LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  value={occupant.health / occupant.maxHealth}
                  color={occupant.health > 0 ? 'good' : 'average'}>
                  <AnimatedNumber value={occupant.health} />
                </ProgressBar>
              </LabeledList.Item>
              {damageTypes.map((damageType) => (
                <LabeledList.Item key={damageType.id} label={damageType.label}>
                  <ProgressBar value={occupant[damageType.type] / 100}>
                    <AnimatedNumber value={occupant[damageType.type]} />
                  </ProgressBar>
                </LabeledList.Item>
              ))}
            </>
          )}
        </LabeledList>
      </Section>
      {!!hasOccupant && (
        <>
          <Section title={"Surgery queue"}>
            <Box width="100%">
              <NoticeBox>
                {surgery ? "SURGERY IN PROGRESS: MANUAL EJECTION ONLY TO BE ATTEMPTED BY TRAINED OPERATORS!" : "Not in surgery"}
              </NoticeBox>
            </Box>
            {queue.map((operation) => (
              <Box>
                - {operation}
              </Box>
            ))}
          </Section>
          <Section title="Functions">
            {!surgery && (
              <Button
                content="Begin surgery"
                onClick={() => act('surgery')}>
              </Button>
            )}
            {!auto && (
              <Button
                content="Clear surgery queue"
                onClick={() => act('clear')}>
              </Button>
            )}
            <Button
              content="Eject patient"
              icon="eject"
              onClick={() => act('eject')}>
            </Button>
          </Section>
          {!auto && !surgery && (
            <Section title="Surgery interface">
              <Section title="Trauma Surgeries">
                <Button
                  content="Surgical Brute Damage Treatment"
                  disabled={queue.includes("Surgical Brute Damage Treatment")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "brute"
                  })}>
                </Button>
                <Button
                  content="Surgical Burn Damage Treatment"
                  disabled={queue.includes("Surgical Burn Damage Treatment")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "burn"
                  })}>
                </Button>
              </Section>
              <Section title="Orthopedic Surgeries">
                <Button
                  content="Broken Bone Surgery"
                  disabled={queue.includes("Broken Bone Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "broken"
                  })}>
                </Button>
                <Button
                  content="Internal Bleeding Surgery"
                  disabled={queue.includes("Internal Bleeding Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "internal"
                  })}>
                </Button>
                <Button
                  content="Foreign Body Removal Surgery"
                  disabled={queue.includes("Foreign Body Removal Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "shrapnel"
                  })}>
                </Button>
                <Button
                  content="Limb Replacement Surgery"
                  disabled={queue.includes("Limb Replacement Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "missing"
                  })}>
                </Button>
              </Section>
              <Section title="Organ Surgeries">
                <Button
                  content="Surgical Organ Damage Treatment"
                  disabled={queue.includes("Surgical Organ Damage Treatment")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "organdamage"
                  })}>
                </Button>
                <Button
                  content="Organ Infection Treatment"
                  disabled={queue.includes("Organ Infection Treatment")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "organgerms"
                  })}>
                </Button>
                <Button
                  content="Corrective Eye Surgery"
                  disabled={queue.includes("Corrective Eye Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "eyes"
                  })}>
                </Button>
              </Section>
              <Section title="Hematology Treatments">
                <Button
                  content="Blood Transfer"
                  disabled={queue.includes("Blood Transfer")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "blood"
                  })}>
                </Button>
                <Button
                  content="Toxin Damage Chelation"
                  disabled={queue.includes("Toxin Damage Chelation")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "toxin"
                  })}>
                </Button>
                <Button
                  content="Dialysis"
                  disabled={queue.includes("Dialysis")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "dialysis"
                  })}>
                </Button>
                <Button
                  content="Necrosis Removal Surgery"
                  disabled={queue.includes("Necrosis Removal Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "necro"
                  })}>
                </Button>
                <Button
                  content="Limb Disinfection Procedure"
                  disabled={queue.includes("Limb Disinfection Procedure")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "limbgerm"
                  })}>
                </Button>
              </Section>
              <Section title="Special Surgeries">
                <Button
                  content="Facial Reconstruction Surgery"
                  disabled={queue.includes("Facial Reconstruction Surgery")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "facial"
                  })}>
                </Button>
                <Button
                  content="Close Open Incision"
                  disabled={queue.includes("Close Open Incision")}
                  onClick={() => act('add_surgery', {
                    surgeryname: "open"
                  })}>
                </Button>
              </Section>
            </Section>
          )}
        </>
      )}
    </>
  );
};
