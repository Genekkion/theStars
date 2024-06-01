import gleam/int
import gleam/list
import gleam/string
import types.{type Color}

fn hex_value(value: String) -> Result(Int, Nil) {
  case value {
    "0" -> Ok(0)
    "1" -> Ok(1)
    "2" -> Ok(2)
    "3" -> Ok(3)
    "4" -> Ok(4)
    "5" -> Ok(5)
    "6" -> Ok(6)
    "7" -> Ok(7)
    "8" -> Ok(8)
    "9" -> Ok(9)
    "a" | "A" -> Ok(10)
    "b" | "B" -> Ok(11)
    "c" | "C" -> Ok(12)
    "d" | "D" -> Ok(13)
    "e" | "E" -> Ok(14)
    "f" | "F" -> Ok(15)
    _ -> Error(Nil)
  }
}

fn parse_hex_code_aux(char_list: List(String), int_list: List(Int)) -> List(Int) {
  case char_list {
    [] | [_] -> int_list
    [first, second, ..remaining] -> {
      let first_result = hex_value(first)
      let second_result = hex_value(second)

      case first_result, second_result {
        Ok(first_value), Ok(second_value) -> {
          parse_hex_code_aux(
            remaining,
            list.append(int_list, [16 * first_value + second_value]),
          )
        }
        _, _ -> []
      }
    }
  }
}

fn parse_hex_code(value: List(String)) -> List(Int) {
  parse_hex_code_aux(value, [])
}

fn parse_color_aux(value: List(Int), string: String) -> String {
  case value {
    [last] -> {
      string <> int.to_string(last) <> "m"
    }
    [first, ..remaining] -> {
      parse_color_aux(remaining, string <> int.to_string(first) <> ";")
    }
    [] | _ -> string
  }
}

fn parse_color(color: Color) -> Result(String, Nil) {
  let char_list = string.to_graphemes(color.value)

  case list.pop(char_list, fn(_) { True }) {
    Ok(#("#", hex_code)) -> {
      case list.length(hex_code) {
        6 -> {
          Ok(parse_color_aux(parse_hex_code(hex_code), ""))
        }
        _ -> Error(Nil)
      }
    }
    Error(_) | _ -> Error(Nil)
  }
}

pub fn get_ansi_code(color: Color) -> String {
  case string.lowercase(color.value) {
    "clear" -> "clear"
    _ -> {
      case parse_color(color) {
        Ok(value) -> value
        Error(_) -> "clear"
      }
    }
  }
}
