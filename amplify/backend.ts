import { defineBackend } from '@aws-amplify/backend';

// Force rebuild to help Amplify detect backend
export const backend = defineBackend({});
