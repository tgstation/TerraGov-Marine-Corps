import type { Observable } from './types';

enum HEALTH {
  Good = 69,
  Average = 19,
}

/** Displays color for buttons based on health. */
export const getDisplayColor = (item: Observable, sectionHasColor = false) => {
  const { health } = item;
  if (typeof health !== 'number') {
    return sectionHasColor ? 'good' : 'grey';
  }
  return getHealthColor(health);
};

/** Returns a disguised name in case the person is wearing someone else's ID */
export const getDisplayName = (full_name: string, nickname?: string) => {
  if (!nickname) {
    return full_name;
  }
  if (
    !full_name?.includes('[')
    || full_name.match(/\(as /)
    || full_name.match(/^Unknown/)
  ) {
    return nickname;
  }
  // return only the name before the first ' [' or ' ('
  return `"${full_name.split(/ \[| \(/)[0]}"`;
};

/** Returns the display color for certain health percentages */
const getHealthColor = (health: number) => {
  switch (true) {
    case health > HEALTH.Good:
      return 'good';
    case health > HEALTH.Average:
      return 'average';
    default:
      return 'bad';
  }
};

/** Checks if a full name or job title matches the search. */
export const isJobOrNameMatch = (
  observable: Observable,
  searchQuery: string
) => {
  if (!searchQuery) {
    return true;
  }
  const { caste, job, full_name } = observable;

  return (
    full_name?.toLowerCase().includes(searchQuery?.toLowerCase())
    || caste?.toLowerCase().includes(searchQuery?.toLowerCase())
    || job?.toLowerCase().includes(searchQuery?.toLowerCase())
    || false
  );
};
