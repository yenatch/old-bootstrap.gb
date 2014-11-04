; rst vectors are single-byte calls.

; Here, they're used as pseudoinstructions for bank management.
; This is not the only way the rst instructions can be used.


section "rst Bankswitch", rom0 [Bankswitch]
	jp rst_Bankswitch

section "rst FarCall", rom0 [FarCall]
	jp rst_FarCall


section "Bankswitch", rom0

rst_Bankswitch:
	ld [hTemp], a
	ld a, l
	ld [hTemp + 1], a
	ld a, h
	ld [hTemp + 2], a

	pop hl
	ld a, [hli]
	push hl

	ld [hRomBank], a
	ld [MBC3RomBank], a

	ld hl, hTemp + 2
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, [hTemp]
	ret


BankswitchHome:
	ld [hRomBank], a
	ld [MBC3RomBank], a
	ret


section "FarCall", rom0

rst_FarCall:
	ld [hTemp], a
	ld a, l
	ld [hTemp + 1], a
	ld a, h
	ld [hTemp + 2], a

	ld a, [hRomBank]
	ld [hTemp + 3], a

	pop hl ; Grab the return address.
	inc hl
	inc hl
	inc hl
	push hl ; Put it back, skipping past the arguments.

	; Read the arguments.
	dec hl
	ld a, [hld]
	ld [hTemp + 4], a
	ld a, [hld]
	ld l, [hl]
	ld h, a

	ld a, [hTemp + 3]
	push af

	; Insert hl between sp and the return address (.callback).
	di

	add sp, 2
	push hl

	ld hl, .callback
	add sp, -4
	push hl

	ei

	ld a, [hTemp + 4]
	rst Bankswitch

	ld hl, hTemp + 2
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, [hTemp]

	ret ; pop pc

.callback
	; A little more stack trickery.
	di

	add sp, 2
	push af

	add sp, -4
	pop af
	rst Bankswitch

	add sp, 4
	pop af
	ei

	ret
