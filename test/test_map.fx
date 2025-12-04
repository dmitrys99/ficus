/*
    Этот файл является частью проекта 
    "Язык программирования Фикус"

    Лицензионное соглашение находится в файле LICENSE
*/

// Тестирование класса Map

from UTest import *
import Map

TEST("map.create", fun() {
  type map_t = (int, int) Map.t
  var m: map_t = Map.empty(cmp) // cmp берется из Builtin

  EXPECT_EQ(m.isempty(), true)
  
  m = m.add(1, 2)
  EXPECT_EQ(m.isempty(), false)

  m = m.add(2, 3)
  EXPECT_EQ(m.count(), 2)

  val found1 = m.mem(1);
  val found5 = m.mem(5);

  EXPECT_EQ(found1, true)
  EXPECT_EQ(found5, false)

})

TEST("map.find", fun() {
  type map_t = (int, int) Map.t
  var m: map_t = Map.empty(cmp) // cmp берется из Builtin
  m = m.add(1, 2).add(2, 3).add(3, 4)

  val find_opt = m.find_opt(1)
  EXPECT_EQ(find_opt, Some(2))

  val find_opt5 = m.find_opt(5)
  EXPECT_EQ(find_opt5, None)

  EXPECT_EQ(m.find(1), 2)
  EXPECT_THROWS(`fun () { ignore(m.find(5)) }`, Map.MapError)
})

TEST("map.from.list", fun() {
  type map_t = (int, int) Map.t
  val ll = [:: (1, 2), (2, 3), (3, 4)]
  var m: map_t = Map.from_list(cmp, ll) // cmp берется из Builtin
  EXPECT_EQ(m.count(), 3)

  val found1 = m.mem(1);
  val found5 = m.mem(5);

  EXPECT_EQ(found1, true)
  EXPECT_EQ(found5, false)
})

TEST("map.from.array", fun() {
  type map_t = (int, int) Map.t
  val arr = [ (1, 2), (2, 3), (3, 4)]
  var m: map_t = Map.from_array(cmp, arr) // cmp берется из Builtin
  EXPECT_EQ(m.count(), 3)

  val found1 = m.mem(1);
  val found5 = m.mem(5);

  EXPECT_EQ(found1, true)
  EXPECT_EQ(found5, false)
})

TEST("map.foldl", fun() {
  type map_t = (int, int) Map.t
  val arr = [ (1, 2), (2, 3), (3, 4)]
  var m: map_t = Map.from_array(cmp, arr) // cmp берется из Builtin
  EXPECT_EQ(m.count(), 3)

  val r0 = m.foldl(fun (k: 'k, d: 'd, r: string): string = r + f"{d}", "")
  EXPECT_EQ(r0, "234")

  val r1 = m.foldr(fun (k: 'k, d: 'd, r: string): string = r + f"{d}", "")
  EXPECT_EQ(r1, "432")
})
