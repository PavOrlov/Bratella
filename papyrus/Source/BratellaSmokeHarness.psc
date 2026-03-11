Scriptname BratellaSmokeHarness extends Quest

BratellaRepository Property Repository Auto
BratellaPollHandler Property PollHandler Auto

String Property EmptyResponseJson Auto
String Property NpcTalkResponseJson Auto

Function RunSmokeSuite()
    Debug.Trace("[BratellaSmokeHarness] RunSmokeSuite started")

    If Repository == None
        Debug.Trace("[BratellaSmokeHarness] Repository is None")
        Return
    EndIf

    If PollHandler == None
        Debug.Trace("[BratellaSmokeHarness] PollHandler is None")
        Return
    EndIf

    Repository.ResetState()
    Debug.Trace("[BratellaSmokeHarness] Repository state reset")

    TestEmptyResponse()
    TestNpcTalkResponse()
    TestDuplicateNpcTalkResponse()

    Debug.Trace("[BratellaSmokeHarness] RunSmokeSuite finished")
EndFunction

Function TestEmptyResponse()
    Debug.Trace("[BratellaSmokeHarness] TestEmptyResponse started")

    PollHandler.HandlePollResponse(EmptyResponseJson)

    Debug.Trace("[BratellaSmokeHarness] LastReplyType=" + Repository.LastReplyType)
    Debug.Trace("[BratellaSmokeHarness] CurrentConversationId=" + Repository.CurrentConversationId)
    Debug.Trace("[BratellaSmokeHarness] LastPollSucceeded=" + Repository.LastPollSucceeded)
    Debug.Trace("[BratellaSmokeHarness] PendingLineToSpeak=" + Repository.PendingLineToSpeak)

    Debug.Trace("[BratellaSmokeHarness] TestEmptyResponse finished")
EndFunction

Function TestNpcTalkResponse()
    Debug.Trace("[BratellaSmokeHarness] TestNpcTalkResponse started")

    PollHandler.HandlePollResponse(NpcTalkResponseJson)

    Debug.Trace("[BratellaSmokeHarness] LastReplyType=" + Repository.LastReplyType)
    Debug.Trace("[BratellaSmokeHarness] CurrentConversationId=" + Repository.CurrentConversationId)
    Debug.Trace("[BratellaSmokeHarness] LastPolledEventId=" + Repository.LastPolledEventId)
    Debug.Trace("[BratellaSmokeHarness] LastSequenceNumber=" + Repository.LastSequenceNumber)
    Debug.Trace("[BratellaSmokeHarness] PendingSpeakerName=" + Repository.PendingSpeakerName)
    Debug.Trace("[BratellaSmokeHarness] PendingSpeakerRefId=" + Repository.PendingSpeakerRefId)
    Debug.Trace("[BratellaSmokeHarness] PendingLineToSpeak=" + Repository.PendingLineToSpeak)
    Debug.Trace("[BratellaSmokeHarness] PendingIsNarration=" + Repository.PendingIsNarration)
    Debug.Trace("[BratellaSmokeHarness] PendingVoiceFile=" + Repository.PendingVoiceFile)
    Debug.Trace("[BratellaSmokeHarness] PendingLineDuration=" + Repository.PendingLineDuration)
    Debug.Trace("[BratellaSmokeHarness] PendingTopicInfoFile=" + Repository.PendingTopicInfoFile)
    Debug.Trace("[BratellaSmokeHarness] PendingActionsJson=" + Repository.PendingActionsJson)

    Debug.Trace("[BratellaSmokeHarness] TestNpcTalkResponse finished")
EndFunction

Function TestDuplicateNpcTalkResponse()
    String beforeEventId = Repository.LastPolledEventId
    Int beforeSequence = Repository.LastSequenceNumber
    String beforeLine = Repository.PendingLineToSpeak

    Debug.Trace("[BratellaSmokeHarness] TestDuplicateNpcTalkResponse started")

    PollHandler.HandlePollResponse(NpcTalkResponseJson)

    Debug.Trace("[BratellaSmokeHarness] BeforeEventId=" + beforeEventId)
    Debug.Trace("[BratellaSmokeHarness] AfterEventId=" + Repository.LastPolledEventId)
    Debug.Trace("[BratellaSmokeHarness] BeforeSequence=" + beforeSequence)
    Debug.Trace("[BratellaSmokeHarness] AfterSequence=" + Repository.LastSequenceNumber)
    Debug.Trace("[BratellaSmokeHarness] BeforeLine=" + beforeLine)
    Debug.Trace("[BratellaSmokeHarness] AfterLine=" + Repository.PendingLineToSpeak)

    Debug.Trace("[BratellaSmokeHarness] TestDuplicateNpcTalkResponse finished")
EndFunction
