#include "reset_tracker.h"
#include "esp_log.h"
#include "esp_system.h"

static const char *TAG = "reset_tracker";

void print_reset_info(void) {
    esp_reset_reason_t reset_reason = esp_reset_reason();
    
    ESP_LOGI(TAG, "╔════════════════════════════════════════╗");
    ESP_LOGI(TAG, "║         RESET REASON DETECTED          ║");
    ESP_LOGI(TAG, "╚════════════════════════════════════════╝");
    
    switch (reset_reason) {
        case ESP_RST_UNKNOWN:
            ESP_LOGE(TAG, "Reset reason: UNKNOWN");
            break;
        case ESP_RST_POWERON:
            ESP_LOGI(TAG, "Reset reason: POWERON");
            break;
        case ESP_RST_EXT:
            ESP_LOGW(TAG, "Reset reason: EXTERNAL (manual reset)");
            break;
        case ESP_RST_SW:
            ESP_LOGW(TAG, "Reset reason: SOFTWARE RESET");
            break;
        case ESP_RST_PANIC:
            ESP_LOGE(TAG, "Reset reason: PANIC");
            break;
        case ESP_RST_INT_WDT:
            ESP_LOGE(TAG, "Reset reason: INTERRUPT WATCHDOG TIMEOUT - ISR took too long!");
            break;
        case ESP_RST_TASK_WDT:
            ESP_LOGE(TAG, "Reset reason: TASK WATCHDOG TIMEOUT - Task blocked for >5 seconds!");
            break;
        case ESP_RST_WDT:
            ESP_LOGE(TAG, "Reset reason: MAIN WATCHDOG TIMEOUT");
            break;
        case ESP_RST_DEEPSLEEP:
            ESP_LOGI(TAG, "Reset reason: DEEP SLEEP WAKE");
            break;
        case ESP_RST_BROWNOUT:
            ESP_LOGE(TAG, "Reset reason: BROWNOUT - POWER SUPPLY VOLTAGE TOO LOW!");
            break;
        case ESP_RST_SDIO:
            ESP_LOGW(TAG, "Reset reason: SDIO");
            break;
#ifdef ESP_RST_USB
        case ESP_RST_USB:
            ESP_LOGW(TAG, "Reset reason: USB RESET (USB peripheral or host action)");
            break;
#endif
#ifdef ESP_RST_JTAG
        case ESP_RST_JTAG:
            ESP_LOGW(TAG, "Reset reason: JTAG RESET");
            break;
#endif
#ifdef ESP_RST_EFUSE
        case ESP_RST_EFUSE:
            ESP_LOGE(TAG, "Reset reason: EFUSE ERROR");
            break;
#endif
#ifdef ESP_RST_PWR_GLITCH
        case ESP_RST_PWR_GLITCH:
            ESP_LOGE(TAG, "Reset reason: POWER GLITCH DETECTED");
            break;
#endif
#ifdef ESP_RST_CPU_LOCKUP
        case ESP_RST_CPU_LOCKUP:
            ESP_LOGE(TAG, "Reset reason: CPU LOCKUP (double exception)");
            break;
#endif
        default:
            ESP_LOGE(TAG, "Reset reason: UNHANDLED (%d)", reset_reason);
    }
}
