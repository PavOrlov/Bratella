Scriptname BratellaPollHandler extends Quest

BratellaRepository Property Repository Auto

Function HandlePollResponse(String aJsonText)
    If Repository == None
        Debug.Trace("[BratellaPollHandler] Repository is None")
        Return
    EndIf

    If aJsonText == ""
        Repository.CommitTransportError("empty response text")
        Debug.Trace("[BratellaPollHandler] empty response text")
        Return
    EndIf

    String replyType = ExtractReplyType(aJsonText)
    String conversationId = ExtractConversationId(aJsonText)

    If replyType == ""
        Repository.CommitTransportError("reply_type missing")
        Debug.Trace("[BratellaPollHandler] reply_type missing")
        Return
    EndIf

    If replyType == "empty"
        Repository.CommitEmptyPoll(conversationId)
        Debug.Trace("[BratellaPollHandler] empty poll for conversation_id=" + conversationId)
        Return
    EndIf

    If replyType == "npc_talk"
        String eventId = ExtractEventId(aJsonText)
        Int sequenceNumber = ExtractSequenceNumber(aJsonText)

        If Repository.IsDuplicateEvent(eventId, sequenceNumber)
            Debug.Trace("[BratellaPollHandler] duplicate event ignored: event_id=" + eventId)
            Return
        EndIf

        String speaker = ExtractSpeaker(aJsonText)
        Int speakerRefId = ExtractSpeakerRefId(aJsonText)
        String lineToSpeak = ExtractLineToSpeak(aJsonText)
        Bool isNarration = ExtractIsNarration(aJsonText)
        String voiceFile = ExtractVoiceFile(aJsonText)
        Float lineDuration = ExtractLineDuration(aJsonText)
        Int topicInfoFile = ExtractTopicInfoFile(aJsonText)
        String actionsJson = ExtractActionsJson(aJsonText)

        Repository.CommitNpcTalkEvent(
            conversationId,
            eventId,
            sequenceNumber,
            speaker,
            speakerRefId,
            lineToSpeak,
            isNarration,
            voiceFile,
            lineDuration,
            topicInfoFile,
            actionsJson
        )

        Debug.Trace("[BratellaPollHandler] npc_talk committed: event_id=" + eventId + ", seq=" + sequenceNumber)
        Return
    EndIf

    Repository.CommitTransportError("unsupported reply_type: " + replyType)
    Debug.Trace("[BratellaPollHandler] unsupported reply_type: " + replyType)
EndFunction

String Function ExtractReplyType(String aJsonText)
    Return ExtractJsonStringValue(aJsonText, "reply_type")
EndFunction

String Function ExtractConversationId(String aJsonText)
    Return ExtractJsonStringValue(aJsonText, "conversation_id")
EndFunction

String Function ExtractEventId(String aJsonText)
    Return ExtractJsonStringValue(aJsonText, "event_id")
EndFunction

Int Function ExtractSequenceNumber(String aJsonText)
    Return ExtractJsonIntValue(aJsonText, "sequence_number")
EndFunction

String Function ExtractSpeaker(String aJsonText)
    Return ExtractJsonStringValue(aJsonText, "speaker")
EndFunction

Int Function ExtractSpeakerRefId(String aJsonText)
    Return ExtractJsonIntValue(aJsonText, "speaker_ref_id")
EndFunction

String Function ExtractLineToSpeak(String aJsonText)
    Return ExtractJsonStringValue(aJsonText, "line_to_speak")
EndFunction

Bool Function ExtractIsNarration(String aJsonText)
    Return ExtractJsonBoolValue(aJsonText, "is_narration")
EndFunction

String Function ExtractVoiceFile(String aJsonText)
    Return ExtractJsonStringValue(aJsonText, "voice_file")
EndFunction

Float Function ExtractLineDuration(String aJsonText)
    Return ExtractJsonFloatValue(aJsonText, "line_duration")
EndFunction

Int Function ExtractTopicInfoFile(String aJsonText)
    Return ExtractJsonIntValue(aJsonText, "topic_info_file")
EndFunction

String Function ExtractActionsJson(String aJsonText)
    Int keyPos = FindKeyStart(aJsonText, "actions")
    If keyPos < 0
        Return ""
    EndIf

    Int arrayStart = FindFrom(aJsonText, "[", keyPos)
    If arrayStart < 0
        Return ""
    EndIf

    Int arrayEnd = FindFrom(aJsonText, "]", arrayStart)
    If arrayEnd < 0
        Return ""
    EndIf

    Return SubstringByIndex(aJsonText, arrayStart, arrayEnd + 1)
EndFunction

Int Function FindKeyStart(String aJsonText, String aKey)
    String token = "\"" + aKey + "\""
    Return StringUtil.Find(aJsonText, token, 0)
EndFunction

Int Function FindFrom(String aText, String aNeedle, Int aStartIndex)
    Return StringUtil.Find(aText, aNeedle, aStartIndex)
EndFunction

String Function ExtractJsonStringValue(String aJsonText, String aKey)
    Int keyPos = FindKeyStart(aJsonText, aKey)
    If keyPos < 0
        Return ""
    EndIf

    Int colonPos = FindFrom(aJsonText, ":", keyPos)
    If colonPos < 0
        Return ""
    EndIf

    Int firstQuote = FindFrom(aJsonText, "\"", colonPos + 1)
    If firstQuote < 0
        Return ""
    EndIf

    Int secondQuote = FindFrom(aJsonText, "\"", firstQuote + 1)
    If secondQuote < 0
        Return ""
    EndIf

    Return SubstringByIndex(aJsonText, firstQuote + 1, secondQuote)
EndFunction

Int Function ExtractJsonIntValue(String aJsonText, String aKey)
    String rawValue = ExtractJsonRawScalar(aJsonText, aKey)
    If rawValue == ""
        Return 0
    EndIf
    Return rawValue as Int
EndFunction

Float Function ExtractJsonFloatValue(String aJsonText, String aKey)
    String rawValue = ExtractJsonRawScalar(aJsonText, aKey)
    If rawValue == ""
        Return 0.0
    EndIf
    Return rawValue as Float
EndFunction

Bool Function ExtractJsonBoolValue(String aJsonText, String aKey)
    String rawValue = ExtractJsonRawScalar(aJsonText, aKey)
    If rawValue == "true"
        Return True
    EndIf
    Return False
EndFunction

String Function ExtractJsonRawScalar(String aJsonText, String aKey)
    Int keyPos = FindKeyStart(aJsonText, aKey)
    If keyPos < 0
        Return ""
    EndIf

    Int colonPos = FindFrom(aJsonText, ":", keyPos)
    If colonPos < 0
        Return ""
    EndIf

    Int valueStart = colonPos + 1
    Int textLength = StringUtil.GetLength(aJsonText)

    While valueStart < textLength
        String c = SubstringByIndex(aJsonText, valueStart, valueStart + 1)
        If c != " " && c != "\t" && c != "\r" && c != "\n"
            ExitWhile
        EndIf
        valueStart += 1
    EndWhile

    Int valueEnd = valueStart
    While valueEnd < textLength
        String c2 = SubstringByIndex(aJsonText, valueEnd, valueEnd + 1)
        If c2 == "," || c2 == "}" || c2 == "]" || c2 == "\r" || c2 == "\n"
            ExitWhile
        EndIf
        valueEnd += 1
    EndWhile

    Return SubstringByIndex(aJsonText, valueStart, valueEnd)
EndFunction

String Function SubstringByIndex(String aText, Int aStartIndex, Int aEndIndex)
    If aStartIndex < 0
        Return ""
    EndIf

    If aEndIndex <= aStartIndex
        Return ""
    EndIf

    Int textLength = StringUtil.GetLength(aText)
    If aStartIndex >= textLength
        Return ""
    EndIf

    If aEndIndex > textLength
        aEndIndex = textLength
    EndIf

    Return StringUtil.Substring(aText, aStartIndex, aEndIndex - aStartIndex)
EndFunction
