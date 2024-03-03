# Execution stages

Instruction execution occurs in a series of *stages* (each stage takes 1 clock cycle)

This computer has 6 stages (0 to 5). It counts up to 5 then goes back to 0 then continue (counts using a 3 bit register)

The stage change occurs at negative clock edge so that the signals can be setup properly

Opcode is passed from the instruction register into the controller to do things based on what instruction is executing

Output of the controller is the 12 control signals in [controller.v](../controller.v)

Different stages of different instructions will assert different signals to accomplish different things

___

# Operations

This computer has 4 operations:

| Opcode | Instruction | Description |
| :----: | ----------- | ----------- |
| *0000* | **LDA $x** | Load value at memory location $x into A |
| *0001* | **ADD $x** | Add value at memory location $x with | value in A and store the sum in A
| *0010* | **SUB $x** | Subtract value at memory location $X from value in A and store the difference in A |
| *1111* | **HLT** | Halt program execution |

Every instruction has the same first 3 stages:
- **Stage 0**: Put the PC onto bus and load that value into MAR (*pc_en* -> *mar_load*)
- **Stage 1**: Increment PC (*pc_inc*)
- **Stage 2**: Put value in memory at the MAR address onto the bus and load that into the IR (*mem_en* -> *ir_load*)

Next 3 stages differs from instruction to instruction:

| Stage | LDA | ADD | SUB | HLT |
| ----- | --- | --- | --- | --- |
| **Stage 3** | Put instruction operand onto the bus and load that value into MAR (*ir_en* -> *mar_load*) | Put instruction operand onto the bus and load that value into MAR (*ir_en* -> *mar_load*) | Put instruction operand onto the bus and load that value into MAR (*ir_en* -> *mar_load*) | Halt the clock (*hlt*) |
| **Stage 4** | Put value in memory at the MAR address onto the bus and load that into the A register (*mem_en* -> *a_load*) | Put value in memory at the MAR address onto the bus and load that into the A register (*mem_en* -> *b_load*) | Put value in memory at the MAR address onto the bus and load that into the A register (*mem_en* -> *b_load*) | Idle |
| **Stage 5** | Idle | Put value in the adder onto the bus and load that into the A register (*adder_en* -> *a_load*) | Subtract then put the value in the adder onto the bus and load that into the A register (*adder_sub* -> *adder_en* -> *a_load*) | Idle |
