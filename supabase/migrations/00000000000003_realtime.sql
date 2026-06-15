-- Enable Supabase Realtime for live chat + notifications.
-- The stream subscription in ChatRepositoryImpl.watchMessages relies on
-- chat_messages being part of the supabase_realtime publication.
--
-- Guarded: ADD TABLE errors if the table is already a publication member
-- (Supabase may add tables by default), which would abort the migration.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'chat_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  END IF;
END $$;
