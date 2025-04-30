# RC5 Key Expansion

The key-expansion module in the RC5 algorithm is designed to transform a user-supplied secret key `K` into an expanded key array `S`, which is later used during encryption and decryption. This process is essential for ensuring that the cryptographic strength of RC5 is rooted in the variability of the input key.

<p align="center">
  <img src="https://github.com/user-attachments/assets/686e1482-8ffe-4dde-bf48-3dd73a270c1a" width="600">
    <br/>
</p>

---

## 🔐 Overview

- The expanded key array `S` consists of `t = 2 * (r + 1)` words. For `r = 8`, this gives `t = 18`.
- Each word in `S` is of size `w = 16` bits.
- Two *magic constants* are used:
  - `Pw = Odd((e – 2) * 2^w)`  → for `w = 16`, `Pw = 0xB7E1`
  - `Qw = Odd((φ – 1) * 2^w)` → for `w = 16`, `Qw = 0x9E37`
  - `Odd(x)` means the nearest odd integer to `x`

---

## 📋 Step-by-Step Algorithm

### Step 1️⃣: Convert Key K to Words in Array L

The secret key `K[0...b-1]` (in bytes) is copied into a new array `L[0...c-1]` where:
- `b =` number of bytes in `K`
- `u =` bytes per word (`u = w / 8 = 2`)
- `c = ceil(b/u)` → for `b = 12`, `c = 6`

```c
for i = b - 1 downto 0:
    L[i / u] = (L[i / u] <<< 8) + K[i]
```

### Step 2️⃣: Initialize Array S

The array `S` is filled with a deterministic sequence derived from `Pw` and `Qw`:

```c
S[0] = Pw
for i = 1 to t - 1:
    S[i] = S[i - 1] + Qw
```

### Step 3️⃣: Mix in the Secret Key

To combine the key material into the `S` array:
- Perform `3 * max(t, c)` iterations
- For each iteration, update `A`, `B`, `S[i]`, and `L[j]` using circular left shifts

```c
A = B = 0
i = j = 0
for k = 0 to 3 * max(t, c) - 1:
    A = S[i] = (S[i] + A + B) <<< 3
    B = L[j] = (L[j] + A + B) <<< (A + B)
    i = (i + 1) % t
    j = (j + 1) % c
```

---

## 🧠 Summary
- The RC5 key expansion is simple but powerful.
- It mixes the key bytes into a pseudo-random array using rotations and modular addition.
- It ensures high diffusion and resistance against key-recovery attacks.

---

## 📖 Reference
- Full paper: [RC5 Encryption Algorithm (Rivest 1994)](http://people.csail.mit.edu/rivest/pubs/Riv94.pdf)

