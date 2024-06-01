import gleam/dict
import gleam/io
import gleam/string_builder
import types.{type Color, Color24}
import utils

pub type Style {
  Style(map: dict.Dict(String, String))
}

const style_foreground = "foreground"

const style_background = "background"

const style_bold = "bold"

const style_underline = "underline"

const style_italic = "italic"

const style_dim = "dim"

const style_blink = "blink"

const style_invert = "invert"

const style_strikethrough = "strikethrough"

fn render_boolean(style: Style, key: String, true_value: String) -> String {
  case get(style, key) {
    "true" -> true_value
    _ -> ""
  }
}

pub fn new_style() -> Style {
  Style(dict.new())
  |> foreground(Color24("clear"))
  |> background(Color24("clear"))
  |> bold(False)
  |> underline(False)
  |> italic(False)
  |> dim(False)
  |> blink(False)
  |> invert(False)
  |> strikethrough(False)
}

fn render_color(style: Style, is_foreground: Bool) -> String {
  let key = {
    case is_foreground {
      True -> style_foreground
      False -> style_background
    }
  }
  let ansi_code = utils.get_ansi_code(Color24(get(style, key)))
  // io.debug(ansi_code)
  case ansi_code {
    "clear" -> "\u{001b}[0m"
    _ -> {
      case is_foreground {
        True -> "\u{001b}[38;2;" <> ansi_code
        False -> "\u{001b}[48;2;" <> ansi_code
      }
    }
  }
}

pub fn render(style: Style, value: String) -> String {
  let builder =
    string_builder.new()
    |> string_builder.append(render_color(style, True))
    |> string_builder.append(render_color(style, False))
    |> string_builder.append(render_boolean(style, style_bold, "\u{001b}[1m"))
    |> string_builder.append(render_boolean(style, style_dim, "\u{001b}[2m"))
    |> string_builder.append(render_boolean(style, style_italic, "\u{001b}[3m"))
    |> string_builder.append(render_boolean(
      style,
      style_underline,
      "\u{001b}[4m",
    ))
    |> string_builder.append(render_boolean(style, style_blink, "\u{001b}[5m"))
    |> string_builder.append(render_boolean(style, style_invert, "\u{001b}[7m"))
    |> string_builder.append(render_boolean(
      style,
      style_strikethrough,
      "\u{001b}[9m",
    ))
    |> string_builder.append(value)
    |> string_builder.append("\u{001b}[0m")

  string_builder.to_string(builder)
}

fn insert(style: Style, key: String, value: String) -> Style {
  Style(dict.insert(style.map, key, value))
}

fn get(style: Style, key: String) -> String {
  case dict.get(style.map, key) {
    Ok(value) -> value

    Error(err) -> {
      io.debug(key)
      io.debug(err)
      panic as "not defined"
    }
  }
}

fn set_boolean_style(style: Style, key: String, value: Bool) -> Style {
  case value {
    True -> insert(style, key, "true")
    False -> insert(style, key, "false")
  }
}

pub fn foreground(style: Style, color: Color) -> Style {
  insert(style, style_foreground, color.value)
}

pub fn background(style: Style, color: Color) -> Style {
  insert(style, style_background, color.value)
}

pub fn bold(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_bold, value)
}

pub fn underline(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_underline, value)
}

pub fn italic(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_italic, value)
}

pub fn dim(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_dim, value)
}

pub fn blink(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_blink, value)
}

pub fn invert(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_invert, value)
}

pub fn strikethrough(style: Style, value: Bool) -> Style {
  set_boolean_style(style, style_strikethrough, value)
}
