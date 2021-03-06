;TODO:
; 1. Fix diablowall skill cpu usage bug
; 2. Tiny Warden enchance
; 3. Treasure Class计算优化，尤其是NoDrop浮点运算
; 4. 伤害计算过程优化
; 5. Uber里面的召唤物，被杀死后，尸体应当尽快消失掉
; 6. 所有曲线的Missile均调用D2COMMON_10945进行浮点运算，优化？

        .486
        .model flat, stdcall
        option casemap:none   ; case sensitive
; Code Start from 68021000h
.code
; Please DONT TOUCH the following code, their offsets are very important!!
MyPatchInitOffset dd offset MyPatchInit
MyPatchInitOffset2 dd offset MyPatchInit2
LoadMyConfigOffset dd offset LoadMyConfig
ShowSOJMessageCheckerOffset dd offset ShowSOJMessageChecker		; d2server.dll 68005AAB
DualAuraPatchOffset dd offset NewDualAuraPatch
MyInitGameHandlerOffset	dd offset MyInitGameHandler			;d2server.dll 68006539
MyPacket0X68HandlerOffset	dd offset MyPacket0X68Handler	;0x18
MyPacket0X66HandlerOffset	dd 0; MyPacket0X66Handler	;0x1C
TradePlayerAuraBugPatchOffset dd offset TradePlayerAuraBugPatch
SingleRoomDCPatchOffset dd offset SingleRoomDCPatch
dummy6 dd 0
dummy7 dd 0
dummy8 dd 0
dummy9 dd 0

;LevelGame Callback在1.10中拥有15个参数，而现在1.11b中，拥有20个参数！需要修正！
;d2server.dll : 68007558
cb_leavegame proc
	mov eax,[esp+48h] ; esi+190
	mov [esp+34h],eax ; 第5个零 存放esi+190
	pop eax ; retaddr
	mov [esp+34h],eax ; 第4个零 存放retaddr
	call cb_leavegame_orig ; 调用原来的回调函数
	ret 10h	 ; 注意修正返回堆栈！！
cb_leavegame endp

;释放掉ExtendGameInfoStruct
;d2server.dll : 6800109C
MyCleanupHandler proc
	pushad
	xor esi,esi
	xor ebx,ebx
next_game:
	push esi
	call GetGameInfo
	add esp,4
	test eax,eax
	jz next_game_increase
	mov	esi,eax
	mov eax,[esi+4]
	test eax,eax
	jz next_game_increase
	push eax
	mov eax,free
	mov eax,[eax]
	call eax
	add esp,4
	mov [esi+4],ebx
next_game_increase:
	inc esi
	cmp	si,402h
	jb short next_game
	popad
	
	call D2GSCleanup
	ret
MyCleanupHandler endp

; OK, you can add your stuff here...
aMyLogo db 'Version 1.13d patch build 2 by lolet. Based on original work by marsgod for patch 1.11b.',0
aD2Server db 'D2Server1.13d',0 
D2COMMON_11103_GetpPlayerDataFromUnit	dd 0 ;1.13d
D2COMMON_10292_GetInvItemByBodyLoc	dd 0 ;1.13d
D2COMMON_10632_GetRoom1	dd 0 ; 1.13d
D2COMMON_10706_GetUnitState	dd 0 ;1.13d
D2COMMON_10550_GetUnitStat	dd 0 ;1.13d
D2Common_10193_ChangeCurrentMode	dd 0 ; 1.13d
D2Common_10590_SetStat dd 0 ; 1.13d fo' so
D2GAME_0C04F0_DeleteTimer dd 0

;internal useage...
cb_leavegame_orig dd 68007310h ; +04
cb_leavegame_entry dd 68013564h
cb_closegame_orig dd 680072E0h ; +00
cb_GetDatabaseCharacter_orig dd 68007360h ; +08
cb_SaveDatabaseCharacter_orig dd 68007390h ; +0C
cb_EnterGame_orig dd 680073C0h ; +14
cb_FindPlayerToken_orig dd 680073E0h ; +18
cb_UpdateCharacterLadder_orig dd 68007450h ; +28
cb_UpdateGameInformation_orig dd 68007480h ; +2C
cb_UnlockDatabaseCharacter_orig dd 680074C0h ;+1C
D2GSPreInit		dd	680010C0h
D2GSInit			dd	680013F0h
D2GSCleanup		dd	68001760h
GetProcAddr		dd	6800B03Ch
D2COMMON			dd	68010F20h
D2GAME				dd	68010F1Ch
D2NET					dd	68010F24h
GetGameInfo		dd	680064E8h
SendSystemMessage dd 68005B20h
malloc				dd	6800B190h
free					dd	6800B18Ch

GetModuleHandleA	dd 6800B028h
LoadLibraryA	dd 6800B018h
FreeLibrary	dd 0040C060h
CreateEventA	dd 0040C024h
SetEvent	dd 6800B010h
WaitForSingleObject	dd 0040C014h
CreateMutexA	dd 0040C044h
CloseHandle	dd 0040C07Ch
CreateThread	dd 0040C018h
GetExitCodeThread	dd 0040C02Ch
TerminateThread	dd 0040C04Ch
Sleep	dd 0040C01Ch
InitializeCriticalSection	dd 0040C040h
EnterCriticalSection	dd 0040C090h
LeaveCriticalSection	dd 0040C080h
DeleteCriticalSection	dd 0040C050h
VirtualProtect dd 6800B040h
GetRandomNumber	dd 680055A0h
sub_68005A10	dd 68005A10h
SOJ_Counter	dd 680145E8h
;D2Game_LeaveCriticalSection	dd 68014644h
D2Game_SysPacketHandling dd 68014618h

D2GS_EventLog_off dd 6800D7D0h
D2GSStrCat dd 68007DF0h
GetConfigString dd 68007DA0h
EnableDebugDumpThread dd 68013554h
_strtoul dd 6800B188h
sub_68004870 dd 68004870h
LoadWorldEventConfigFileOffset dd 68007D94h

aSpawnProbability db 'SpawnProbability',0
aMaxSpawnNum db 'MaxSpawnNum',0
aSpawnInterv db 'SpawnInterval',0
aActivArea db 'ActivArea',0
aStallTime db 'StallTime',0
aSpawnMonsters db 'SpawnMonsters',0
aSplit db ', ',0

aUberMephisto db 'UberMephisto',0
aUberDiablo db 'UberDiablo',0

aSpawnMinions db 'SpawnMinions',0
SpawnMinions dd 0

aWorldEvent db 'World Event',0
aDcItemRate db 'DcItemRate',0
aShowSOJMessage db 'ShowSOJMessage',0
aShowSOJMessageDisabledMsg db 'SOJ Message Disabled.',0

ShowSOJMessage dd 0
DcItemRate dd 0

aEnableWarden db 'EnableWarden',0
aWardenEnableMsg db 'Warden Enabled.',0
EnableWarden dd 0

;Other configuration
aNewFeatures db 'NewFeatures',0

aEnableMeleeHireableAI db 'EnableMeleeHireableAI',0
aMeleeHireableAIEnableMsg db 'Act2 & Act5 MeleeHireableAIFix Enabled, when IM, no attack.',0
EnableMeleeHireableAI dd 0
aEnableNeroPetAI db 'EnableNeroPetAI',0
aNeroPetAIEnableMsg db 'NeroPetAIFix Enabled, when IM, no attack.',0
EnableNeroPetAI dd 0
aEnableExpGlitchFix db 'EnableExpGlitchFix',0
aExpGlitchFixEnableMsg db 'ExpGlitchFix Enabled.',0
EnableExpGlitchFix dd 0
aDisableUberUp db 'DisableUberUp',0
aUberUpDisableMsg db 'UberUp Disabled.',0
DisableUberUp dd 0

aEnableUnicodeCharName db 'EnableUnicodeCharName',0
aEnableUnicodeCharNameMsg db 'Unicode Char Name Enabled.',0
EnableUnicodeCharName dd 0

aEnablePreCalculateTCNoDropTbl db 'EnablePreCalculateTCNoDropTbl',0
aEnablePreCalculateTCNoDropTblMsg db 'PreCalculate TC NoDropTbl Enabled.',0
EnablePreCalculateTCNoDropTbl dd 0

aEnableEthSocketBugFix db 'EnableEthSocketBugFix',0
aEnableEthSocketBugFixMsg db 'EthSocketBugFix Enabled.',0
EnableEthSocketBugFix dd 0

aDisableBugMF db 'DisableBugMF',0
aDisableBugMFMsg db 'BugMF Disabled.',0
DisableBugMF dd 0

aDisableDCSpawnInSomeArea db 'DisableDCSpawnInSomeArea',0
aDisableDCSpawnInSomeAreaMsg db 'DC will not spawn in some area.'
DisableDCSpawnInSomeArea dd 0

D2GamePatched dd 0
aD2GamePatchedMsg db 'D2Game is already patched.',0

D2GS_OnPacketRecv_OFF   dd 6800D9B8h ; d2game.dll 6FC903B6
D2GS_OnCreatePacket_OFF dd 6800D9BCh ; d2game.dll 6FD0832F
D2GS_SaveChar_OFF       dd 6800F9A4h ; d2game.dll 6FC4557F
D2GS_OnGameAdd_OFF      dd 6800F9A8h ; d2game.dll 6FD0818C
D2GS_OnEachClient_OFF   dd 6800F9ACh ; d2game.dll 6FD0744A
D2GS_OnItemSell_OFF     dd 6800F980h ; d2game.dll 6FCB2859 used for DC <- probably wil be removed
D2GS_OnUniqMonSpawn_OFF dd 6800F984h ; d2game.dll 6FD0CF10 used for DC
D2GS_OnPacketRecv_OLD	dd 0
D2GS_OnCreatePacket_ORG	dd 0
D2GS_SaveChar_ORG	    dd 0
D2GS_OnGameAdd_ORG	    dd 0
D2GS_OnEachClient_ORG	dd 0
D2GS_OnItemSell_ORG 	dd 0
D2GS_OnUniqMonSpawn_ORG	dd 0


D2CLIENT_pGameList 	            dd 6801467Ch	;d2client.dll	6FB7D5C1
D2GAME_ParseIncomingPackets 	dd 68014658h	;d2game.dll		6FC903B6
D2GAME_ParseCreatePackets 	    dd 68014618h	;d2game.dll		6FD0832F
D2GAME_GetClientById 	        dd 68014638h	;d2game.dll		6FD04A30
D2GAME_GetClientDataByClientID 	dd 68014610h	;d2game.dll		6FCE4C40
D2GAME_LeaveCriticalSection 	dd 68014644h	;d2game.dll		6FD03AD0
D2GAME_SendPacket 	            dd 68014604h	;d2game.dll		6FC3C710
D2GAME_UNIT_GetClientData 	    dd 6801460Ch	;d2game.dll		6FCBC2E0
D2GAME_GetUnitInteractionStatus dd 68014668h	;d2game.dll		6FCBD820
D2GAME_FindUnit 	            dd 68014640h	;d2game.dll		6FCBBB00
D2GAME_D2S_Save 	            dd 68014650h	;d2game.dll		6FC4557F
D2GAME_ParseEvents          	dd 68014678h	;d2game.dll		6FD0818C
D2GAME_DispatchPacketsToClient 	dd 6801462Ch	;d2game.dll		6FD0744A
D2GAME_SavePlayer 	            dd 6801463Ch	;d2game.dll		6FC8A500
D2GAME_FindUnitByClientData 	dd 68014654h	;d2game.dll		6FC31E20
D2GAME_ForEach               	dd 6801465Ch	;d2game.dll		6FC3B0E0
D2GAME_GetGameSocketListByToken dd 68014684h	;d2game.dll		6FC35840
D2GAME_GetGameBySocket          dd 68014670h	;d2game.dll		6FD049A0
D2GAME_DupeItem              	dd 6801468Ch	;d2game.dll		6FC51070
D2COMMON_TestItemFlag       	dd 6801461Ch	;d2game.dll		6FCB2858
D2GAME_SpawnMonster 	        dd 68014660h	;d2game.dll		6FD0CF10

dword_save_func00	dd 0	;d2client.dll	6FB7D5C1
D2GAME_ParseIncomingPackets_OLD dd 0	;d2game.dll		6FC903B6
D2GAME_ParseCreatePackets_OLD	dd 0	;d2game.dll		6FD0832F
D2GAME_GetGameByClientID_OLD	dd 0	;d2game.dll		6FD04A30
D2GAME_GetClientDataByClientID_OLD	dd 0;d2game.dll		6FCE4C40
D2GAME_LeaveCriticalSection_OLD	dd 0	;d2game.dll		6FD03AD0
D2GAME_SendPacket_OLD	dd 0	;d2game.dll		6FC3C710
D2GAME_UNIT_GetClientData_OLD	dd 0	;d2game.dll		6FCBC2E0	; nocall 0
D2GAME_GetUnitInteractionStatus_OLD	dd 0	;d2game.dll		6FCBD820
D2GAME_FindUnit_OLD	dd 0	;d2game.dll		6FCBBB00
D2GAME_D2S_Save_OLD	dd 0	;d2game.dll		6FC4557F
D2GAME_ParseEvents_OLD	dd 0	;d2game.dll		6FD0818C
D2GAME_DispatchPacketsToClient_OLD	dd 0	;d2game.dll		6FD0744A
D2GAME_SavePlayer_OLD	dd 0	;d2game.dll		6FC8A500
D2GAME_FindUnitByClientData_OLD	dd 0	;d2game.dll		6FC31E20
D2GAME_ForEach_OLD	dd 0	;d2game.dll		6FC3B0E0
D2GAME_GetGameSocketListByToken_OLD	dd 0	;d2game.dll		6FC35840
D2GAME_GetGameBySocket_OLD	dd 0	;d2game.dll		6FD049A0
D2GAME_DupeItem_OLD	dd 0	;d2game.dll		6FC51070
D2COMMON_TestItemFlag_OLD	dd 0	;d2game.dll		6FCB2858
D2GAME_SpawnMonster_OLD	dd 0	;d2game.dll		6FD0CF10

dword_fog_patch00	dd 6800DCC4h; patch length to 6
dword_fog_patch01	dd 6800DCC8h; patch offset
dword_fog_patch02 db 59h, 58h, 51h, 33h, 0C0h, 0C3h ; patch code

ExtendGameInfoStruct struc
	rand_l dd ?
	rand_h dd ?
	PortalOpenedFlag dd ?
	BOSS_A_AREA	dd ?
	BOSS_B_AREA	dd ?
	BOSS_C_AREA	dd ?
	BOSS_D0_AREA	dd ?
	BOSS_D1_AREA	dd ?
	BOSS_D2_AREA	dd ?
	Diablo_rand_l	dd ?
	Diablo_rand_h	dd ?
	Meph_rand_l	dd ?
	Meph_rand_h	dd ?
	LoD_Game	dd ?
ExtendGameInfoStruct ends

start:

MyPatchInit proc

	xor eax,eax
	mov D2GamePatched,eax		; 初始化D2GamePatched为False，防止多次对D2Game进行补丁

	; Announce my version first
	pushad
	push    offset aMyLogo
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	popad
	push ecx
	
	; Patch the Fog.dll 6FF65CD0h , this should be done before D2GSPreInit!
	; pop ecx  ; return address
	; pop eax  ; arg_0
	; push ecx
	; xor eax,eax
	; ret
	
	mov eax,dword_fog_patch00
	mov ecx,6
	mov [eax],ecx
	mov eax,dword_fog_patch01
	mov ecx,offset dword_fog_patch02
	mov [eax],ecx
	
; setup D2GAME CallBack Hook before D2GSPreInit!
; 07.01.2015 <- handled by d2warden
;	mov ecx, D2GS_OnPacketRecv_OFF
;	mov eax,[ecx]
;	mov D2GS_OnPacketRecv_OLD,eax
;	mov eax,offset D2GS_OnPacketRecv_STUB
;	mov [ecx],eax
	
;	mov ecx, D2GS_OnCreatePacket_OFF
;	mov eax,[ecx]
;	mov D2GS_OnCreatePacket_ORG,eax
;	mov eax,offset D2GS_OnCreatePacket_STUB
;	mov [ecx],eax
	
	mov ecx, D2GS_SaveChar_OFF
	mov eax,[ecx]
	mov D2GS_SaveChar_ORG,eax
	mov eax,offset D2GS_CharSave_STUB
	mov [ecx],eax
	
	mov ecx, D2GS_OnGameAdd_OFF
	mov eax,[ecx]
	mov D2GS_OnGameAdd_ORG,eax
	mov eax,offset D2GS_OnGameAdd_STUB
	mov [ecx],eax
	
	mov ecx, D2GS_OnEachClient_OFF
	mov eax,[ecx]
	mov D2GS_OnEachClient_ORG,eax
	mov eax,offset D2GS_OnEachClient_STUB
	mov [ecx],eax
	
	mov ecx, D2GS_OnItemSell_OFF
	mov eax,[ecx]
	mov D2GS_OnItemSell_ORG,eax
	mov eax,offset D2GS_OnItemSell_STUB
	mov [ecx],eax
	
	mov ecx, D2GS_OnUniqMonSpawn_OFF
	;mov eax,[ecx]
	mov eax,MyCheckSpawnDiabloClone
	mov D2GS_OnUniqMonSpawn_ORG,eax
	mov eax,offset D2GS_OnUniqMonSpawn_STUB
	mov [ecx],eax


	; OK, let's init the d2server
	mov eax,68010EF0h
	mov [eax],esi
	call D2GSPreInit
	push eax
	
	push 11103
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2COMMON_11103_GetpPlayerDataFromUnit,eax

	push 10292
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2COMMON_10292_GetInvItemByBodyLoc,eax

	push 10706
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2COMMON_10706_GetUnitState,eax

	push 10550
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2COMMON_10550_GetUnitStat,eax

	push 10193
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2Common_10193_ChangeCurrentMode,eax

	push 10590
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2Common_10590_SetStat,eax

	push 10632
	mov eax,D2COMMON
	mov eax,[eax]
	push eax
	mov eax,6800B03Ch
	mov eax,[eax]
	call eax; GetProcAddr
	mov D2COMMON_10632_GetRoom1,eax

; Call D2Game
;	mov ecx, D2CLIENT_pGameList
; mov eax,[ecx]
;	mov dword_save_func00,eax
; mov eax,offset stub_func00
;	mov [ecx],eax

	mov ecx, D2GAME_ParseIncomingPackets
	mov eax,[ecx]
	mov D2GAME_ParseIncomingPackets_OLD,eax
	mov eax,offset D2GAME_ParseIncomingPackets_STUB
	mov [ecx],eax

	 mov ecx, D2GAME_ParseCreatePackets
	 mov eax,[ecx]
	 mov D2GAME_ParseCreatePackets_OLD,eax
	 mov eax,offset D2GAME_ParseCreatePackets_STUB
	 mov [ecx],eax

	mov ecx, D2GAME_GetClientById
	mov eax,[ecx]
	mov D2GAME_GetGameByClientID_OLD,eax
	mov eax,offset D2GAME_GetGameByClientID_STUB
	mov [ecx],eax

	mov ecx, D2GAME_GetClientDataByClientID
	mov eax,[ecx]
	mov D2GAME_GetClientDataByClientID_OLD,eax
	mov eax,offset D2GAME_GetClientDataByClientID_STUB
	mov [ecx],eax

	mov ecx, D2GAME_LeaveCriticalSection
	mov eax,[ecx]
	mov D2GAME_LeaveCriticalSection_OLD,eax
	mov eax,offset D2GAME_LeaveCriticalSection_STUB
	mov [ecx],eax

	mov ecx, D2GAME_SendPacket
	mov eax,[ecx]
	mov D2GAME_SendPacket_OLD,eax
	mov eax,offset D2GAME_SendPacket_STUB
	mov [ecx],eax

	mov ecx, D2GAME_UNIT_GetClientData
	mov eax,[ecx]
	mov D2GAME_UNIT_GetClientData_OLD,eax
	mov eax,offset D2GAME_UNIT_GetClientData_STUB
	mov [ecx],eax

	mov ecx, D2GAME_GetUnitInteractionStatus
	mov eax,[ecx]
	mov D2GAME_GetUnitInteractionStatus_OLD,eax
	mov eax,offset D2GAME_GetUnitInteractionStatus_STUB
	mov [ecx],eax

	mov ecx, D2GAME_FindUnit
	mov eax,[ecx]
	mov D2GAME_FindUnit_OLD,eax
	mov eax,offset D2GAME_FindUnit_STUB
	mov [ecx],eax

	mov ecx, D2GAME_D2S_Save
	mov eax,[ecx]
	mov D2GAME_D2S_Save_OLD,eax
	mov eax,offset D2GAME_D2S_Save_STUB
	mov [ecx],eax

	mov ecx, D2GAME_ParseEvents
	mov eax,[ecx]
	mov D2GAME_ParseEvents_OLD,eax
	mov eax,offset D2GAME_ParseEvents_STUB
	mov [ecx],eax

	mov ecx, D2GAME_DispatchPacketsToClient
	mov eax,[ecx]
	mov D2GAME_DispatchPacketsToClient_OLD,eax
	mov eax,offset D2GAME_DispatchPacketsToClient_STUB
	mov [ecx],eax

	mov ecx, D2GAME_SavePlayer
	mov eax,[ecx]
	mov D2GAME_SavePlayer_OLD,eax
	mov eax,offset D2GAME_SavePlayer_STUB
	mov [ecx],eax

	mov ecx, D2GAME_FindUnitByClientData
	mov eax,[ecx]
	mov D2GAME_FindUnitByClientData_OLD,eax
	mov eax,offset D2GAME_FindUnitByClientData_STUB
	mov [ecx],eax

	mov ecx, D2GAME_ForEach
	mov eax,[ecx]
	mov D2GAME_ForEach_OLD,eax
	mov eax,offset D2GAME_ForEach_STUB
	mov [ecx],eax

	mov ecx, D2GAME_GetGameSocketListByToken
	mov eax,[ecx]
	mov D2GAME_GetGameSocketListByToken_OLD,eax
	mov eax,offset D2GAME_GetGameSocketListByToken_STUB
	mov [ecx],eax

	mov ecx, D2GAME_GetGameBySocket
	mov eax,[ecx]
	mov D2GAME_GetGameBySocket_OLD,eax
	mov eax,offset D2GAME_GetGameBySocket_STUB
	mov [ecx],eax

	mov ecx, D2GAME_DupeItem
	mov eax,[ecx]
	mov D2GAME_DupeItem_OLD,eax
	mov eax,offset D2GAME_DupeItem_STUB
	mov [ecx],eax

	mov ecx, D2COMMON_TestItemFlag
	mov eax,[ecx]
	mov D2COMMON_TestItemFlag_OLD,eax
	mov eax,offset D2COMMON_TestItemFlag_STUB
	mov [ecx],eax

	mov ecx, D2GAME_SpawnMonster
	mov eax,[ecx]
	mov D2GAME_SpawnMonster_OLD,eax
	mov eax,offset D2GAME_SpawnMonster_STUB
	mov [ecx],eax
	
	; for warden patch 0x68,0x66 packet handler
;	mov ecx,68003815h	; system packet handler
;	mov eax,offset MyPacket0X68Handler

; @bj: not needed anymore (handled in d2warden)
;	mov ecx,6800F31Ch	; packet 0x68 handler 68003AC0
;	mov eax,offset MyPacket0X68Handler
;	mov [ecx],eax

	call UberQuestPatchInit

	pop eax
	pop ecx
	ret
MyPatchInit endp

; After D2GS init, patch it
MyPatchInit2 proc
	call D2GSInit
	test eax,eax
	jnz	continue
	pop eax
	xor eax,eax
	push 68001054h
	ret
continue:
	;将CallBack函数设置为NULL
	push ebx
	mov eax,680135A0h
	xor ebx,ebx
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	add eax,4
	mov [eax],ebx
	mov eax,680135B4h
	mov ebx,68001A90h	;nullsub_1 <-- this should be get file time EventCallbackTable func +54h
	mov [eax],ebx
	pop ebx
	call Patch_sgptDataTables

over:	
	pop eax
	push 6800106Dh
	ret
MyPatchInit2 endp


D2GamePatch proc
	pushad
	mov esi,D2GAME
	mov esi,[esi]
	push esi
	push 0
	call UnProtectDLL2
	
	; 1.13 CompareFileTime workaround -> skipping cause Warden patches that in better way (commented out 29.04.2015)
	;mov	ecx,esi
	;add	ecx, 024F0Ah		;6FC44F35 7E14
	;mov	ax, 053EBh
	;mov	word ptr[ecx],ax
    
	; for warden patch 0x68,0x66 packet handler
	;mov ecx,esi
	;add ecx,0FA9C8h		; packet 0x66 handler .113d
	;mov eax,offset MyPacket0X66Handler
	;mov [ecx],eax
	
;Town TP corpse crash bug patch
;Creating a town portal when corpses or other objects entirely fill the area where the portal will appear in town will no longer crash the game. 
;68022800
;D2Game.dll	0X10AD9	DD9EFFFF	231D3FF8	0 #6FC30AD9 = Patch Call Offset(x-6FC30ADD)
;	mov ecx,esi
;	add ecx,1602Bh ; 1.13d
;	mov eax,offset TPCrashBugPatch
;	sub eax,ecx
;	sub eax,4
;	mov [ecx],eax

;Dual Aura Bug Patch(This include the PET & Player)
;When the item remove from pet or player, the aura event is not removed from the unit.
;D2Game.dll	0X7604C	6A098BC7E80BAEFFFF	FF1510100268909090	0 #6FC9604C(7604C) remove the aura event from unit
;call    DestroyAuraEventHandler->call NewDualAuraPatch
; TODO: Add NewDualAuraPatch for 1.13c
;	mov ecx,esi
;	add ecx,7604Ch
;	mov eax,101015FFh
;	mov [ecx],eax
;	add ecx,4
;	mov eax,90906802h
;	mov [ecx],eax
;	add ecx,4
;	mov eax,245C8B90h
;	mov [ecx],eax

;Missile_DO_diabwallmaker Patch
;D2Game.dll	0X104B80	60F9CB6F	F0DFCB6F	3 #6FD24B80(11C4B80) replace Missile_DO_diabwallmaker with Missile_DO_01
	mov ecx,esi
	add ecx, 108448h ; 1.13d, was 104B80h
	mov eax, 434A0h ; 1.13d, was 9DFF0h
	add eax,esi
	mov [ecx],eax

;Carry1 Trade Patch(for USC\ULC\UGC trade), skip the carry1 check in trade
;D2Game.dll	0X36D85	740A	EB0A	0 #6FC56D85(10F6D85)
;	mov ecx,esi
;	add ecx,36D84h
;	mov eax,0C70AEBC0h
;	mov [ecx],eax



	mov eax,EnableExpGlitchFix
	test eax,eax
	jz no_EnableExpGlitchFix
;ExpGlitchFix
;D2Game.dll	0X7E021	E9 ExpGlitchFix	0 #6FC9E021
	pushad
	
	mov eax,offset ExpGlitchFixEnd
	mov ebx,offset ExpGlitchFix
	sub eax,ebx
	; eax has the size of proc ExpGlitchFix
	mov edi,eax
	
	;7E0AC
	mov ecx,esi
	add ecx, 08A42Dh ; 1.13d 7E0ADh
	sub ecx,eax
	
	;ecx has the start address of ExpGlitchFix
	mov ebx,ecx	; save start address
	
	; patch first jnz at 6FC9E021
	mov eax,esi
	add eax, 08A3A1h ; 1.13d 7E021h
	sub ecx,eax
	dec ecx
	mov byte ptr[eax],cl
	
	; patch last jl at 6FC9E0CA
	mov eax,esi
	add eax, 08A44Ah ; .1.13d 7E0CAh
	mov byte ptr[eax],0D0h

;transfer ExpGlitchFix to target
	mov ecx,edi
	mov esi,offset ExpGlitchFix
	mov edi,ebx
	rep movsb
	popad

no_EnableExpGlitchFix:

	mov eax,EnableMeleeHireableAI
	test eax,eax
	jz no_EnableMeleeHireableAI
;D2Game.dll	0X67F99	MeleePetAIFix	0 #6FC87F99
	mov ecx,esi
	add ecx, 0B0309h; 1.3d 67F99h
	mov byte ptr[ecx],0E8h
	inc ecx
	mov eax,offset MeleePetAIFix
	sub eax,ecx
	sub eax,4
	mov [ecx],eax

no_EnableMeleeHireableAI:

	mov eax,EnableNeroPetAI
	test eax,eax
	jz no_EnableNeroPetAI
;D2Game.dll	0X6E98C	NeroPetAIFix	0 #6FC8E98C
	mov ecx,esi
	add ecx, 0AFBCCh ; 1.13d 6E98Ch
	mov byte ptr[ecx],0E8h
	inc ecx
	mov eax,offset NeroPetAIFix
	sub eax,ecx
	sub eax,4
	mov [ecx],eax
	
no_EnableNeroPetAI:

	mov eax,EnableUnicodeCharName
	test eax,eax
	jz no_EnableUnicodeCharName
;D2Game.dll	0XE47B5	UnicodeCharNameCheck	0 #6FD047B5
	mov ecx,esi
	add ecx, 0BC4C5h ; 1.13d 0E47B5h
	mov eax,offset UnicodeCharNameCheck
	sub eax,ecx
	sub eax,4
	mov [ecx],eax

	pushad
	mov esi,D2COMMON
	mov esi,[esi]
	push esi
	push 0
	call UnProtectDLL
	
	mov ecx,esi
	add ecx, 046437h; 76B27h
	mov eax,8306B60Fh;  0FB60683
	mov [ecx],eax
	add ecx,4
	mov eax,90907FE0h;  E07F9090
	mov [ecx],eax
	add ecx,4
	mov eax,83909090h;  90909083
	mov [ecx],eax
	
	mov ecx,esi
	add ecx, 0447B4h ; 1.13d 74744h
	
	mov eax,8306B60Fh;  0FB60683
	mov [ecx],eax
	add ecx,4
	mov eax,90907FE0h;  E07F9090
	mov [ecx],eax
	add ecx,4
	mov eax,83909090h;  90909083
	mov [ecx],eax
	
	mov ecx,esi
	add ecx,04480Bh	
	mov eax,8306B60Fh;  0FB60683
	mov [ecx],eax
	add ecx,4
	mov eax,90907FE0h;  E07F9090
	mov [ecx],eax
	add ecx,4
	mov eax,83909090h;  90909083
	mov [ecx],eax
	push esi
	push 0
	call ProtectDLL
	
	popad
no_EnableUnicodeCharName:
	mov eax,EnablePreCalculateTCNoDropTbl
	test eax,eax
	jz no_EnablePreCalculateTCNoDropTbl
	pushad
	call PreCalculateTreasureClassNoDropTbl
	test eax,eax
	mov PreCalculateTCNoDropTbl,eax
	popad
	jz no_EnablePreCalculateTCNoDropTbl
	mov EnablePreCalculateTCNoDropTbl,eax

;D2Game.dll	0XD20F4	CalculateTreasureClassNoDropPatch	0 #6FCF20F4
	mov ecx,esi
	add ecx, 0E41C4h ; 1.13d 0D20F4h
	
	mov byte ptr[ecx],0E8h
	inc ecx
	mov eax,offset CalculateTreasureClassNoDropPatch
	sub eax,ecx
	sub eax,4
	mov [ecx],eax
	mov eax,03909090h
	add ecx,4
	mov [ecx],eax


no_EnablePreCalculateTCNoDropTbl:
	mov eax,EnableEthSocketBugFix
	test eax,eax
	jz no_EnableEthSocketBugFix

;D2Game.dll	0X37910	call    D2Common_10193_ChangeCurrentMode->call EthBugFix	0 #6FC57910
	mov ecx,esi
	add ecx, 097250h; 1.13d 37910h
	mov eax,offset EthBugFix
	sub eax,ecx
	sub eax,4
	mov [ecx],eax
	
no_EnableEthSocketBugFix:

	mov eax,DisableBugMF
	test eax,eax
	jz no_DisableBugMF

;D2Game.dll	0X3F3B1	call    GetPlayerCurrentQuestRecord->call MFBugFix	0 #6FC5F3B1
	mov ecx,esi
	add ecx, 087571h ; 1.13d 3F3B1h
	mov eax,offset MFBugFix
	sub eax,ecx
	sub eax,4
	mov [ecx],eax
	
no_DisableBugMF:

; Monster Damage Fix
; D2Game.dll 6FCB4750
;MonsterDamageFix
;	mov ecx,esi
;	add ecx,94750h
;	mov byte ptr[ecx],0E8h
;	inc ecx
;	mov eax,offset MonsterDamageFix
;	sub eax,ecx
;	sub eax,4
;	mov [ecx],eax
;	add ecx,4
;	mov byte ptr[ecx],90h


;Uber Quest Patchs

;openPandPortal=68021BD0
;D2Game.dll	0XFA7B8	2049C56F	D01B0268 1 #6FD1A7B8(11BA7B8)
;	mov ecx,esi
;	add ecx, 0FA2C4h; 1.13d 0FA7B8h
;	mov eax,offset openPandPortal
;	mov [ecx],eax

;openPandFinalPortal=68021C78
;D2Game.dll	0XFA7BC	1049C56F	781C0268 1 #6FD1A7BC(11BA7BC)
;	mov ecx,esi
;	add ecx, 0FA2C8h; 1.13d 0FA7BCh
;	mov eax,offset openPandFinalPortal
;	mov [ecx],eax

;SpawnUberBossOff=68021CF0 ; Hook
;D2Game.dll	0XE6B52 6ACAF3FF	F01C0268 20  #6FD06B52(11A6B52) = Patch Call Offset
;	mov ecx,esi
;	add ecx, 0BE9ABh ;  1.13d 0E6B52h
;	mov eax,offset SpawnUberBoss
;	sub eax,ecx
;	sub eax,4
;	mov [ecx],eax

;#####################################################################################################
;#Marsgod's AI table !! Use Ball\Mephisto\Diablo AI
;#####################################################################################################
;UberBaal AI
;D2Game.dll	0X10F5E8	00A3C46F	80BCC46F 3 #6FD2F5E8(11CF5E8) nullsub->UberBaal_AI(6FC4BC80)
	mov ecx,esi
	add ecx,010F618h ; 1.13d 10F5E8h
	mov eax,0C8850h ; 1.13d 2BC80h
	add eax,esi
	mov [ecx],eax

;UberMephisto AI
;D2Game.dll	0X10F5F8	702DCF6F	8F200268 1 #6FD2F5F8 nullsub->UberMephisto_AI(6802208F)
;D2Game.dll	0X10F5F4	00000000	5C200268 0 #6FD2F5F4 0->UberMephisto_AI0(6802205C)
	mov ecx,esi
	add ecx, 010F628h ; 10F5F8h
	mov eax,offset UberMephisto_AI
	mov [ecx],eax
	mov ecx,esi
	add ecx, 010F624h; 10F5F4h
	mov eax,offset UberMephisto_AI0
	mov [ecx],eax

;UberDiablo AI
;D2Game.dll	0X10F608	60FEC96F	DC200268 1 #6FD2F608 nullsub->UberDiablo_AI(680220DC)
;D2Game.dll	0X10F604	00000000	29200268 0 #6FD2F604 0->UberDiablo_AI0(68022029)
	mov ecx,esi
	add ecx, 010F638h; 10F608h
	mov eax,offset UberDiablo_AI
	mov [ecx],eax
	mov ecx,esi
	add ecx, 010F634h ;10F604h
	mov eax,offset UberDiablo_AI0
	mov [ecx],eax

	push esi
	push 0
	call ProtectDLL2
	
	mov eax,1
	mov D2GamePatched,eax		; 设置标志，防止再次Patch
	popad
	ret
D2GamePatch endp

myEBX dd 0

LoadMyConfig proc
	mov ecx,EnableDebugDumpThread
	mov	[ecx],eax
	mov myEBX,ebx

	push esi
	mov esi,offset aNewFeatures
	push offset aEnableMeleeHireableAI
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnableMeleeHireableAI,eax
	test eax,eax
	jz cont_101
	push    offset aMeleeHireableAIEnableMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8

cont_101:
	push offset aEnableNeroPetAI
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnableNeroPetAI,eax
	test eax,eax
	jz cont_102
	push    offset aNeroPetAIEnableMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	
cont_102:
	push offset aEnableExpGlitchFix
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnableExpGlitchFix,eax
	test eax,eax
	jz cont_103
	push    offset aExpGlitchFixEnableMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	
cont_103:
	push offset aDisableUberUp
	push esi
	call    D2GSStrCat
	add esp,8
	mov DisableUberUp,eax
	test eax,eax
	jz cont_104
	push    offset aUberUpDisableMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	
cont_104:

	push offset aEnableUnicodeCharName
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnableUnicodeCharName,eax
	test eax,eax
	jz cont_1044
	push    offset aEnableUnicodeCharNameMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8

cont_1044:

	push offset aEnablePreCalculateTCNoDropTbl
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnablePreCalculateTCNoDropTbl,eax
	test eax,eax
	jz cont_108
	push    offset aEnablePreCalculateTCNoDropTblMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8

cont_108:

	push offset aEnableEthSocketBugFix
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnableEthSocketBugFix,eax
	test eax,eax
	jz cont_109
	push    offset aEnableEthSocketBugFixMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8

cont_109:

	push offset aDisableBugMF
	push esi
	call    D2GSStrCat
	add esp,8
	mov DisableBugMF,eax
	test eax,eax
	jz cont_1010
	push    offset aDisableBugMFMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8

cont_1010:

	push offset aDisableDCSpawnInSomeArea
	push esi
	call    D2GSStrCat
	add esp,8
	mov DisableDCSpawnInSomeArea,eax
	test eax,eax
	jz cont_10555
	push    offset aDisableDCSpawnInSomeAreaMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8

cont_10555:
	mov esi,offset aWorldEvent
	push offset aSpawnMinions
	push esi
	call    D2GSStrCat
	add esp,8
	mov SpawnMinions,eax

cont_105:
	mov esi,offset aWorldEvent
	push offset aShowSOJMessage
	push esi
	call    D2GSStrCat
	add esp,8
	mov ShowSOJMessage,eax
	test eax,eax
	jnz cont_1055
	push    offset aShowSOJMessageDisabledMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	

cont_1055:
	mov esi,offset aWorldEvent
	push offset aDcItemRate
	push esi
	call    D2GSStrCat
	add esp,8
	cmp	eax,1000
	jle	eax_0
	mov	eax,1000
	jmp	eax_ok
eax_0:
	cmp	eax,0
	jge	eax_ok
	mov	eax,0
eax_ok:
	mov DcItemRate,eax

cont_106:

	mov esi,offset aNewFeatures
	push offset aEnableWarden
	push esi
	call    D2GSStrCat
	add esp,8
	mov EnableWarden,eax
	test eax,eax
	jz cont1
	push    offset aWardenEnableMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	
	; 创建Warden线程
	call InitWardenThread
cont1:
	mov esi,offset aUberMephisto

	push offset aSpawnProbability
	push esi
	call    D2GSStrCat
	add esp,8
	cmp eax,100
	jle ok_M0
	mov eax,100
ok_M0:
	mov SpawnProbability_M,eax

	push offset aMaxSpawnNum
	push esi
	call    D2GSStrCat
	add esp,8
	mov MaxSpawnNum_M,eax
	
	push offset aSpawnInterv
	push esi
	call    D2GSStrCat
	add esp,8
	mov SpawnInterv_M,eax

	push offset aActivArea
	push esi
	call    D2GSStrCat
	add esp,8
	mov ActivArea_M,eax

	push offset aStallTime
	push esi
	call    D2GSStrCat
	add esp,8
	mov StallTime_M,eax

	; Read the SpawnMonsters from config file
	lea edx,[esp+10h] ; CHECK, CHECK, CHECK!!!
	push 400h ; nSize
	push edx ; lpReturnedString
	push offset aSpawnMonsters
	push esi ; UberMephisto
	call GetConfigString
	
	test eax,eax
	jz over_M1
	jmp haha1
over_M1:
	add esp,10h
	jmp over_M
haha1:
	
	xor esi,esi
	lea ecx,[esp+18h] ; CHECK, CHECK, CHECK!!!
	lea edx,[esp+20h] ; CHECK, CHECK, CHECK!!!
	push ecx
	push offset aSplit ; ", "
	push edx
	call sub_68004870 ; split the string with ","
	mov ebx,eax
	add esp,1Ch ; CHECK, CHECK, CHECK!!!
	cmp ebx,esi
	jz noSpawnMonsters_M
	
	mov eax,[esp+08h]
	mov [esp+0Ch],esi
	cmp eax,esi
	jle noSpawnMonsters_M
	cmp eax,10
	jle	continue_M
	mov eax,10
	mov [esp+08h],eax
continue_M:
	
	push edi
	push ebp
	mov edi,ds:_strtoul
	mov edi,[edi]
	mov esi,ebx
	
	xor ebp,ebp
again_UberMephisto:
	mov eax,[esi] ; eax=数字串的偏移
	push 10 ; 十进制
	push 0
	push eax
	call edi ; strtoul
	add esp,0Ch
	cmp eax,733
	jle ok_M
	xor eax,eax
ok_M:
	mov SpawnMonsters_M[ebp*4],eax
	
	mov eax,[esp+14h]
	mov ecx,[esp+10h]
	inc eax
	inc ebp
	add esi,4
	cmp eax,ecx
	mov [esp+14h],eax
	jl again_UberMephisto
	mov TypeOfSpawns_M,eax
	xor esi,esi
	pop ebp
	pop edi
	
noSpawnMonsters_M:
	push ebx
	mov eax,free
	mov eax,[eax]
	call eax
	add esp,4

over_M:	
		
	mov esi,offset aUberDiablo

	push offset aSpawnProbability
	push esi
	call    D2GSStrCat
	add esp,8
	cmp eax,100
	jle ok_D0
	mov eax,100
ok_D0:
	mov SpawnProbability_D,eax

	push offset aMaxSpawnNum
	push esi
	call    D2GSStrCat
	add esp,8
	mov MaxSpawnNum_D,eax
	
	push offset aSpawnInterv
	push esi
	call    D2GSStrCat
	add esp,8
	mov SpawnInterv_D,eax

	push offset aActivArea
	push esi
	call    D2GSStrCat
	add esp,8
	mov ActivArea_D,eax

	push offset aStallTime
	push esi
	call    D2GSStrCat
	add esp,8
	mov StallTime_D,eax

	; Read the SpawnMonsters from config file
	lea edx,[esp+10h] ; CHECK, CHECK, CHECK!!!
	push 400h ; nSize
	push edx ; lpReturnedString
	push offset aSpawnMonsters
	push esi ; UberDiablo
	call GetConfigString
	test eax,eax
	jz over_D1
	jmp haha2
over_D1:
	add esp,10h
	jmp over_D
haha2:
	
	xor esi,esi
	lea ecx,[esp+18h] ; CHECK, CHECK, CHECK!!!
	lea edx,[esp+20h] ; CHECK, CHECK, CHECK!!!
	push ecx
	push offset aSplit ; ", "
	push edx
	call sub_68004870 ; split the string with ","
	mov ebx,eax
	add esp,1Ch ; CHECK, CHECK, CHECK!!!
	cmp ebx,esi
	jz noSpawnMonsters_D
	
	mov eax,[esp+08h]
	mov [esp+0Ch],esi
	cmp eax,esi
	jle noSpawnMonsters_D
	cmp eax,10
	jle	continue_D
	mov eax,10
	mov [esp+08h],eax
continue_D:
	
	push edi
	push ebp
	mov edi,ds:_strtoul
	mov edi,[edi]
	mov esi,ebx
	
	xor ebp,ebp
again_UberDiablo:
	mov eax,[esi] ; eax=数字串的偏移
	push 10 ; 十进制
	push 0
	push eax
	call edi ; strtoul
	add esp,0Ch
	cmp eax,733
	jle ok_D
	xor eax,eax
ok_D:
	mov SpawnMonsters_D[ebp*4],eax
	
	mov eax,[esp+14h]
	mov ecx,[esp+10h]
	inc eax
	inc ebp
	add esi,4
	cmp eax,ecx
	mov [esp+14h],eax
	jl again_UberDiablo
	mov TypeOfSpawns_M,eax
	xor esi,esi
	pop ebp
	pop edi
	
noSpawnMonsters_D:
	push ebx
	mov eax,free
	mov eax,[eax]
	call eax
	add esp,4
	
over_D:
	mov	eax,D2GamePatched
	test	eax,eax
	jz	Not_Patched
	push    offset aD2GamePatchedMsg
	push    offset aD2Server
	mov eax,D2GS_EventLog_off
	mov eax,[eax]
	call    eax
	add     esp, 8
	jmp Patched_Over
Not_Patched:
	call D2GamePatch
Patched_Over:
	mov ebx,myEBX
	pop esi
	mov eax,1
	jmp LoadWorldEventConfigFileOffset
LoadMyConfig endp

ShowSOJMessageChecker proc
	push ebx
	mov ebx,ShowSOJMessage
	test ebx,ebx
	pop ebx
	jz ShowSOJMessageChecker_over
	push eax
	push 4
	push 11h
	push esi
	call SendSystemMessage
	add     esp, 10h
ShowSOJMessageChecker_over:
	ret
ShowSOJMessageChecker endp

;retaddr	dd 0
;tmp			dd 0
;tmp1		dd 0
;tmp2		dd 0
;tmp3		dd 0
;tmp4		dd 0
;tmp5		dd 0

;d2client.dll	6FAA8941 4 6FBA7828(void) 6FB7D5C1 4 6FBD3320(void)
stub_func00 proc
	call dword_save_func00
	ret
stub_func00 endp

;6FC31C74 4 000576A8(ecx,edx,arg_0,arg_4)			6FC903B6 4 FFFBD3F6 4(arg_0,esi,ebx,arg_4)(void)
;堆栈完整
;可以改变EAX、ECX、EDX，其他不能变
;MessageHandler
; eax返回值！！
;
;
;          ecx
;          arg_4
;ret       esi
;arg_0     ebx
;arg_4     ret
D2GAME_ParseIncomingPackets_STUB proc
	; stack fix...
	mov [esp-8],ecx
	mov eax,[esp+8] ; arg_4
	mov [esp-4],eax
	mov eax,[esp] ; retaddr
	mov [esp+8],eax
	mov [esp],esi ; save esi
	mov eax,[esp+4] ; arg_0
	mov [esp+4],ebx	; save ebx
	mov ebx,eax ; arg_0
	mov esi,edx
	sub esp,8
	
	call D2GAME_ParseIncomingPackets_OLD
	pop esi
	pop ebx
	ret
D2GAME_ParseIncomingPackets_STUB endp

;6FC38551 4 FFFF93BB(ecx,edx)			6FD0832F 4 FFF8809D(arg_0,eax) packet handler!!(void)
;堆栈完整
;可以改变EAX、ECX、EDX，其他不能变
	; for warden patch 0x68,0x66 packet handler
;	mov ecx,68003815h	; system packet handler
;	mov eax,offset MyPacket0X68Handler
;	mov ecx,6800F31Ch	; packet 0x68 handler
;	mov eax,offset MyPacket0X68Handler
;	mov [ecx],eax

D2GAME_ParseCreatePackets_STUB proc
;ecx=ClientID+ptPacket
;edx=packet_len
	sub esp,4
	mov [esp], ecx	;save the ptr
	cmp edx,25h
	jz check_0x68
not_0x68:
	push ecx
	mov eax,edx
	call D2GAME_ParseCreatePackets_OLD
	add esp,4
	ret
	
check_0x68:
	cmp byte ptr[ecx+4],68h
	jnz not_0x68
	push ecx
	mov eax,edx
	call D2GAME_ParseCreatePackets_OLD
	cmp eax,3
	jz over
	test eax,eax
	jz over
	; eax=ptClient
	push eax
	push ecx
	push edx
	mov ecx,[esp+0Ch]
	;add ecx,4					; ptPacket
	;mov edx,eax				; ptClient
	;ecx=ClientID+Packet
	call MyPacket0X68Handler_Post
	pop edx
	pop ecx
	pop eax
over:
	add esp,4
	retn
D2GAME_ParseCreatePackets_STUB endp

;6FC394E0 6 57E98B565553(ecx)							6FD04A30 6 FFF25912E856(esi)	;需进一步检查(=eax)
;GetClient
;已经OK
;堆栈完整
; EAX、ECX、EDX可以改变，其他不能变
D2GAME_GetGameByClientID_STUB proc
	push esi
	mov esi,ecx
	call D2GAME_GetGameByClientID_OLD
	pop esi
	ret
D2GAME_GetGameByClientID_STUB endp

;6FC31DE0 5 681E75C985(ecx,edx)		6FCE4C40 5 681F75C085(eax,ecx)(=eax)
;堆栈完整
; EAX、ECX、EDX可以改变，其他不能变
D2GAME_GetClientDataByClientID_STUB proc
	mov eax,ecx
	mov ecx,edx
	call D2GAME_GetClientDataByClientID_OLD
	ret
D2GAME_GetClientDataByClientID_STUB endp

;6FC395B0 4 1E75C985(ecx)				6FD03AD0 4 0775C085(eax)(=void)
;堆栈完整
D2GAME_LeaveCriticalSection_STUB proc
	mov eax,ecx
	call D2GAME_LeaveCriticalSection_OLD
	ret
D2GAME_LeaveCriticalSection_STUB endp

;6FC3C710 5 F18B565551(ecx, edx(no use), arg_0) 6FCC0D50 5 246C8B5553(eax,arg_0(no use),arg_4)(=void)
; eax=ptPlayer arg_0=ptPacket arg_4=PacketLen
; ecx=ptPlayer edx=ptPacket   arg_0=PacketLen
;堆栈完整
;可以改变EAX、ECX、EDX，其他不能变
;SendPacket2Client
;
;
;
;
;            edx
;ret         arg_0
;arg_0       ret
D2GAME_SendPacket_STUB proc
	; stack fix
	mov [esp-4],edx
	mov edx,[esp] ; retaddr
	mov eax,[esp+4] ; arg_0
	mov [esp+4],edx ; retaddr
	mov [esp],eax   ; arg_0;
	mov eax,ecx
	sub esp,4
	
	call D2GAME_SendPacket_OLD
	ret
D2GAME_SendPacket_STUB endp

;6FCBC2E0 7 39831474C985(fastcall, ecx)已经被内嵌了，需要disable这个Patch，然后改为调用如下代码
;typedef LPCLIENT ( __fastcall * D2Game_UnitGetClientFunc)(LPUNIT lpUnitPlayer,
; 	LPCSTR szFile, DWORD dwLine);
;堆栈完整
D2GAME_UNIT_GetClientData_STUB proc
	test    ecx, ecx
	jz      short loc_6FCBC2F8
	cmp     dword ptr [ecx], 0
	jnz     short loc_6FCBC2F8
	push    ecx
	call    D2COMMON_11103_GetpPlayerDataFromUnit
	mov     eax, [eax+9Ch]
	retn    4
loc_6FCBC2F8:
	xor     eax, eax
	retn    4
D2GAME_UNIT_GetClientData_STUB endp

;6FCBD820 8 0C24548B0424448B(arg_0,arg_4,arg_8)				6FCDE460 8 68488B0A8964488B(eax,arg_0,edx)(=eax)
;堆栈完整(使用Waypoint)
;
;
;
; ret
; arg_0
; arg_4     arg_4
; arg_8     ret
D2GAME_GetUnitInteractionStatus_STUB proc
	; stack fix
	mov edx,[esp+12] ; arg_8
	mov eax,[esp] ; retaddr
	mov [esp+12],eax
	mov eax,[esp+4] ; arg_0
	add esp,8
	
	call D2GAME_GetUnitInteractionStatus_OLD
	ret
D2GAME_GetUnitInteractionStatus_STUB endp

;6FCBBB00 4 7556C985(ecx,edx,arg_0)	6FCDEF80 4 1F75C985(ecx,eax,edx)(=eax)
;typedef LPUNIT 	( __fastcall * D2Game_GameFindUnitFunc)(LPGAME ptGame, DWORD dwUnitType, DWORD dwUnitId);
;没发现调用
;
;
;
; ret
; arg_0   ret
D2GAME_FindUnit_STUB proc
	; stack fix
	mov [esp-4],edx ; save edx
	mov edx,[esp+4] ; arg_0
	mov eax,[esp]   ; retaddr
	mov [esp+4],eax
	mov eax,[esp-4] ; restore edx
	add esp,4
	
	call D2GAME_FindUnit_OLD
	ret
D2GAME_FindUnit_STUB endp

;d2game.dll		6FC8A200(6FC8D940) 4 0000373C(ecx,edx,arg_0,arg_4,arg_8,arg_12,arg_16)  6FC4557F 4 000037BD (edx,ecx,...)
;交换ecx和edx，然后直接跳转，不是call！！
;typedef DWORD (__fastcall * D2Game_GetPlrSaveDataFunc)(LPGAME ptGame, LPUNIT ptUnitPlayer, 
;		LPSTR lpBuf, DWORD * pSize, DWORD dwBufSize, BOOL bInTrade, BOOL bQuit);
; ecx=ptPlayer edx=ptGame arg0=var_2000? arg_4=var_25F8filename? arg_8=2000h arg_12=0 arg_16=0
; ecx=ptGame edx=ptPlayer arg0=unk_12D884 arg_4=unk_12D244 arg_8=2000h arg_12=0 arg_16=0
D2GAME_D2S_Save_STUB proc
	mov eax,edx
	mov edx,ecx
	mov ecx,eax
	jmp D2GAME_D2S_Save_OLD
D2GAME_D2S_Save_STUB endp

;6FC38F7A 4 FFFFF752(ecx)		6FD0818C 4 FFFFFDF0(eax)
;堆栈完整
;UpdateGameEvent
D2GAME_ParseEvents_STUB proc
	mov eax,ecx
	call D2GAME_ParseEvents_OLD
	ret
D2GAME_ParseEvents_STUB endp

;6FC39391 4 FFFFFC9B(ecx,edx,arg_0,arg_4)			6FD0744A 4 FFFFFCC2(arg_0,eax,arg_4,edx)
;typedef VOID	( __fastcall * D2Game_GameSendAllMsgsFunc)(LPGAME ptGame, LPCLIENT ptClient, BOOL u1, BOOL u2);
;堆栈完整
;
;
;
;
; ret      ecx
; arg_0    arg_0
; arg_4    ret
D2GAME_DispatchPacketsToClient_STUB proc
	; stack fix
	mov [esp-4],edx ; save edx
	mov edx,[esp] ; retaddr
	mov eax,[esp+8] ; arg_4
	mov [esp+8],edx ; retaddr
	mov [esp],ecx
	mov edx,eax			; arg_4->edx
	mov eax,[esp-4] ; restore edx
	
	call D2GAME_DispatchPacketsToClient_OLD
	ret
D2GAME_DispatchPacketsToClient_STUB endp

;6FC8A500 4 002640B8(ecx,edx,arg_0,arg_4)（保存玩家档案） 6FC45860 4 8538EC83(ebx,esi,arg_0,arg_4)
;GameSavePlayer
;保存Hack玩家档案？？？需要再次检查！！参数数目是对的，但是顺序不知道如何？
;
;
;
;         arg_0
;         arg_4
; ret     esi
; arg_0   ebx
; arg_4   ret
D2GAME_SavePlayer_STUB proc
	; stack fix
	mov eax,[esp+8]		; arg_4
	mov [esp-4],eax
	mov eax,[esp+4]		; arg_0
	mov [esp-8],eax
	mov eax,[esp]			; retaddr
	mov [esp+8],eax
	mov [esp+4],ebx
	mov [esp],esi
	sub esp,8
	mov ebx,ecx
	mov esi,edx

	call D2GAME_SavePlayer_OLD
	pop esi
	pop ebx
	ret
D2GAME_SavePlayer_STUB endp

;6FC31E20 4 24748B56 0 0(arg_0,arg_4)  		6FCE5600 4 1F75F685(esi,arg_0)
; 从Client获得ptUnit
;没找到调用，已经检查调用了～
;
;
;
; ret    arg_4
; arg_0  esi
; arg_4  ret
D2GAME_FindUnitByClientData_STUB proc
	; stack fix
	mov eax,[esp+8]	; arg_4
	mov [esp-4],eax	; save arg_4
	mov eax,[esp]		; retaddr
	mov [esp+8],eax
	mov eax,[esp-4]	; restore arg_4
	mov [esp],eax
	mov eax,[esp+4]	; arg_0
	mov [esp+4],esi	; save esi
	mov esi,eax
	
	call D2GAME_FindUnitByClientData_OLD
	pop esi
	ret
D2GAME_FindUnitByClientData_STUB endp

;6FC3B0E0 6 FA8B57F18B56(ecx,edx,arg_0)				6FD036D0 6 75F685F08B56(eax,edi,ebx)
;typedef VOID	( __fastcall * D2Game_GameTraverseClientCBFunc)(LPCLIENT lpClient,LPVOID lpData);
;没找到调用
;
;
;
;
;         ebx
; ret     edi
; arg_0   ret
D2GAME_ForEach_STUB proc
	; stack fix
	mov [esp-4],ebx
	mov ebx,[esp+4] ; arg_0
	mov eax,[esp]	; retaddr
	mov [esp+4],eax
	mov [esp],edi
	sub esp,4
	mov eax,ecx
	mov edi,edx
	
	call D2GAME_ForEach_OLD
	pop ebx
	pop edi
	ret
D2GAME_ForEach_STUB endp

;6FC35840 4 57F18B56(ecx)	6FD04400 4 0125BA56(arg_0)
;typedef DWORD	( __fastcall * D2Game_GameHashFromIdFunc)(WORD wGameId);
;没找到调用
D2GAME_GetGameSocketListByToken_STUB proc
	push ecx
	call D2GAME_GetGameSocketListByToken_OLD
	ret
D2GAME_GetGameSocketListByToken_STUB endp

;6FC397A0 4 358B5653(ecx)									6FD049A0 4 D31BE0A1(arg_0)
;typedef LPGAME 	( __fastcall * D2Game_GameFromHashFunc)(DWORD dwHashId);
;没找到调用
D2GAME_GetGameBySocket_STUB proc
	push ecx
	call D2GAME_GetGameBySocket_OLD
	ret
D2GAME_GetGameBySocket_STUB endp

;6FC51070 8 555300000430EC81(ecx=ptGame,edx,arg_0,arg_4=1)		6FCF0410 8 8B530000042CEC81(eax=ptGame,arg_0=item,NULL,arg_4=1)
; typedef LPUNIT  ( __fastcall * D2Game_ItemDuplicateFunc)(LPGAME lpGame,
;		LPUNIT lpUnitItem, LPUNIT lpUnitCreator, DWORD dwFlags);
;没找到调用，没人调用！！？
;
;
;
;
;
; ret      edx
; arg_0    arg_4
; arg_4    ret
D2GAME_DupeItem_STUB proc
	; stack fix
	mov eax,[esp] ; retaddr
	mov [esp],edx
	mov edx,[esp+8] ; arg_4
	mov [esp+8],eax ; retaddr
	mov eax,[esp+4] ; arg_0
	mov [esp+4],edx ; arg_4
	
	mov eax,ecx
	call D2GAME_DupeItem_OLD
	ret
D2GAME_DupeItem_STUB endp

;d2game.dll		6FCC77D0 4 00054032(arg_0,arg_4,arg_8,arg_12) 6FCB2859 4 FFF77DE5(arg_0,arg_4,arg_8,arg_12)
;typedef BOOL (__stdcall * D2Common_ItemTestFlagFunc)(LPUNIT ptItem, DWORD dwFlag, DWORD dwLine, LPCSTR lpLine); 
;static BOOL __stdcall D2GameSellItemCheck(LPUNIT ptItem, DWORD dwFlag, DWORD dwLine, LPCSTR lpFile) 
;没找到调用
D2COMMON_TestItemFlag_STUB proc
	;call Send0XAEPacket
	jmp D2COMMON_TestItemFlag_OLD
D2COMMON_TestItemFlag_STUB endp

;d2game.dll		6FC6F720 4 FFFFFAFC(ecx,edx,arg_0,arg_4,arg_8,arg_12,arg_16,arg_20) 6FD0CF10 4 FFFFF8CC(arg_0,arg_4,edx,arg_8,arg_12,arg_16,ecx,eax)
;SpawnDiabloClone
;CowKing:
;eax=1
;ecx=187
;stack=unk,unk,0,0,FFFFFFF
;
;
;
;
; ret
; arg_0      ecx
; arg_4      edx
; arg_8      arg_4
; arg_12     arg_8
; arg_16     arg_12
; arg_20     ret
;
;
;0=143b 4=FFFFFF 8=14 12=0 16=14d 20=0 x=3 ecx=ptgameE0CC4200A0... edx=CC60235B...
;0=ptgame 4=edx 8=FFFFFF 12=14 16=0 ecx=14D edx=143b eax=0
D2GAME_SpawnMonster_STUB proc
	; stack fix
	mov eax,[esp+24]	; arg_20
	mov [esp-4],eax		; save arg_20
	mov eax,[esp+20]	; arg_16
	mov [esp-8],eax		; save arg_16
	mov eax,[esp]
	mov [esp+24],eax	; retaddr
	mov eax,[esp+16]	; arg_12
	mov [esp+20],eax
	mov eax,[esp+12]	; arg_8
	mov [esp+16],eax
	mov eax,[esp+8]		; arg_4
	mov [esp+12],eax
	mov [esp+8],edx
	mov edx,[esp+4]		; arg_0
	mov [esp+4],ecx
	
	mov eax,[esp-4]		; restore arg_20
	mov ecx,[esp-8]		; restore arg_16
	add esp,4

	call D2GAME_SpawnMonster_OLD
	ret
D2GAME_SpawnMonster_STUB endp

;6FC31C74 4 000576A8(ecx,edx,arg_0,arg_4)			6FC903B6 4 FFFBD3F6(arg_0,esi,ebx,arg_4)
;堆栈完整
;MessageHandling
;
;
;
;
; ret     ebx
; arg_0   arg_4
; arg_4   ret
D2GS_OnPacketRecv_STUB proc
	; stack fix
	mov eax,[esp]		; retaddr
	mov edx,[esp+8]	; arg_4
	mov [esp+8],eax	; retaddr
	mov ecx,[esp+4]	; arg_0
	mov [esp+4],edx	; arg_4
	mov [esp],ebx
	mov edx,esi
	
	call D2GS_OnPacketRecv_OLD
	ret
D2GS_OnPacketRecv_STUB endp

;6FC38551 4 FFFF93BB(ecx,edx)			6FD0832F 4 FFF8809D(arg_0,eax)
;堆栈完整
;
;
;
; ret
; arg_0 ret
D2GS_OnCreatePacket_STUB proc
	; stack fix
	pop edx	; retaddr
	pop ecx	; arg_0
	push edx	; retaddr
	mov edx,eax

	call D2GS_OnCreatePacket_ORG
	ret
D2GS_OnCreatePacket_STUB endp

;d2game.dll		6FC8A200(6FC8D940) 4 0000373C(ecx,edx,arg_0,arg_4,arg_8,arg_12,arg_16)  6FC4557F 4 000037BD (edx,ecx,...)
;没找到调用
D2GS_CharSave_STUB proc
	mov eax,ecx
	mov ecx,edx
	mov edx,eax
	jmp D2GS_SaveChar_ORG
D2GS_CharSave_STUB endp

;6FC38F7A 4 FFFFF752(ecx)			6FD0818C 4 FFFFFDF0(eax)
;堆栈完整（推测）
D2GS_OnGameAdd_STUB proc
	mov ecx,eax
	call D2GS_OnGameAdd_ORG
	ret
D2GS_OnGameAdd_STUB endp

;6FC39391 4 FFFFFC9B(ecx,edx,arg_0,arg_4)			6FD0744A 4 FFFFFCC2(arg_0,eax,arg_4,edx)
;堆栈完整（推测）
;
;
;
;
;
; ret     arg_4
; arg_0   edx
; arg_4   ret
D2GS_OnEachClient_STUB proc
	; stack fix
	mov [esp-4],eax	; save eax
	mov ecx,[esp+4]	; arg_0
	mov [esp+4],edx
	mov eax,[esp]	; retaddr
	mov edx,[esp+8]	; arg_4
	mov [esp+8],eax	; retaddr
	mov [esp],edx
	
	mov edx,[esp-4]	; restore eax

	call D2GS_OnEachClient_ORG
	ret
D2GS_OnEachClient_STUB endp

;d2game.dll		6FCC77D0 4 00054032(arg_0,arg_4,arg_8,arg_12) 6FCB2859 4 FFF77DE5(arg_0,arg_4,arg_8,arg_12)
;没找到调用
D2GS_OnItemSell_STUB proc
	jmp D2GS_OnItemSell_ORG
D2GS_OnItemSell_STUB endp

;d2game.dll		6FC6F720 4 FFFFFAFC(ecx,edx,arg_0,arg_4,arg_8,arg_12,arg_16,arg_20) 6FD0CF10 4 FFFFF8CC(arg_0,arg_4,edx,arg_8,arg_12,arg_16,ecx,eax)
;SpawnDiabloClone
;
;
;
;
;
;          edx
; ret      arg_8
; arg_0    arg_12
; arg_4    arg_16
; arg_8    ecx
; arg_12   eax
; arg_16   ret
D2GS_OnUniqMonSpawn_STUB proc
	; stack fix
	mov [esp-4],edx
	mov [esp-8],eax		; save eax
	mov [esp-12],esi	; save esi
	mov edx,[esp+20]	; arg_16
	mov eax,[esp]			; retaddr
	mov [esp+20],eax
	mov eax,[esp+12]	; arg_8
	mov [esp],eax
	mov [esp+12],ecx
	mov eax,[esp+8]		; arg_4
	mov [esp+8],edx
	mov edx,eax				; arg_4
	mov ecx,[esp+4]		; arg_0
	mov esi,[esp+16]	; arg_12
	mov eax,[esp-8]		; restore eax
	mov [esp+16],eax
	mov [esp+4],esi		; arg_12
	mov esi,[esp-12]	; restore esi
	sub esp,4
	
	
	call D2GS_OnUniqMonSpawn_ORG
	ret
D2GS_OnUniqMonSpawn_STUB endp

	INCLUDE UberQuest.asm

;双光环PET的BUG
;产生原因：当物品被移除的时候，挂在PET身上相应的光环事件并没有被移除，导致再次装备物品的时候，光环事件不断增多
;解决方法：当物品被移除的时候，检查PET身上的事件链，将被移除物品对应的光环事件移除。
;新解决方法：在AuraSkill_related_event9_handler->UpdateAuraEvent中，当清除完旧事件，准备创建新事件的时候，检查UID是否是合法的UID
NewDualAuraPatch proc
	;首先提取PET或者Player身上所有装备的UID，保存到一个数组，然后对PET、Player身上所有的光环事件，检查其UID是否就是装备的UID，如果不是，则移除光环

	;	6FC9604C push    9
	;(ecx=ptGame,edx=?,ebx=UID,edi=ptPet)
	; ebx,ecx,eax,edx均可以破坏，不必保存
	
	test ecx,ecx
	jz over
	test edi,edi
	jz over
	
	pushad
	sub esp,80
	mov ebp,esp
	
	mov ebx,15
	push ecx

again:							; 获取PET身上所有装备的UID，并保存到一个临时数组中
	mov edx,[edi+60h]	; ptPet->Inv
	push ebx
	push edx
	call D2COMMON_10292_GetInvItemByBodyLoc
	test eax,eax
	jz check_next_loc
	mov eax,[eax+0Ch]
check_next_loc:
	mov [ebp+ebx*4],eax
	dec ebx
	jge again

	pop ecx
		
	mov esi,[edi+0DCh]	; ptPet->EventChain
	test esi,esi
	jz my_over1
	
again_event:
	movzx edx,byte ptr [esi]
	cmp edx,9		; an Aura event
	jnz next_event_prev
	mov eax,[esi+14h] ; the Aura Owner Item uid	对每一个光环事件，检查是否属于PET身上装备的UID
	
	cmp eax,0FFFFFFFFh
	jz next_event_prev
	
	mov ebx,15
again_uid:
	cmp eax,[ebp+ebx*4]
	jz next_event_prev
	dec ebx
	jge again_uid

	pushad				; 非法光环，清除掉
	mov edi,ecx
	mov eax,esi
	call D2GAME_0C04F0_DeleteTimer		; eax=the event edi=ptGame
	popad
;	mov esi,[edi+0DCh] ; Get the Event chain from pet unit
;	test esi,esi
;	jnz again_event
next_event_prev:
	mov esi,[esi+24h] ; set prev event
	test esi,esi
	jnz again_event
	
my_over1:
	add esp,80
	popad
	
over:
	retn 4

NewDualAuraPatch endp

DualAuraPatch proc
	; ebp the PET
	; eax the Item
	pushad
	
	mov edi,[ebp+80h] ; Get the ptGame
	mov esi,[ebp+0DCh] ; Get the Event chain from pet unit
	test esi,esi
	jz over
	test edi,edi
	jz over
	
	
	
again_prev:
	mov edx,[esi]	
	cmp edx,9		; an Aura event
	jnz next_event_prev
	mov ebx,[esi+14h] ; the Aura Owner Item uid
	cmp ebx,[eax+0Ch] ; the Item->uid
	jnz next_event_prev
	pushad
	mov eax,esi
	call D2GAME_0C04F0_DeleteTimer		; eax=the event edi=ptGame
	popad
	mov esi,[ebp+0DCh] ; Get the Event chain from pet unit
	test esi,esi
	jnz again_prev
next_event_prev:
	mov esi,[esi+20h] ; set prev event
	test esi,esi
	jnz again_prev

	mov esi,[ebp+0DCh] ; Get the Event chain from pet unit
	test esi,esi
	jz over

again_next:
	mov edx,[esi]	
	cmp edx,9		; an Aura event
	jnz next_event_next
	mov ebx,[esi+14h] ; the Aura Owner Item uid
	cmp ebx,[eax+0Ch] ; the Item->uid
	jnz next_event_next
	pushad
	mov eax,esi
	call D2GAME_0C04F0_DeleteTimer		; eax=the event edi=ptGame
	popad
	mov esi,[ebp+0DCh] ; Get the Event chain from pet unit
	test esi,esi
	jnz again_next
next_event_next:
	mov esi,[esi+24h] ; set next event
	test esi,esi
	jnz again_next

over:
	popad
	ret
DualAuraPatch endp

; 检查交易双方，是否有多余的光环事件
TradePlayerAuraBugPatch proc
	test edx,edx
	jz over
	pushad
	mov ebp,edx
	call PlayerAuraCheckPatch
	
	mov edx,[ebp+64h]	; 获取交易对方的UnitID
	mov ecx,[ebp+80h]	; ptGame
	xor eax,eax				; Player Type
	call D2GAME_FindUnit_OLD	; 获取交易对方的Unit
	test eax,eax
	jz over1
	mov ebp,eax
	call PlayerAuraCheckPatch
over1:
	popad
over:
	mov di,[eax+3]
	xor esi,esi
	ret
TradePlayerAuraBugPatch endp

; 检查玩家身上的所有光环，看这些光环事件的Item UID是否装备在玩家身上，如果没装备在玩家身上，则移除该事件
PlayerAuraCheckPatch proc
	; ebp the Player
	pushad
	
	mov edi,[ebp+80h] ; Get the ptGame
	mov esi,[ebp+0DCh] ; Get the Event chain from player unit
	test esi,esi
	jz over
	test edi,edi
	jz over
	
again_prev:
	mov edx,[esi]	; Get the event type
	cmp edx,9		; an Aura event
	jnz next_event_prev
	
	mov ebx,[esi+14h] ; the Aura Owner Item uid
	
; 循环检查玩家身上装备的所有物品
	pushad
	xor edi,edi
next_inv_item1:
	push edi					; body location
	mov eax,[ebp+60h]	; Player's Inventory
	push eax
	call D2COMMON_10292_GetInvItemByBodyLoc
	test eax,eax
	jz try_next_item1
	cmp ebx,[eax+0Ch]	; item->nUnitId
	jz found_aura_item1
try_next_item1:
	inc edi
	cmp edi,0Bh
	jnz next_inv_item1
	popad
	jmp remove_aura1
found_aura_item1:
	popad
	jmp next_event_prev

remove_aura1:	
	pushad
	mov eax,esi
	call D2GAME_0C04F0_DeleteTimer		; eax=the event edi=ptGame
	popad
	mov esi,[ebp+0DCh] ; Get the Event chain from player unit
	test esi,esi
	jnz again_prev
next_event_prev:
	mov esi,[esi+20h] ; set prev event
	test esi,esi
	jnz again_prev

	mov esi,[ebp+0DCh] ; Get the Event chain from player unit
	test esi,esi
	jz over

again_next:
	mov edx,[esi]	
	cmp edx,9		; an Aura event
	jnz next_event_next
	mov ebx,[esi+14h] ; the Aura Owner Item uid

; 循环检查玩家身上装备的所有物品
	pushad
	xor edi,edi
next_inv_item2:
	push edi					; body location
	mov eax,[ebp+60h]	; Player's Inventory
	push eax
	call D2COMMON_10292_GetInvItemByBodyLoc
	test eax,eax
	jz try_next_item2
	cmp ebx,[eax+0Ch]	; item->nUnitId
	jz found_aura_item2
try_next_item2:
	inc edi
	cmp edi,0Bh
	jnz next_inv_item2
	popad
	jmp remove_aura2
found_aura_item2:
	popad
	jmp next_event_next

remove_aura2:	
	pushad
	mov eax,esi
	call D2GAME_0C04F0_DeleteTimer		; eax=the event edi=ptGame
	popad
	mov esi,[ebp+0DCh] ; Get the Event chain from player unit
	test esi,esi
	jnz again_next
next_event_next:
	mov esi,[esi+24h] ; set next event
	test esi,esi
	jnz again_next

over:
	popad
	ret
PlayerAuraCheckPatch endp

TPCrashBugPatch proc
	; fix the stack first
	; save the retaddr
	pop esi		; retaddr
	
	call D2COMMON_10632_GetRoom1
	push esi	; retaddr
	push ebx
	push ecx
	push edx
	push eax	; retval
			
	mov ecx,[esp+30h]	; X
	mov edx,[esp+34h]	; Y
			
	mov esi,eax
	test esi,esi
	jz fail_over
	mov eax,[esi+4Ch]	; Get room XStart
	cmp ecx,eax
	jl fail_over		; X<XStart, fail
	mov ebx,[esi+54h]	; Get room XSize
	add ebx,eax				; room XEnd
	cmp ecx,ebx				; X>XEnd, fail
	jge fail_over
	mov eax,[esi+50h]	; Get room YStart
	cmp edx,eax
	jl fail_over			; Y<YStart, fail
	mov ebx,[esi+58h]	; Get room YSize
	add ebx,eax				; room YEnd
	cmp edx,ebx
	jge fail_over			; Y>YEnd, fail
	pop eax	; retval	; the corrent room return
	pop edx
	pop ecx
	pop ebx
	ret
fail_over:
	pop eax	; stack fix: retval
	pop edx
	pop ecx
	pop ebx
	pop eax	;	stack fix: retaddr
	mov eax, D2GAME_0X1606D ; 1.13d		; fail, destroy the town portal already created
	push eax	; new retaddr
	xor eax,eax
	ret
TPCrashBugPatch endp

ExpGlitchFix proc
	;6FC9E051
	; esi=MonsterBaseExp=0x0039FD64(Diablo)最大0x004537D4(Baal)
	; ecx=NumberOfPlayerShareExp=8
	; [esp+5C] = 同一场景内所有玩家级别之和

	; eax=exp1
	
	;exp1=(MonsterBaseExp*(NumberOfPlayerShareExp-1)*89)/256+MonsterBaseExp=0xEDAAB0
	;player_exp=exp1*CLVL/TotalCLVL
	;exp1*CLVL=EDAAB0*99=0x5BE90210
	
	mov		esi,[esp+70h]	; 引入结盟因素，总经验值exp=0x0039FD64
	lea		eax,[ecx-1]
	imul	eax,59h			; (NumberOfPlayerShareExp-1)*89
	mul		esi					; MonsterBaseExp*(NumberOfPlayerShareExp-1)*89
	xor		edx,edx
	mov		ebx,256
	div		ebx					; (MonsterBaseExp*(NumberOfPlayerShareExp-1)*89)/256
	add		eax,esi			;	(MonsterBaseExp*(NumberOfPlayerShareExp-1)*89)/256+MonsterBaseExp
	
	mov		[esp+5Ch+arg_8],eax
	
	xor		esi,esi

Loop_ExpGlitchFix:
	mov		edi,[esp+esi*4+34h]	;玩家级别
	mov		ebx,[esp+esi*4+14h]	;ptPlayer
	mov		eax,[esp+5Ch+arg_8]
	mul		edi
	div		dword ptr [esp+58h]						; TotalCLVL
;6FC9E0A9
ExpGlitchFix endp

ExpGlitchFixEnd proc
ExpGlitchFixEnd endp

;.text:6FC9E09C                 mov     [esp+5Ch+arg_8], edi
;.text:6FC9E0A0                 fild    [esp+5Ch+arg_8] ; 4B
;.text:6FC9E0A4                 fmul    dword ptr [esp+70h]
;.text:6FC9E0A8                 call    __ftol2       
;
;修改为：
;	mov eax,[esp+5Ch+arg_8]
;	mul edi
;	div [esp+5Ch]						; TotalCLVL
	


MyInitGameHandler	proc
	; eax=ptGameInfo
;	xor ecx,ecx
;	mov [eax],ecx
;	mov [eax+4],ecx
;	ret

	
	pushad
	mov	esi,eax
	mov ebx,[esi+4]
	test ebx,ebx
	jnz already_malloc
	push 1024					; sizeof ExtendGameInfoStruct
	mov eax,malloc
	mov eax,[eax]
	call eax ; malloc
	add esp,4
	mov [esi+4],eax ; 指向新的ExtendGameInfoStruct
	test eax,eax
	jz fail_over
already_malloc:
	xor ebx,ebx
	mov [esi],ebx
	mov eax,[esi+4]
	
	mov [eax+ExtendGameInfoStruct.PortalOpenedFlag],ebx
	
;00300004	游戏Flag，
;test ecx,100000h	用于判断是否是D2C或者LOD游戏
	mov ecx,[esp+2Ch];	获取D2C标志
	test ecx,100000h
	jz D2C_Type
	mov [eax+ExtendGameInfoStruct.LoD_Game],1
	jmp fail_over
D2C_Type:
	mov [eax+ExtendGameInfoStruct.LoD_Game],0
fail_over:
	popad
	ret
MyInitGameHandler	endp

MeleePetAIFix proc
	;6FC87F99
	; esi=ptPet ecx=petType=152=Act2Pet
	
	push 55		; STATE_IRONMAIDEN
	push esi
	call D2COMMON_10706_GetUnitState
	test eax,eax
	mov  edi,62h
	jz over
	xor  edi,edi	; 如果是中了IM，则不做攻击行动
over:
	ret
MeleePetAIFix endp

NeroPetAIFix proc
	; 6FC8E98C
	; ebx=ptPet
	
	push 55		; STATE_IRONMAIDEN
	push ebx
	call D2COMMON_10706_GetUnitState
	test eax,eax
	mov  eax,64h
	jz over
	mov eax,07FFFFFFFh	; 如果是中了IM，则不做攻击行动
over:
	ret
NeroPetAIFix endp

UnicodeCharNameCheck proc
	; edi=最大长度；eax=CharName
	push esi
	push ebx
	xor ebx,ebx
	test edi,edi
	mov esi,eax
	jle fail_over
	
next_char:
	mov al,byte ptr[esi]
	test al,al
	jz success_ok
	inc esi
	inc ebx
	
	xor ecx,ecx
next_invalid_char:
	mov dl,byte ptr InvalidChar[ecx]
	test dl,dl
	jz over
	cmp al,dl
	jz fail_over
	inc ecx
	jmp next_invalid_char

over:
	cmp ebx,edi
	jle next_char
success_ok:
	mov eax,1
	jmp ok
fail_over:
	xor eax,eax
ok:
	pop ebx
	pop esi
	ret
UnicodeCharNameCheck endp

InvalidChar db '\','/',':','*','?','"','<','>','|',0

MonsterDamageFix proc
	; 6FCB4750
	; ebp=ptMonster
	
	;orig code
	mov	eax,[ebp+0]
	cmp	eax,1
	jnz	fail_over
	; Check monster emode
	; 0,1,2,3,6,12,15~均不需要进行MonsterDamage计算！
	mov eax,[ebp+10h]
	cmp eax,14
	jg	fail_over
	cmp	eax,4
	jl	fail_over
	cmp	eax,6
	jz	fail_over
	cmp	eax,12
	jz	fail_over
	;正常！
	xor eax,eax
	cmp eax,0
	ret
fail_over:
	;set the NZ flag
	xor eax,eax
	cmp eax,1
	ret
MonsterDamageFix endp


INCLUDE Warden.asm

ProtectDLL proc
	flOldProtect    = dword ptr -4
	arg_0           = byte ptr  4
	arg_4           = dword ptr  8
	
	push    ecx
	mov     ecx, [esp+4+arg_4]
	mov     eax, [ecx+3Ch]
	push    esi
	push    edi
	add     eax, ecx
	mov     [esp+0Ch+flOldProtect], 0
	mov     edi, [eax+1Ch]
	mov     esi, [eax+2Ch]
	lea     eax, [esp+0Ch+flOldProtect]
	push    eax             ; lpflOldProtect
	push    20h             ; flNewProtect
	add     esi, ecx
	push    edi             ; dwSize
	push    esi             ; lpAddress
	mov			eax,VirtualProtect
	mov			eax,[eax]
	call    eax

	pop     edi
	pop     esi
	pop     ecx
	retn 8
ProtectDLL endp

UnProtectDLL proc
	flOldProtect    = dword ptr -4
	arg_0           = byte ptr  4
	arg_4           = dword ptr  8
	
	push    ecx
	mov     ecx, [esp+4+arg_4]
	mov     eax, [ecx+3Ch]
	push    esi
	push    edi
	add     eax, ecx
	mov     [esp+0Ch+flOldProtect], 0
	mov     edi, [eax+1Ch]
	mov     esi, [eax+2Ch]
	lea     eax, [esp+0Ch+flOldProtect]
	push    eax             ; lpflOldProtect
	push    40h             ; flNewProtect	PAGE_EXECUTE_READWRITE=0x40 PAGE_EXECUTE_READ=0x20 PAGE_READWRITE=0x04
	add     esi, ecx
	push    edi             ; dwSize
	push    esi             ; lpAddress
	mov			eax,VirtualProtect
	mov			eax,[eax]
	call    eax
	
	pop     edi
	pop     esi
	pop     ecx
	retn 8
UnProtectDLL endp

ProtectDLL2 proc
	flOldProtect    = dword ptr -4
	arg_0           = byte ptr  4
	arg_4           = dword ptr  8
	
	push    ecx
	mov     ecx, [esp+4+arg_4]
	mov     eax, [ecx+3Ch]
	push    esi
	push    edi
	add     eax, ecx
	mov     [esp+0Ch+flOldProtect], 0
	mov     edi, [eax+1Ch]
	mov     esi, [eax+2Ch]
	lea     eax, [esp+0Ch+flOldProtect]
	push    eax             ; lpflOldProtect
	push    20h             ; flNewProtect
	add     esi, ecx
	push    edi             ; dwSize
	push    esi             ; lpAddress
	mov			eax,VirtualProtect
	mov			eax,[eax]
	call    eax

	;protect the .rdata segment
	mov     ecx, [esp+0Ch+arg_4]
	add     ecx, 0F8D64h				; .rdata start address
	lea     eax, [esp+0Ch+flOldProtect]
	push    eax             ; lpflOldProtect
	push    2	              ; flNewProtect	PAGE_EXECUTE_READWRITE=0x40 PAGE_EXECUTE_READ=0x20 PAGE_READWRITE=0x04
	push    0000629Ch       ; dwSize
	push    ecx             ; lpAddress
	mov			eax,VirtualProtect
	mov			eax,[eax]
	call    eax

	pop     edi
	pop     esi
	pop     ecx
	retn 8
ProtectDLL2 endp

UnProtectDLL2 proc
	flOldProtect    = dword ptr -4
	arg_0           = byte ptr  4
	arg_4           = dword ptr  8
	
	push    ecx
	mov     ecx, [esp+4+arg_4]
	mov     eax, [ecx+3Ch]
	push    esi
	push    edi
	add     eax, ecx
	mov     [esp+0Ch+flOldProtect], 0
	mov     edi, [eax+1Ch]
	mov     esi, [eax+2Ch]
	lea     eax, [esp+0Ch+flOldProtect]
	push    eax             ; lpflOldProtect
	push    40h             ; flNewProtect	PAGE_EXECUTE_READWRITE=0x40 PAGE_EXECUTE_READ=0x20 PAGE_READWRITE=0x04
	add     esi, ecx
	push    edi             ; dwSize
	push    esi             ; lpAddress
	mov			eax,VirtualProtect
	mov			eax,[eax]
	call    eax
	
	;unprotect the .rdata segment
	mov     ecx, [esp+0Ch+arg_4]
	add     ecx, 0F8D64h				; .rdata start address
	lea     eax, [esp+0Ch+flOldProtect]
	push    eax             ; lpflOldProtect
	push    4	              ; flNewProtect	PAGE_EXECUTE_READWRITE=0x40 PAGE_EXECUTE_READ=0x20 PAGE_READWRITE=0x04
	push    0000629Ch       ; dwSize
	push    ecx             ; lpAddress
	mov			eax,VirtualProtect
	mov			eax,[eax]
	call    eax
	
	
	pop     edi
	pop     esi
	pop     ecx
	retn 8
UnProtectDLL2 endp

SingleRoomDCPatch proc
	; esi=卖给NPC的Item
	
	push	1000
	push	0
	call	GetRandomNumber
	mov		edx,DcItemRate
	add		esp,8
	cmp		eax,edx
	sbb		eax,eax
	neg		eax
	
	test	eax,eax
	jz		over_retn
	
	mov		esi,[esi+80h]
	test	esi,esi
	jz		over_retn
	push	1		;是否释放DiabloClone？
	push	1		;是否显示xx颗SOJ卖给商人？
	push	esi
	call	sub_68005A10
	add		esp,0Ch
;	mov		ecx,esi
;	mov		eax,D2Game_LeaveCriticalSection
;	mov		eax,[eax]
;	call	eax

over_retn:
	mov		eax,SOJ_Counter
	mov		eax,[eax]
	inc		eax
	
	ret
SingleRoomDCPatch endp

dbl_1000FDF0    dq 1.0
PreCalculateTCNoDropTbl	dd 0

PreCalculateTreasureClassNoDropTbl proc near

var_1C          = dword ptr -1Ch
var_18          = dword ptr -18h
var_14          = qword ptr -14h
var_C           = dword ptr -0Ch
var_8           = dword ptr -8
var_4           = dword ptr -4

                push    ebp
                mov     ebp, esp
                sub     esp, 1Ch
                push    esi
				
                mov     eax,D2COMMON ; 1.13d 6FDF114Ch
				mov		eax, [eax]
				add 	eax, 0A6214h
                mov     esi, [eax]
                test    esi, esi
                push    edi
				
			    mov     edi,  D2COMMON ; 1.13d 6FDF1150h
				mov		edi,[edi]
				add 	edi, 0A6218h
				mov edi, [edi]
                mov     [ebp+var_18], edi
                jz      loc_10003F98
                test    edi, edi
                jz      loc_10003F98
                lea     eax, ds:0[edi*8]
                sub     eax, edi
                add     eax, eax
                add     eax, eax
                add     eax, eax
                push    eax             ; Size
                mov			eax,malloc
								mov			eax,[eax]
                call    eax
                add     esp, 4
                test    eax, eax
                mov     [ebp+var_1C], eax
                jz      loc_10003F98
                push    ebx
                xor     ebx, ebx
                test    edi, edi
                jle     loc_10003F8E
                mov     edi, eax
                add     esi, 8
                jmp     short loc_10003E90
; ---------------------------------------------------------------------------
                align 10h

loc_10003E90:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+5Bj
                                        ; PreCalculateTreasureClassNoDropTbl+158j
                lea     ecx, [esi-8]
                test    ecx, ecx
                jz      loc_10003F8E
                mov     eax, [esi+0Ch]
                test    eax, eax
                mov     ecx, [esi]
                mov     edx, [esi+4]
                mov     [ebp+var_4], eax
                mov     [ebp+var_C], ecx
                mov     dword ptr [ebp+var_14+4], edx
                jnz     short loc_10003EDA
                mov     eax, edi
                mov     ecx, 7
                jmp     short loc_10003EC0
; ---------------------------------------------------------------------------
                align 10h

loc_10003EC0:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+87j
                                        ; PreCalculateTreasureClassNoDropTbl+A3j
                mov     dword ptr [eax+1Ch], 0
                mov     dword ptr [eax], 0
                add     eax, 4
                sub     ecx, 1
                jnz     short loc_10003EC0
                jmp     loc_10003F7C
; ---------------------------------------------------------------------------

loc_10003EDA:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+7Ej
                fild    [ebp+var_4]
                add     ecx, eax
                mov     [ebp+var_8], ecx
                add     edx, eax
                fstp    [ebp+var_4]
                lea     ecx, [edi+1Ch]
                fild    [ebp+var_8]
                mov     [ebp+var_8], edx
                mov     edx, 7
                fdivr   [ebp+var_4]
                fld     st
                fild    [ebp+var_8]
                fdivr   [ebp+var_4]
                fld     st
                fild    [ebp+var_C]
                fild    dword ptr [ebp+var_14+4]

loc_10003F08:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+13Ej
                fld     st(5)
                add     ecx, 4
                fmulp   st(5), st
                fld     st(4)
                fld     ds:dbl_1000FDF0
                fsub    st, st(1)
                fnstcw  word ptr [ebp+var_4+2]
                movzx   eax, word ptr [ebp+var_4+2]
                or      ah, 0Ch
                fdivr   st, st(3)
                mov     dword ptr [ebp+var_14+4], eax
                fmul    st, st(1)
                fldcw   word ptr [ebp+var_14+4]
                fistp   qword ptr [ebp-14h]
                mov     eax, dword ptr [ebp+var_14]
                mov     [ecx-20h], eax
                fstp    st
                fldcw   word ptr [ebp+var_4+2]
                fld     st(3)
                fmulp   st(3), st
                fld     st(2)
                fld     ds:dbl_1000FDF0
                fsub    st, st(1)
                fnstcw  word ptr [ebp+var_4+2]
                movzx   eax, word ptr [ebp+var_4+2]
                or      ah, 0Ch
                sub     edx, 1
                fdivr   st, st(2)
                mov     dword ptr [ebp+var_14+4], eax
                fmul    st, st(1)
                fldcw   word ptr [ebp+var_14+4]
                fistp   [ebp+var_14]
                mov     eax, dword ptr [ebp+var_14]
                mov     [ecx-4], eax
                fstp    st
                fldcw   word ptr [ebp+var_4+2]
                jnz     short loc_10003F08
                fstp    st
                fstp    st
                fstp    st
                fstp    st
                fstp    st
                fstp    st

loc_10003F7C:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+A5j
                add     ebx, 1
                add     esi, 2Ch
                add     edi, 38h
                cmp     ebx, [ebp+var_18]
                jl      loc_10003E90

loc_10003F8E:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+50j
                                        ; PreCalculateTreasureClassNoDropTbl+65j
                mov     eax, [ebp+var_1C]
                pop     ebx
                pop     edi
                pop     esi
                mov     esp, ebp
                pop     ebp
                retn
; ---------------------------------------------------------------------------

loc_10003F98:                           ; CODE XREF: PreCalculateTreasureClassNoDropTbl+1Aj
                                        ; PreCalculateTreasureClassNoDropTbl+22j ...
                pop     edi
                xor     eax, eax
                pop     esi
                mov     esp, ebp
                pop     ebp
                retn
PreCalculateTreasureClassNoDropTbl endp

CalculateTreasureClassNoDropPatch proc
	; edi=人数
	mov	eax,EnablePreCalculateTCNoDropTbl
	test eax,eax
	jz orig_code
	; 使能预计算的TC NoDrop
	mov     ebx,D2COMMON ; 1.13d 6FDF114Ch
	mov		ebx, [ebx]
	add 	ebx, 0A6214h
	mov     esi, [ebx] ;start address
	add		ebx,4
  mov     ebx, [ebx] ; ds:6FDF1150h
;  test esi,esi
;  jz orig_code
;  test ebx,ebx
;  jz orig_code
  
	mov eax,[esp+3Ch]	; the record address
;	cmp eax,esi
;	jl orig_code
	
;	mov ecx,ebx
;	imul ecx,2Ch
;	mov ebx,esi
;	add ebx,ecx
;	cmp eax,ebx
;	jg orig_code
	
	sub eax,esi
	xor edx,edx
	mov ecx,2Ch
	div ecx
;	test edx,edx
;	jnz orig_code
	
	;eax指向记录序号
	mov ebx,[esp+30h] ;游戏类型d2x=1，d2c=0
	xor ecx,ecx
	test ebx,ebx
	jz d2c
	mov ecx,28
d2c:	
	imul eax,56	;56个字节一条记录
	mov ebx,PreCalculateTCNoDropTbl
	lea ebx,[eax+ebx]
	lea esi,[ebx+ecx]
	dec edi
	dec edi

	mov esi,[esi+edi*4]
	mov [esp+10h],esi
	pop eax
	mov eax,D2GAME
	mov eax,[eax]
	add eax, 0E428Fh ; 1.13d 0D21BFh
	push eax
	ret
orig_code:
	mov ecx,[esp+14h]
	fild dword ptr [esp+10h]
	ret
CalculateTreasureClassNoDropPatch endp

EthBugFix proc
	; edi==item
	cmp dword ptr [edi],4
	jnz orig_code
	mov eax,[edi+14h]
	test eax,eax
	jz orig_code
	mov eax,[eax+18h]
	and eax,400000h
	jz orig_code
Ethereal_Item:
	pushad
	mov ebx,3

	push 0
	push 15h	;mindamage
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 15h
	push edi
	call D2Common_10590_SetStat
	
	push 0
	push 16h	;maxdamage
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 16h
	push edi
	call D2Common_10590_SetStat
	
	push 0
	push 17h	;secondary_mindamage
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 17h
	push edi
	call D2Common_10590_SetStat
	
	push 0
	push 18h	;secondary_maxdamage
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 18h
	push edi
	call D2Common_10590_SetStat
	
	push 0
	push 9Fh	;item_throw_mindamage
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 9Fh
	push edi
	call D2Common_10590_SetStat
	
	push 0
	push 0A0h	;item_throw_maxdamage
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 0A0h
	push edi
	call D2Common_10590_SetStat
	
	push 0
	push 1Fh	;armorclass
	push edi
	call D2COMMON_10550_GetUnitStat
	lea eax,[eax+eax]
	cdq
	div ebx
	push 0
	push eax
	push 1Fh
	push edi
	call D2Common_10590_SetStat
	
	popad
	
orig_code:
	mov eax,D2Common_10193_ChangeCurrentMode
	jmp eax
EthBugFix endp

MFBugFix proc
	; 使用ptGame的QuestRecord进行检查
	pop eax
	pop ecx
	pop ebx
	pop edx
	push eax	; ret addr
orig_code:
	push edx
	push ebx
	push ecx
	call D2Common_10156_GetQuestFlag
	cmp eax,1
	jz over
	;get the ptGame->ptQuest
	mov ecx,[esp+28h]
	mov eax,[ecx+10F4h]
	mov ebx,[eax+0Ch]
	
	test ebx,ebx
	jz over
	movzx   eax, byte ptr [ebp+9Eh]
	
	push 0Fh
	push eax
	push ebx
	call D2Common_10156_GetQuestFlag ; 任务已经完成？
	cmp eax,1
	jz over
	
	movzx   ecx, byte ptr [ebp+9Eh]
	push 1
	push ecx
	push ebx
	call D2Common_10156_GetQuestFlag	; 任务奖励中？
	cmp eax,1
	jz over
	
	movzx   edx, byte ptr [ebp+9Fh]
	movzx   ecx, byte ptr [ebp+9Eh]
	push edx
	push ecx
	push ebx
	call D2Common_10156_GetQuestFlag	;可以进行任务Drop？
over:
	ret
MFBugFix endp

MyCheckSpawnDiabloClone proc
 arg_0           = dword ptr  8
 arg_4           = dword ptr  0Ch
 arg_8           = dword ptr  10h
 arg_C           = dword ptr  14h
 arg_10          = dword ptr  18h
 arg_14          = dword ptr  1Ch

                 push    esi
                 mov     esi, ecx
                 push    edi
                 mov     edi, edx
                 mov eax,DisableDCSpawnInSomeArea
                 test eax,eax
                 jz not_check_level
                 push    edi
                 call    D2COMMON_10691_GetLevelIdFromRoom  ; 11021	; Get Level ID , 1 arg
                 cmp eax,108	; 不能在混沌避难所创建DiabloClone
                 jz loc_6800575C
                 cmp eax,120	; 不能在亚瑞特山脉巅峰创建DiabloClone
                 jz loc_6800575C
                 cmp eax,132	; 不能在6BOSS处创建DiabloClone
                 jg loc_6800575C
not_check_level:
                 mov     ax, [esi+28h]
                 push    eax
                 call    GetGameInfo
                 add     esp, 4
                 test    eax, eax
                 jz      short loc_6800575C
                 mov     ecx, [eax]
                 test    cl, 8
                 jz      short loc_6800575C
                 test    cl, 10h
                 jnz     short loc_6800575C
                 or      ecx, 10h
                 mov     [eax], ecx
                 mov     eax, SpawnMinions
                 test    eax, eax
                 jnz     short loc_68005750
                 mov     ecx, [esp+4+arg_14]
                 mov     edx, [esp+4+arg_C]
                 mov     eax, [esp+4+arg_8]
                 push    ecx
                 mov     ecx, [esp+8+arg_4]
                 push    14Dh            ; 超级Diablo
                 push    edx
                 mov     edx, [esp+10h+arg_0]
                 push    eax
                 push    ecx
                 push    edx
                 mov     edx, edi
                 mov     ecx, esi
                 mov eax,D2GAME_SpawnMonster; D2Game_SpawnMonsterInCurrentRoom
                 call    dword ptr [eax]
                 xor     eax, eax
                 pop     edi
                 pop     esi
                 retn    18h
 ; ---------------------------------------------------------------------------

 loc_68005750:                           ; CODE XREF: CheckSpawnDiabloClone+2Fj
                 mov     eax, [esp+4+arg_14]
                 push    eax
                 push    14Dh
                 jmp     short loc_68005766
 ; ---------------------------------------------------------------------------

 loc_6800575C:                           ; CODE XREF: CheckSpawnDiabloClone+15j
                                         ; CheckSpawnDiabloClone+1Cj ...
                 mov     edx, [esp+4+arg_14]
                 mov     eax, [esp+4+arg_10]
                 push    edx
                 push    eax

 loc_68005766:                           ; CODE XREF: CheckSpawnDiabloClone+6Aj
                 mov     ecx, [esp+0Ch+arg_C]
                 mov     edx, [esp+0Ch+arg_8]
                 mov     eax, [esp+0Ch+arg_4]
                 push    ecx
                 mov     ecx, [esp+10h+arg_0]
                 push    edx
                 push    eax
                 push    ecx
                 mov     edx, edi
                 mov     ecx, esi
                 mov eax,D2GAME_SpawnMonster; D2Game_SpawnMonsterInCurrentRoom
                 call    dword ptr [eax]
                 pop     edi
                 pop     esi
                 retn    18h
MyCheckSpawnDiabloClone endp
end start

;系统报文ID需要+1
;原来是-0x66，现在是-0x67


SpawnAMonster_1 6FD0F870(ecx,edx,arg_0,arg_4,arg_8,arg_C,arg_10=2.4,arg_14=42)
6FC3D678 SpawnAMonster_1 6FD0F870(ecx=170,edx=1,arg_0,arg_4,arg_8,arg_C,arg_10=0FFFFFFFF,arg_14=0)
6FC3D7C5 SpawnAMonster_1 6FD0F870(ecx=129,edx=1,arg_0=[esi],arg_4=esi+8,arg_8=esi+14,arg_C=esi+18,arg_10=3,arg_14)

6FCC6E40 sub_6FCC6E40 (esi,edi,arg_0,arg_4)

6FC40A80 sub_6FC40A80 (ecx,edx(ptUnit?ptGame?MonSeq?),arg_0(hcidx),arg_4) 应该是一个标准的Spawn函数

6FD0F870 SpawnAMonster_1(ecx=hcidx,edx=monseq,arg_0,arg_4,arg_8,arg_C,0FFFFFFFFF,0)
(ecx=1FF,edx=1,arg_0=unk1,arg_4=unk2,arg_8=1416,arg_C=13A5,arg_10=5,arg_14=0)
(ecx=1C5,edx=0,arg_0=save_fp,arg_4=unk,arg_8=x,arg_C=Y,arg_10=FFFFFFFFF,arg_14=0)
(ecx=1EC,edx=C,arg_0=ptGame,arg_4=hroom,arg_8=x,arg_C=Y,arg_10=FFFFFFFFF,arg_14=0)
(ecx=2C1,edx=1,arg_0=ptGame,arg_4=hroom,arg_8=621C,arg_C=1456,arg_10=0FFFFFFFF,arg_14=40)
SpawnMonster_Main
0C	HCIDX
