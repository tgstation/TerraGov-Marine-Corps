import { useState } from 'react';

import { useBackend } from '../../backend';
import { Box, Button, Section, Stack, TextArea } from '../../components';

export const BackgroundInformation = (props) => {
  const { act, data } = useBackend<BackgroundInformationData>();
  const {
    flavor_text,
    med_record,
    gen_record,
    sec_record,
    exploit_record,
    xeno_desc,
    profile_pic,
    nsfwprofile_pic,
    xenoprofile_pic,
  } = data;
  const [characterDesc, setCharacterDesc] = useState(flavor_text);
  const [medicalDesc, setMedicalDesc] = useState(med_record);
  const [employmentDesc, setEmploymentDesc] = useState(gen_record);
  const [securityDesc, setSecurityDesc] = useState(sec_record);
  const [exploitsDesc, setExploitsDesc] = useState(exploit_record);
  const [xenoDesc, setXenoDesc] = useState(xeno_desc);
  const [profilePic, setProfilePic] = useState(profile_pic);
  const [nsfwprofilePic, setNSFWProfilePic] = useState(nsfwprofile_pic);
  const [xenoprofilePic, setXenoProfilePic] = useState(xenoprofile_pic);
  return (
    <Section title="Background information">
      <Section
        title="Character Description"
        buttons={
          <Box>
            <Button
              icon="save"
              disabled={characterDesc === flavor_text}
              onClick={() => act('flavor_text', { characterDesc })}
            >
              Save
            </Button>
            <Button icon="times" onClick={() => setCharacterDesc(flavor_text)}>
              Reset
            </Button>
          </Box>
        }
      >
        <TextArea
          key="character"
          height="200px"
          maxLength={12000}
          value={characterDesc}
          onChange={(e, value) => setCharacterDesc(value)}
        />
      </Section>
      <Section
        title="Xenomorph Description"
        buttons={
          <Box>
            <Button
              icon="save"
              disabled={xenoDesc === xeno_desc}
              onClick={() => act('xeno_desc', { xenoDesc })}
            >
              Save
            </Button>
            <Button icon="times" onClick={() => setXenoDesc(xeno_desc)}>
              Reset
            </Button>
          </Box>
        }
      >
        <TextArea
          key="xeno"
          height="200px"
          maxLength={12000}
          value={xenoDesc}
          onChange={(e, value) => setXenoDesc(value)}
        />
      </Section>

      <Stack>
        <Stack.Item grow>
          <Section
            title="Medical Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={medicalDesc === med_record}
                  onClick={() => act('med_record', { medicalDesc })}
                >
                  Save
                </Button>
                <Button icon="times" onClick={() => setMedicalDesc(med_record)}>
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={1024}
              value={medicalDesc}
              onChange={(e, value) => setMedicalDesc(value)}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Employment Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={employmentDesc === gen_record}
                  onClick={() => act('gen_record', { employmentDesc })}
                >
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setEmploymentDesc(gen_record)}
                >
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={1024}
              value={employmentDesc}
              onChange={(e, value) => setEmploymentDesc(value)}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section
            title="Security Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={securityDesc === sec_record}
                  onClick={() => act('sec_record', { securityDesc })}
                >
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setSecurityDesc(sec_record)}
                >
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={1024}
              value={securityDesc}
              onChange={(e, value) => setSecurityDesc(value)}
            />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Exploit Records"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={exploitsDesc === exploit_record}
                  onClick={() => act('exploit_record', { exploitsDesc })}
                >
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setExploitsDesc(exploit_record)}
                >
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={1024}
              value={exploitsDesc}
              onChange={(e, value) => setExploitsDesc(value)}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack>
        <Stack.Item grow>
          <Section
            title="Human Picture"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={profilePic === profile_pic}
                  onClick={() => act('profile_pic', { profilePic })}
                >
                  Save
                </Button>
                <Button icon="times" onClick={() => setProfilePic(profile_pic)}>
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={2048}
              value={profilePic}
              onChange={(e, value) => setProfilePic(value)}
            />
            <img src={profile_pic} width={350} height={400} />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Human Nakie Picture"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={nsfwprofilePic === nsfwprofile_pic}
                  onClick={() => act('nsfwprofile_pic', { nsfwprofilePic })}
                >
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setProfilePic(nsfwprofile_pic)}
                >
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={2048}
              value={nsfwprofilePic}
              onChange={(e, value) => setNSFWProfilePic(value)}
            />
            <img src={nsfwprofile_pic} width={350} height={400} />
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section
            title="Xeno Profile Picture"
            buttons={
              <Box>
                <Button
                  icon="save"
                  disabled={xenoprofilePic === xenoprofile_pic}
                  onClick={() => act('xenoprofile_pic', { xenoprofilePic })}
                >
                  Save
                </Button>
                <Button
                  icon="times"
                  onClick={() => setXenoProfilePic(xenoprofile_pic)}
                >
                  Reset
                </Button>
              </Box>
            }
          >
            <TextArea
              height="100px"
              maxLength={2048}
              value={xenoprofilePic}
              onChange={(e, value) => setXenoProfilePic(value)}
            />
            <img src={xenoprofile_pic} width={350} height={400} />
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
