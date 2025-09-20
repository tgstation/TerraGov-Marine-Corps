import { ByondUi } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const ProfilePicture = (props) => {
  const { data } = useBackend<ProfilePictureData>();
  const { mapRef } = data;
  return (
    <ByondUi
      style={{ width: '400px', height: '100px' }}
      params={{
        id: mapRef,
        type: 'map',
      }}
    />
  );
};
