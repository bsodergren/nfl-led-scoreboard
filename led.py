from rgbmatrix import RGBMatrixOptions, graphics

def led_matrix_options():
  options = RGBMatrixOptions()

  options.rows = 32
  options.cols = 64
  options.gpio_slowdown = 4
  options.hardware_mapping = 'adafruit-hat'
  options.brightness = 35

  return options
