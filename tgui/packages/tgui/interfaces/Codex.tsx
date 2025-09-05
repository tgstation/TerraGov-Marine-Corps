import React, { useState } from 'react';
import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar'; // Import the SearchBar component

// Stores the data of the codex entry
interface CodexData {
  name: string; // Entry name
  description: string; // Entry description
  attributes: Record<string, string>; // Object with key-value pairs for attributes
  mechanics: Record<string, string | Record<string, string[]>>; // Key-value pairs, with "Compatible Attachments" being a nested object
  background: Array<string>; // Array of strings for background information
  lore: string; // Lore text for the entry
  antag: string; // Antagonist type, if applicable
  is_gun: boolean; // Whether the entry is a gun
  is_clothing: boolean; // Whether the entry is a piece of clothing
  search_results: Array<string>; // Array of search results
}

// Main Codex component to display the codex entry
export const Codex = () => {
  const { act, data } = useBackend<CodexData>();
  const [search_query, update_search_query] = useState('');
  const [search_results, update_search_results] = useState<string[]>([]);

  // Function to handle querying the codex and retrieving results
  const handle_searching = async (query: string) => {
    // Update what the user is trying to search for via the state via useState hook
    update_search_query(query);

    // Let the backend know the user is searching for something
    act('search_codex', { query });

    // Extract search results from the response
    const results = data.search_results || [];

    // Update the search results to display with the extracted results
    update_search_results(Array.isArray(results) ? results : []);
  };

  // What to do when a search result is clicked; JUST PLACEHOLDER, FIX THIS
  const handle_result_click = (result: string) => {
    act('view_codex_entry', { entry: result });
  };

  return (
    <Window width={600} height={750} theme="ntos_rusty">
      <Window.Content scrollable>
        {/* Search bar and results grouped together */}
        <Box position="relative" mt={2} mb={1}>
          {/* Render the search bar; a component already exists so it does most of the work */}
          <SearchBar
            query={search_query}
            onSearch={handle_searching}
            placeholder="Search the Codex..."
            autoFocus
          />

          {/* Display the search results in a drop down */}
          {search_results.length > 0 && (
            <Box
              position="absolute" // Position it under the search bar without displacing other elements
              top="100%"
              ml={'18px'} // Adds a margin to the left of the dropdown the size of the magnifying glass icon next to search bar
              width="calc(100% - 20px)" // Adjust width to account for the left margin; perfectly flush under search bar
              backgroundColor="#222222"
              style={{
                border: '1px solid #3cff14',
                borderTop: 'none',
                zIndex: 10, // Ensure it appears above other elements
              }}
              maxHeight="200px" // Don't make the dropdown too tall
              overflowY="auto"
              mt={0} // Remove margin to keep it flush with search bar
            >
              {/* Render each result as a button since they are already clickable and easy to fit*/}
              {search_results.map((result, index) => (
                <Button
                  key={index}
                  fluid // Stretch the button to fill the width of the dropdown
                  ellipsis // Add ellipsis to the text if it overflows
                  backgroundColor="#222222"
                  textColor="white"
                  onClick={() => handle_result_click(result)}
                >
                  {result}
                </Button>
              ))}
            </Box>
          )}
        </Box>

        {/* Display basic info like name and description */}
        <Section title="Basic Info">
          <Box mb={2}>
            <b>Name: </b>
            {data.name}
          </Box>
          <Box>
            <b>Description: </b>
            {data.description}
          </Box>
        </Section>

        {/* Use the AttributesSection subcomponent */}
        <AttributesSection />

        {/* Use the MechanicsSection subcomponent */}
        <MechanicsSection />

        {/* Display the background section if it exists */}
        {data.background && data.background.length > 0 && (
          <Section title="Background">
            {data.background.map((info, index) => (
              <Box
                key={index}
                mb={index === data.background.length - 1 ? 0 : 4} // Add margin except for the last item
              >
                {info}
              </Box>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

// Component to display the attributes section of the codex entry
const AttributesSection = () => {
  const { act, data } = useBackend<CodexData>();

  // If no attributes exist, show nothing
  if (Object.keys(data.attributes).length === 0) {
    return null;
  }

  // Special rendering for guns
  if (data.is_gun) {
    return (
      <Section title="Attributes">
        <LabeledList>
          {Object.entries(data.attributes).map(([key, value], index) => (
            <React.Fragment key={index}>
              <AttributesRendering label={key} value={value} />
            </React.Fragment>
          ))}
        </LabeledList>
      </Section>
    );
  }

  // Default rendering for everything else
  return (
    <Section title="Attributes">
      <LabeledList>
        {Object.entries(data.attributes).map(([key, value], index) => (
          <React.Fragment key={index}>
            <AttributesRendering label={key} value={value} />
          </React.Fragment>
        ))}
      </LabeledList>
    </Section>
  );
};

// Component for displaying attributes; just a simple labeled list
const AttributesRendering = ({
  label,
  value,
}: {
  label: string;
  value: string;
}) => {
  // Extract tooltip text if "TT: " is found
  const [displayValue, tooltip] = value.includes('TT| ')
    ? value.split('TT| ').map((str) => str.trim())
    : [value, null];

  return (
    <>
      <LabeledList.Item
        label={label}
        tooltip={tooltip || undefined} // Only set tooltip if it exists
        className="codex-label"
      >
        {displayValue}
      </LabeledList.Item>
      <LabeledList.Divider size={1} />
    </>
  );
};

// Component to display the mechanics section of the codex entry
const MechanicsSection = () => {
  const { act, data } = useBackend<CodexData>();

  // If no mechanics entries exist, do not render anything
  if (Object.keys(data.mechanics).length === 0) {
    return null;
  }

  // Special rendering for guns
  if (data.is_gun) {
    return (
      <Section title="Mechanics">
        {Object.entries(data.mechanics).map(([key, value]) => (
          <React.Fragment key={key}>
            {/* Hardcoded the attachments list key name; if found, proceed below to render attachments in a fancy table */}
            {key === 'Compatible Attachments' && (
              // Call a component to render attachments, pass the attachments list (value) as a parameter
              <AttachmentsTable value={value as Record<string, string[]>} />
            )}

            {/* Render all other mechanics entries as normal */}
            {key !== 'Compatible Attachments' && (
              <MechanicsRendering
                key={key}
                label={key}
                value={value as string}
              />
            )}
          </React.Fragment>
        ))}
      </Section>
    );
  }

  // Default rendering for non-guns
  return (
    <Section title="Mechanics">
      {Object.entries(data.mechanics).map(([key, value]) => (
        <MechanicsRendering key={key} label={key} value={value as string} />
      ))}
    </Section>
  );
};

// Component for displaying mechanics entries; just a simple labeled list
const MechanicsRendering = ({
  label,
  value,
}: {
  label: string;
  value: string;
}) => {
  return (
    <>
      <LabeledList.Item label={label} className="codex-label">
        {value}
      </LabeledList.Item>
      <LabeledList.Divider size={1} />
    </>
  );
};

// Component for rendering attachments in a table
const AttachmentsTable = ({ value }: { value: Record<string, string[]> }) => {
  return (
    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
      {/* Title of the table */}
      <thead>
        <tr>
          <th
            colSpan={Object.keys(value).length} // Stretch the table title across the length of the table
            style={{
              border: '1px solid #ccc',
              padding: '8px',
              // Center the text horizontally and vertically
              textAlign: 'center',
              verticalAlign: 'middle',
            }}
          >
            Attachments
          </th>
        </tr>
      </thead>

      <thead>
        <tr>
          {/* Render the attachment categories as table headers */}
          {Object.keys(value).map((attachment_category) => (
            <th
              key={attachment_category}
              style={{
                border: '1px solid #ccc',
                padding: '8px',
                // Center the text horizontally and vertically
                textAlign: 'center',
                verticalAlign: 'middle',
              }}
            >
              {attachment_category}
            </th>
          ))}
        </tr>
      </thead>

      <tbody>
        {/* Create rows for the table based on the maximum number of attachments in any category */}
        {Array.from(
          {
            length: Math.max(
              ...Object.values(value).map((attachments) => attachments.length),
            ),
          },

          (_, row) => (
            <tr key={row}>
              {/* Generate table cells for each attachment category */}
              {Object.entries(value).map(
                ([attachment_category, attachments], column) => {
                  // Make sure the attachments entry is actually an array
                  if (Array.isArray(attachments)) {
                    return (
                      <td
                        key={column}
                        style={{
                          border: '1px solid #ccc',
                          padding: '8px',
                          // Center the text horizontally and vertically
                          textAlign: 'center',
                          verticalAlign: 'middle',
                        }}
                      >
                        {/* Display the attachment in the cell if it exists, otherwise leave blank */}
                        {attachments[row] || ''}
                      </td>
                    );
                  }
                  return null; // In the event the attachments entry is not an array
                },
              )}
            </tr>
          ),
        )}
      </tbody>
    </table>
  );
};
