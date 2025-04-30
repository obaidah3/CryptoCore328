# 🔐 RC5 Cryptography on AVR (ATmega328P)

A **high-performance AVR Assembly implementation** of the **RC5 symmetric-key encryption algorithm** with **LCD integration**, **manual memory management**, and **secure key handling**. Designed for 8-bit microcontrollers, this project provides a complete educational and functional example of low-level cryptographic systems.

---

## 📑 Table of Contents

- [🔐 RC5 Cryptography on AVR (ATmega328P)](#-rc5-cryptography-on-avr-atmega328p)
- [📌 Features](#-features)
  - [🧠 Optimized Assembly Implementation](#-optimized-assembly-implementation)
  - [🔐 RC5 Cryptographic Algorithm](#-rc5-cryptographic-algorithm)
  - [📺 LCD Integration](#-lcd-integration)
  - [📦 Memory Management](#-memory-management)
  - [⏱️ Robust Delay Routines](#️-robust-delay-routines)
  - [📚 Educational Value](#-educational-value)
- [🧪 How It Works](#-how-it-works)
- [🔧 Configuration Parameters](#-configuration-parameters)
- [📷 Demo](#-demo)
- [🔐 Security Considerations](#-security-considerations)
- [📘 Use Cases](#-use-cases)
- [🛠 Hardware Requirements](#-hardware-requirements)
- [🛠️ Toolchain & Simulation](#️-toolchain--simulation)
- [📂 Project Structure](#-project-structure)
- [🚧 Limitations](#-limitations)
- [🧠 Future Improvements](#-future-improvements)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)
- [📚 References](#-references)
- [💬 Author](#-author)

---


## 📌 Features

### 🧠 Optimized Assembly Implementation
- **AVR-Specific Optimization:** Written entirely in AVR Assembly, tailored for the **ATmega328P**.
- **Direct Hardware Control:** Uses **bare-metal register manipulation** for GPIO and SRAM operations—no Arduino libraries or abstractions.

### 🔐 RC5 Cryptographic Algorithm
<p align="center">
  <img src="https://github.com/user-attachments/assets/2c2349ea-4330-4c62-b272-a90421666ca6" width="450"/>
<br/>
</p>

- **Fully Compliant RC5:**  
  - **Word Size:** 16-bit  
  - **Rounds:** 8 (configurable via `ROUNDS` constant)  
  - **Key Length:** 12 bytes  
  - **Expanded Key Table (S):** 18 words (S[0] to S[17])  
- **Secure Key Expansion:** Implements the full RC5 key scheduling process using:
  - `Pw = 0xB7E1`  
  - `Qw = 0x9E37`  
- **Sensitive Data Wiping:** A `secure_clear` routine clears secret data (keys, S-table) from SRAM after use to prevent key extraction (cold-boot attack mitigation).

### 📺 LCD Integration
- **16x2 Character LCD** displays:
  - Plaintext
  - Encrypted ciphertext
  - Decrypted result (validation)
- **Bit-Banged Control:** Minimal pin usage with efficient LCD driving via bit-level operations on **PORTD (6 pins total).**

### 📦 Memory Management
- SRAM layout avoids overlapping of buffers, key storage, and the S-table.
- Correct handling of **little-endian** 16-bit data storage.

### ⏱️ Robust Delay Routines
- Calibrated `delay_1us`, `delay_100ms`, and other delay routines for:
  - LCD timing requirements
  - Human-readable output pacing

### 📚 Educational Value
- Demonstrates a full **symmetric encryption workflow** on microcontrollers.
- Provides insight into:
  - Key expansion
  - Block encryption and decryption
  - Secure memory handling
  - Low-level register manipulation on AVR

---

## 🧪 How It Works

1. **Initialization:**
   - Loads sample plaintext: `A0 = 0x1C34`, `B0 = 0xA2C3`
   - Dynamically expands a 12-byte key into the 18-entry S-table
2. **Encryption:** Uses RC5 algorithm with 8 rounds
3. **Decryption:** Validates output by comparing to original plaintext
4. **Display:** Results shown on LCD for inspection

---

## 🔧 Configuration Parameters

| Parameter        | Value     | Description                            |
|------------------|-----------|----------------------------------------|
| `w`              | 16 bits   | Word size                              |
| `r`              | 8         | Number of encryption rounds            |
| `b`              | 12 bytes  | Secret key length                      |
| `c`              | 6         | Words in key (b / u)                   |
| `t`              | 18        | Size of S-table (`2*(r + 1)`)          |
| `n`              | 54        | Iterations in key expansion (`3 * max(t, c)`) |
| `Pw`             | `0xB7E1`  | Constant for key expansion             |
| `Qw`             | `0x9E37`  | Constant for key expansion             |

---

## 📷 Demo

> ✅ LCD Output Example:
```
Plaintext:  1C34 A2C3
Encrypted:  XXXX YYYY
Decrypted:  1C34 A2C3
```
_Confirms round-trip encryption integrity._

---

## 🔐 Security Considerations

- ✅ **Key Sanitization:** Secure erase after use
- ❌ **No Side-Channel Protections:** Not hardened against timing/power attacks
- ❌ **Fixed Key Size:** Only supports 12-byte keys (can be extended)

---

## 📘 Use Cases

- 🔧 **Cryptographic Education:** Teaches block ciphers and key expansion
- 🔐 **Secure IoT Prototypes:** Lightweight encryption for embedded applications
- 🧵 **Assembly Language Projects:** Real-world demonstration of AVR Assembly mastery

---

## 🛠 Hardware Requirements

- **Microcontroller:** ATmega328P (e.g., Arduino Uno)
- **Display:** 16x2 Character LCD
- **Power Supply:** 5V regulated
- **Pins Used:** 6 GPIO pins on PORTD for LCD


---

## 🛠️ Toolchain & Simulation

- **Simulator:** [Proteus Design Suite](https://www.labcenter.com/) was used to simulate the hardware behavior, including the ATmega328P microcontroller and 16x2 LCD.  
  > **⚠️Important Note:** When running the simulation, **ensure you load the correct hex file** generated by the assembler compiler (Assembly language). Proteus relies on the compiled **hex file**, and **not the source assembly code** directly. Using an incorrect file may result in inaccurate simulation behavior, so always double-check that the hex file is the one produced after assembly compilation.

- **Compiler/IDE:** The project was developed and compiled using **AVR Studio (by Atmel, now Microchip)** with Microsoft integration, enabling low-level AVR Assembly development and debugging.

---

## 📂 Project Structure

```
/rc5-assembly-avr/
│
├── rc5.asm             # Main RC5 algorithm (encryption + decryption)
├── key_expansion.asm   # Key expansion module
├── lcd.asm             # LCD display routines
├── delay.asm           # Delay subroutines
├── secure_clear.asm    # Memory wipe routine
├── Makefile            # Build script for AVR-GCC
└── README.md           # You're here!
```

---

## 🚧 Limitations

- ⚠ **AVR-Specific Code:** Not portable to ARM or RISC-V without rewriting
- 🔒 **Not Production-Grade Security:** Lacks side-channel protections
- 🧱 **Fixed Config:** Key size and rounds are constants in this implementation

---

## 🧠 Future Improvements

- [ ] Add side-channel resistance (e.g., constant-time logic)
- [ ] Make rounds and key size dynamically configurable
- [ ] Add UART/Serial output for remote monitoring

---

## 🤝 Contributing

Pull requests are welcome! Whether it's:
- Porting to other AVR chips
- Adding parameter configuration via UART
- Extending the encryption algorithm

Feel free to fork and enhance!

---

## 📜 License

This project is released under the **MIT License**.

---
## 📚 References

- **RC5 Specification:**  
  Rivest, R. L. (1994). *The RC5 Encryption Algorithm*. [MIT Technical Report](http://people.csail.mit.edu/rivest/pubs/Riv94.pdf).  
  A foundational paper describing the RC5 symmetric-key block cipher algorithm in detail.

- **AVR Instruction Set Manual:**  
  Atmel Corporation. *AVR Instruction Set Manual - Complete List of Opcodes and Descriptions.*  
  Available in the [ATmega328P Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/ATmega328P-Complete-DS-DS40002061B.pdf), covering AVR assembly, registers, and RTL instructions.

- **Proteus Design Suite Documentation:**  
  Labcenter Electronics. *Official Proteus Documentation and Tutorials.*  
  Available at [https://www.labcenter.com](https://www.labcenter.com) — covers simulation setup, component libraries, and virtual debugging.

- **16x2 LCD Datasheet (HD44780 Controller):**  
  Hitachi. *HD44780U LCD Controller Datasheet.*  
  [Download PDF](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf) — details instruction set, pinout, timing diagrams, and character generation.

  RC5 is designed by Rivest, which is a symmetric-key block cipher notable for its simplicity (http://people.csail.mit.edu/rivest/pubs/Riv94.pdf) 

---
## 💬 Author

**Obaidah Essam**  
🚗 Embedded Systems | 🛡 Cybersecurity | 🌐 IoT & Cloud for Smart Vehicles  
🔗 [LinkedIn](https://www.linkedin.com/in/abdulrahman-essam-a600202a9/)





