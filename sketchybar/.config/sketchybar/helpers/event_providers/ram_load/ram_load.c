#include "ram.h"
#include "../sketchybar.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char** argv) {
  float update_freq;
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);

  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  struct ram ram;
  char trigger_message[512];
  for (;;) {
    ram_update(&ram);
    snprintf(trigger_message, 512, "--trigger '%s' used_percent='%d'", argv[1], ram.used_percent);
    sketchybar(trigger_message);
    usleep(update_freq * 1000000);
  }
  return 0;
}
