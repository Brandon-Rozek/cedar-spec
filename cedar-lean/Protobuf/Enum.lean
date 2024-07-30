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
import Protobuf.BParsec
import Protobuf.Varint
namespace Proto

class ProtoEnum (α : outParam Type) where
  fromInt : Int → Except String α
export ProtoEnum (fromInt)

def parse_enum (α: Type) [ProtoEnum α] : BParsec α := do
  let wdata: Int ← parse_int32
  let result: Except String α := fromInt wdata
  match result with
    | Except.ok r => pure r
    | Except.error e => throw e

def interpret_enum (α: Type) [ProtoEnum α] (b: ByteArray): Except String α :=
  BParsec.run (parse_enum α) b

end Proto
