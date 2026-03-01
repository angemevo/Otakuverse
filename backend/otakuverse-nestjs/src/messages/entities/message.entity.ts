export class Message {
    id!: String;
    conversation_id!: String;
    sender_id!: String;
    content!: String;
    message_type!: 'text' | 'image' | 'video' | 'audio' | 'file';
    media_url?: String;
    reply_to_id!: String;
    is_read: boolean = false;
    read_at?: Date;
    is_deleted: boolean = false;
    deleted_at?: Date;
    created_at!: Date;
    updated_at!: Date;
}
