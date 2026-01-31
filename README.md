# FPGA DSP Tools (Octave)

This repository provides a small collection of **GNU Octave scripts**
used to generate **fixed-point DSP coefficients and lookup tables**
for FPGA-based audio processing cores.

The focus of this repository is **numerical tooling**, not DSP cores.
All outputs are intended to be consumed directly by **RTL designs**
(FIR, IIR, biquad, non-linear blocks).

---

## Scope and Philosophy

- Fixed-point first (Q-format based)
- Deterministic and hardware-oriented
- No real-time audio processing
- No floating-point runtime dependency in RTL
- Designed to support AXI-Stream / AXI-Lite based FPGA DSP modules

This repository is meant to **support** RTL repositories, not replace them.

---

## Tools Overview

### 1. FIR Coefficient Generator

File: `gen_fir.m`

Generates FIR filter coefficients with configurable:

- Number of taps (NTAPS)
- Cutoff frequency (normalized)
- Window function

Filter form:

```
y[n] = h[0]·x[n] + h[1]·x[n-1] + ... + h[N-1]·x[n-(N-1)]
```

Output:

- `fir_coef.mem`  (Q1.15, one coefficient per line)
- `fir_coef.txt`  (human-readable)

---

### 2. IIR First-Order Coefficient Generator

File: `gen_iir1.m`

Implements a standard first-order IIR filter:

```
y[n] = b0*x[n] + b1*x[n-1] - a1*y[n-1]
```

Supported types:

- Low-pass
- High-pass

Output format (single file):

```
b0
b1
a1
```

Output:

- `iir1_coef.mem`
- `iir1_coef.txt`

---

### 3. IIR Biquad Coefficient Generator

File: `gen_biquad.m`

Standard biquad (Direct Form I):

```
y[n] = b0·x[n] + b1·x[n-1] + b2·x[n-2] - a1·y[n-1] - a2·y[n-2]
```

Supported types:

- Low-pass
- High-pass
- Band-pass

Output format:

```
b0
b1
b2
a1
a2
```

Output:

- `biquad_coef.mem`
- `biquad_coef.txt`

---

## Fixed-Point Format

All coefficients are exported in:

- **Q1.15 signed fixed-point**
- Two’s complement
- Saturated to ±32768

Helper functions:

- `q15.m`       → fixed-point quantization
- `write_mem.m` → `.mem` file writer (1 value per line)

The `.mem` files are directly compatible with:

```verilog
$readmemh("coef.mem", coef_rom);
```

---

## Repository Structure

```
repo_tools_octave/
│
├── gen_fir.m
├── gen_iir1.m
├── gen_biquad.m
│
├── q15.m
├── write_mem.m
│
└── README.md
```

---

## Requirements

- GNU Octave
- Octave package:

    - signal

Load the package explicitly inside scripts:

```
pkg load signal
```

---

## Related FPGA RTL Repositories

The coefficient generators in this repository are designed to be used
together with the following FPGA RTL DSP cores:

- **IIR 1st-Order Stereo Filter (FPGA)**  
  https://github.com/vrm-lab/IIR-1st-Order-Stereo-FPGA

- **FIR Stereo Filter (FPGA)**  
  https://github.com/vrm-lab/FIR-Stereo-FPGA

- **IIR Biquad Stereo Filter (FPGA)**  
  https://github.com/vrm-lab/IIR-Biquad-Stereo-FPGA

These RTL repositories consume the `.mem` coefficient files generated
by the Octave scripts in this repository and implement the corresponding
filters using fixed-point arithmetic.

--- 

## Intended Use

This repository is intended to be used as:

- A coefficient generation toolchain
- A preprocessing step before RTL synthesis
- A companion repository for FPGA DSP cores

It is not intended as:

- A general DSP tutorial
- A floating-point reference implementation
- A real-time audio processing environment

---

## Notes

- Coefficient ordering is explicit and deterministic
- RTL designs must follow the same coefficient order
- Sign conventions for feedback terms must match RTL implementation

---

## License

Licensed under the MIT License.
Provided as-is, without warranty.
