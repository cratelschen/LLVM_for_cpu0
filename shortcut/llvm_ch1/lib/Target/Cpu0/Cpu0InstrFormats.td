//===-- Cpu0InstrFormats.td - Cpu0 Instruction Formats -----*- tablegen -*-===//
//
//                    The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.

//
//===----------------------------------------------------------------------===//
//
// Describe CPU0 instructions format
// Cratels:定义CPU0的指令格式
//
// CPU INSTRUCTION FORMATS
//
// opcode - operation code.
// ra     - dst reg, only used on 3 regs instr.
// rb     - src reg.
// rc     - src reg (on a 3 reg instr).
// cx     - immediate
//
//===----------------------------------------------------------------------===//

// Format specifies the encoding used by the instruction. This is part of the
// ad-hoc solution used to emit machine instruction encodings by our machine
// code emitter.
// Cratels:格式指定指令使用的编码。这是我们的机器码发射器用于发射机器指令编码的临时解决方案的一部分。

// Cratels:这里使用了4个比特，是不是3个就够了？
class Format<bits<4> val>
{
  bits<4> Value = val;
}

def Pseudo      : Format<0>; // Cratels:伪指令
def FrmA        : Format<1>; // Cratels:A类指令的格式
def FrmL        : Format<2>; // Cratels:L类指令的格式
def FrmJ        : Format<3>; // Cratels:J类指令的格式
def FrmOther    : Format<4>; // Instruction w/ a custom format

// Generic Cpu0 Format
class Cpu0Inst<dag outs, dag ins, string asmStr, list<dag> pattern,
               InstrItinClass itin, Format f> : Instruction
{
  // Inst and Size: for tablegen(... -gen-emitter) and
  // tablegen(... -gen-disassembler) in CMakeLists.txt
  // Cratels:定义指令，其长度为32bits
  field bits<32> Inst;

  // Cratels:指令格式
  Format Form = f;

  // Cratels:指令所在namespace
  let Namespace = "Cpu0";

  // Cratels:这里的size是指指令长度
  let Size = 4;

  // Cratels:使用8bits来代表操作符op，最多可以表示64中操作数
  bits<8> Opcode = 0;

  // Top 8 bits are the 'opcode' field
  // Cratels:无论哪种指令，31-24=8bits都是一个独立单元表示op，因此将其提取到基础类中
  let Inst{31-24} = Opcode;

  let OutOperandList = outs;
  let InOperandList  = ins;

  let AsmString = asmStr;
  let Pattern   = pattern;
  let Itinerary = itin;

  // Attributes specific to Cpu0 instructions
  bits<4> FormBits = Form.Value;

  // Cratels:3bits就够用了
  let TSFlags{3-0} = FormBits;

  let DecoderNamespace = "Cpu0";

  field bits<32> SoftFail = 0;
}

//===----------------------------------------------------------------------===//
// Format A instruction class in Cpu0 : <|opcode|ra|rb|rc|cx|>
//===----------------------------------------------------------------------===//

class FA<bits<8> op, dag outs, dag ins, string asmStr,
         list<dag> pattern, InstrItinClass itin>
  : Cpu0Inst<outs, ins, asmStr, pattern, itin, FrmA>
{

  // Cratels:将rb与rc中的数据使用op计算后放进ra中

  // Cratels:返回寄存器编码
  bits<4>  ra;
  // Cratels:输入寄存器编码
  bits<4>  rb;
  // Cratels:输入寄存器编码
  bits<4>  rc;

  // Cratels:辅助操作编码
  bits<12> shamt;

  let Opcode = op;

  let Inst{23-20} = ra;
  let Inst{19-16} = rb;
  let Inst{15-12} = rc;
  let Inst{11-0}  = shamt;
}

//===----------------------------------------------------------------------===//
// Format L instruction class in Cpu0 : <|opcode|ra|rb|cx|>
//===----------------------------------------------------------------------===//

class FL<bits<8> op, dag outs, dag ins, string asmStr,
         list<dag> pattern, InstrItinClass itin>
  : Cpu0Inst<outs, ins, asmStr, pattern, itin, FrmL>
{
  bits<4>  ra;
  bits<4>  rb;
  bits<16> imm16;

  let Opcode = op;

  let Inst{23-20} = ra;
  let Inst{19-16} = rb;
  let Inst{15-0}  = imm16;
}

//===----------------------------------------------------------------------===//
// Format J instruction class in Cpu0 : <|opcode|address|>
//===----------------------------------------------------------------------===//

class FJ<bits<8> op, dag outs, dag ins, string asmStr,
         list<dag> pattern, InstrItinClass itin>
  : Cpu0Inst<outs, ins, asmStr, pattern, itin, FrmJ>
{
  bits<24> addr;

  let Opcode = op;

  let Inst{23-0} = addr;
}
