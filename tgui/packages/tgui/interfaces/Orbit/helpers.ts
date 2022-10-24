import type { Observable } from './types';

enum HEALTH {
  Good = 69,
  Average = 19,
}

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

/**
 * ### getDisplayColor
 * Displays color for buttons based on health.
 * @param {Observable} item - The point of interest.
 * @param {string} color - OPTIONAL: The color to default to.
 */
export const getDisplayColor = (item: Observable, color?: string) => {
  const { health } = item;
  if (typeof health !== 'number') {
    return color ? 'good' : 'grey';
  }
  return getHealthColor(health);
};

/** Checks if a full name or job title matches the search. */
export const isJobOrNameMatch = (
  observable: Observable,
  searchQuery: string
) => {
  if (!searchQuery) {
    return true;
  }
  const { name, job } = observable;

  return (
    name?.toLowerCase().includes(searchQuery?.toLowerCase())
    || job?.toLowerCase().includes(searchQuery?.toLowerCase())
    || false
  );
};
