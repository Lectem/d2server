/* ==========================================================
 * d2warden
 * https://github.com/lolet/d2warden
 * ==========================================================
 * Copyright 2013 lolet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */

#include "stdafx.h"
#include "LEvents.h"
#include "LRoster.h"

void __stdcall OnBroadcastEvent(Game* pGame, EventPacket * pEvent)
{
	DEBUGMSG("OnBroadcastEvent %d",pEvent->MsgType);
	if(pGame) {
		if(pGame->bFestivalMode == 1)
			if(pEvent->MsgType == 0 || pEvent->MsgType == 1 || pEvent->MsgType == 3) // Leave msgs 
			{
				DEBUGMSG("DEBUG: Szukam struktury ClientData z nazwa %s",pEvent->Name1);

				ClientData* pClient = FindClientDataByName(pGame,pEvent->Name1);
				if(pClient) {
					if(pClient->pPlayerUnit->pPlayerData->isPlaying == 0)  return;
					DoRoundEndStuff(pGame, pClient->pPlayerUnit);
				}
				else DEBUGMSG("Nie znalazlem struktury WardenClient w %s",__FUNCTION__);
			}
			if(pEvent->MsgType == 2) // Join packet
			{
				ClientData* pClient = FindClientDataByName(pGame,pEvent->Name1);
				if(pClient) {
					LRost::SyncClient(pGame,pClient);
					LRoster* pRoster = LRost::Find(pGame,pEvent->Name1);
					if(pRoster && pClient->pPlayerUnit) {
						LRost::SyncClient(pGame,pClient->pPlayerUnit->dwUnitId,pRoster);
					}
				}
			}
	BroadcastPacket(pGame,(BYTE*)pEvent,40);
	}

}


void DoRoundEndStuff(Game* pGame, UnitAny* pUnit) //Sprawdz czy wskaznik jest ok przed wywolaniem, WardenClient = Victim
{
	DEBUGMSG("DEBUG: Robie DoRoundEndStuff");
	if(!pGame || !pUnit) return;

	ostringstream str; 
	string wynik;

	short P1Out = 0,P2Out = 0;
	int P1ID = 0, P2ID = 0;
	int vPID = D2Funcs::D2GAME_GetPartyID(pUnit);

	if(pGame->nPlaying == 0) return;

	for(ClientData* pClient = pGame->pClientList; pClient; pClient = pClient->ptPrevious) {
		if(!pClient->pPlayerUnit) continue;
		if(pClient->InitStatus != 4) continue;
		
		if(pClient->pPlayerUnit->pPlayerData->isPlaying == 1) {
			Room1* pRoom = D2Funcs::D2COMMON_GetUnitRoom(pClient->pPlayerUnit);
			if(!pRoom) continue;
			if(D2Funcs::D2COMMON_GetLevelNoByRoom(pRoom) != D2Funcs::D2COMMON_GetTownLevel(pClient->pPlayerUnit->dwAct))
			{
			int pId = D2Funcs::D2GAME_GetPartyID(pClient->pPlayerUnit);
			if(pId != -1 && P1ID == 0) P1ID = pId;
			else if(pId != -1 && P1ID && pId != P1ID && P2ID == 0) P2ID = pId;

			if(pId != -1 && pClient->pPlayerUnit->dwMode != PLAYER_MODE_DEAD && pClient->pPlayerUnit->dwMode != PLAYER_MODE_DEATH) {
				if(pId == P1ID) P1Out++;
				else if(pId == P2ID) P2Out++;
			}
		}
		}
	}

	DEBUGMSG("Party %d Out = %d, Party %d Out = %d,  Victim Party Id = %d ", P1ID, P1Out,  P2ID, P2Out,  vPID);

	if((P1ID == 0) || (P1Out == 0 || P2Out == 0)) {
		for(ClientData* pClient = pGame->pClientList; pClient; pClient = pClient->ptPrevious)
		{
			if(!pClient->pPlayerUnit) continue;
			if(pClient->InitStatus != 4) continue;

			if(pClient->pPlayerUnit->pPlayerData->isPlaying == 1)
			if(pClient->pPlayerUnit->dwMode != PLAYER_MODE_DEAD && pClient->pPlayerUnit->dwMode != PLAYER_MODE_DEATH)
			{
				int aLevel = D2Funcs::D2COMMON_GetTownLevel(pClient->pPlayerUnit->dwAct);
				int aCurrLevel = D2Funcs::D2COMMON_GetLevelNoByRoom(pClient->pPlayerUnit->pPath->pRoom1);
				if(aCurrLevel!=aLevel)
					D2Funcs::D2GAME_MoveUnitToLevelId(pClient->pPlayerUnit,aLevel,pGame);
			}

		}
		pGame->nPlaying = 0;
		ClearSayGoFlag(pGame);
		ClearCanAttackFlag(pGame);
		ClearIsPlayingFlag(pGame);
		BroadcastExEvent(pGame,1,0,3,-1,200, "Runda zakonczona!", "Round end!");
	}

}