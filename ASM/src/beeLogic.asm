
;***** GetArrayOffset *********************************************************************************************************
;
; Return the offset to an array in rax
; 
; 

GetArrayOffset									macro index:req, entrySize:req  

												mov rax, index
												mov rbx, entrySize
												mul rbx												

												endm

;-----------------------------------------------------------------------------------------------------------------------
;                                                      																-
; ClearBees                                        																-
;                                                      																-
; Initializes the positions of the bees
;-----------------------------------------------------------------------------------------------------------------------
;                                                      																-
; In:  nothing                                         																-
; Out: nothing                                                        																-
; 
;-----------------------------------------------------------------------------------------------------------------------

ClearBees										proc  																; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local   			holder:qword  									;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers														; Save incoming registers

												xor rdi, rdi ; set index to 0
												mov r8d, team1NumberOfBees ; load number of loops into rdx

SetupInstances_For: 							cmp edi, r8d ; Check if index is equal to number of loops
												je SetupInstances_End_For

												mov eax, 3
												mul edi
												mov ebx, eax
												mov ecx, 200
												div ecx
												mov r11d, edx; load the remainder to r11d, this is our i value
												mov r12d, eax; load the quotent to r12d, this is out j value
												cvtsi2ss xmm1, r11d
												cvtsi2ss xmm0, r12d
												subss xmm1, r255
												subss xmm0, r255

												mov eax, sizeof ( vector3 )
												mul edi
												lea rbx, team1BeeMovementArray
												;movss xmm1, r0
												movss real4 ptr [rbx+rax + vector3.x], xmm1
												movss xmm2, r24p5
												movss real4 ptr [rbx+rax + vector3.y], xmm2
												;movss xmm0, r0
												movss real4 ptr [rbx+rax + vector3.z], xmm0


												lea rbx, team2BeeMovementArray
												;movss xmm1, r0
												movss real4 ptr [rbx+rax + vector3.x], xmm1
												movss xmm2, r49
												movss real4 ptr [rbx+rax + vector3.y], xmm2
												;movss xmm0, r0
												movss real4 ptr [rbx+rax + vector3.z], xmm0

												inc edi
												jmp SetupInstances_For

SetupInstances_End_For:

												mov team1AliveBees, 0
												mov team2AliveBees, 0

												mov team1DeadBees, 0
												mov team2DeadBees, 0
;-----[Zero final return]----------------------------------------------

												xor 				rax, rax  										; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align   			qword 											; Set qword alignment
												Restore_Registers 													; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret   																; Return to caller

ClearBees										endp  																; End function


;***** SetBit *********************************************************************************************************
;
; Sets bit in bit mask array
; cannot use rax or rbx or rdx as parameters
;
; 

SetBit 											macro dest:req, index:req 

												;calculate array index
												mov rax, index
												shr rax, 6
												mov rdx, index
												and rdx, 63
												;Quotient in rax
												;Remainder in rdx	
												mov rbx, qword ptr [dest + rax * 8]
												push rax
												mov rax, 1
												push rcx												
												mov cl, dl
												shl rax, cl ;we now have our bit to set 
												pop rcx
												or rbx, rax
												pop rax
												mov qword ptr[dest + rax * 8], rbx

												endm

;***** ClearBit *********************************************************************************************************
;
; Clears bit in bit mask array
; cannot use rax or rbx or rdx as parameters
;
; 

ClearBit 										macro dest:req, index:req 

												;calculate array index
												mov rax, index
												shr rax, 6
												mov rdx, index
												and rdx, 63
												;Quotient in rax
												;Remainder in rdx		
												mov rbx, qword ptr [dest + rax * 8]
												push rax
												mov rax, 1
												push rcx
												mov cl, dl
												shl rax, cl ;we now have our bit to set 
												pop rcx
												not rax ; now all bits are set to 1 exept the one that should be cleared
												and rbx, rax
												pop rax
												mov qword ptr[dest + rax * 8], rbx

												endm

;***** GetBit *********************************************************************************************************
;
; Returns the bit at given index
; cannot use rax or rbx or rdx as parameters
; result in rax
; 

GetBit 											macro dest:req, index:req 

												;calculate array index
												mov rax, index
												shr rax, 6
												mov rdx, index
												and rdx, 63
												;Quotient in rax
												;Remainder in rdx				
												mov rbx, qword ptr [dest + rax * 8] 												
												mov rax, 1
												push rcx
												mov cl, dl
												shr rbx, cl ;we now have our bit to set 
												pop rcx
												and rax, rbx

												endm


;***** InitBees *********************************************************************************************************
;
; Does not restore registers!
;
; Initialises newly spawned bees
; rcx, index for first bee
; rdx, number of bees
; r8, teamIndex
; 

InitBees										macro

												mov r10, rcx
												mov r11, rdx
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												
												lea r9, team1AliveBees
												add r9, rax

												mov rbx, sizeof(Vector4)
												mov rax, r8
												mul rbx

												lea rcx, team1SpawnPos
												movaps xmm0, xmmword ptr [rcx + rax] ;spawn pos as vector4
												movaps xmm1, xmm0
												shufps xmm1, xmm1, 39h
												shufps xmm1, xmm1, 39h
												xorps xmm2, xmm2
												;xmm1 now holds z in first positon
												movss xmm5, beeMaxSize
												subss xmm5, beeMinSize
												movss xmm4, LR0p00001
												movss xmm6, beeMinSize
												

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team

												lea r15, beeSizes
												mov r15, qword ptr [r15 + rax]

												lea r12, teamNoTargets
												mov r12, qword ptr [r12 + rax] ;no target array for team index
												lea r14, teamHasTargets
												mov r14, qword ptr [r14 + rax] ;has target array for team index

												;We don't clear the target array here since it should not be read if no target bit is set to 1

												
												mov rdi, r10 ;first bee index
												mov rsi, rdi 
												add rsi, r11 ;end index 
												mov rax, sizeof(movement)
												mov rbx, r10
												mul rbx
												mov r11d, randSeed
Init_Bees_Loop:

												
												cmp rdi, rsi
												jge Init_Bees_Loop_End

												movsd qword ptr [rcx + rax], xmm0 ;x, y
												movss real4 ptr [rcx + rax + 8], xmm1 ; z
												
												;set velocity to 0
												movsd qword ptr [rcx + rax + movement.velocity], xmm2 ;x, y
												movss real4 ptr [rcx + rax + movement.velocity + 8], xmm2 ; z
												push rax
												SetBit r12, rdi ;set no target bit to 1
												ClearBit r14, rdi ;set has taget bit to 0	

												xorps xmm3, xmm3
												mov rax, 100000
												push rcx
												mov rcx, r11
												GetRandomNumberMacro
												mov r11, rcx
												pop rcx
												cvtsi2ss xmm3, rax
												mulss xmm3, xmm4 ;0.0 to 1.0
												mulss xmm3, xmm5 
												addss xmm3, xmm6												
												movss real4 ptr [r15 + rdi * 4], xmm3 ;write to size array

												pop rax
												inc dword ptr [r9] ;add 1 to alivebees of the current team

												inc rdi
												add rax, sizeof(movement)
												jmp Init_Bees_Loop
Init_Bees_Loop_End:
												endm



;-----------------------------------------------------------------------------------------------------------------------
;                                                      																-
; SpawnBees                                        																-
;                                                      																-
; Spawns new bees until the total max is reached for the specified team
;-----------------------------------------------------------------------------------------------------------------------
;                                                      																-
; In:  rcx teamIndex                                         																-
; Out: nothing                                                        																-
; 
;-----------------------------------------------------------------------------------------------------------------------

SpawnBees										proc  																; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local   			holder:qword  									;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers														; Save incoming registers

												;keep teamIndex in r8
												mov r8, rcx
												lea rcx, team1AliveBees
												;calc pointer offset to team
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												mov r9d, dword ptr [rcx + rax] ;alive bees for team
												lea rcx, team1DeadBees
												mov r10d, dword ptr [rcx + rax] ;dead bees for team
												mov r12, r10 ; save dead bee count here
												add r10, r9

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team												
											
												lea r13, beeSizes
												mov r13, qword ptr [r13 + rax]
												lea r15, beeRotations
												mov r15, qword ptr [r15 + rax]
												
												lea r14, beeDeadTimers
												mov r14, qword ptr [r14 + rax]
												

												;r9 alive bees
												;r10 now holds number of active bees
												;r11 unused
												;r12 deadbees
												;r13 beeSizes
												;r14 beeDeadTimers
												;r15 beeRotations
												;rcx beeMovements


												mov rdi, starting_bees_per_team
												sub rdi, r10 ;number of bees to spawn

												cmp r12, 0
												je No_Copy

												cmp r12, rdi
												jl Under_Limit
												mov r12, rdi

Under_Limit:												
												xor rsi, rsi ;bee index
												add rsi, r12
												add rdi, r12
Copy_Loop:
												cmp rsi, rdi
												jge No_Copy
												
												
												GetArrayOffset rsi, sizeof(movement)
												movups xmm5, xmmword ptr [rcx + rax] ;position, and x of velocity
												mov r10, qword ptr [rcx + rax + sizeof(xmmword)] ; y and z of velocity 

												movss xmm0, real4 ptr [r13 + rsi * 4] ;save size
												GetArrayOffset rsi, sizeof(Vector3)
												movups xmm1, xmmword ptr [r15 + rax] ;save rotation

												movss xmm4, real4 ptr [r14 + rsi * 4]
												
												GetArrayOffset rdi, sizeof(movement)
												movups xmmword ptr [rcx + rax], xmm5
												mov qword ptr [rcx + rax + sizeof(xmmword)], r10

												movss real4 ptr [r13 + rdi * 4], xmm0
												GetArrayOffset rdi, sizeof(Vector3)
												movsd qword ptr [r15 + rax], xmm1
												shufps xmm1, xmm1, 39h
												shufps xmm1, xmm1, 39h
												movss real4 ptr [r15 + rax + Vector3.z], xmm1
												
												movss real4 ptr [r14 + rdi * 4], xmm4 

												inc rsi
												jmp Copy_Loop
												
No_Copy:												
												sub rdi, r12
												mov rcx, r9 ;start index (alive count)
												mov rdx, rdi ;number of bees
												;r8 already holds team index

												InitBees



;-----[Zero final return]----------------------------------------------

												xor 				rax, rax  										; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align   			qword 											; Set qword alignment
												Restore_Registers 													; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret   																; Return to caller

SpawnBees										endp  																; End function


;-----------------------------------------------------------------------------------------------------------------------
;																													-
; UpdateMovements																										-
;																													-
; Updates the movements of the bees of one team
;-----------------------------------------------------------------------------------------------------------------------
;																													-
; In:  rcx teamIndex																										-
; Out: nothing																														-
; 
;-----------------------------------------------------------------------------------------------------------------------


UpdateMovements									proc																 ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local				holder:qword									;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers														; Save incoming registers
												Save_SIMD_registers

												;keep teamIndex in r8
												mov r8, rcx
												lea rcx, team1AliveBees
												;calc pointer offset to team
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												mov esi, dword ptr [rcx + rax] ;alive bees for team

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team

												lea r12, beeRotations
												mov r12, qword ptr [r12 + rax] ;now hold pointer to the rotations array for the current team

												;setup some local "variables" with registers 
												mov rax, deltaTimeMicros
												cvtsi2ss xmm10, rax
												movss xmm0, r0000001
												mulss xmm10, xmm0 ;delta time in seconds
												movss xmm11, r09
												movss xmm12, r1
												movaps xmm13, xmmword ptr XMMask3
												movss xmm14, r01 
												shufps xmm14, xmm14, 00h
												movss xmm15, r4
												mulss xmm15, xmm10
												shufps xmm15, xmm15, 00h

												mov r11d, randSeed
												xor rdi, rdi ;bee index
												xor r10, r10 ;movement array offset
												xor r13, r13 ;rotation array offset

Movement_Loop:

												cmp rdi, rsi
												jge Movement_Loop_End

												
												;Get position of 2 random ally bees
												mov rax, rsi ;number of alive bees in team
												push rcx
												mov rcx, r11
												GetRandomNumberMacro
												mov r11, rcx
												mov rcx, qword ptr [rsp] ;keep rcx on stack
												;rax now holds our random bee index
												mov rbx, sizeof(movement)
												mul rbx
												movups xmm7, xmmword ptr [rcx + rax] ;position of ally bee

												mov rax, rsi ;number of alive bees in team												
												mov rcx, r11
												GetRandomNumberMacro
												mov r11, rcx
												pop rcx
												;rax now holds our random bee index
												mov rbx, sizeof(movement)
												mul rbx
												movups xmm8, xmmword ptr [rcx + rax] ;position of ally bee

												push rcx
												mov rcx, r11
												GetRandomInsideUnitSphere
												mov r11, rcx 
												pop rcx ;now we pop rcx to remove it from the stack
												;we now have a random point in a unit sphere in xmm0
												mov rax, flight_jitter 
												cvtsi2ss xmm6, rax
												
												mulss xmm6, xmm10 ;delta time
												shufps xmm6, xmm6, 00h
												mulps xmm6, xmm0 ;multiply with random unit sphere point
												movups xmm5, xmmword ptr [rcx + r10] ;position of current bee
												vaddps xmm6, xmm6, xmmword ptr [rcx + r10 + movement.velocity] ; add jitter to velocity
												;calc damping
												movss xmm1, xmm11 ;0.9f
												mulss xmm1, xmm10 ;delta time
												movss xmm3, xmm12 ;1.0f
												subss xmm3, xmm1
												shufps xmm3, xmm3, 00h
												mulps xmm6, xmm3 ;apply damping to velocity

												movaps xmm0, xmm7
												subps xmm0, xmm5 ;diff between current bee and ally target bee
												andps xmm0, xmm13; zero w component
												FastLengthOfVectorFromRegister

												;length is in xmm1, 
												movaps xmm1, xmm0
												maxps xmm1, xmm14 ;0.1f
												mov rax, team_attraction
												cvtsi2ss xmm3, rax
												mulss xmm3, xmm10 ;delta time
												divss xmm3, xmm1 ;divide by distance
												shufps xmm3, xmm3, 00h
												mulps xmm1, xmm3 ;dist * attraction force
												addps xmm6, xmm1 ;add to velocity
												
												movaps xmm0, xmm8
												subps xmm0, xmm5 ;diff between current bee and ally target bee
												andps xmm0, xmm13; zero w component
												FastLengthOfVectorFromRegister

												;length is in xmm1, 
												movaps xmm1, xmm0
												maxps xmm1, xmm14 ;0.1f
												mov rax, team_repulsion
												cvtsi2ss xmm0, rax
												mulss xmm0, xmm10 ;delta time
												divss xmm0, xmm1 ;divide by distance
												shufps xmm0, xmm0, 00h
												mulps xmm1, xmm0 ;dist * repulsion force
												subps xmm6, xmm1 ;sub from vel
												
												movaps xmm0, xmm6 ;store vel here for later
												movsd qword ptr [rcx + r10 + movement.velocity], xmm6 ;write back vel to array x and y
												shufps xmm6, xmm6, 39h
												shufps xmm6, xmm6, 39h
												movss real4 ptr [rcx + r10 + movement.velocity + sizeof(qword)], xmm6 ;write back vel to array z

												
												andps xmm0, XMMask3
												FastNormalizeVectorFromRegister
												movups xmm2, xmmword ptr [r12 + r13]
												subps xmm0, xmm2
												mulps xmm0, xmm15 ;mul by delta time * 4
												addps xmm0, xmm2
												;movaps xmm0, XMRed

												;write direction
												movsd qword ptr [r12 + r13], xmm0
												shufps xmm0, xmm0, 39h
												shufps xmm0, xmm0, 39h
												movss real4 ptr [r12 + r13 + Vector3.z], xmm0

												inc rdi
												add r10, sizeof(movement)
												add r13, sizeof(Vector3)
												jmp Movement_Loop

Movement_Loop_End:

												mov randSeed, r11d 

;-----[Zero final return]----------------------------------------------

												xor					rax, rax										; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align				qword											; Set qword alignment
												Restore_SIMD_registers												; Restore incoming registers
												Restore_Registers													; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret																	; Return to caller

UpdateMovements									endp																 ; End function


;-----------------------------------------------------------------------------------------------------------------------
;																													-
; UpdatePositions																										-
;																													-
; Updates the positions of all the active bees
;-----------------------------------------------------------------------------------------------------------------------
;																													-
; In:  rcx, teamIndex																										-
; Out: nothing																														-
; 
;-----------------------------------------------------------------------------------------------------------------------

UpdatePositions									proc																 ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local				holder:qword									;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers														; Save incoming registers
												Save_SIMD_registers

												
												;keep teamIndex in r8
												mov r8, rcx
												lea rcx, team1AliveBees
												;calc pointer offset to team
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												mov esi, dword ptr [rcx + rax] ;alive bees for team
												lea rcx, team1DeadBees
												add esi, dword ptr [rcx + rax] ;dead bees for team

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team

												mov rax, deltaTimeMicros
												cvtsi2ss xmm10, rax
												movss xmm0, r0000001
												mulss xmm10, xmm0 ;delta time in seconds
												shufps xmm10, xmm10, 00h
												movaps xmm13, xmmword ptr XMMask3

												xor rdi, rdi ;bee index
												xor r10, r10 ;movement array offset

Position_Loop:

												cmp rdi, rsi
												jge Position_Loop_End

												movups xmm5, xmmword ptr [rcx + r10] ;position of current bee, w is garbage
												movups xmm6, xmmword ptr [rcx + r10 + movement.velocity] ; velocity of current bee, w is garbage

												mulps xmm6, xmm10
												addps xmm6, xmm5
												movsd qword ptr [rcx + r10], xmm6 ;write back pos to array x and y
												shufps xmm6, xmm6, 39h
												shufps xmm6, xmm6, 39h
												movss real4 ptr [rcx + r10 + sizeof(qword)], xmm6 ;write back pos to array z


												inc rdi
												add r10, sizeof(movement)
												jmp Position_Loop

Position_Loop_End:

;-----[Zero final return]----------------------------------------------

												xor					rax, rax										; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align				qword											; Set qword alignment
												Restore_SIMD_registers													; Restore incoming registers
												Restore_Registers													; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret																	; Return to caller

UpdatePositions									endp																 ; End function




;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; GetNewEnemyTargets                                                                                                        -
;                                                                                                                      -
; Gets new enemy targets for any bee that needs it
;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; In:  rcx, teamIndex    rdx, enemy teamIndex                                                                                                     -
; Out: nothing                                                                                                                        -
; 
;-----------------------------------------------------------------------------------------------------------------------

GetNewEnemyTargets								proc                                                                  ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local               holder:qword                                      ;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers                                                        ; Save incoming registers

												
												mov r8, rcx ;team index
												mov r12, rdx ;enemy team index
												mov r15d, randSeed
												;calc pointer offset to team
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												lea rcx, team1AliveBees
												mov esi, dword ptr [rcx + rax] ;alive bees for team
												sar esi, 6 ;divide by 64
												inc esi ;we add by one to catch the rest part when not evenly divisible by 64	

												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												lea rcx, teamNoTargets
												mov r9, qword ptr [rcx + rax] ;no target array for team index
												lea rcx, beeTargets
												mov r10, qword ptr [rcx + rax] ;targets array for team index
												lea rcx, teamHasTargets
												mov r8, qword ptr [rcx + rax] ;has target array for team index
												
												;calc pointer offset to enemy team
												mov rax, r12
												mov rbx, sizeof(dword)
												mul rbx
												lea rcx, team1AliveBees
												mov r12d, dword ptr [rcx + rax] ;alive bees for enemy team		

												cmp r12, 0
												je GetTarget_No_Enemies_Alive												
												
												;rcx reserved for mask
												;r8 hasTarget
												;r9 noTarget
												;r10 targets
												;r12 enemyAliveCount
												;r14 bitmask array offset
												;r15 randSeed
									

												xor r14, r14
												xor rdi, rdi
GetTarget_Mask_Loop:												
												cmp rdi, rsi
												jge GetTarget_Loop_Mask_End

												mov rcx, qword ptr[r9 + r14] ;no target
												
												test rcx, rcx
												jz GetTarget_Continue ;no bits are set in this qword
GetTarget_Bit_Loop:												
												tzcnt rbx, rcx
												mov r11, rbx ;hold our bit index

												;get random enemy target index 
												push rcx
												mov rcx, r15 ;random seed
												mov rax, r12 ;alive enemy bees
												GetRandomNumberMacro
												mov r15, rcx ;keep random seed here
												pop rcx

												;write target to target array
												mov r13, rax ;save target index
												mov rax, rdi
												mov rbx, 64 ;bits per qword
												mul rbx
												add rax, r11 ;bee index
												mov r11, rax
												mov rbx, sizeof(dword)
												mul rbx 
												mov dword ptr [r10 + rax], r13d
												;update bit masks
												SetBit r8, r11 ;has target
												ClearBit r9, r11 ;no target
												blsi rax, rcx ;leaves only the least significant bit turned on
												xor rcx, rax ;flip the bit we just handled

												jnz GetTarget_Bit_Loop


GetTarget_Continue:									
												inc rdi
												add r14, sizeof(qword)
												jmp GetTarget_Mask_Loop
GetTarget_Loop_Mask_End:

												mov randSeed, r15d ;store random seed that was kept in r15
GetTarget_No_Enemies_Alive:
;-----[Zero final return]----------------------------------------------

												xor                 rax, rax                                          ; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align               qword                                             ; Set qword alignment
												Restore_Registers                                                     ; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret                                                                   ; Return to caller

GetNewEnemyTargets								endp                                                                  ; End function

;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; Attack                                                                                                        -
;                                                                                                                      -
; Handles attacks of bees of the selected team
;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; In:  rcx, teamIndex rdx, enemyTeamIndex                                                                                                         -
; Out: nothing                                                                                                                        -
; 
;-----------------------------------------------------------------------------------------------------------------------

Attack											proc                                                                  ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local               holder:qword                                      ;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers                                                        ; Save incoming registers

												mov r8, rcx ;team index
												mov r12, rdx ;enemy team index
												movq xmm15, r12
												;calc pointer offset to team
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												lea rcx, team1AliveBees
												mov esi, dword ptr [rcx + rax] ;alive bees for team
												push rsi
												sar esi, 6 ;divide by 64
												inc esi ;we add by one to catch the rest part when not evenly divisible by 64	

												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												lea rcx, beeMovements
												mov r15, qword ptr [rcx + rax] ;team1 bee movements ptr
												lea rcx, teamNoTargets
												mov r9, qword ptr [rcx + rax] ;no target array for team index
												lea rcx, beeTargets
												mov r10, qword ptr [rcx + rax] ;targets array for team index
												lea rcx, teamHasTargets
												mov r8, qword ptr [rcx + rax] ;has target array for team index
												
												;calc pointer offset to enemy team
												mov rax, r12
												mov rbx, sizeof(qword)
												mul rbx
												lea rcx, beeMovements
												mov r13, qword ptr [rcx + rax] ;team2 bee movements ptr

												mov rax, r12
												mov rbx, sizeof(dword)
												mul rbx
												lea rcx, team1AliveBees
												mov r12d, dword ptr [rcx + rax] ;alive bees for enemy team		
												
												;rcx reserved for mask
												;r8 hasTarget
												;r9 noTarget
												;r10 targets
												;r11 beeIndex
												;r12 enemyAliveCount
												;r13 enemyMovements
												;r14 bitmask array offset
												;r15 movements
												;xmm15 enemy teamIndex

												;setup some local "variables" with registers 
												mov rax, deltaTimeMicros
												cvtsi2ss xmm10, rax
												movss xmm0, r0000001
												mulss xmm10, xmm0 ;delta time in seconds												
												movaps xmm11, xmmword ptr XMMask3
									

												xor r14, r14
												xor rdi, rdi
AttackTarget_Mask_Loop:												
												cmp rdi, rsi
												jge AttackTarget_Loop_Mask_End

												mov rcx, qword ptr[r8 + r14] ;hasTarget
												
												test rcx, rcx
												jz AttackTarget_Continue ;no bits are set in this qword
AttackTarget_Bit_Loop:												
												tzcnt rbx, rcx
												mov r11, rbx ;hold our bit index

												;check if target bee is dead
												mov rax, rdi
												mov rbx, 64 ;bits per qword
												mul rbx
												add rax, r11 ;bee index
												cmp rax, qword ptr [rsp] ;alivebeesCount pushed on stack
												jge AttackTarget_Loop_Mask_End
												mov r11, rax
												mov rbx, sizeof(dword)
												mul rbx 
												mov edx, dword ptr [r10 + rax]

												cmp rdx, r12
												jl Target_Alive 
																								
												;set target index to 0 and set no target and clear has target
												
												xor ebx, ebx ;set target index to 0
												mov dword ptr [r10 + rax], ebx
												
												SetBit r9, r11 ;no target
												ClearBit r8, r11 ;has target
												jmp AttackTarget_Bit_Loop_Continue
Target_Alive:												
												
												;Target is alive, try to attack it
												;rdx holds attack target
												push rdx ;save enemy target
												mov rax, sizeof(movement)
												mul rdx

												movups xmm7, xmmword ptr [r13 + rax] ;position of target bee, w is garbage
												
												mov rbx, sizeof(movement)
												mov rax, r11
												mul rbx
												pop rdx ;restore target index
												
												movups xmm5, xmmword ptr [r15 + rax] ;position of current bee, w is garbage
												movups xmm6, xmmword ptr [r15 + rax + movement.velocity] ; velocity of current bee, w is garbage
												push rax ;save movement array offset

												;calc diff between current bee and target
												subps xmm7, xmm5
												movaps xmm0, xmm7
												andps xmm0, xmm11 ;clear w since that hold data outside out vector3
												movaps xmm4, xmm0 ;save diff here 

												FastLengthOfVectorFromRegisterSquared	;leaves length in xmm0
												movaps xmm1, xmm0
												comiss xmm1, attackDistanceSqr 	
												mov rax, attackForce
												mov rbx, chaseForce
												cmova rax, rbx ;if we are not in range we use chase force	

												;move bee towards target with selected force
												movss xmm0, xmm10 ;delta time
												movss xmm2, xmm1
												sqrtss xmm2, xmm2
												divss xmm0, xmm2 ;delta time / distance
												cvtsi2ss xmm2, rax ;get force as float
												mulss xmm0, xmm2
												shufps xmm0, xmm0, 00h ;move our value to all spots
												mulps xmm0, xmm4 ;this now holds vel diff this frame
												addps xmm6, xmm0 ;new velocity

												pop rax ;restore movement array offset 
												movsd qword ptr [r15 + rax + movement.velocity], xmm6 ;write back vel to array x and y
												shufps xmm6, xmm6, 39h
												shufps xmm6, xmm6, 39h
												movss real4 ptr [r15 + rax + movement.velocity + sizeof(qword)], xmm6 ;write back vel to array z
												
												comiss xmm1, hitDistanceSqr
												ja Not_In_Range
												;we are in hit range, kill enemy bee
												push rcx
												push rdx
												mov rcx, rdx ;target index
												movq rdx, xmm15;enemy team index
												LocalCall KillBee
												pop rdx
												pop rcx
												dec r12

Not_In_Range:												


AttackTarget_Bit_Loop_Continue:
												blsi rax, rcx ;leaves only the least significant bit turned on
												xor rcx, rax ;flip the bit we just handled

												jnz AttackTarget_Bit_Loop


AttackTarget_Continue:									
												inc rdi
												add r14, sizeof(qword)
												jmp AttackTarget_Mask_Loop
AttackTarget_Loop_Mask_End:

												pop rsi ;pop pushed alive count from start
;-----[Zero final return]----------------------------------------------

												xor                 rax, rax                                          ; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align               qword                                             ; Set qword alignment
												Restore_Registers                                                     ; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret                                                                   ; Return to caller

Attack									endp                                                                  ; End function

;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; KillBee                                                                                                        -
;                                                                                                                      -
; Kills a bee
;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; In:  rcx, beeIndex rdx, teamIndex                                                                                                         -
; Out: nothing                                                                                                                        -
; 
;-----------------------------------------------------------------------------------------------------------------------

KillBee											proc                                                                  ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local               holder:qword                                      ;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers                                                        ; Save incoming registers

												mov r8, rdx ;team index
												mov rdi, rcx ; bee index

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team

												
												lea r12, teamNoTargets
												mov r12, qword ptr [r12 + rax] ;no target array for team index
												lea r14, teamHasTargets
												mov r14, qword ptr [r14 + rax] ;has target array for team index

												lea r13, beeSizes
												mov r13, qword ptr [r13 + rax]
												lea r15, beeRotations
												mov r15, qword ptr [r15 + rax]

												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												
												lea r9, team1AliveBees
												add r9, rax
												
												lea r11, team1DeadBees
												add r11, rax
												inc dword ptr [r11]

												mov esi, dword ptr[r9]
												dec esi
												mov dword ptr[r9], esi

												;rcx, movement
												;r13 size
												;r15 rotation

												;save position of current bee
												GetArrayOffset rdi, sizeof(movement)
												movups xmm0, xmmword ptr [rcx + rax]
												mov r11, qword ptr [rcx + rax + sizeof(xmmword)]
												;save size 
												movss xmm1, real4 ptr [r13 + rdi * 4]	
												;save rotation		
												GetArrayOffset rdi, sizeof(Vector3)
												movups xmm3, xmmword ptr [r15 + rax]										

												;get data from last alive bee to copy
												GetArrayOffset rsi, sizeof(movement)
												movups xmm5, xmmword ptr [rcx + rax] ;position, and x of velocity
												mov r10, qword ptr [rcx + rax + sizeof(xmmword)] ; y and z of velocity 
												
												;write movement to new dead bee
												movups xmmword ptr [rcx + rax], xmm0
												mov qword ptr[rcx + rax + sizeof(xmmword)], r11

												movss xmm2, real4 ptr [r13 + rsi * 4] ;size

												GetArrayOffset rsi, sizeof(Vector3)
												movups xmm4, xmmword ptr [r15 + rax]	;rotation	
												;write rotation to new dead bee
												movsd qword ptr [r15 + rax], xmm3 
												shufps xmm3, xmm3, 39h
												shufps xmm3, xmm3, 39h
												movss real4 ptr [r15 + rax + Vector3.z], xmm3

												;write size to new dead bee
												movss real4 ptr[r13 + rsi * 4], xmm1
												
												;write data of last alive bee to old bees index
												GetArrayOffset rdi, sizeof(movement)
												movups xmmword ptr [rcx + rax], xmm5
												mov qword ptr [rcx + rax + sizeof(xmmword)], r10
												;size
												movss real4 ptr[r13 + rdi * 4], xmm2

												;rotation
												GetArrayOffset rdi, sizeof(Vector3)
												movsd qword ptr [r15 + rax], xmm4
												shufps xmm4, xmm4, 39h
												shufps xmm4, xmm4, 39h
												movss real4 ptr [r15 + rax + Vector3.z], xmm4
												
												;set dead timer of dead bee
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												lea r9, beeDeadTimers
												mov r9, qword ptr [r9 + rax]
												movss xmm0, r1
												movss real4 ptr [r9 + rsi * 4], xmm0
												

												GetBit r14, rsi ;has target
												cmp rax, 1
												jne No_Target

												SetBit r14, rdi ;has target
												ClearBit r12, rdi ;no target
												jmp	Return											
No_Target:
												SetBit r12, rdi ;no target
												ClearBit r14, rdi ;has target




Return:
;-----[Zero final return]----------------------------------------------

												xor                 rax, rax                                          ; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align               qword                                             ; Set qword alignment
												Restore_Registers                                                     ; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret                                                                   ; Return to caller

KillBee									endp                                                                  ; End function

;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; DeleteBee                                                                                                        -
;                                                                                                                      -
; Deletes a bee
;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; In:  rcx, beeIndex rdx, teamIndex                                                                                                         -
; Out: nothing                                                                                                                        -
; 
;-----------------------------------------------------------------------------------------------------------------------

DeleteBee										proc                                                                  ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local               holder:qword                                      ;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers                                                        ; Save incoming registers

												

												mov r8, rdx ;team index
												mov rdi, rcx ; bee index

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team												
											
												lea r13, beeSizes
												mov r13, qword ptr [r13 + rax]
												lea r15, beeRotations
												mov r15, qword ptr [r15 + rax]

												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												
												lea r9, team1AliveBees
												add r9, rax
												
												lea r11, team1DeadBees
												add r11, rax
												dec dword ptr [r11]

												mov esi, dword ptr[r9]
												add esi, dword ptr[r11]

												GetArrayOffset rsi, sizeof(movement)
												movups xmm5, xmmword ptr [rcx + rax] ;position, and x of velocity
												mov r10, qword ptr [rcx + rax + sizeof(xmmword)] ; y and z of velocity 

												movss xmm0, real4 ptr [r13 + rsi * 4] ;save size
												GetArrayOffset rsi, sizeof(Vector3)
												movups xmm1, xmmword ptr [r15 + rax] ;save rotation
												
												GetArrayOffset rdi, sizeof(movement)
												movups xmmword ptr [rcx + rax], xmm5
												mov qword ptr [rcx + rax + sizeof(xmmword)], r10

												movss real4 ptr [r13 + rdi * 4], xmm0
												GetArrayOffset rdi, sizeof(Vector3)
												movsd qword ptr [r15 + rax], xmm1
												shufps xmm1, xmm1, 39h
												shufps xmm1, xmm1, 39h
												movss real4 ptr [r15 + rax + Vector3.z], xmm1

Return:
;-----[Zero final return]----------------------------------------------

												xor                 rax, rax                                          ; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align               qword                                             ; Set qword alignment
												Restore_Registers                                                     ; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret                                                                   ; Return to caller

DeleteBee									endp                                                                  ; End function

;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; CheckCollisionsWall                                                                                                        -
;                                                                                                                      -
; Checks and handles collisions with walls
;-----------------------------------------------------------------------------------------------------------------------
;                                                                                                                      -
; In:  rcx teamindex                                                                                                         -
; Out: nothing                                                                                                                        -
; 
;-----------------------------------------------------------------------------------------------------------------------

CheckCollisionsWall								proc                                                                  ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local               holder:qword                                      ;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers                                                        ; Save incoming registers
												
												mov r8, rcx ;team index
												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team

												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												
												lea r9, team1AliveBees
												add r9, rax
												
												lea r11, team1DeadBees
												add r11, rax

												mov esi, dword ptr [r9]
												add esi, dword ptr [r11] ;alive + dead

												movss xmm8, r1
												shufps xmm8, xmm8, 00h 	;1
												movaps xmm9, xmmword ptr [XMMaskAbs]
												movaps xmm10, xmmword ptr [XMMask3]
												movss xmm11, r05
												shufps xmm11, xmm11, 00h
												movss xmm12, r08
												shufps xmm12, xmm12, 00h
												movss xmm13, r05n
												shufps xmm13, xmm13, 00h
												movss xmm14, r0n
												shufps xmm14, xmm14, 00h

												xor rdi, rdi
												xor rbx, rbx ;movement offset
For_Loop:
												cmp rdi, rsi
												jge For_Loop_End

												movups xmm5, xmmword ptr [rcx + rbx] ;position of current bee, w is garbage
												movups xmm7, xmmword ptr [rcx + rbx + movement.velocity] ;velocity of current bee, w is garbage
												andps xmm5, xmm10 ;clear w part
												andps xmm7, xmm10 ;clear w part
												movaps xmm4, xmmword ptr [fieldSizeHalf]

												;check if less than field size
												;get absolute value of all dimensions
												movaps xmm6, xmm5
												andps xmm5, xmm9												
												vcmpps xmm0, xmm5, xmm4, 0EH ;position greater than half fieldsize 
												
												;check if bee is outside or not
												pmovmskb rax, xmm0
												test rax, rax
												jz For_Loop_Continue ;if all bits are zero bee is inside field

												movaps xmm3, xmm0 ;save mask here

												;get inverted mask
												BitwiseVectorNot
												movaps xmm2, xmm0

												;calc new position
												;first get the sign of the position
												movaps xmm0, xmm6
												xorps   xmm1, xmm1
												cmpneqps xmm1, xmm0		; mask for non zero values
												andps   xmm0, xmm14    	; x_signbit for all values
												andps   xmm1, xmm8		; 1.0, holds 1 in the spots that had non zero values
												orps    xmm0, xmm1		; apply signbit to all non-zero values

												;multiply sign with fieldsize half
												mulps xmm0, xmm4 	;values clamped inside field
												;mask for the values outside the field
												andps xmm0, xmm3
												movaps xmm1, xmm6 	;position of bee
												andps xmm6, xmm2 	;0 positions that are outside field
												addps xmm6, xmm0	;add new values 
												
												movsd qword ptr [rcx + rbx], xmm6 ;write back pos to array x and y
												shufps xmm6, xmm6, 39h
												shufps xmm6, xmm6, 39h
												movss real4 ptr [rcx + rbx + sizeof(qword)], xmm6 ;write back pos to array z

												;now switch velocity direction and dampen												
												movaps xmm0, xmm13 	;-0.5 
												andps xmm0, xmm3	;any values that were outside field
												mulps xmm0, xmm7
												;dampen the rest
												movaps xmm1, xmm12 	;0.8
												andps xmm1, xmm2
												mulps xmm1, xmm7
												addps xmm0, xmm1

												movsd qword ptr [rcx + rbx + movement.velocity], xmm0 ;write back vel to array x and y
												shufps xmm0, xmm0, 39h
												shufps xmm0, xmm0, 39h
												movss real4 ptr [rcx + rbx + movement.velocity + sizeof(qword)], xmm0 ;write back vel to array z												

For_Loop_Continue:
												inc rdi
												add rbx, sizeof(movement)
												jmp For_Loop
For_Loop_End:
												
;-----[Zero final return]----------------------------------------------

												xor                 rax, rax                                          ; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align               qword                                             ; Set qword alignment
												Restore_Registers                                                     ; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret                                                                   ; Return to caller

CheckCollisionsWall									endp                                                                  ; End function

;-----------------------------------------------------------------------------------------------------------------------
;																													-
; UpdateDead																										-
;																													-
; Updates dead bees
;-----------------------------------------------------------------------------------------------------------------------
;																													-
; In:  rcx, team index																												-
; Out: nothing																														-
; 
;-----------------------------------------------------------------------------------------------------------------------

UpdateDead										proc																 ; Declare function
;------[Local Data]-----------------------------------------------------------------------------------------------------
												local				holder:qword									;

;------[Save incoming registers]----------------------------------------------------------------------------------------
												Save_Registers														; Save incoming registers

												;keep teamIndex in r8
												mov r8, rcx
												lea rcx, team1AliveBees
												;calc pointer offset to team
												mov rax, r8
												mov rbx, sizeof(dword)
												mul rbx
												mov edi, dword ptr [rcx + rax] ;alive bees for team, used as start index
												lea rcx, team1DeadBees
												mov esi, dword ptr [rcx + rax] ;dead bees for team
												add esi, edi

												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												lea r9, beeDeadTimers
												mov r9, qword ptr [r9 + rax]

												lea rcx, beeMovements
												mov rax, r8
												mov rbx, sizeof(qword)
												mul rbx
												mov rcx, qword ptr [rcx + rax] ;now holds a pointer to the movement array for the current team

												mov rax, deltaTimeMicros
												cvtsi2ss xmm10, rax
												movss xmm0, r0000001
												mulss xmm10, xmm0 ;delta time in seconds
												movss xmm11, xmm10
												mulss xmm11, r01
												shufps xmm10, xmm10, 00h
												movaps xmm13, xmmword ptr XMMask3
												xorps xmm14, xmm14
												movss xmm0, gravity
												mulss xmm0, xmm10 ;scale with delta time
												movss xmm14, xmm0 ;gravity in x pos
												shufps xmm14, xmm14, 93h ;move gravity to y, rest contains 0

												mov rax, sizeof(movement)
												mul rdi

For_Loop:
												cmp rdi, rsi
												jge For_Loop_End
											
												movups xmm6, xmmword ptr [rcx + rax + movement.velocity] ;velocity of bee
												addps xmm6, xmm14 ;add gravity to y part of velocity
												;reduce dead timer
												movss xmm0, real4 ptr [r9 + rdi * 4]
												subss xmm0, xmm11
												xorps xmm1, xmm1
												comiss xmm0, xmm1
												ja Not_Dead

												push rcx
												mov rcx, rdi
												mov rdx, r8
												LocalCall DeleteBee
												pop rcx
												jmp Continue
Not_Dead:
												movsd qword ptr [rcx + rax + movement.velocity], xmm6 ;write back vel to array x and y
												movss real4 ptr [r9 + rdi * 4], xmm0
Continue:
												inc rdi
												add rax, sizeof(movement)
												jmp For_Loop
For_Loop_End:

;-----[Zero final return]----------------------------------------------

												xor					rax, rax										; Zero final return

;------[Restore incoming registers]-------------------------------------------------------------------------------------

												align				qword											; Set qword alignment
												Restore_Registers													; Restore incoming registers

;------[Return to caller]-----------------------------------------------------------------------------------------------

ret																	; Return to caller

UpdateDead									endp																 ; End function