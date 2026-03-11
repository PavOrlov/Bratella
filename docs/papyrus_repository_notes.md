# Bratella Papyrus Repository Notes

Минимальный Papyrus-side runtime contract для хранения состояния разговора между poll-итерациями.

## Назначение

`BratellaRepository` — это quest-side state holder.
Он не должен заниматься HTTP, JSON-парсингом, TTS или subtitle rendering напрямую.
Его задача — хранить последний подтверждённый transport state и pending NPC event.

## Что хранит Repository

### Conversation state

- `CurrentConversationId`
- `IsConversationRunning`

### Poll/result state

- `LastReplyType`
- `LastPolledEventId`
- `LastSequenceNumber`
- `LastPollSucceeded`
- `LastServerError`

### Pending NPC talk payload

- `PendingSpeakerName`
- `PendingSpeakerRefId`
- `PendingLineToSpeak`
- `PendingIsNarration`
- `PendingVoiceFile`
- `PendingLineDuration`
- `PendingTopicInfoFile`
- `PendingActionsJson`

## Минимальный lifecycle

1. После успешного `start_conversation` вызвать `StartConversationState(conversationId)`.
2. После poll с `reply_type == "empty"` вызвать `CommitEmptyPoll(conversationId)`.
3. После poll с `reply_type == "npc_talk"`:
   - проверить `IsDuplicateEvent(eventId, sequenceNumber)`
   - если событие новое, вызвать `CommitNpcTalkEvent(...)`
   - потом downstream layer читает pending поля и исполняет реплику
4. При завершении разговора вызвать `ResetState()`.

## Почему так

Такой подход отделяет:
- transport layer;
- repository/state layer;
- actual presentation layer.

Это полезно для Papyrus, потому что quest logic, stage fragments и polling callbacks не должны напрямую зависеть от сиюминутного JSON-текста.

## Минимальные правила

- Не исполнять NPC reply прямо из raw JSON.
- Сначала коммитить event в repository.
- Не обрабатывать повторно одинаковый `event_id`.
- Не принимать sequence, который меньше или равен `LastSequenceNumber`.
- `Pending*` поля считаются текущим подтверждённым NPC event payload.

## Что не входит в Repository

`BratellaRepository` не должен:
- сам выполнять HTTP-запросы;
- сам разбирать JSON-строку;
- сам проигрывать звук;
- сам выбирать actor через сложный поиск по миру;
- сам исполнять actions.

Это должен делать отдельный transport/parser/runner слой.
