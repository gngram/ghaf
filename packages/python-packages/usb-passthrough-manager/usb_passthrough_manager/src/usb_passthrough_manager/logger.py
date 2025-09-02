# Copyright 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

import logging

logger = logging.getLogger("usb_passthrough_manager")

def setup_logger(level: str = "info"):
  handler = logging.StreamHandler()
  handler.setFormatter(logging.Formatter("%(levelname)s %(message)s"))
  logger.addHandler(handler)
  if level == "info":
    logger.setLevel(logging.INFO)
  elif level == "debug":
        logger.setLevel(logging.DEBUG)
  elif level == "error":
        logger.setLevel(logging.ERROR)
  elif level == "warning":
        logger.setLevel(logging.WARNING)
  elif level == "critical":
        logger.setLevel(logging.CRITICAL)
  else:
    logger.setLevel(logging.INFO)
