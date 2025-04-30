## 🔓 RC5 Decryption Module

The **decryption module** of RC5 reverses the encryption process using the same expanded key array `S[0:17]`. It takes the ciphertext block (2×16-bit) and recovers the original plaintext after `r = 8` rounds by **reversing the sequence of operations**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/1c07347e-c65b-41c1-9b83-d9ebb4cc7b38" alt="Simulation Screenshot" width="600">
    <br/>
</p>

### 🧠 Inputs:
- `Aᵣ`, `Bᵣ`: 16-bit ciphertext words (output of encryption).
- `S[0:17]`: Expanded key array.
- `r = 8`: Number of decryption rounds.
- `w = 16`: Word size in bits.

### 🔁 Algorithm Overview:

Each round undoes:
- Addition → Subtraction
- Rotate-Left → Rotate-Right
- XOR → XOR (self-inverse)

#### 📜 Pseudo-Code: RC5 Decryption

```c
for (i = r; i >= 1; i--) {
    B = ((B - S[2 * i + 1]) >>> A) ^ A;
    A = ((A - S[2 * i]) >>> B) ^ B;
}
B = B - S[1];
A = A - S[0];
```

### 🔧 Operations Count:
To decrypt one block:
- 🔁 8 Rounds
- ➖ `18` subtractions
- 🔁 `16` Rotate-Right operations
- ✖️ `16` XOR operations

### 🔄 Block Diagram:

The **unrolled decryption architecture** mirrors the encryption, executing all operations in a single clock cycle. It requires:
- `(2r + 2)` subtractors
- `2r` rotate-right units
- `2r` XOR gates

Each stage works as follows:
```
[A, B] → Subtract (key) → Rotate Right → XOR → [A', B']
```
