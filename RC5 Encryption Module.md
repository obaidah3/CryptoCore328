## 🔐 RC5 Encryption Module

The **encryption module** of RC5 takes a plaintext block and produces a ciphertext block using the **expanded key array `S[0:t-1]`**, where `t = 2 * (r + 1) = 18`. It operates on two input words `A₀` and `B₀`, each of `w` bits (16 bits), and applies **r rounds** (typically 8) of data-dependent operations.

<p align="center">
  <img src="https://github.com/user-attachments/assets/27074907-720e-4b72-a6ec-e0175e91c6ee" width="600">
    <br/>
</p>


### 🧠 Inputs:
- `A₀`, `B₀`: 16-bit plaintext words.
- `S[0:17]`: Expanded key array from key-expansion module.
- `r = 8`: Number of encryption rounds.
- `w = 16`: Word size in bits.

### 🔁 Algorithm Overview:

Each round consists of:
- XOR
- Rotate-Left (circular shift)
- Addition modulo `2^w`

#### 📜 Pseudo-Code: RC5 Encryption

```c
A = A + S[0];
B = B + S[1];
for (i = 1; i <= r; i++) {
    A = ((A ^ B) <<< B) + S[2 * i];       // S[2], S[4], ..., S[16]
    B = ((B ^ A) <<< A) + S[2 * i + 1];   // S[3], S[5], ..., S[17]
}
```

### 🔧 Operations Count:
To encrypt one block (32 bits total = 2×16-bit):
- 🔁 8 Rounds
- ➕ `18` additions
- 🌀 `16` Rotate-Left operations
- ✖️ `16` XOR operations

### 🧩 Block Diagram:

The unrolled architecture executes all rounds **in one clock cycle**. This results in:
- Faster encryption (ideal for hardware/FPGAs)
- Larger area due to full unrolling

Each stage of the pipeline performs:
```
[A, B] → XOR → Rotate Left → Add (with key) → [A', B']
```

<p align="center">
  <img src="https://github.com/user-attachments/assets/c18d6b7e-249e-4357-9123-b878a42e5a56" width="600">
    <br/>
</p>

---

