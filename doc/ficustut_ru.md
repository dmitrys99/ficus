
# Введение

Ficus -- функциональный язык программирования, поддерживающий императивную и объектно-ориентированную парадигмы программирования. Основная область применения языка Ficus -- вычисления. В языке есть полноценная поддержка многомерных массивов, они могут эффективно обрабатываться в один или несколько потоков. Компилятор Ficus преобразует исхоные файлы .fx и генерирует переносимый код на C/C++. Созданный код хорошо совместим с C и C ++ в обоих направлениях: удобно вызывать код C/C++ из Ficus, также как и вызывать код на C, сгенерированный компилятором Ficus, из пользовательских приложений.

Этот документ дает краткое и, надеюсь, исчерпывающее введение в синтаксис и семантику языка и позволит вам начать с ним работать. Предполагается некоторое базовое знание C/C++ или других языков программирования (C#, Java, Javascript, Python, F#, OCaml, ...), поскольку многие концепции похожи и, вероятно, описаны не очень подробно.

# Лицензия

Ficus -- проект с открытым исходным кодом. Компилятор, среда исполнения и стандартная библиотека распространяются под лицензией Apache 2.

# Установка

Компилятор Ficus реализован на Ficus. Предварительно сгенерированные исходные тексты `.c` ранее созданной версии компилятора поставляются вместе с дистрибутивом. Поэтому процесс сборки довольно прост:

1. Первоначальная версия компилятора собирается из сохраненных исходных текстов на C (обозначим ее как `ficus0`).
2. Следом из исходных текстов `.fx` собирается свежий компилятор (`ficus`).

Для запуска процедуры раскрутки (bootstrap) достаточно иметь работающий C/C++ компилятор и утилиту make.

## В Unix-подобных системах (Linux, Mac OS, BSD и др.)

1. Клонируете репозиторий:

 ```
$ cd ~/myprojects # в какой-то из ваших папок с проектами
$ git clone https://github.com/vpisarev/ficus.git
 ```

2. Переходите в каталог Ficus и собираете компилятор Ficus с именем `ficus`:

 ```
 $ cd ficus
 $ make -j8 # создаете ficus0, затем ficus
 $ bin/ficus -run test/test_all.fx # запускаете тесты, чтобы удостовериться
                                   # что собранный компилятор работает
 ```

3. Настраиваете переменные окружения, чтобы командная оболочка знала, где найти Ficus (чтобы `ficus` можно было запускать без явного указания пути).

 ```
 $ export PATH=~/myprojects/ficus/bin:$PATH
 $ export FICUS_PATH=~/myprojects/ficus/lib # путь поиска стандартной библиотеки
 ```

Примечание: Если исполняемый файл `ficus` и библиотека находятся рядом в определенных местах, компилятор Ficus автоматически обнаруживает стандартную библиотеку. Если же переменная `FICUS_PATH` задана, например, в `.bash_profile` или аналогичном месте, исполняемый файл `ficus` можно переносить в любое место и запускать оттуда.

## Windows

TBD

## Использование

После установки Ficus можно запустить примеры из `ficus/examples` и попробовать написать свою программу.
Самая простая и известная программа, конечно, *Hello, world!*. Откройте текстовый редактор и введите:

```
println("Hello, world!")
```

Сохраните в файле `helloworld.fx`, затем запустите его с помощью команды

```
$ ./bin/ficus -run helloworld.fx
```

Программа поприветствует мир. В той же директории, куда вы поместили `helloworld.fx` появится поддиректория `__fxbuild__/helloworld/` с несколькими файлами `*.c`, включая `helloworld.c`. Это результат работы компилятора. Кроме того, там же находятся файлы приложений `helloworld` (на Unix) или `helloworld.exe` (на Windows).

Можно собрать приложение и запустить его отдельными действиями:

```
$ ./bin/ficus -app helloworld.fx
$ ./__fxbuild__/helloworld/helloworld
```

Вы уже видели опции компилятора `-app` и `-run`,  они указывают компилятору собрать и запустить приложение соответственно. Весь список опций можно получить, запустив 

```
$ ficus -h
```

Подробности пожно посмотреть в [Приложении А](#appendix-a.-using-ficus) в конце этого документа.

Хорошо, давайте посмотрим, как писать программы на Ficus.

Программа на Ficus состоит из одного или нескольких файлов с расширением `.fx`, называемых модулями. Модуль может импортировать другие модули и/или может импортироваться из других модулей, см. раздел [Модули](#modules). Модули представляют собой текстовые файлы в кодировке UTF-8, содержащие последовательность (возможно рекурсивную) деклараций, директив и выражений. Где это не привнесет неясности, для краткости будем называть все перечисленное выражениями. Набор выражений разделяется `;` или переводом каретки (LF/CR/CRLF). Выражения могут занимать несколько строк. В большинстве случаев Ficus автоматически отделяет одно выражение от другого, но иногда могут потребоваться явное добавление точки с запятой или круглых скобок.

С точки зрения компилятора выражения это последовательность токенов. Токенами являются операторы, идентификаторы, ключевые слова, литералы и пр. Отступы и пробелы в почти не имеют значения для компилятора. Оформляйте код, как вам нравится. Например, следующиий фрагмент кода плохо оформлен, но это все ещё корректный код:

  ```
  if a>b {
     a
  }else {println("b победил"); b}
  ```

Пробел между `a` и `>`, `>` и `b`, `}` и `else` не обязателен, но можно и поставить. Но пробел(ы) требуется, чтобы отделить `a` от `if`.  Также для отделения `println(...)` от `b` требуется `;`, поскольку два последовательных выражения в рамках одного блока расположены на одной строке.

В Ficus *пробел* это пробельный символ (`' '`, ASCII `0x20`), табуляция (ASCII `0x09`), перевод каретки (LF/CR/CRLF), комментарий или любая комбинация всего перечисленного.

Комментарии бывают двух типов:

1. Блочный комментарий, ограниченный строками `/*` и `*/`. Такие комментарии могут располагаться в любом месте между токенами, могут занимать одну и более строчек и могут быть вложенными.

```
  /* Комментируем вообще всё
  /*
    Ищем максимум a и b
     a и b
  */
  if a > b /* давайте сравним */ {a} else {b /*b>=a*/}
  */
  ```

2. Однострочные комментарии, начинающиеся с `//` и продолжающиеся до конца строки

  ```
  if a > b {
     a // a победитель
  } else {
     // b победитель,
     // и мы об этом сообщаем
     println("b победитель")
     b // println() и b разделены переводом каретки
  }
  ```

Как выше сказано, иногда перевод каретки может трактоваться как конец одного выражения и начало следущего, хотя предполагалось обратное.
Типичные ситуации:

1. перенос строки перед бинарным оператором трактует последний как унарный оператор, например `+`, `-` или`*`:

   ```
   val diff =  a
             - b
   ```

трактуется как `val diff = a; -b`, что, скорее всего, не то, что ожидалось. В большинстве таких случаев компилятор выдаст сообщение об ошибке, встретив не-void выражение в середине блока кода. Правильный способ переноса таких выражений на несколько строк: 

   ```
   val diff = a -
              b
   ```

   или

   ```
   val diff = (a   // включение выражения в скобки указывает, что мы задали единое выражение
               -b)
   ```

   Можно поискать подозрительные места в коде по регулярному выражению `^\s+[+-*]`.

2. перенос строки перед открывающей круглой скобкой `(` при вызове фукнции:

    ```
    foo
    (
       x,
       y
    )
    ```
    Такой код будет трактован как `foo; (x, y)`, где первое выражение вернет функцию `foo`, второе создаст пару `(x, y)`. В этом случае компилятор также сообщит о не-void выражении `foo` в середине блока кода. Для исправления достаточно прижать `(` к имени функции:
    ```
    foo(
          x,
          y
      )
    ```

    или

    ```
    foo(x, y)
    ```

4. перенос строки перед открывающей квадратной скобкой `[` при доступе к массиву или индексируемой коллекции:

    ```
    mymatrix
        [
           i,
           j
        ]
    ```

   Как и в случае с функцией, код будет трактован как `mymatrix; [i, j]`, где первое выражение вернет матрицу `mymatrix`, а второе создаст список из двух элементов `[x, y]`. Компилятор и здесь укажет на ошибку. Поместите `[` на ту же строку, что и `mymatrix`, это исправит ситуацию:

    ```
    mymatrix[
          i,
          j
      ]
    ```

    или

    ```
    mymatrix[i, j]
    ```

## Токены

В Ficus используются следующие типы токенов:

* **литералы**, представляющие разнообразные скалярные значения:

  * 8-, 16-, 32- или 64-битные, знаковые или беззнаковые целые (литералы типов `int8`, `uint8`, `int16`, `uint16`, `int32`, `uint32`, `int`, `uint64`, `int64` cсоответственно), 16-, 32- или 64-битные числа с плавающей точкой (типов `half`, `float` и `double` соответственно):

    ```
    42    // десятичное число
    0xffu8 // 8-битное беззнаковое число в шестнадцатеричной нотации
    12345678987654321i64 // 64-битное целое,
                         // суффикс i... обозначает литерал n-битного знакового целого
                         // суффикс u... обозначает литерал n-битного беззнакового целого
    0777  // восьмеричное число
    0b11110000 // целое в двоичной нотации
    3.14  // число с плавающей точкой двойной точности
    1e-5f // число с плавающей точкой одинарной точности 
          // в экспоненциальной нотации
    0.25h // 16-битное число с плавющей точкой
          // (пока такие числа реально в Ficus не поддерживаются)
    nan   // особый литерал 'not a number' (не число) двойной точности
          // добавление суффикса 'f' дает 'nan' одинарной точности
    -inff // литерал '-infinity' (минус бесконечность) одинарной точности
          // удаление суффикса 'f' дает значение двойной точности.
    ```

  * логические значения (типа `bool`)

    ```
    true
    false
    ```

  * текстовые строки (типа `string`)

    ```
    "abc"
    "hello, world!\n" //  поддерживаются обычные ESC-последовательности в стиле C

    /*
      Non-ASCII characters are captured properly
      from UTF8-encoded source,
      and then stored and processed as
      unicode (4-byte) characters.
      That is, the code will output 9
    */
    println(length("привет! \U0001F60A"))

    // It's possible to embed particular characters
    // using their ASCII or Unicode value:
    // \ooo — 1-3 digit octadecimal ASCII codes,
    // \xXX — 2-digit hexadecimal ASCII codes,
    // \uXXXX — 4-digit hexadecimal Unicode value
    // \UXXXXXXXX — 8-digit hexedecimal Unicode value
    "Hola \U0001F60A"

    // Similar to Python, f-strings may embed expression values using {} string interpolation construction
    val r = 10
    println(f"a circle with R={r} has area={3.1415926*r*r}")
    // the line above is converted by the parser to
    println("a circle with R=" + string(r) +
           " has area=" + string(3.1415926*r*r))

    // therefore, custom objects can also be interpolated
    // once you've provided string() function for them:
    type point = { x: int; y: int }
    // note that to avoid confusion, literal '{' and '}'
    // need to be duplicated in f-strings
    fun string(p: point) = f"{{x={p.x}, y={p.y}}}"
    val pt = point { x=10, y=5 }
    println(f"pt={pt}")

    // Multi-line string literals are possible too:
    // By default, end-of-line characters in the produced
    // string are retained. \r\n is replaced with \n for
    // cross-platform compatibility.
    val author="anonymous"
    f"multi-line
      strings
        are
      delimited
     by quotes, just like the normal string literals
       and can also embed some values.
            {author}
    "
    // Put \ before a newline to remove this newline and
    // the subsequent spaces from the literal
    val errmsg = "A very long and \
       detailed error message explaining \
       what's going wrong."

    // r-string literals are mostly used for regular expressions,
    // because they let to specify character classes and other
    // special symbols without duplicating '\'
    val assigment_regexp = Re.compile(
      r"(?:val|var)\s+([\a_]\w+)\s*=\s*(\d+|\w+)")
    ```

  * characters (of type `char`) — this is what the text strings are made of. Character literals look exactly like single-line text literals, but are enclosed into single quotes.

    ```
    chr(ord('A')) == 'A' // ~ true
    ```

  * polymorphic literal — an empty list, vector or 1D, 2D etc. array (of type `'t list`, `'t vector`, `t []`, `t [,]` etc., respectively)

    ```
    []
    ```

  * null C-pointer (see the section about interaction with C/C++)

    ```
    null
    ```

* **identifiers** — they denote all the named entities, built-in or defined in the code: values, variables, functions, types, exceptions, variant tags etc. An identifier starts with the underscore `_` or a letter (Latin or not) and contains zero or more subsequent underscores, letters or decimal digits, i.e. it can be defined with the following regular expression: `[\a_]\w+`. Identifier `_` has a special meaning. It denotes an unused function parameter or, in general, element of a pattern that user does not care of (patterns are discussed further in this document).

* **keywords** — they look like identifiers and are used to form various syntactic constructions. You may not have an identifier with the same name as keyword. Here is a list of Ficus keywords:

  ```
  as break catch class continue do else exception
  false finally fold for from fun if import inf inff
  interface match nan nanf null operator ref return throw
  true try type val var when while
  ```

  There are also **attribute-keywords** that start with `@` and are used to describe various properties of defined symbols, for-loops, code blocks etc. Here they are:

  ```
  @ccode @data @inline @nothrow @pragma
  @parallel @private @pure @sync @text @unzip
  ```

  The names of standard data types can also be treated as keywords:

  ```
  int8 uint8 int16 uint16 int32 uint32 int uint64 int64
  half float double bool string char list vector cptr exn
  ```

  But the important difference is that it's possible to define a function or a value with the name that matches the standard data type. In particular, it's the common practice — to give the name of target datatype to the type cast function:

  ```
  fun string(set: 't Set.t) =
    join_embrace("{", "}", ", ", set.map(repr))
  type ratio_t = {n: int; d: int}
  fun double(r: ratio_t) = double(r.n)/r.d
  ```

* **operators**

  There are quite a few operators, binary and unary.

  **Binary**:

  ```
  // overridable binary operators
  + − * / % **
  .+ .- .* ./ .**
  == != > < <= >= <=> ===
  .== .!= .> .< .<= .>= .<=>
  & | ^ >> << \

  // other binary operators
  .{...}

  = += −= *= /= %= &= |= ^= >>= <<=
  .={...}

  && || :: :>
  ```

  **Unary**

  ```
  // overridable prefix operator
  ~
  // other prefix operators
  + − *
  .- ! \

  // overridable postfix operator
  '
  ```

  The overridable operators can be enclosed into `()` and be used as identifiers, e.g. to pass to a higher-level function. Also, such operators can be overridden using `operator` keyword:

  ```
  type ratio = { n: int; d: int }
  operator < (r1: ratio, r2: ratio) {
    val scale = r1.d*r2.d
    if scale > 0 {r1.n*r2.d < r2.n*r1.d}
    else {r1.n*r2.d > r2.n*r1.d}
  }
  fun R(n: int, d: int) = ratio {n=n, d=d}
  val sorted = [R(1,2), R(3,5), R(2,3)].sort((<))
  ```

* There are also various **delimiters** and **parentheses**

  ```
  -> => <- @ . , : ; [ ] ( ) { }
  ```

All these operators will be explained later in the tutorial.

Now let's make a step up and see how various language constructions are composed out of the tokens

