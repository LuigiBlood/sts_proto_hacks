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

// In Course Demo mode:
//Skip camera demo with all buttons except arrows
seek($818A19)
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
