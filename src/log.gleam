import birl
import gleam/int
import gleam/io
import gleam/string
import styles
import types.{Color24}

pub const log_level_debug = 0

pub const log_level_info = 1

pub const log_level_warn = 2

pub const log_level_error = 3

pub const log_level_fatal = 4

pub opaque type Logger {
  Logger(
    log_level: Int,
    show_timestamp: Bool,
    debug_style: styles.Style,
    info_style: styles.Style,
    warn_style: styles.Style,
    error_style: styles.Style,
    fatal_style: styles.Style,
  )
}

pub fn new_logger() -> Logger {
  let style =
    styles.new_style()
    |> styles.bold(True)

  let debug_style =
    style
    |> styles.foreground(Color24("#FFFFFF"))
    |> styles.background(Color24("#414868"))

  let info_style =
    style
    |> styles.foreground(Color24("#FFFFFF"))
    |> styles.background(Color24("#485E30"))

  let warn_style =
    style
    |> styles.foreground(Color24("#000000"))
    |> styles.background(Color24("#FF9E64"))

  let error_style =
    style
    |> styles.foreground(Color24("#000000"))
    |> styles.background(Color24("#F7768E"))

  let fatal_style =
    style
    |> styles.foreground(Color24("#000000"))
    |> styles.background(Color24("#BB9AF7"))

  Logger(
    0,
    False,
    debug_style,
    info_style,
    warn_style,
    error_style,
    fatal_style,
  )
}

fn pretty_datetime(logger: Logger) -> String {
  case logger.show_timestamp {
    True -> {
      let datetime = birl.now()
      let date = birl.get_day(datetime)
      let time = birl.get_time_of_day(datetime)

      let pad2 = fn(x) { string.pad_left(int.to_string(x), to: 2, with: "0") }
      let pad4 = fn(x) { string.pad_left(int.to_string(x), to: 4, with: "0") }

      "["
      <> pad2(date.date)
      <> "-"
      <> pad2(date.month)
      <> "-"
      <> pad4(date.year)
      <> "] "
      <> pad2(time.hour)
      <> ":"
      <> pad2(time.minute)
      <> ":"
      <> pad2(time.second)
    }
    False -> ""
  }
}

pub fn debug(logger: Logger, value: anything) -> anything {
  io.print_error(
    pretty_datetime(logger)
    <> " "
    <> styles.render(logger.debug_style, " DEBUG: ")
    <> " ",
  )
  io.debug(value)
}

pub fn info(logger: Logger, value: String) -> String {
  case logger.log_level <= log_level_info {
    True ->
      io.println(
        pretty_datetime(logger)
        <> " "
        <> styles.render(logger.info_style, " INFO:  ")
        <> " "
        <> value,
      )
    _ -> Nil
  }
  value
}

pub fn warn(logger: Logger, value: String) -> String {
  case logger.log_level <= log_level_warn {
    True ->
      io.println_error(
        pretty_datetime(logger)
        <> " "
        <> styles.render(logger.warn_style, " WARN:  ")
        <> " "
        <> value,
      )
    _ -> Nil
  }
  value
}

pub fn error(logger: Logger, value: String) -> String {
  case logger.log_level <= log_level_error {
    True ->
      io.println_error(
        pretty_datetime(logger)
        <> " "
        <> styles.render(logger.error_style, " ERROR: ")
        <> " "
        <> value,
      )
    _ -> Nil
  }
  value
}

pub fn fatal(logger: Logger, value: String) -> String {
  case logger.log_level <= log_level_info {
    True ->
      io.println_error(
        pretty_datetime(logger)
        <> " "
        <> styles.render(logger.fatal_style, " FATAL: ")
        <> " "
        <> value,
      )
    _ -> Nil
  }
  value
}
