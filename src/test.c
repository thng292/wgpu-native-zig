#include "webgpu.h"
#include <stdio.h>

WGPUAdapter _adapter = NULL;
WGPUDevice _device = NULL;

void adapterCallback(WGPURequestAdapterStatus status, WGPUAdapter adapter,
                     WGPUStringView message, WGPU_NULLABLE void *userdata1,
                     WGPU_NULLABLE void *userdata2) {
  _adapter = adapter;
}
void deviceCallback(WGPURequestDeviceStatus status, WGPUDevice device,
                    WGPUStringView message, WGPU_NULLABLE void *userdata1,
                    WGPU_NULLABLE void *userdata2) {
  _device = device;
}

int main() {
  WGPUInstance instance = wgpuCreateInstance(NULL);
  wgpuInstanceRequestAdapter(instance, NULL,
                             (WGPURequestAdapterCallbackInfo){
                                 .mode = WGPUCallbackMode_AllowSpontaneous,
                                 .callback = adapterCallback,
                             });
  wgpuAdapterRequestDevice(_adapter, NULL,
                           (WGPURequestDeviceCallbackInfo){
                               .mode = WGPUCallbackMode_AllowSpontaneous,
                               .callback = deviceCallback,
                           });
  WGPUAdapterInfo info = {};
  wgpuAdapterGetInfo(_adapter, &info);
  printf("%.*s\n", info.device.length, info.device.data);
  printf("%p\n", info.vendor.data);
  wgpuAdapterInfoFreeMembers(info);
  printf("Free members\n");
  wgpuDeviceRelease(_device);
  printf("Device\n");
  wgpuAdapterRelease(_adapter);
  printf("Adapter\n");
  wgpuInstanceRelease(instance);
  printf("Instance\n");
}