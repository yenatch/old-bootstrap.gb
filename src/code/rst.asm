; rst vectors are single-byte calls.

; Here, farcall is used as a pseudoinstruction.
; This is not the only way rst vectors can or should be used.


section "rst Bankswitch", rom0 [Bankswitch]
	ld [hRomBank], a
	ld [MBC3RomBank], a
	ret

section "rst FarCall", rom0 [FarCall]
	jp FarCall_



section "farcall", rom0

FarCall_:
	ld  [wFarCallHold + 0], a
	put [wFarCallHold + 1], h
	put [wFarCallHold + 2], l

	pop hl
	put [wFarCallBank],        [hli]
	put [wFarCallTarget],      $c8 ; <jp>
	put [wFarCallAddress + 0], [hli]
	put [wFarCallAddress + 1], [hli]
	push hl

	ld hl, wFarCallHold + 1
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [hRomBank]
	push af
	ld a, [wFarCallBank]
	rst Bankswitch

	ld a, [wFarCallHold + 0]

	call wFarCallTarget

	push af

	add sp, 2
	pop af ; hRomBank
	add sp, -4
	rst Bankswitch

	pop af
	ret


pushs
section "farcall wram", wramx

wFarCallHold:    ds 3
wFarCallBank:    db
wFarCallTarget:  db ; jp
wFarCallAddress: dw

pops

