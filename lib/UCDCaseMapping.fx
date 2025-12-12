//
// Этот файл является частью проекта
// "Язык программирования Фикус"
//
// Лицензионное соглашение находится в файле LICENSE
//
// ==================================================

import Map

type case_map_t = (char, string) Map.t

fun char_cmp(a: char, b: char): int = a <=> b

fun char_identity(c: char): string = string(c)

fun new_case_map(): case_map_t {
    Map.empty(char_cmp)
}

class case_mapping_t = {
  chars: uint32[];
  lens: uint8[];
  data: uint32[];
  var m: case_map_t
}

fun case_mapping_t.case_convert(c: char): string {
    match self.m.find_opt(c) {
        | Some(v) => v
        | None    => char_identity(c)
    }
}

// Построение отображения 'символ' <==> 'строка'
// Из-за особенностей генерации сложных типов компилятором 
// Ficus, созданный код для списка пар или массива пар
// ('символ', 'строка') становится довольно большим и компилируется
// очень долго на этапе компиляции кода на C.
// При этом инициализация этого кода все-равно происходит
// во время старта программы.
// Поэтому сгенерированные данные были разделены на 3 блока
// в виде простых численных массивов:
// 1. массив символов
// 2. массив длин строк, соответствующих символам
// 3. массив символов, составляющих строки.
// Инициализация производится выделением подмассивов символов из (3)
// с последующей конвертацией в строку и записью в отображение.
fun case_mapping_t.init() {
    assert(self.chars.length() == self.lens.length())
    val data_len = fold sum=0 for d <- self.lens { sum+d }
    assert(data_len == self.data.length())
    
    var counter = 0
    for c@i <- self.chars {
        val data = self.data[counter:counter + self.lens[i]]
        counter += self.lens[i]
        val data_str = join("", data.map(fun(x) { string(x :> char) }))
        self.m = self.m.add(c :> char, data_str)
    }
}