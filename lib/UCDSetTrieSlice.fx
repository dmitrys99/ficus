//
// Этот файл является частью проекта
// "Язык программирования Фикус"
//
// Лицензионное соглашение находится в файле LICENSE
//
// ==================================================

val CHUNK_SIZE = 64u32;

class triesetslice_t = {
    tree1_level1: uint64[]
    tree2_level1: uint8[]
    tree2_level2: uint64[]
    tree3_level1: uint8[]
    tree3_level2: uint8[]
    tree3_level3: uint64[]
}

fun triesetslice_t.chunk_contains(cp: uint32, chunk: uint64): bool {
    ((chunk >> (cp & 0b111111u32)) & 1u64) == 1u64
}

fun triesetslice_t.contains(cp: uint32): bool {
    if cp < 0x800u32 {
        self.chunk_contains(cp, self.tree1_level1[cp >> 6u32])
    } else if cp < 0x10000u32 {
        val pos = (cp >> 6u32) - 0x20u32
        
        if pos >= self.tree2_level1.size() {
          return false
        }

        val leaf: uint8 =  self.tree2_level1[pos]        
        self.chunk_contains(cp, self.tree2_level2[leaf])
    } else {
        val pos = (cp >> 12u32) - 0x10u32
        if pos >= self.tree3_level1.size() {
            return false
        }

        val child = self.tree3_level1[pos]
        val i = (child * CHUNK_SIZE) + (((cp >> 6u32) :> uint32) & 0b111111u32);

        val leaf = self.tree3_level2[i]
        self.chunk_contains(cp, self.tree3_level3[leaf])
    }
}

// Возвращает true тогда и только тогда, когда заданный код символа
// (codepoint) входит во множество
//
// Если заданное значение превышает диапазон кодов символов, т.е. 
// оно больше `0x10FFFF`, возвращает false
fun triesetslice_t.contains_u32(cp: uint32): bool {
    if cp > 0x10FFFF {
        return false
    }
    self.contains(cp)
}

// Возвращает true тогда и только тогда, когда заданный символ
// Unicode входит во множество
fun triesetslice_t.contains_char(c: char): bool {
    self.contains(c :> uint32)
}
