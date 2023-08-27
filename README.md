# cpu-datapath
I designed, tested, and synthesized a  multicycle processor that supports a significant subset of the MIPS instruction set architecture.  

It supports the following MIPS
instructions:

| R-types | I-types | J-types |
| :------ | :------ | :------ |
| `and`   | `andi`  | `j`     |
| `or`    | `ori`   | `jal`   |
| `xor`   | `xori`  | `jr`    |
| `nor`   | `slti`  |         |
| `sll`   | `addi`  |         |
| `srl`   | `beq`   |         |
| `sra`   | `bne`   |         |
| `slt`   | `lw`    |         |
| `add`   | `sw`    |         |
| `sub`   |         |         |
| `nop`   |         |         |
