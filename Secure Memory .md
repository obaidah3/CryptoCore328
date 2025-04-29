## 🔒 Secure Memory Clear Routine

### Purpose:
This assembly routine securely **clears (overwrites) sensitive data** from memory, specifically the `S_table` and `expanded_key`. This is crucial in cryptographic applications to ensure **no residual secrets** are left in RAM after encryption/decryption is done.

---

### 🧠 Memory Regions Affected:

1. `S_table` – typically used in substitution or key scheduling (36 bytes).
2. `expanded_key` – likely stores the round keys for the cipher (12 bytes).

---

### 🔁 Workflow Breakdown:

#### ✅ Zero Register Initialization:
```asm
clr zero_reg
```
- Clears the `zero_reg` (usually `r1`), which is then used as the value `0x00` to overwrite memory.

---

#### 🧹 Clearing `S_table` (36 Bytes):
```asm
ldi ZL, low(s_table)
ldi ZH, high(s_table)
ldi temp_reg, 36
clear_s_loop:
    st Z+, zero_reg
    dec temp_reg
    brne clear_s_loop
```
- Initializes `Z` register (pointer) to the start of `s_table`.
- Iterates 36 times, storing `0x00` in each byte of `s_table`.

---

#### 🧹 Clearing `expanded_key` (12 Bytes):
```asm
ldi ZL, low(expanded_key)
ldi ZH, high(expanded_key)
ldi temp_reg, 12
clear_l_loop:
    st Z+, zero_reg
    dec temp_reg
    brne clear_l_loop
```
- Reuses `Z` register to point to `expanded_key`.
- Iterates 12 times, zeroing each byte.

---

### ✅ Return:
```asm
ret
```
- Cleanly exits the function after memory has been wiped.

---

### 🔐 Why It Matters:
- This is a **best practice in embedded and cryptographic software**, where attackers could analyze RAM after execution to recover sensitive data.
- Ensures **forward secrecy and memory hygiene**, especially important in applications like **ECU security, IoT cryptography, or firmware-based encryption**.
