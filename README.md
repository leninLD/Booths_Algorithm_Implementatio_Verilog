# Booth's Algorithm Multiplier

A hardware implementation of Booth's Multiplication Algorithm using a finite state machine (FSM) controller and datapath. This design performs signed multiplication of two binary numbers efficiently using fewer addition operations compared to traditional multiplication methods.

## 🚀 Features

- **Signed Multiplication**: Supports both positive and negative numbers in 2's complement format
- **Booth's Algorithm**: Optimized multiplication using bit-pair recoding
- **FSM-based Control**: State machine controller for precise timing and sequencing
- **Parameterized Width**: Configurable bit-width (default: 8-bit)
- **Testbench**: Complete verification with VCD waveform generation

## 📁 File Structure

```
├── README.md               # This documentation
├── control.v              # Control path FSM
├── datapath.v            # Booth multiplier datapath
├── test.v                # Testbench with test cases
└── test.vcd              # Generated waveform file (after simulation)
```

## 🏗️ Architecture

### 1. Control Path (control.v)

The Finite State Machine (FSM) controller that orchestrates the entire multiplication process:

**States:**
- `S0_IDLE (000)`: Wait for start signal
- `S1_LOAD (001)`: Load all registers
- `S2_DECODE (010)`: Examine Q₀ and Q₋₁ bits to decide operation
- `S3_ADD (011)`: Add multiplicand to accumulator
- `S4_SUB (100)`: Subtract multiplicand from accumulator
- `S5_SHIFT (101)`: Arithmetic right shift
- `S6_DONE (110)`: Multiplication complete

**Control Signals:**
- `ld_all`: Load all registers (A, Q, counter, M)
- `add_sub`: 0=add, 1=subtract
- `shift`: Perform arithmetic right shift
- `dec_cnt`: Decrement counter

### 2. Datapath (datapath.v)

The computational unit that performs the actual multiplication:

**Key Components:**
- **A Register**: Accumulator for partial products
- **Q Register**: Stores the multiplier (shifts right)
- **M Register**: Stores the multiplicand (fixed)
- **Q₋₁ Register**: Stores the previous bit of Q
- **Adder/Subtractor**: Performs A ± M operations
- **Counter**: Tracks number of iterations (initialized to WIDTH)
- **Shift Logic**: Performs arithmetic right shift on {A, Q, Q₋₁}

**Operation Flow:**
1. Load multiplicand (M) and multiplier (Q)
2. Based on Q₀ and Q₋₁ bits:
   - `01`: Add M to A
   - `10`: Subtract M from A
   - `00 or 11`: No operation
3. Arithmetic right shift {A, Q, Q₋₁}
4. Decrement counter
5. Repeat until counter reaches zero

### 3. Booth's Algorithm Logic

The algorithm examines bit pairs (Q₀, Q₋₁) to determine operations:

| Q₀ | Q₋₁ | Operation | Explanation |
|---|---|---|---|
| 0 | 0 | Shift | String of 0s - no addition |
| 0 | 1 | Add M | End of a string of 1s |
| 1 | 0 | Subtract M | Start of a string of 1s |
| 1 | 1 | Shift | Middle of a string of 1s |

## 🔧 Implementation Details

### Parameters
- `WIDTH`: Default 8 bits (configurable)
- Product width: 2×WIDTH bits (16 bits for WIDTH=8)

### Signals

**Inputs:**
- `clk`: System clock
- `reset`: Asynchronous reset (active low)
- `start`: Initiate multiplication
- `multiplicand`: Signed input (M)
- `multiplier`: Signed input (Q)

**Outputs:**
- `product`: Final multiplication result (signed)
- `done`: Completion indicator

**Status Signals:**
- `q0`: LSB of Q register
- `q_minus`: Q₋₁ bit (previous Q bit)
- `cnt_zero`: Counter reached zero

## 🧪 Testbench (test.v)

### Test Cases
- `5 × 3 = 15` (positive × positive)
- `-5 × 3 = -15` (negative × positive)

### Simulation

```bash
# Compile and run simulation (using Icarus Verilog)
iverilog -o booth_sim test.v control.v datapath.v
vvp booth_sim

# View waveforms
gtkwave test.vcd
```

### Expected Output
```
Done: 5 * 3 = 15 (expected 15)
Done: -5 * 3 = -15 (expected -15)
```

## ⚙️ How It Works - Step by Step

**Example: 5 × 3**

```
Multiplicand (M) = 5 (0000 0101)
Multiplier (Q) = 3 (0000 0011)
Initial: A = 0000 0000, Q = 0000 0011, Q₋₁ = 0

Step 1: Q₀Q₋₁ = 10 → Subtract M from A
  A = A - M = 0000 0000 - 0000 0101 = 1111 1011 (-5 in 2's complement)
  Shift right: A=1111 1101, Q=1000 0001, Q₋₁=1

Step 2: Q₀Q₋₁ = 11 → Shift only
  Shift right: A=1111 1110, Q=1100 0000, Q₋₁=1

Step 3: Q₀Q₋₁ = 00 → Shift only
  Shift right: A=1111 1111, Q=0110 0000, Q₋₁=0
  ... continues until counter reaches zero

Final Product = 0000 0000 0000 1111 (15)
```

## 📊 Performance Characteristics

- **Latency**: WIDTH clock cycles (plus 1-2 cycles for setup)
- **Throughput**: One multiplication per WIDTH+2 cycles
- **Area**: Moderate (registers, adder, shift logic)
- **Power**: Efficient due to reduced addition operations

## 🔍 Debugging Tips

### Waveform Analysis
Use GTKWave to examine:
- State transitions in control FSM
- Register values (A, Q, M)
- Control signal timing
- Counter decrement

### Common Issues
- **Incorrect product**: Check adder/subtractor logic
- **Stuck in loop**: Verify counter decrement and zero detection
- **Wrong shift**: Confirm arithmetic vs logical shift

### Verification
- Test edge cases (max/min values: -128, 127)
- Test with zero operands
- Test negative × negative cases

## 📚 Theory Behind Booth's Algorithm

Booth's algorithm reduces the number of addition operations in multiplication by:
1. Recognizing strings of 1s in the multiplier
2. Replacing multiple additions with one addition and one subtraction
3. Working efficiently with signed numbers in 2's complement

**Mathematical Basis:**

For a string of 1s from position i to j:

```
2ʲ - 2ⁱ = 2ⁱ(2ʲ⁻ⁱ - 1) = 2ⁱ(1 + 2 + 4 + ... + 2ʲ⁻ⁱ⁻¹)
```

Instead of adding M multiple times, we subtract M at position i and add M at position j+1.

## 🎯 Applications

- Digital Signal Processors (DSP)
- Arithmetic Logic Units (ALU)
- Embedded systems with multiplication requirements
- Educational purposes for computer architecture courses

## 🤝 Contributing

Feel free to:
- Add more test cases
- Implement different bit-width configurations
- Optimize the design for speed/area
- Add pipelining for higher throughput

## 📄 License

This project is available for educational and research purposes.

---

This implementation demonstrates the classic Booth's algorithm using a clean separation of control and datapath, making it ideal for studying computer architecture principles and hardware design methodologies.
