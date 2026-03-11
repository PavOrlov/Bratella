# Bratella Papyrus JSON Contract

Минимальный transport contract между локальным Python runtime и Papyrus-side polling logic.

## Poll response types

### empty

```json
{
  "reply_type": "empty",
  "conversation_id": "smoke-c1",
  "event_available": false
}
```

### npc_talk

```json
{
  "reply_type": "npc_talk",
  "conversation_id": "smoke-c1",
  "event_id": "c8d9ed2e-4b59-4822-ab96-22b48332a9b3",
  "sequence_number": 1,
  "actor_talk": {
    "speaker": "Hadvar",
    "speaker_ref_id": 180127,
    "line_to_speak": "Принято. Ты сказал: Hadvar, status report.",
    "is_narration": false,
    "voice_file": "",
    "line_duration": 0.0,
    "actions": [],
    "topic_info_file": 0
  }
}
```
## Fields read by quest script

Quest/repository script должен читать:

- `reply_type`
- `conversation_id`
- `event_id`
- `sequence_number`
- `actor_talk.speaker`
- `actor_talk.speaker_ref_id`
- `actor_talk.line_to_speak`
- `actor_talk.is_narration`
- `actor_talk.voice_file`
- `actor_talk.line_duration`
- `actor_talk.actions`
- `actor_talk.topic_info_file`

## Repository state between polls

BratellaRepository должен хранить:

- `CurrentConversationId`
- `IsConversationRunning`
- `LastReplyType`
- `LastPolledEventId`
- `LastSequenceNumber`
- `LastPollSucceeded`
- `LastServerError`
- `PendingSpeakerName`
- `PendingSpeakerRefId`
- `PendingLineToSpeak`
- `PendingIsNarration`
- `PendingVoiceFile`
- `PendingLineDuration`
- `PendingTopicInfoFile`
- `PendingActionsJson`

## Minimal poll flow

1. `start_conversation`
2. Сохранить `conversation_id` в `BratellaRepository`
3. Отправить `player_input`
4. Вызвать `/events/next`
5. Если `reply_type == "empty"` — ничего не исполнять
6. Если `reply_type == "npc_talk"`:
   - проверить duplicate по `event_id`
   - проверить порядок по `sequence_number`
   - сохранить payload в `BratellaRepository`
   - передать реплику в subtitle / TTS / future action layer
