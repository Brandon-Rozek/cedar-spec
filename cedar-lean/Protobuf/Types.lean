/-
 Copyright Cedar Contributors

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-/
/-
Protobuf Native and Wire Types
-/
namespace Proto
inductive PType where
  -- WireType.VARINT
  | int32: PType
  | int64: PType
  | uint32: PType
  | uint64: PType
  | bool: PType
  | enum: PType
  | sint32: PType
  | sint64: PType
  -- WireType.I32
  | sfixed32: PType
  | fixed32: PType
  | float: PType -- TODO: Float is 64 bits in Lean
  -- WireType.I64
  | sfixed64: PType
  | fixed64: PType
  | double: PType
  -- WireType.LEN
  | string: PType
  | message: PType
  | bytes: PType
  | packed (p: PType): PType
deriving Repr

inductive WireType where
  | VARINT : WireType
  | I64: WireType
  | LEN: WireType
  | SGROUP: WireType
  | EGROUP: WireType
  | I32: WireType
deriving Inhabited, Repr, DecidableEq

namespace WireType

def isCompatible (w: WireType) (p: PType) : Bool :=
  match p with
  | PType.int32 => w = WireType.VARINT
  | PType.int64 => w = WireType.VARINT
  | PType.uint32 => w = WireType.VARINT
  | PType.uint64 => w = WireType.VARINT
  | PType.bool => w = WireType.VARINT
  | PType.enum => w = WireType.VARINT
  | PType.sint32 => w = WireType.VARINT
  | PType.sint64 => w = WireType.VARINT
  | PType.sfixed32 => w = WireType.I32
  | PType.fixed32 => w = WireType.I32
  | PType.float => w = WireType.I32
  | PType.sfixed64 => w = WireType.I64
  | PType.fixed64 => w = WireType.I64
  | PType.double => w = WireType.I64
  | PType.string => w = WireType.LEN
  | PType.message => w = WireType.LEN
  | PType.bytes => w = WireType.LEN
  | PType.packed _ => w = WireType.LEN

end WireType
end Proto
