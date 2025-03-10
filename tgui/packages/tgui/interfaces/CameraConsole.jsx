import { useState } from 'react';
import { Button, ByondUi, Flex, Input, Section } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const defaultRole = 'Other';

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
export const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(
    (camera) => camera.name === activeCamera.name,
  );
  return [cameras[index - 1]?.name, cameras[index + 1]?.name];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
export const selectCameras = (cameras, searchText = '') => {
  const useRoles = cameras.some((camera) => camera.role);

  let camerasToSort = cameras;
  if (useRoles) {
    camerasToSort = cameras.map((camera) => ({
      ...camera,
      role: camera.role || defaultRole,
    }));
  }

  const testSearch = createSearch(
    searchText,
    (camera) => camera.name + camera.role,
  );
  return camerasToSort
    .filter((camera) => camera?.name)
    .filter((camera) => !searchText || testSearch(camera))
    .sort((a, b) => {
      // prefer Other roles to be last
      if (a.role === defaultRole && b.role !== defaultRole) {
        return 1;
      }
      if (a.role !== defaultRole && b.role === defaultRole) {
        return -1;
      }
      return a.name.localeCompare(b.name);
    });
};

export const CameraConsole = (props) => {
  const { act, data } = useBackend();
  const { cameras, mapRef, activeCamera } = data;
  const filteredCameras = selectCameras(cameras);
  const [prevCameraName, nextCameraName] = prevNextCamera(
    filteredCameras,
    activeCamera,
  );
  return (
    <Window width={870} height={708}>
      <div className="CameraConsole__left">
        <Window.Content scrollable>
          <CameraConsoleContent />
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {(activeCamera && activeCamera.name) || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() =>
              act('switch_camera', {
                name: prevCameraName,
              })
            }
          />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() =>
              act('switch_camera', {
                name: nextCameraName,
              })
            }
          />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </div>
    </Window>
  );
};

export const CameraConsoleContent = (props) => {
  const { data } = useBackend();
  const [searchText, setSearchText] = useState('');
  const { activeCamera, cameras } = data;
  const useRoles = cameras.some((camera) => camera.role);
  const filteredCameras = selectCameras(cameras, searchText);
  return (
    <Flex direction={'column'} height="100%">
      <Flex.Item>
        <Input
          autoFocus
          fluid
          mt={1}
          placeholder="Search for a camera"
          onInput={(e, value) => setSearchText(value)}
        />
      </Flex.Item>
      <Flex.Item height="100%">
        <Section fill scrollable>
          <CameraRoles
            cameras={filteredCameras}
            activeCamera={activeCamera}
            useRoles={useRoles}
          />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export const CameraRoles = (props) => {
  const { cameras, activeCamera, useRoles } = props;
  const { data } = useBackend();
  if (!cameras) {
    return null;
  }

  // Group cameras by role
  const rolesCameras = {};
  for (let i = 0; i < cameras.length; i++) {
    const role = cameras[i].role || defaultRole;
    if (!rolesCameras[role]) {
      rolesCameras[role] = [];
    }
    rolesCameras[role].push(cameras[i]);
  }

  // Render each role group
  return Object.entries(rolesCameras).map(([role, roleCameras]) => {
    return (
      <div key={role}>
        {useRoles && <div className="CameraConsole__role">{role}</div>}
        <CameraEntries cameras={roleCameras} activeCamera={activeCamera} />
      </div>
    );
  });
};

export const CameraEntries = (props) => {
  const { cameras, activeCamera } = props;
  const { data, act } = useBackend();
  return cameras.map((camera) => (
    // We're not using the component here because performance
    // would be absolutely abysmal (50+ ms for each re-render).
    <div
      key={camera.name}
      title={camera.name}
      className={classes([
        'Button',
        'Button--fluid',
        'Button--color--transparent',
        'Button--ellipsis',
        activeCamera && camera.name === activeCamera.name && 'Button--selected',
      ])}
      onClick={() =>
        act('switch_camera', {
          name: camera.name,
        })
      }
    >
      {camera.name}
    </div>
  ));
};
