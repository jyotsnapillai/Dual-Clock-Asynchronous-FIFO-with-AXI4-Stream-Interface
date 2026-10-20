# Dual-Clock Asynchronous FIFO with AXI4-Stream Interface

A fully parameterized, dual-clock (asynchronous) FIFO written in Verilog, with an AXI4-Stream slave/master wrapper. The design safely moves data between two unrelated clock domains using Gray-code pointers and 2-flop synchronizers, and is packaged as a reusable Vivado IP block.

Verified with Vivado behavioral simulation (XSim).

---

## Features

- **Dual-clock operation**: independent write clock (`s_axis_aclk`) and read clock (`m_axis_aclk`)
- **Safe clock domain crossing (CDC)**: Gray-code read/write pointers passed through 2-stage synchronizers
- **First-Word Fall-Through (FWFT)** read: the next word is already on the output when the FIFO is not empty
- **AXI4-Stream handshake**: `valid/ready` backpressure on both the slave (write) and master (read) sides
- **Fully parameterized**: configurable data width and depth
- **Vivado IP packaged**: drop-in reusable IP block with AXI4-Stream ports

---

## Architecture

```
axis_async_fifo.v              AXI4-Stream protocol wrapper (top level)
 └── async_fifo_top.v          Core asynchronous FIFO
      ├── fifomem.v            Dual-port memory array, FWFT combinational read
      ├── sync_r2w.v           Read pointer  -> write clock domain (2-FF synchronizer)
      ├── sync_w2r.v           Write pointer -> read clock domain  (2-FF synchronizer)
      ├── wptr_full.v          Write pointer logic + full flag generation
      └── rptr_empty.v         Read pointer logic + empty flag generation
```

### Module summary

| Module | Clock domain | Role |
|---|---|---|
| `axis_async_fifo` | both | Maps AXI4-Stream handshakes onto the FIFO's write/read enables |
| `async_fifo_top` | both | Connects memory, pointer logic and synchronizers |
| `fifomem` | write (write port) / read (async read) | Memory array. Read is combinational: `assign data_out = mem[rd_addr];` |
| `wptr_full` | write | Maintains the write pointer (binary + Gray) and generates `full` |
| `rptr_empty` | read | Maintains the read pointer (binary + Gray) and generates `empty` |
| `sync_r2w` | write | Synchronizes the Gray-coded read pointer into the write domain |
| `sync_w2r` | read | Synchronizes the Gray-coded write pointer into the read domain |

---

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `DATA_WIDTH` | `8` | Width of each FIFO word in bits |
| `ADDR_WIDTH` | `4` | Address width. FIFO depth = `2^ADDR_WIDTH` (16 entries by default) |

---

## Interface

### Slave (write) side, `s_axis_*`

| Signal | Dir | Description |
|---|---|---|
| `s_axis_aclk` | in | Write-domain clock |
| `s_axis_aresetn` | in | Write-domain reset |
| `s_axis_tdata` | in | Write data |
| `s_axis_tvalid` | in | Source has valid data |
| `s_axis_tready` | out | FIFO can accept data (`!full`) |

A write occurs when `s_axis_tvalid && s_axis_tready`.

### Master (read) side, `m_axis_*`

| Signal | Dir | Description |
|---|---|---|
| `m_axis_aclk` | in | Read-domain clock |
| `m_axis_aresetn` | in | Read-domain reset |
| `m_axis_tdata` | out | Read data (FWFT) |
| `m_axis_tvalid` | out | FIFO has data (`!empty`) |
| `m_axis_tready` | in | Sink is ready to accept data |

A read occurs when `m_axis_tvalid && m_axis_tready`.

> Signal names above follow the AXI4-Stream convention used in this project. Check the port list in `axis_async_fifo.v` and adjust this table if any names differ.

---

## How the CDC works

1. Each side keeps its own pointer in binary (to address memory) and in **Gray code** (to cross domains).
2. Only the Gray-coded pointer crosses the clock boundary. Because Gray code changes one bit per increment, a synchronizer that samples mid-transition sees either the old or the new value, never a corrupt one.
3. Each Gray pointer passes through a **2-flip-flop synchronizer** in the destination domain to reduce metastability risk.
4. **Full** is generated in the write domain by comparing the write pointer with the synchronized read pointer. **Empty** is generated in the read domain by comparing the read pointer with the synchronized write pointer.
5. Because pointers are synchronized with a delay, `full` and `empty` are conservative. The FIFO may report full or empty a few cycles later than the true state, but never incorrectly the other way. This is the expected 2-to-3 cycle synchronizer latency.

---

## Verification

Verified with **Vivado behavioral simulation (XSim)** using two testbenches:

| Testbench | Target |
|---|---|
| `tb_async_fifo.v` | Core FIFO (`async_fifo_top`) |
| `tb_axis_async_fifo.v` | AXI4-Stream wrapper (`axis_async_fifo`) |

Scenarios covered:

- Gray-code pointer increments in both domains
- 2-to-3 cycle CDC synchronizer latency on `full` / `empty`
- Backpressure handshakes (`tready` deasserted while the FIFO is full or the sink is stalled)
- Data integrity across asynchronous clocks

---

## Repository structure

```
.
├── rtl/
│   ├── axis_async_fifo.v
│   ├── async_fifo_top.v
│   ├── fifomem.v
│   ├── sync_r2w.v
│   ├── sync_w2r.v
│   ├── wptr_full.v
│   └── rptr_empty.v
├── tb/
│   ├── tb_async_fifo.v
│   └── tb_axis_async_fifo.v
└── README.md
```

> Adjust folder names to match how you organize the repo.

---

## Running the simulation (Vivado XSim)

1. Create a new Vivado project (any part; behavioral simulation only).
2. Add all files in `rtl/` as **design sources** and the testbenches in `tb/` as **simulation sources**.
3. In *Simulation Settings*, set the top module to `tb_async_fifo` or `tb_axis_async_fifo`.
4. Click **Run Simulation → Run Behavioral Simulation**.
5. Inspect the waveform: compare write-domain and read-domain pointers, and the `full` / `empty` flags.

---

## Using it as an IP block

The design was packaged with Vivado's **Create and Package New IP** flow so it can be added to a block design with AXI4-Stream slave and master ports. To reuse it:

1. Add the IP repository path to your Vivado project (*Settings → IP → Repository*).
2. Add **axis_async_fifo** from the IP Catalog.
3. Connect `s_axis_*` to your producer and `m_axis_*` to your consumer, each with its own clock.

---

## Tools

Verilog HDL · Xilinx Vivado · Vivado IP Packager · XSim

---

## Author

**Jyotsna Pillai Raghav**
B.Tech ECE, Vellore Institute of Technology
[LinkedIn](https://linkedin.com/in/jyotsnapillai) · [GitHub](https://github.com/jyotsnapillai)
