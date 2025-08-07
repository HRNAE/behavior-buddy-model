import { defineStorage } from "@aws-amplify/backend";

/*export const storage = defineStorage({
  name: 'audioRecordings',
  access: (allow) => ({
    'recordings/{entity_id}/*': [
      allow.entity('identity').to(['read', 'write', 'delete'])
    ]
  })
});*/

export const storage = defineStorage({
  name: 'Recordings',
  access: (allow) => ({
    'recordings/{entity_id}/*': [
      // {entity_id} is the token that is replaced with the user identity id
      allow.entity('identity').to(['read', 'write', 'delete'])
    ]
  })
});

