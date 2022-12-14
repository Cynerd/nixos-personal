[
  {
    name = "RGB Osvětlení";
    command_topic = "homeassistant/led-strip";
    brightness_scale = 100;
    brightness_command_topic = "bigclown/node/power-controller:0/led-strip/-/brightness/set";
    #brightness_state_topic = "bigclown/node/power-controller:0/led-strip/-/brightness/set";
    rgb_command_template = ''"#{{"%02x" % red}}{{"%02x" % green}}{{"%02x" % blue}}"'';
    rgb_command_topic = "bigclown/node/power-controller:0/led-strip/-/color/set";
    #rgb_value_template = ''{{int(value[2:4],16)}},{{int(value[5:7],16)}},{{int(value[8:10],16)}}'';
    #rgb_state_topic = "bigclown/node/power-controller:0/led-strip/-/color/set";
  }
]
