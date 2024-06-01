import log

pub fn main() {
  let value = "Hello from the_stars!"
  let logger = log.new_logger()

  log.debug(logger, value)
  log.info(logger, value)
  log.warn(logger, value)
  log.error(logger, value)
  log.fatal(logger, value)
}
