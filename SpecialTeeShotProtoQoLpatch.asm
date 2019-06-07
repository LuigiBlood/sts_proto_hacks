// Special Tee Shot (1992 Prototype) - Quality of Life Patch
// by LuigiBlood

// Requires ARM9 bass fork

arch snes.cpu

//LoROM
macro seek(n) {
  origin (({n} & $7F0000) >> 1) | ({n} & $7FFF)
  base {n}
}

macro seekFile(n) {
  origin {n}
  base {n}
}

//Change the filename to the original ROM file accordingly
seekFile(0)
insert "StS_proto_trim.sfc"

// Add Header for better emulator support
seek($80FFC0)
    db "SPECIAL TEE SHOTPROTO"      //Name
    db $30                          //ROM Speed / Map (FastROM / LoROM)
    db $02                          //Chipset (ROM+RAM+Battery)
    db $0A                          //ROM Size: 1 MB
    db $03                          //RAM Size: 8 KB
    db $01                          //Country (North America / NTSC)
    db $01                          //Developer ID: Nintendo (01)
    db $FF                          //Version
    dw $0000,$FFFF                  //Checksum

// QoL - Leave curve path enabled
// 7EC859 - calculated curve flag
// 7EC85B - enables curve path
// 7EC887 - Angle (if not 0 then it's an angled shot)

seek($80F316)
    lda $C887

//Has something to do with the curve tip
seek($83C9B7)
    lda $C887

seek($82B4D4)
    lda $C887

//Camera anchor to end of curve path after Free Look
seek($82B2DF)
    lda $C887

//Camera anchor to end of curve path when aiming
seek($82B3B4)
    ldy $C887

//Make Start button work by skipping the other camera code and not loop back
seek($82B3C2)
    jmp $B3D7


// QoL - Reverse Left/Right Putt for better clarity
// 7ec923? 83D043? 7ec919?
// 7ec919 * 5 + CA6F
seek($81CA6F)
    db $2B,$0A
    dl $800736

    db $2B,$0A
    dl $800236

    db $2B,$09
    dl $80FC36

    db $2B,$0A
    dl $80F636

    db $2B,$0A
    dl $80F136


// QoL - Don't edit a signature after the member was created (maybe add a button to let users do that)
seek($83FCB4)
    nop
    nop
    nop
    nop


// QoL - Change controls to be more like final
// $7E0051 - Joypad 1 Hold
// $7E0053 - Joypad 2 Hold
// $7E0059 - Joypad 1 Press
// $7E005B - Joypad 2 Press

// $7E1A2C - Current Joypad ID
// $7E005D - Current Joypad Hold
// $7E0061 - Current Joypad Press

// In Gameplay Mode:
// Cancel Putt to B/Y/X
seek($83CFF9)
    bit.w #$C040

// Free Look to B/Y/X
seek($82B23A)
    and.w #$C040

// Map / Result access to Select
seek($82B342)
    and.w #$2000

// See Angle / Direction to L/R
seek($82B248)
    and.w #$0030
seek($82B357)
    bit.w #$0030

// Direction change 45° Anchor
// $7EC885 - Direction (0 = 90°, south east for some reason)

// Right
seek($82B5D3)
    lda.w #$0003
    jmp turn_right45_check

seek($82B5DC)
    lda.w #$0001
    jmp turn_right45_check

// Left
seek($82B618)
    lda.w #$0003
    jmp turn_left45_check

seek($82B621)
    lda.w #$0001
    jmp turn_left45_check

seek($82C4E0)
turn_directions:
    dw $0000, $002D, $005A, $0087, $00B4, $00E1, $010E, $013B, $0000
turn_right45_check:
    phx
    pha
    //Check if R button is held
    lda $005D
    and #$0010
    beq turn_right45_normal
    
    //Compare to a set of directions (X) < A
    ldx.w #$0010
    lda $C885
turn_right45_loop:
    dex
    dex
    bmi turn_right45_last
    beq turn_right45_last
    cmp turn_directions,x
    bcc turn_right45_loop
    bra turn_right45_equal
turn_right45_last:
    ldx.w #$000E
    bra turn_right45_load
turn_right45_equal:
    dex
    dex
turn_right45_load:
    lda $0061
    and.w #$0100
    beq turn_right45_return
    lda turn_directions,x
    sta $C885
turn_right45_return:
    pla
    plx
    jmp $B5EC

turn_right45_normal:
    pla
    plx
    cmp.w #3
    bcc turn_right45_normal1
turn_right45_normal3:
    lda $C885
    sec
    sbc.w #$0003
    jmp $B5E3
turn_right45_normal1:
    inc $C8AF
    lda $C885
    dec
    jmp $B5E3


turn_left45_check:
    phx
    pha
    //Check if R button is held
    lda $005D
    and #$0010
    beq turn_left45_normal
    
    //Compare to a set of directions (X) > A
    ldx.w #$FFFE
    lda $C885
turn_left45_loop:
    inx
    inx
    cpx #$0010
    bcs turn_left45_last
    cmp turn_directions,x
    bcs turn_left45_loop
    bra turn_left45_load
turn_left45_last:
    ldx.w #$0000
    bra turn_left45_load
turn_left45_equal:
    inx
    inx
turn_left45_load:
    lda $0061
    and.w #$0200
    beq turn_left45_return
    lda turn_directions,x
    sta $C885
turn_left45_return:
    pla
    plx
    jmp $B633

turn_left45_normal:
    pla
    plx
    cmp.w #3
    bcc turn_left45_normal1
turn_left45_normal3:
    lda $C885
    clc
    adc.w #$0003
    jmp $B628
turn_left45_normal1:
    inc $C8AF
    lda $C885
    inc
    jmp $B628

// In Course Demo mode:
//Skip camera demo with all buttons except arrows
seek($818A19)
    and.w #$F0F0

//Skip ball counter animation
seek($83A912)
    and.w #$F0F0
seek($83A835)
    and.w #$F0F0

//Skip shot counter animation
seek($83E67C)
    and.w #$F0F0

// In Choose Shot / "Pause" menu:
// Free Look to B/X (Y could be used for Select Ball, just in case)
// You can select ball if 7EEAFC is 0001
seek($83E96F)
    and.w #$8040

// Map / Result access to Select
seek($83E9B6)
    and.w #$2000

// QoL - Skip to putt stuff
seek($83E6D6)
    bra $83E6EE


// Map / Result mode:
seek($82BDE1)   // Go to Results with A / Start
    and.w #$1080

seek($82BDEE)   // Go back with B/X/Y/Select
    and.w #$E040

seek($84A8CA)   // Go back to gameplay from Results
    lda.w #$F0C0
