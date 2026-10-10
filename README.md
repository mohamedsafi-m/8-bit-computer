8-Bit Computer in Verilog --- RTL Design and FPGA Implementation
1. Project Overview
This project implements a custom 8-bit computer using Verilog HDL. It is
inspired by SAP-style educational CPU architectures and is built from
modular datapath components controlled by a multi-cycle finite-state
machine (FSM).
The design focuses on understanding how a processor fetches
instructions, decodes opcodes, transfers data between registers,
performs ALU operations, accesses RAM, and controls program flow.
Key specifications
---
Feature                             Implementation
---
HDL                                 Verilog
Datapath width                      8 bits
Program counter width               4 bits
Memory address width                4 bits
RAM organization                    16 × 8 bits
Instruction width                   8 bits
Opcode                              Instruction bits `[7:4]`
Operand                             Instruction bits `[3:0]`
Internal data path                  Shared 8-bit bus
Control                             Multi-cycle FSM / T-state
sequencing
FPGA clock                          100 MHz board clock, divided for
slower CPU execution
Output                              Four-digit seven-segment display
controller
Program initialization              RAM initialized from a `.mem` file
using `$readmemb`
> **Implementation note:** This document reflects the project details
> discussed so far. Confirm the signal behavior and exact FSM
> transitions against the current RTL before treating the tables as a
> cycle-accurate specification.
2. Architecture
The CPU is divided into a datapath and a control unit.
Datapath: PC, MAR, RAM, IR, A register, B register, ALU, flags,
input register, output register, and shared bus.
Control unit: Decodes the current instruction and FSM state,
then asserts control signals over dedicated wires.
Shared data bus: Carries 8-bit data between components. Control
signals are separate wires; they do not travel through the data bus.
Clock divider: Produces a slower clock for observing instruction
execution on hardware.
Display logic: Converts the output-register value to decimal
digits and drives the seven-segment display.
Conceptual data flow
``` text
                 +------------------+
                 |   Control Unit   |
                 | FSM + opcode     |
                 | decode           |
                 +---------+--------+
                           |
                  dedicated control wires
                           |
+--------------------------------------------------------+
|                       Datapath                         |
|                                                        |
| PC <-> MAR <-> RAM <-> IR                               |
|                  |                                     |
|                  +---- Shared 8-bit data bus           |
|                         |       |       |               |
|                       A reg   B reg   Input reg         |
|                         |       |       |               |
|                         +--- ALU <------+               |
|                              |                         |
|                         Flags / A reg                  |
|                              |                         |
|                         Output register                |
+------------------------------+-------------------------+
                               |
                        Display controller
```
The diagram is conceptual: the precise bus connections and control
polarity are defined by the Verilog modules.
3. Instruction Set Architecture (ISA)
Every instruction is one byte:
``` text
  7             4 3             0
 +---------------+---------------+
 | Opcode (4 bit)| Operand (4 bit)|
 +---------------+---------------+
```
The lower nibble is interpreted as a memory address, immediate value, or
jump target depending on the instruction.
Opcode   Mnemonic     Meaning
---
`0000`   `NOP`        No operation
`0001`   `LDA addr`   Load A from RAM: `A ← RAM[addr]`
`0010`   `ADD addr`   Add RAM value to A: `A ← A + RAM[addr]`
`0011`   `SUB addr`   Subtract RAM value from A: `A ← A − RAM[addr]`
`0100`   `STA addr`   Store A in RAM: `RAM[addr] ← A`
`0101`   `LDI imm`    Load the 4-bit immediate into A
`0110`   `JMP addr`   Unconditional jump: `PC ← addr`
`0111`   `JC addr`    Jump if carry flag is set
`1000`   `JZ addr`    Jump if zero flag is set
`1001`   `SFL`        Shift A left
`1010`   `SFR`        Shift A right
`1011`   `XRA addr`   XOR A with RAM value
`1100`   `ANA addr`   AND A with RAM value
`1101`   `INP`        Wait for/accept external input into A
`1110`   `OUT`        Copy A to the output register
`1111`   `HLT`        Halt instruction execution
Instruction notes
`LDA`, `ADD`, `SUB`, `STA`, `XRA`, and `ANA` use the low nibble as a
RAM address.
`LDI` uses the low nibble as a 4-bit immediate. The immediate is
zero-extended to 8 bits when loaded into A.
`JMP`, `JC`, and `JZ` use the low nibble as a 4-bit program address.
`SFL` and `SFR` operate on the accumulator. Their exact
shifted-out-bit and flag behavior depends on the ALU/flag RTL.
`INP` accepts the external 8-bit input through the input register.
In the current design, the `start` control is also used to confirm
input while the FSM is waiting.
`OUT` captures A into the output register for display.
4. Control Signals
The control unit drives these signals through dedicated control wires.
They are not carried over the shared data bus.
---
Signal                              Function
---
`CO`                                Enable PC value onto the bus
`CL`                                Load the PC from the bus
`CE`                                Increment the PC
`OI`                                Load the output register from the
bus
`BI`                                Load the B register from the bus
`SUB1`                              Select ALU subtraction
`ALO`                               Enable ALU result onto the bus
`AO`                                Enable A-register value onto the
bus
`AI`                                Load A register from the bus
`IO`                                Enable the instruction
operand/immediate onto the bus
`II`                                Load the instruction register from
the bus
`RO`                                Enable RAM data onto the bus
`RI`                                Write bus data into RAM
`MI`                                Load MAR from the bus
`HLT1`                              Halt the control unit / CPU
execution
`FE`                                Capture ALU flags into the flag
register
`XRAE`                              Select ALU XOR operation
`ANAE`                              Select ALU AND operation
`INPI`                              Enable input-register data onto the
bus, according to the module's
control convention
`INPO`                              Input-related control signal;
confirm its exact role in the
current `inp_reg` and CU RTL
`SFL1`                              Select ALU shift-left operation
`SFR1`                              Select ALU shift-right operation
> Signal names such as `INPI` and `INPO` are project-specific. Check the
> port directions in `inp_reg` and the CU before changing or documenting
> their precise electrical meaning.
Shared bus behavior
The shared bus carries data, while the CU selects the source and
destination by asserting controls. For example:
`CO` makes the PC value available on the bus.
`MI` makes the MAR capture the bus value.
`RO` makes RAM data available on the bus.
`II` makes the instruction register capture the bus value.
Only one bus source should drive the bus at a time in a tri-state
implementation. If the internal tri-state bus is later replaced with a
mux, the control unit selects the mux source instead.
5. T-State Sequencing
The CPU uses a multi-cycle FSM. The common instruction fetch sequence
is:
T-state   Control signals   Micro-operation
---
`T0`      `CO`, `MI`        `MAR ← PC`
`T1`      `RO`, `II`        `IR ← RAM[MAR]`
`T2`      `CE`              `PC ← PC + 1`
After fetch, the CU decodes the opcode and executes the instruction
using the relevant control sequence. The exact number of execution
cycles depends on the instruction and FSM implementation.
Execution micro-operations
The table below summarizes the execution sequences discussed for the
current RTL. Signals listed together are asserted in the same T-state.
---
Instruction                         Execution sequence after fetch
---
`NOP`                               No datapath operation; proceed to
next fetch
`LDA addr`                          `T3: IO, MI` → `MAR ← IR[3:0]`;
`T4: RO, AI` → `A ← RAM[MAR]`
`STA addr`                          `T3: IO, MI` → `MAR ← IR[3:0]`;
`T4: AO, RI` → `RAM[MAR] ← A`
`ADD addr`                          `T3: IO, MI`; `T4: RO, BI`;
`T5: ALO, AI, FE` → A captures ALU
result and flags capture
`SUB addr`                          `T3: IO, MI`; `T4: RO, BI`;
`T5: SUB1, ALO, AI, FE`
`LDI imm`                           `IO, AI` →
`A ← zero_extend(IR[3:0])`
`JMP addr`                          `IO, CL` → `PC ← IR[3:0]`
`JC addr`                           If carry is set: `IO, CL`;
otherwise continue to next fetch
`JZ addr`                           If zero is set: `IO, CL`; otherwise
continue to next fetch
`XRA addr`                          `T3: IO, MI`; `T4: RO, BI`; ALU XOR
selected; `ALO, AI, FE` captures
result/flags
`ANA addr`                          `T3: IO, MI`; `T4: RO, BI`; ALU AND
selected; `ALO, AI, FE` captures
result/flags
`SFL`                               Select shift-left; enable ALU
result to bus and load A; update
flags if enabled by CU
`SFR`                               Select shift-right; enable ALU
result to bus and load A; update
flags if enabled by CU
`INP`                               Enter input-wait state; when
confirmed, enable external input
path and load A
`OUT`                               `AO, OI` → `OUTREG ← A`
`HLT`                               Assert halt control and remain
halted
Important: This is a readable summary, not a substitute for the
exact CU case statement. Confirm the precise state where `LDI`, jumps,
shifts, and `INP` assert their controls by checking the current `cu`
module.
6. ALU and Flags
The ALU operates on the A and B register values and supports:
---
Operation select                    Operation
---
`SUB1 = 0`, `XRAE = 0`, `ANAE = 0`, Addition: `A + B`
shift selects low
`SUB1 = 1`                          Subtraction: `A − B`
`XRAE = 1`                          Bitwise XOR
`ANAE = 1`                          Bitwise AND
`SFL1 = 1`                          Shift left
`SFR1 = 1`                          Shift right
Only the intended operation select should be active at a time. The
precise ALU priority must match the `case`/conditional logic in `alu`.
Flags
Zero flag (`flag_z`): Indicates whether the ALU result is zero.
Carry flag (`flag_c`): Stores the carry/borrow-related result as
defined by the ALU implementation.
Flag register (`flag_reg`): Captures flag values when `FE` is
asserted.
`JC` tests the carry flag; `JZ` tests the zero flag. For subtraction,
verify whether the implementation defines the carry-related output as
borrow or no-borrow before explaining it as an arithmetic convention.
7. RTL Module Structure
The design is assembled from small Verilog modules.
---
Module                              Responsibility
---
`cpu`                               Top-level integration of CPU
datapath, CU, clock divider, and
display
`clk_div`                           Divides the board clock to produce
a slower CPU clock
`pc`                                4-bit program counter: output,
increment, load, reset
`mar`                               Holds the 4-bit RAM address
`ram`                               16 × 8-bit memory, with program
initialization from `.mem`
`ir`                                Holds the fetched 8-bit instruction
and exposes opcode/operand fields
`a_reg`                             8-bit accumulator
`b_reg`                             8-bit second ALU operand register
`alu`                               Arithmetic, logical, and shift
operations
`flag_reg`                          Stores zero and carry-related flags
`inp_reg`                           Interfaces external input to the
internal datapath
`out_reg`                           Captures CPU output for display
`cu`                                FSM and opcode decode; generates
datapath control signals
`disp_ctrl`                         Scans the display digits and
converts output to decimal digits
`segment_7`                         Converts a BCD digit to
seven-segment patterns
Top-level interface
The current top-level interface discussed for FPGA use is:
``` verilog
module cpu(
    ext_inp, start, clk, rst,
    D0_AN, D0_SEG
);
```
`clk`: board clock (100 MHz).
`rst`: reset input.
`start`: starts CPU execution and is also used to confirm input when
the CPU waits for `INP`.
`ext_inp[7:0]`: external input data.
`D0_AN` and `D0_SEG`: digit-select and segment outputs for the
display.
The display controller should use the fast board clock for refresh,
while the CPU's sequential datapath and RAM use the divided CPU clock
(`clkf`).
8. RAM and Program Initialization
The memory contains 16 locations, each 8 bits wide. The 4-bit address
allows locations `0` through `F`.
The RAM module initializes the program using a memory file, typically
with:
``` verilog
$readmemb("fibonacci.mem", ram);
```
The memory file should contain one 8-bit binary instruction/data value
per line, in the address order expected by the RAM module. The `.mem`
file must be included in the Vivado project and be available to the
simulation and synthesis flow.
RAM should not be cleared by the CPU reset if the same memory is used to
hold the program and data. Reset the CPU registers and control state
separately.
9. Clocking and Reset
The board clock is 100 MHz.
The clock divider produces a slow CPU clock for visible step-by-step
execution.
The RAM and CPU registers must use the intended CPU clock
consistently.
The display refresh logic should use the original fast board clock
to avoid visible flicker.
Check whether reset is active-high or active-low in the board wiring
and XDC. The RTL and physical button polarity must agree.
Reset should clear the PC, instruction/working registers, flags,
output register, and CU state as designed, while preserving
initialized program RAM.
A common debugging symptom is that the display resets but execution
resumes from an old state. In that case, verify that the PC,
accumulator, flags, IR, and CU all receive the same effective reset.
10. Example: Fibonacci Program
The following memory layout is the Fibonacci program previously
discussed for this CPU. It uses the low nibble as the address field and
stores working values in RAM locations `D`, `E`, and `F`.
``` text
Address   Binary      Meaning
0         00011110    LDA E
1         11100000    OUT
2         00111101    ADD D
3         10111100    JC C
4         11100000    OUT
5         00101111    STA F
6         00011110    LDA E
7         00101101    STA D
8         00011111    LDA F
9         00101110    STA E
A         10100010    JMP 2
B         00000000    NOP
C         11110000    HLT
D         00000000    Previous value
E         00000001    Current value
F         00000000    Temporary value
```
This program is intended to output Fibonacci values through the output
register. Because the arithmetic is 8-bit, the carry flag is used to
stop before continuing with an overflowing sum. Confirm the actual
output sequence and halt behavior in simulation for the exact current
program and CU implementation.
11. Simulation and Verification
Recommended checks for the testbench and waveform:
Reset puts the PC at address `0` and initializes the CPU's state as
expected.
`T0` places the PC address on the bus and loads MAR.
`T1` fetches RAM data into IR.
`T2` increments the PC.
The opcode and operand decode correctly.
Memory instructions use the operand as the MAR address.
ALU instructions load B, select the correct operation, and update
A/flags.
`JC` and `JZ` branch only when their respective flags satisfy the
condition.
`INP` waits for the input-confirmation action and then loads
external input.
`OUT` captures A and updates the displayed value.
`HLT` prevents further instruction execution.
Reset clears CPU state even if the CPU clock is slow.
Useful signals to inspect include `clkf`, `bus`, `opcode`, `addr`,
PC/MAR values, A/B outputs, `alu_result`, `flag_z`, `flag_c`, CU state,
and the relevant control wires.
12. FPGA Target and Tools
FPGA board: Real Digital Boolean development board.
FPGA device discussed: Xilinx/AMD `XC7S50-CSGA324-1`.
Tool: AMD Vivado.
Clock: 100 MHz board clock, constrained in the XDC.
Display: Four-digit seven-segment display, with digit and
segment pins assigned in the project's XDC.
The exact pin constraints and I/O standards must match the board's
official master constraints and the current top-level port names.
13. Current Design Scope and Possible Extensions
The current project demonstrates:
Modular RTL design in Verilog
A custom 8-bit instruction set
A shared internal data bus
A multi-cycle control FSM
RAM-based instruction and data storage
ALU operations and condition flags
Conditional and unconditional branches
External input and output
FPGA clock division and seven-segment display output
Potential future extensions include a mux-based internal bus, additional
instructions, improved input debouncing, breakpoint/trace support, and a
more advanced CPU architecture. These are extensions, not claims about
the current implementation.
14. Conclusion
This project builds a small 8-bit computer from explicit RTL modules.
The control unit sequences fetch and execution through T-states, while
independent control wires coordinate data transfers over the shared bus.
The PC, RAM, IR, registers, ALU, and flags implement the datapath, and
the output register connects CPU results to the FPGA display.
The project provides a practical foundation for understanding
instruction execution, FSM-based control, bus transfers, Verilog
simulation, and FPGA implementation.
