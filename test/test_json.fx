/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// jsonpp.fx example converted into a test

from UTest import *
import Json

TEST("json.parse", fun() {
    val js_data = "
    // sample json from https://ru.wikipedia.org/wiki/JSON
    {
        \"firstName\": \"Иван\",
        \"lastName\": \"Иванов\",
        \"address\": {
            \"streetAddress\": \"Московское ш., 101, кв.101\",
            \"city\": \"Ленинград\",
            \"postalCode\": 101101
        },
        \"phoneNumbers\": [
            \"812 123-1234\",
            \"916 123-4567\",
        ]
    }"
    val js = Json.parse_string("", js_data)
    match js {
    | Json.Map(m) =>
        match m.assoc_opt("address") {
        | Some(Json.Map(m)) =>
            EXPECT_EQ(m.assoc("city"), Json.Str("Ленинград"))
            EXPECT_EQ(m.assoc("postalCode"), Json.Int(101101L))
        | _ => throw TestFailure("'address' is not found or is not a map")
        }
        match m.assoc_opt("phoneNumbers") {
        | Some(Json.Seq(s)) => EXPECT_EQ(s.nth(1), Json.Str("916 123-4567"))
        | _ => throw TestFailure("'phoneNumbers' is not found or is not a sequence")
        }
    | _ => throw TestFailure("top-level json value is not a map")
    }
    EXPECT_EQ(string(js),
"{
   \"firstName\": \"Иван\",
   \"lastName\": \"Иванов\",
   \"address\": {
      \"streetAddress\": \"Московское ш., 101, кв.101\",
      \"city\": \"Ленинград\",
      \"postalCode\": 101101
   },
   \"phoneNumbers\": [ \"812 123-1234\", \"916 123-4567\" ]
}")
})

TEST("json.pprint", fun() {

val rng = new_uniform_rng(123u64)
val s_list_list = [: for i <- 0:10 {
    val n = rng(0, 100)
    Json.Commented(f"#{i}", Json.Seq([: for j <- 0:n {
        Json.Int(int64(rng(0, 100000)))} :]))
    } :]

val sample_js = Json.Commented(
    "small Json pretty-printing example",
    Json.Map([:
    ("ain't it cool?", Json.Bool(true)),
    ("pi", Json.Commented("the famous constant", Json.Real(3.1415926))),
    ("a little array of arrays", Json.Commented("demonstrates compact representation of scalar arrays",
        Json.Seq(s_list_list))),
    ("greeting", Json.Commented("'hello' in Chinese", Json.Str("你好"))),
     :]))

val pprinted = string(sample_js)
EXPECT_EQ(pprinted,
"// small Json pretty-printing example
{
   \"ain't it cool?\": true,
   // the famous constant
   \"pi\": 3.1415926,
   // demonstrates compact representation of scalar arrays
   \"a little array of arrays\": [
      // #0
      [ 71492, 69451 ],
      // #1
      [ 20810, 37822, 14538, 79407, 21199, 93302, 4465, 43837, 41071, 65920, 10733,
         62481, 50515, 21289, 51475, 56018, 88038, 2281, 22487, 50355, 2325, 96961,
         37799, 8090, 56083, 38149, 35695, 40695, 96382, 11498, 73549, 23435, 52355,
         57675, 70921, 20666, 82635, 38407, 64731, 79762, 74625, 17659, 19149, 27885,
         28012 ],
      // #2
      [ 6259, 39786, 97843, 57723, 20978, 53834, 64158, 81833, 71564, 89367, 97224,
         532, 33625, 76151, 84425, 19383, 96743, 41301, 20716, 42839, 95627, 39004,
         14848 ],
      // #3
      [ 27874, 45795, 87327, 71216, 51636, 3644, 99946, 38841, 87312, 18238, 50311,
         55659, 79598, 2067, 74785, 31260, 94364, 3029, 73352, 3474, 45786, 35473,
         50529, 79329, 39893, 90161, 76811, 99764, 62138, 91844, 13847 ],
      // #4
      [ 65785, 92212, 89676, 40930, 75776, 61170, 34105, 73023, 79565, 7046, 71471,
         99549, 88132, 35255, 16408, 94371, 23590, 70782, 66255, 9287, 71689, 69575,
         9371, 35176, 29096, 11935, 5798, 69800, 53646, 59297, 41687, 89722, 14657,
         65055, 51795, 15507, 71174, 60425, 49373, 61972, 65060, 90287, 19742, 86978,
         14803, 18402, 26851, 98881, 66884, 48534, 74018, 58281, 91605, 50076, 579,
         9746, 1716, 76082, 6684, 39490, 74977, 63702, 22051, 98124, 59377, 3955,
         81567, 45194, 353, 41476, 50928, 43380, 8630, 22763, 76918, 57999, 23516,
         41265, 41796, 40790 ],
      // #5
      [ 10319, 43090, 84542, 95532, 35406, 55449, 50370, 32453, 42383, 24156, 25061,
         45178, 79165, 61646, 92285, 85199, 83072, 42954, 55955, 92245, 59687, 52087,
         61810, 4643, 46757, 68671, 71554, 60997, 69208, 94678, 37061, 36596, 4342,
         53032, 34150, 31625, 95538, 11490, 47348, 9453, 29707, 9027, 42843, 25014,
         92992, 53360, 2385, 84094, 55554, 53445, 11283, 25567, 50676, 35751, 58333,
         90934, 24646, 84509, 74886, 51746, 26892, 58978, 5943, 28532, 45205, 29103,
         61492, 26732, 712, 72295, 48159, 71483, 21290, 58040, 87339, 42095, 91901,
         38338, 19132, 49604, 74612 ],
      // #6
      [ 67502, 63184, 64374, 50180, 10382, 72341, 50981, 16409, 86027, 190, 77069,
         24020, 75181, 63977, 45752, 26436, 79718, 44858, 39489, 55769, 72033, 75233,
         97277, 66300, 57785, 37545, 90603, 59581, 86960, 39889, 55179, 26892 ],
      // #7
      [ 73317, 12485, 21177, 53446, 89039, 15646, 14962, 3616, 12549, 24026, 31029,
         98734, 78364, 87822, 40626, 55770, 44185, 27654, 67342, 84519, 94632, 16358,
         33198, 66875, 66224, 79212, 68278, 13174, 67708, 58372, 64592, 81545, 62131,
         40998, 79016, 76602, 91456, 67474, 96929, 46402, 78849, 41463, 20923, 93445,
         4832, 70053, 74478, 89776, 28452, 88353, 30654, 77628, 76151, 86647, 53230,
         7348, 73577, 14848, 17546, 98189, 45227, 19662, 53830, 20655, 1181, 99768,
         95635, 37652, 8526, 84192, 81466, 48414, 52098, 30868, 9337, 91452, 22685,
         55694, 83400, 19047, 42594, 42716, 33969, 70182, 37918, 33170, 40654, 68625,
         82947, 26037, 85943, 57994, 57081 ],
      // #8
      [ 8476, 67555, 42357, 55949, 43874, 84895, 39706, 96846, 60028, 61260, 68370,
         46852, 31096, 13023, 48124, 41684, 66117, 75761 ],
      // #9
      [ 19881, 98492, 68636, 21623, 22660, 46844, 27869, 29144, 41997, 66024, 44484,
         28819, 89382, 88145, 88305, 34183, 81290, 86431, 37895, 66221, 1740, 63305,
         40834, 94781, 9393, 92947, 14052, 14579, 95163, 28573, 5416, 78250, 97343,
         47724, 24623, 36987, 42454, 99875, 93806, 52713, 73422, 81897, 5139, 45081,
         39990, 24531, 14250, 65091, 19987, 46940, 86242, 99458, 28201, 39305, 25081,
         78728, 75512, 33058, 90918, 23268, 84309, 80668, 26896, 85594, 92499, 119,
         17480, 57445, 55841, 72994, 49626, 57797, 71914 ]
   ],
   // 'hello' in Chinese
   \"greeting\": \"你好\"
}")
})
