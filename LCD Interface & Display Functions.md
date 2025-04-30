# 📟 AVR LCD Interface & Display Functions – Explanation

This document provides a detailed explanation of the AVR Assembly code used to interface with a **4-bit LCD** and display values such as plaintext and encrypted outputs from an RC5 project.

---

## 🧪 Simulation Snapshots (Proteus)

To help visualize how the LCD routines behave during runtime, real simulation screenshots were captured using Proteus:

📷 **[Click here to view the simulation screenshots](https://github.com/obaidah3/CryptoCore328/blob/main/Proteus%20simulatoin/Screenshots.md#simulation-screenshots)**

These images demonstrate:

- ✅ Proper LCD initialization with message: `RC5 Test_`
- 📥 Displaying plaintext values before encryption.
- 🔁 Correct output of decrypted values matching the original plaintext.

---

## 🔧 LCD Initialization & Communication

### `lcd_init`
Initializes the LCD in 4-bit mode:
- Configures all necessary data and control pins (`RS`, `EN`, `D4–D7`) as outputs.
- Sends the sequence required to set the LCD in 4-bit, 2-line mode.
- Sets display parameters: turn display ON, clear display, entry mode (increment cursor).

---

## 📤 Sending Data to LCD

### `lcd_send_nibble`
Sends **4 bits** (a nibble) to the LCD:
- Extracts individual bits from `temp_reg` and sets the data lines accordingly.
- Generates a pulse on the `EN` pin to latch data.

### `lcd_send_command`
Sends an **8-bit command** to the LCD:
- RS is cleared (instruction mode).
- High nibble is sent first, followed by the low nibble.

### `lcd_send_char`
Sends an **8-bit character** to be displayed:
- RS is set (data mode).
- High and low nibbles are sent just like in `lcd_send_command`.

---

## 🖨️ Printing Functions

### `lcd_print_string`
Prints a null-terminated string stored in program memory (`.db "string", 0`):
- Uses `lpm` to load character from flash memory.
- Calls `lcd_send_char` in a loop.

### `lcd_clear`
Clears the display and returns the cursor to the home position using standard LCD commands (`0x01`, `0x02`).

---

## 📈 Application Display Routines

### `display_values`
Displays **plaintext values**:
- Positions cursor at second line (`0xC0`).
- Loads 16-bit variables `plaintext_a` and `plaintext_b` from SRAM.
- Displays each byte (high and low) as 2-digit hexadecimal using `lcd_print_hex`.

### `display_encrypted`
Similar to `display_values`, but prints encrypted output stored in `result_a` and `result_b`.

---

## 🔢 Hexadecimal Display

### `lcd_print_hex`
Displays a byte in **hexadecimal format**:
- Extracts the high nibble (most significant 4 bits), converts it to ASCII hex digit.
- Sends character via `lcd_send_char`.
- Repeats the process for the low nibble.

Example:
```asm
ldi temp_reg, 0x4F ; Output will be: '4' then 'F'
rcall lcd_print_hex
```

---

## ⏱️ Delay Subroutines

### `delay_1us`, `delay_100us`, `delay_5ms`, `delay_100ms`, `delay_1s`
Software-based delays using nested loops:
- Used to meet LCD timing requirements.
- Prevents timing issues during LCD communication.

---

## 📄 Variables and Assumptions

- `temp_reg` and `rot_val` are general-purpose temporary registers.
- `plaintext_a`, `plaintext_b`, `result_a`, and `result_b` are 16-bit values in SRAM.
- All LCD pins (`LCD_RS`, `LCD_EN`, `LCD_D4–D7`) are predefined as macros using `#define`.

---

## ✅ Summary

This file implements a fully functional LCD interface using AVR Assembly with:
- Initialization and 4-bit communication.
- Byte-wise printing in both characters and hexadecimal format.
- Use cases for displaying encrypted/decoded values (ideal for crypto projects).
- Human-readable structure to facilitate future upgrades (like 32-bit printing or cursor control).

