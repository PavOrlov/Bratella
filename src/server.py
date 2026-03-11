from __future__ import annotations

import json
from pathlib import Path
from uuid import uuid4

import tomli
from fastapi import FastAPI, HTTPException, Response

CONFIG_PATH = Path("config/default.toml")
if CONFIG_PATH.exists():
    with CONFIG_PATH.open("rb") as f:
        CONFIG = tomli.load(f)
else:
    CONFIG = {}

app = FastAPI(title="Bratella Mini", version="0.1.3")
STATE: dict[str, dict] = {}


def utf8_json(data: dict) -> Response:
    return Response(
        content=json.dumps(data, ensure_ascii=False),
        media_type="application/json; charset=utf-8",
    )


@app.get("/health")
async def health():
    return utf8_json({"status": "ok"})


@app.post("/game")
async def game(payload: dict):
    request_type = payload.get("request_type")

    if request_type == "start_conversation":
        conversation_id = payload.get("conversation_id") or str(uuid4())

        STATE[conversation_id] = {
            "conversation_id": conversation_id,
            "actors": payload.get("actors", []),
            "context": payload.get("context", {}),
            "last_player_input": "",
            "queue": [],
            "next_sequence_number": 1,
            "consumed_events": [],
        }

        return utf8_json({
            "reply_type": "accepted",
            "conversation_id": conversation_id,
            "accepted": True,
            "message": "start accepted",
        })

    if request_type == "player_input":
        conversation_id = payload.get("conversation_id")
        if not conversation_id or conversation_id not in STATE:
            raise HTTPException(status_code=404, detail="conversation not found")

        STATE[conversation_id]["last_player_input"] = payload.get("player_input", "")
        if "context" in payload:
            STATE[conversation_id]["context"] = payload["context"]

        actors = STATE[conversation_id].get("actors", [])
        first_actor = actors[0] if actors else {}
        speaker = first_actor.get("name", "Hadvar")
        speaker_ref_id = first_actor.get("ref_id", 0)
        player_text = STATE[conversation_id]["last_player_input"].strip()
        sequence_number = STATE[conversation_id].get("next_sequence_number", 1)

        fake_event = {
            "reply_type": "npc_talk",
            "conversation_id": conversation_id,
            "event_id": str(uuid4()),
            "sequence_number": sequence_number,
            "actor_talk": {
                "speaker": speaker,
                "speaker_ref_id": speaker_ref_id,
                "line_to_speak": f"Принято. Ты сказал: {player_text}" if player_text else "Принято.",
                "is_narration": False,
                "voice_file": "",
                "line_duration": 0.0,
                "actions": [],
                "topic_info_file": 0,
            },
        }

        STATE[conversation_id]["queue"].append(fake_event)
        STATE[conversation_id]["next_sequence_number"] = sequence_number + 1

        return utf8_json({
            "reply_type": "accepted",
            "conversation_id": conversation_id,
            "accepted": True,
            "message": "player_input accepted",
        })

    if request_type == "end_conversation":
        conversation_id = payload.get("conversation_id")
        if conversation_id:
            STATE.pop(conversation_id, None)

        return utf8_json({
            "reply_type": "accepted",
            "conversation_id": conversation_id or "",
            "accepted": True,
            "message": "end accepted",
        })

    raise HTTPException(status_code=400, detail="unknown request_type")


@app.get("/events/next")
async def events_next(conversation_id: str):
    state = STATE.get(conversation_id)
    if not state or not state["queue"]:
        return utf8_json({
            "reply_type": "empty",
            "conversation_id": conversation_id,
            "event_available": False,
        })

    event = state["queue"].pop(0)

    state.setdefault("consumed_events", []).append({
        "event_id": event.get("event_id"),
        "sequence_number": event.get("sequence_number"),
        "reply_type": event.get("reply_type"),
    })
    state["consumed_events"] = state["consumed_events"][-20:]

    return utf8_json(event)


@app.get("/debug/state")
async def debug_state():
    conversations = {}

    for conversation_id, state in STATE.items():
        conversations[conversation_id] = {
            "conversation_id": state.get("conversation_id"),
            "actors": state.get("actors", []),
            "context": state.get("context", {}),
            "last_player_input": state.get("last_player_input", ""),
            "next_sequence_number": state.get("next_sequence_number", 1),
            "queue_length": len(state.get("queue", [])),
            "queue_preview": state.get("queue", [])[:3],
            "consumed_events": state.get("consumed_events", []),
        }

    return utf8_json({
        "conversation_count": len(STATE),
        "conversation_ids": list(STATE.keys()),
        "conversations": conversations,
    })
