#include <mach/mach.h>
#include <stdint.h>

struct ram {
  int used_percent;
};

static inline void ram_update(struct ram* ram) {
  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  vm_statistics64_data_t vmstat;
  if (host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vmstat, &count) != KERN_SUCCESS) {
    ram->used_percent = -1;
    return;
  }

  int64_t page_size;
  host_page_size(mach_host_self(), (vm_size_t*)&page_size);

  // Migliore approssimazione della "Memoria utilizzata" di Monitoraggio Attività:
  // usata = active + wired + compressed
  // totale = active + inactive + wired + compressed + free + speculative
  int64_t mem_used = (vmstat.active_count + vmstat.wire_count + vmstat.compressor_page_count) * page_size;
  int64_t mem_total = (vmstat.active_count + vmstat.inactive_count + vmstat.wire_count + vmstat.compressor_page_count + vmstat.free_count + vmstat.speculative_count) * page_size;
  ram->used_percent = (int)((double)mem_used / (double)mem_total * 100.0);
}
