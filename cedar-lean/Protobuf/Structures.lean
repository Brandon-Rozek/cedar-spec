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
Various Protobuf Structures, likely will reorganize later
-/
import Lean.Data.HashMap
import Protobuf.BParsec
import Protobuf.Varint
import Protobuf.Types

namespace Proto

structure MessageSchema where
  schema: Lean.HashMap Nat PType

structure Tag where
  fieldNum: Nat
  wireType: WireType
deriving Repr, DecidableEq

structure Len where
  size: Nat
  payload: Slice
deriving Repr, DecidableEq

namespace Len
  def parse : BParsec Len := do
    let slice ← BParsec.attempt find_varint
    let isize ← parse_int32 (slice.last - slice.first)
    match isize with
    | Int.negSucc _ => BParsec.fail "Expected positive size in len payload"
    | Int.ofNat size =>
        let slice ← fun it => BParsec.ParseResult.success it (Slice.mk it.pos (it.pos + size))
        pure (Len.mk size slice)
end Len

namespace Tag
@[inline]
def parse : BParsec Tag := do
  let slice ← BParsec.attempt find_varint
  let element ← parse_uint32 (slice.last - slice.first)
  have wt_uint := element &&& 7
  let wire_type ← if wt_uint = 0 then pure WireType.VARINT
                    else if wt_uint = 1 then pure WireType.I64
                    else if wt_uint = 2 then pure WireType.LEN
                    else if wt_uint = 3 then pure WireType.SGROUP
                    else if wt_uint = 4 then pure WireType.EGROUP
                    else if wt_uint = 5 then pure WireType.I32
                    else BParsec.fail "Unexcepted Wire Type"
  have field_num := element >>> 3
  pure (Tag.mk field_num.toNat wire_type)

@[inline]
def interpret (b: ByteArray) : Except String Tag :=
  BParsec.run Tag.parse b

instance : DecidableEq (Except String Tag) := Except.dec_eq
end Tag

#guard Tag.interpret (ByteArray.mk #[08]) = Except.ok (Tag.mk 1 WireType.VARINT)
#guard Tag.interpret (ByteArray.mk #[18]) = Except.ok (Tag.mk 2 WireType.LEN)
#guard Tag.interpret (ByteArray.mk #[50]) = Except.ok (Tag.mk 6 WireType.LEN)

end Proto
