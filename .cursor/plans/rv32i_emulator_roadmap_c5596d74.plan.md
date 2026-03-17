---
name: RV32I Emulator Roadmap
overview: Zigの学習とRISC-Vアーキテクチャの理解を両立しながら、RV32I基本整数命令セットのエミュレータを段階的に実装し、最終的に「OS in 1000 Lines」をQEMUの代わりに自作エミュレータ上で動かすことを目標とする。
todos:
  - id: phase0
    content: "Phase 0: CPU構造体（レジスタx0-x31, PC）とメモリ構造体（read/write 8/16/32）の定義"
    status: done
  - id: phase1
    content: "Phase 1: 命令デコーダの実装（6フォーマット: R/I/S/B/U/J の各フィールド抽出と即値符号拡張）"
    status: done
  - id: phase2
    content: "Phase 2: ALU命令の実装（R-type 10命令 + I-type 9命令 + U-type 2命令）とメインループ"
    status: done
  - id: phase3
    content: "Phase 3: メモリアクセス命令の実装（Load 5命令 + Store 3命令）"
    status: done
  - id: phase4
    content: "Phase 4: 分岐・ジャンプ命令の実装（B-type 6命令 + JAL + JALR）、アセンブラ・テスト整備"
    status: done
  - id: phase5
    content: "Phase 5: メモリシステムの再設計（RAM を 0x80000000 ベースに、UART/CLINT の MMIO 対応、バイナリロード）"
    status: pending
  - id: phase6
    content: "Phase 6: CSR レジスタの追加（mstatus/mtvec/mepc/mcause/sstatus/stvec/sepc/scause 等）"
    status: pending
  - id: phase7
    content: "Phase 7: CSR 命令の実装（CSRRW/CSRRS/CSRRC と即値版、FENCE は NOP）"
    status: pending
  - id: phase8
    content: "Phase 8: 特権モード（M/S/U）とトラップ処理（ecall/例外→stvec、mret/sret）の実装"
    status: pending
  - id: phase9
    content: "Phase 9: OpenSBI の偽装（起動時の委譲設定、SBI ecall の処理: console_putchar / set_timer）"
    status: pending
  - id: phase10
    content: "Phase 10: タイマー割り込み（CLINT mtime/mtimecmp、割り込み発生とハンドラ遷移）"
    status: pending
  - id: phase11
    content: "Phase 11: 仮想メモリ Sv32（satp によるページテーブルウォーク、ページフォルト例外）"
    status: pending
isProject: false
---

# RV32I エミュレータ in Zig -- 実装ロードマップ

## 最終目標

**OS in 1000 Lines**（ベアメタル RISC-V 向け簡易 OS）を QEMU の代わりに自作エミュレータ上で動かす。

## 参考資料

- [RISC-V Unprivileged ISA Specification (Chapter 2: RV32I)](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html)
- [RISC-V Privileged Architecture Specification](https://github.com/riscv/riscv-isa-manual/releases/latest)
- [Verylで作るCPU](https://cpu.kanataso.net/00-preface.html) -- 特に第3章「RV32Iの実装」の構成を参考
- [A RISC-V emulator in Zig, Part 1](https://undeleted.ronsor.com/a-risc-v-emulator-in-zig-part-1-instruction-decoding/) -- Zigでのデコード手法の参考

## 現在の状態

- Phase 0〜4 完了
- RV32I の全基本命令（ALU/メモリ/分岐/ジャンプ）が動作する
- アセンブラ・テスト整備済み（91テスト通過）
- PC は 0x0 始まり、メモリはフラット配列

---

## Phase 0〜4: 完了 ✅

RV32I 基本命令セット（約40命令）の実装・テスト完了。
詳細は git log を参照。

---

## Phase 5: メモリシステムの再設計

**目的**: OS in 1000 Lines が前提とするアドレスマップを実現する

### アドレスマップ（QEMU virt 互換）

```
0x00001000          リセットベクタ（未使用でも可）
0x02000000          CLINT（mtime / mtimecmp）
0x10000000          UART（コンソールI/O）
0x80000000          RAM 開始（128MB）
0x80200000          カーネルのロードアドレス（リンカスクリプトの . = 0x80200000）
```

### やること

- `memory.zig` をアドレスで振り分ける構造に変更
  - `0x80000000〜` → RAM 配列にオフセット変換してアクセス
  - `0x10000000` → UART（write = `std.debug.print` で文字出力）
  - `0x02000000〜` → CLINT（後の Phase で実装、今は stub）
- カーネルバイナリ（`.bin`）をファイルから読み込み `0x80200000` に配置
- PC 初期値を `0x80200000` に変更
- `main.zig` でコマンドライン引数からバイナリパスを受け取る

---

## Phase 6: CSR レジスタの追加

**目的**: カーネルが使う CSR を保持できるようにする

### やること

- `cpu.zig` に `csr: [4096]u32` を追加
- `csr_read(addr) u32` / `csr_write(addr, value)` を実装
- アクセス時に現在のモードで権限チェック（書き込み禁止 CSR など）

### 実装する主な CSR

```
M-mode:
  0x300 mstatus    現在のモード・割り込み有効フラグ等
  0x301 misa       実装している ISA（固定値で可）
  0x302 medeleg    例外の S-mode 委譲ビットマップ
  0x303 mideleg    割り込みの S-mode 委譲ビットマップ
  0x304 mie        割り込み有効ビットマップ
  0x305 mtvec      M-mode トラップベクタアドレス
  0x340 mscratch   スクラッチレジスタ
  0x341 mepc       トラップ前の PC
  0x342 mcause     トラップ原因コード
  0x343 mtval      トラップ補足情報
  0x344 mip        割り込みペンディングビットマップ

S-mode:
  0x100 sstatus    mstatus のサブセット
  0x104 sie        S-mode 割り込み有効
  0x105 stvec      S-mode トラップベクタアドレス
  0x140 sscratch   スクラッチレジスタ
  0x141 sepc       S-mode トラップ前の PC
  0x142 scause     S-mode トラップ原因コード
  0x143 stval      S-mode トラップ補足情報
  0x144 sip        S-mode 割り込みペンディング
  0x180 satp       ページテーブルベースアドレスとモード

カウンタ（読み取り専用）:
  0xC00 cycle      命令実行数カウント（近似値で可）
  0xC01 time       現在時刻（cycle と同値で可）
```

---

## Phase 7: CSR 命令の実装

**目的**: execute_i_system を完成させる

### 命令エンコーディング（opcode = 0b1110011）

```
funct3:
  0x0: ECALL / EBREAK（funct12 で区別）/ MRET / SRET / WFI
  0x1: CSRRW  rd ← csr; csr ← rs1
  0x2: CSRRS  rd ← csr; csr |= rs1
  0x3: CSRRC  rd ← csr; csr &= ~rs1
  0x5: CSRRWI rd ← csr; csr ← zimm（5ビット即値）
  0x6: CSRRSI rd ← csr; csr |= zimm
  0x7: CSRRCI rd ← csr; csr &= ~zimm

FENCE（opcode = 0b0001111）: NOP として実装
```

### やること

- `executor.zig` の `execute_i_system` に各 CSR 命令を実装
- `mret` / `sret` / `wfi` を funct12 で区別して実装（本実装は Phase 8）
- FENCE を NOP として実装

---

## Phase 8: 特権モードとトラップ処理

**目的**: ecall や例外発生時にカーネルのトラップハンドラへ正しく遷移する

### cpu.zig への追加

```
mode: enum(u2) { U = 0, S = 1, M = 3 }
```

### トラップ発生時の処理（medeleg で S-mode に委譲済みの場合）

```
sepc   ← PC（ecall なら ecall のアドレス）
scause ← 原因コード
         ecall from U-mode = 8
         ecall from S-mode = 9（SBI 呼び出し用）
         タイマー割り込み  = 0x80000005
sstatus.SPIE ← sstatus.SIE
sstatus.SIE  ← 0
sstatus.SPP  ← 現在のモード
PC     ← stvec
mode   ← S
```

### sret の実装

```
PC           ← sepc
mode         ← sstatus.SPP（0=U, 1=S）
sstatus.SIE  ← sstatus.SPIE
sstatus.SPIE ← 1
```

### mret の実装

```
PC           ← mepc
mode         ← mstatus.MPP（OpenSBI 偽装では使わないが実装しておく）
mstatus.MIE  ← mstatus.MPIE
```

---

## Phase 9: OpenSBI の偽装

**目的**: カーネルが SBI ecall を発行したときエミュレータ側で処理し、OpenSBI バイナリなしで起動できるようにする

### 起動時の初期設定（main.zig）

```
// 割り込み・例外を S-mode に委譲
csr_write(mideleg, 0x0222)
csr_write(medeleg, 0xb109)
// S-mode で起動（OpenSBI の mret 相当）
cpu.mode = .S
cpu.pc   = 0x80200000
// スタックトップを a0 に渡す（OS in 1000 Lines の boot() が参照）
cpu.write(10, stack_top)
```

### ecall (S-mode から) の処理

```
a7=0x01 (sbi_console_putchar):
  stdout に a0 の文字を出力
  a0=0, a1=0 をセット

a7=0x00 (sbi_set_timer):
  mtimecmp ← a0（rv32 では a1 が上位32ビット）

a7=0x10 (sbi_get_spec_version):
  a0=0, a1=0x02 (SBI spec v0.2) をセット

共通後処理:
  sepc += 4
  sret と同等の処理で S-mode に戻る
```

---

## Phase 10: タイマー割り込み

**目的**: プロセスのスケジューリングに必要なタイマー割り込みを実装する

### CLINT MMIO

```
0x02004000: mtimecmp (64bit, rv32 では 下位32bit / 上位32bit の2アクセス)
0x0200BFF8: mtime    (64bit, 読み取り専用)
```

### 実装内容

- 命令実行カウンタを `mtime` として返す（実時間でなくてよい）
- 各命令実行後にチェック:
  ```
  mtime >= mtimecmp
  かつ mie.STIE=1（タイマー割り込み有効）
  かつ sstatus.SIE=1
    → scause = 0x80000005（S-mode タイマー割り込み）
    → stvec にジャンプ
  ```

---

## Phase 11: 仮想メモリ Sv32（必要になったら）

**目的**: カーネルが `satp` を設定した後もメモリアクセスが正しく動く

### 実装内容

- `satp.MODE = 1` のとき Sv32 ページテーブルウォークを実施
  - 仮想アドレス[31:22] → VPN[1] → 1段目ページテーブルエントリ
  - 仮想アドレス[21:12] → VPN[0] → 2段目ページテーブルエントリ
  - 物理アドレス = PPN + offset
- ページフォルト例外（Instruction/Load/Store PageFault）の実装
- `sfence.vma` は NOP として実装

---

## 依存関係

```
Phase 5 (メモリ・バイナリロード)
    ↓
Phase 6 (CSR格納)
    ↓
Phase 7 (CSR命令)
    ↓
Phase 8 (トラップ処理 + mret/sret)
    ↓
Phase 9 (SBI偽装)  ←── ここまでで「OS in 1000 Lines」の起動ログが出る見込み
    ↓
Phase 10 (タイマー) ←── プロセス切り替えが動く
    ↓
Phase 11 (Sv32)    ←── 仮想メモリが必要な場合のみ
```

---

## ファイル構成（予定）

```
riscv-zig/
  build.zig
  src/
    main.zig        -- エントリポイント、メインループ、SBI偽装初期化
    cpu.zig         -- CPU構造体（x[32], pc, csr[4096], mode）
    memory.zig      -- アドレスで RAM/UART/CLINT を振り分け
    decoder.zig     -- 命令デコーダ
    executor.zig    -- 命令実行エンジン（CSR命令・トラップ処理を含む）
    assembler.zig   -- 簡易アセンブラ（テスト用）
    test_*.zig      -- 各種テスト
```
