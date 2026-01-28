export interface User {
    id: string;
    username: string;
    displayName?: string | null;
    avatarUrl?: string | null;
    bio?: string | null;
    createdAt: Date;
    updatedAt: Date;
}