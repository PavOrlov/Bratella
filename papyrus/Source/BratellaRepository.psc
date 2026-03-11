Scriptname BratellaRepository extends Quest

String Property CurrentConversationId Auto
Bool Property IsConversationRunning Auto

String Property LastReplyType Auto
String Property LastPolledEventId Auto
Int Property LastSequenceNumber Auto
Bool Property LastPollSucceeded Auto
String Property LastServerError Auto

String Property PendingSpeakerName Auto
Int Property PendingSpeakerRefId Auto
String Property PendingLineToSpeak Auto
Bool Property PendingIsNarration Auto
String Property PendingVoiceFile Auto
Float Property PendingLineDuration Auto
Int Property PendingTopicInfoFile Auto
String Property PendingActionsJson Auto

Function ResetState()
    CurrentConversationId = ""
    IsConversationRunning = False

    LastReplyType = ""
    LastPolledEventId = ""
    LastSequenceNumber = 0
    LastPollSucceeded = False
    LastServerError = ""

    ResetPendingEvent()
EndFunction

Function StartConversationState(String aConversationId)
    CurrentConversationId = aConversationId
    IsConversationRunning = True

    LastReplyType = ""
    LastPolledEventId = ""
    LastSequenceNumber = 0
    LastPollSucceeded = False
    LastServerError = ""

    ResetPendingEvent()
EndFunction

Function ResetPendingEvent()
    PendingSpeakerName = ""
    PendingSpeakerRefId = 0
    PendingLineToSpeak = ""
    PendingIsNarration = False
    PendingVoiceFile = ""
    PendingLineDuration = 0.0
    PendingTopicInfoFile = 0
    PendingActionsJson = ""
EndFunction

Bool Function IsDuplicateEvent(String aEventId, Int aSequenceNumber)
    If aEventId != "" && aEventId == LastPolledEventId
        Return True
    EndIf

    If aSequenceNumber > 0 && aSequenceNumber <= LastSequenceNumber
        Return True
    EndIf

    Return False
EndFunction

Function CommitNpcTalkEvent( ;
    String aConversationId, ;
    String aEventId, ;
    Int aSequenceNumber, ;
    String aSpeaker, ;
    Int aSpeakerRefId, ;
    String aLineToSpeak, ;
    Bool aIsNarration, ;
    String aVoiceFile, ;
    Float aLineDuration, ;
    Int aTopicInfoFile, ;
    String aActionsJson)

    CurrentConversationId = aConversationId
    IsConversationRunning = True

    LastReplyType = "npc_talk"
    LastPolledEventId = aEventId
    LastSequenceNumber = aSequenceNumber
    LastPollSucceeded = True
    LastServerError = ""

    PendingSpeakerName = aSpeaker
    PendingSpeakerRefId = aSpeakerRefId
    PendingLineToSpeak = aLineToSpeak
    PendingIsNarration = aIsNarration
    PendingVoiceFile = aVoiceFile
    PendingLineDuration = aLineDuration
    PendingTopicInfoFile = aTopicInfoFile
    PendingActionsJson = aActionsJson
EndFunction

Function CommitEmptyPoll(String aConversationId)
    CurrentConversationId = aConversationId
    IsConversationRunning = True

    LastReplyType = "empty"
    LastPollSucceeded = True
    LastServerError = ""

    ResetPendingEvent()
EndFunction

Function CommitTransportError(String aErrorText)
    LastPollSucceeded = False
    LastServerError = aErrorText
EndFunction

Bool Function HasPendingNpcTalk()
    Return PendingLineToSpeak != ""
EndFunction
