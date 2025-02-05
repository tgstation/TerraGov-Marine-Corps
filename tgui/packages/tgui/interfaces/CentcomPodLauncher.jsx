import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// This is more or less a direct port from old tgui, with some slight
// text cleanup. But yes, it actually worked like this.
export const CentcomPodLauncher = (props) => {
  const { act, data } = useBackend();
  return (
    <Window title="Config/Launch Supplypod" width={700} height={700}>
      <Window.Content>
        <NoticeBox>
          To use this, simply spawn the atoms you want in one of the five
          Centcom Supplypod Bays. Items in the bay will then be launched inside
          your supplypod, one turf-full at a time! You can optionally use the
          following buttons to configure how the supplypod acts.
        </NoticeBox>
        <Section title="Centcom Pod Customization">
          <LabeledList>
            <LabeledList.Item label="Supply Bay">
              <Button
                content="Bay #1"
                selected={data.bayNumber === 1}
                onClick={() => act('bay1')}
              />
              <Button
                content="Bay #2"
                selected={data.bayNumber === 2}
                onClick={() => act('bay2')}
              />
              <Button
                content="Bay #3"
                selected={data.bayNumber === 3}
                onClick={() => act('bay3')}
              />
              <Button
                content="Bay #4"
                selected={data.bayNumber === 4}
                onClick={() => act('bay4')}
              />
              <Button
                content="ERT Bay"
                selected={data.bayNumber === 5}
                tooltip={`
                  This bay is located on the western edge of CentCom. Its the
                  glass room directly west of where ERT spawn, and south of the
                  CentCom ferry. Useful for launching ERT/Deathsquads/etc. onto
                  the station via drop pods.
                `}
                onClick={() => act('bay5')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Teleport to">
              <Button
                content={data.bay}
                onClick={() => act('teleportCentcom')}
              />
              <Button
                content={data.oldArea ? data.oldArea : 'Where you were'}
                disabled={!data.oldArea}
                onClick={() => act('teleportBack')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Clone Mode">
              <Button
                content="Launch Clones"
                selected={data.launchClone}
                tooltip={`
                  Choosing this will create a duplicate of the item to be
                  launched in Centcom, allowing you to send one type of item
                  multiple times. Either way, the atoms are forceMoved into
                  the supplypod after it lands (but before it opens).
                `}
                onClick={() => act('launchClone')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Launch style">
              <Button
                content="Ordered"
                selected={data.launchChoice === 1}
                tooltip={`
                  Instead of launching everything in the bay at once, this
                  will "scan" things (one turf-full at a time) in order, left
                  to right and top to bottom. undoing will reset the "scanner"
                  to the top-leftmost position.
                `}
                onClick={() => act('launchOrdered')}
              />
              <Button
                content="Random"
                selected={data.launchChoice === 2}
                tooltip={`
                  Instead of launching everything in the bay at once, this
                  will launch one random turf of items at a time.
                `}
                onClick={() => act('launchRandom')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Explosion">
              <Button
                content="Custom Size"
                selected={data.explosionChoice === 1}
                tooltip={`
                  This will cause an explosion of whatever size you like
                  (including flame range) to occur as soon as the supplypod
                  lands. Dont worry, supply-pods are explosion-proof!
                `}
                onClick={() => act('explosionCustom')}
              />
              <Button
                content="Adminbus"
                selected={data.explosionChoice === 2}
                tooltip={`
                  This will cause a maxcap explosion (dependent on server
                  config) to occur as soon as the supplypod lands. Dont worry,
                  supply-pods are explosion-proof!
                `}
                onClick={() => act('explosionBus')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Damage">
              <Button
                content="Custom Damage"
                selected={data.damageChoice === 1}
                tooltip={`
                  Anyone caught under the pod when it lands will be dealt
                  this amount of brute damage. Sucks to be them!
                `}
                onClick={() => act('damageCustom')}
              />
              <Button
                content="Gib"
                selected={data.damageChoice === 2}
                tooltip={`
                  This will attempt to gib any mob caught under the pod when
                  it lands, as well as dealing a nice 5000 brute damage. Ya
                  know, just to be sure!
                `}
                onClick={() => act('damageGib')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Effects">
              <Button
                content="Stun"
                selected={data.effectStun}
                tooltip={`
                  Anyone who is on the turf when the supplypod is launched
                  will be stunned until the supplypod lands. They cant get
                  away that easy!
                `}
                onClick={() => act('effectStun')}
              />
              <Button
                content="Delimb"
                selected={data.effectLimb}
                tooltip={`
                  This will cause anyone caught under the pod to lose a limb,
                  excluding their head.
                `}
                onClick={() => act('effectLimb')}
              />
              <Button
                content="Yeet Organs"
                selected={data.effectOrgans}
                tooltip={`
                  This will cause anyone caught under the pod to lose all
                  their limbs and organs in a spectacular fashion.
                `}
                onClick={() => act('effectOrgans')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Movement">
              <Button
                content="Bluespace"
                selected={data.effectBluespace}
                tooltip={`
                  Gives the supplypod an advanced Bluespace Recyling Device.
                  After opening, the supplypod will be warped directly to the
                  surface of a nearby NT-designated trash planet (/r/ss13).
                `}
                onClick={() => act('effectBluespace')}
              />
              <Button
                content="Stealth"
                selected={data.effectStealth}
                tooltip={`
                  This hides the red target icon from appearing when you
                  launch the supplypod. Combos well with the "Invisible"
                  style. Sneak attack, go!
                `}
                onClick={() => act('effectStealth')}
              />
              <Button
                content="Quiet"
                selected={data.effectQuiet}
                tooltip={`
                  This will keep the supplypod from making any sounds, except
                  for those specifically set by admins in the Sound section.
                `}
                onClick={() => act('effectQuiet')}
              />
              <Button
                content="Reverse Mode"
                selected={data.effectReverse}
                tooltip={`
                  This pod will not send any items. Instead, after landing,
                  the supplypod will close (similar to a normal closet closing),
                  and then launch back to the right centcom bay to drop off any
                  new contents.
                `}
                onClick={() => act('effectReverse')}
              />
              <Button
                content="Missile Mode"
                selected={data.effectMissile}
                tooltip={`
                  This pod will not send any items. Instead, it will immediately
                  delete after landing (Similar visually to setting openDelay
                  & departDelay to 0, but this looks nicer). Useful if you just
                  wanna fuck some shit up. Combos well with the Missile style.
                `}
                onClick={() => act('effectMissile')}
              />
              <Button
                content="Any Descent Angle"
                selected={data.effectCircle}
                tooltip={`
                  This will make the supplypod come in from any angle. Im not
                  sure why this feature exists, but here it is.
                `}
                onClick={() => act('effectCircle')}
              />
              <Button
                content="Machine Gun Mode"
                selected={data.effectBurst}
                tooltip={`
                  This will make each click launch 5 supplypods inaccuratly
                  around the target turf (a 3x3 area). Combos well with the
                  Missile Mode if you dont want shit lying everywhere after.
                `}
                onClick={() => act('effectBurst')}
              />
              <Button
                content="Specific Target"
                selected={data.effectTarget}
                tooltip={`
                  This will make the supplypod target a specific atom, instead
                  of the mouses position. Smiting does this automatically!
                `}
                onClick={() => act('effectTarget')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Name/Desc">
              <Button
                content="Custom Name/Desc"
                selected={data.effectName}
                tooltip="Allows you to add a custom name and description."
                onClick={() => act('effectName')}
              />
              <Button
                content="Alert Ghosts"
                selected={data.effectAnnounce}
                tooltip={`
                  Alerts ghosts when a pod is launched. Useful if some dumb
                  shit is aboutta come outta the pod.
                `}
                onClick={() => act('effectAnnounce')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Sound">
              <Button
                content="Custom Falling Sound"
                selected={data.fallingSound}
                tooltip={`
                  Choose a sound to play as the pod falls. Note that for this
                  to work right you should know the exact length of the sound,
                  in seconds.
                `}
                onClick={() => act('fallSound')}
              />
              <Button
                content="Custom Landing Sound"
                selected={data.landingSound}
                tooltip="Choose a sound to play when the pod lands."
                onClick={() => act('landingSound')}
              />
              <Button
                content="Custom Opening Sound"
                selected={data.openingSound}
                tooltip="Choose a sound to play when the pod opens."
                onClick={() => act('openingSound')}
              />
              <Button
                content="Custom Leaving Sound"
                selected={data.leavingSound}
                tooltip={`
                  Choose a sound to play when the pod departs (whether that be
                  delection in the case of a bluespace pod, or leaving for
                  centcom for a reversing pod).
                `}
                onClick={() => act('leavingSound')}
              />
              <Button
                content="Admin Sound Volume"
                selected={data.soundVolume}
                tooltip={`
                  Choose the volume for the sound to play at. Default values
                  are between 1 and 100, but hey, do whatever. Im a tooltip,
                  not a cop.
                `}
                onClick={() => act('soundVolume')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Timers">
              <Button
                content="Custom Falling Duration"
                selected={data.fallDuration !== 4}
                tooltip={`
                  Set how long the animation for the pod falling lasts. Create
                  dramatic, slow falling pods!
                `}
                onClick={() => act('fallDuration')}
              />
              <Button
                content="Custom Landing Time"
                selected={data.landingDelay !== 20}
                tooltip={`
                  Choose the amount of time it takes for the supplypod to hit
                  the station. By default this value is 0.5 seconds.
                `}
                onClick={() => act('landingDelay')}
              />
              <Button
                content="Custom Opening Time"
                selected={data.openingDelay !== 30}
                tooltip={`
                  Choose the amount of time it takes for the supplypod to open
                  after landing. Useful for giving whatevers inside the pod a
                  nice dramatic entrance! By default this value is 3 seconds.
                `}
                onClick={() => act('openingDelay')}
              />
              <Button
                content="Custom Leaving Time"
                selected={data.departureDelay !== 30}
                tooltip={`
                  Choose the amount of time it takes for the supplypod to leave
                  after landing. By default this value is 3 seconds.
                `}
                onClick={() => act('departureDelay')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Style">
              {data.styles.map((style) => (
                <Button
                  key={style.id}
                  content={style[1]}
                  selected={data.styleChoice === style[3]}
                  tooltip={style[2]}
                  onClick={() => act('setstyle', { style: style[0] })}
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label={data.numObjects + ' turfs in ' + data.bay}
              buttons={
                <>
                  <Button
                    content="undo Pody Bay"
                    tooltip={`
                      Manually undoes the possible things to launch in the
                      pod bay.
                    `}
                    onClick={() => act('undo')}
                  />
                  <Button
                    content="Enter Launch Mode"
                    selected={data.giveLauncher}
                    tooltip="THE CODEX ASTARTES CALLS THIS MANEUVER: STEEL RAIN"
                    onClick={() => act('giveLauncher')}
                  />
                  <Button
                    content="Clear Selected Bay"
                    color="bad"
                    tooltip={`
                      This will delete all objs and mobs from the selected bay.
                    `}
                    tooltipPosition="left"
                    onClick={() => act('clearBay')}
                  />
                </>
              }
            />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
