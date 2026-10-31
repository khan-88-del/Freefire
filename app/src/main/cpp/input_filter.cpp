#include <jni.h>
#include <android/input.h>
#include <unordered_map>
#include <chrono>

static std::unordered_map<int32_t, int64_t> last_key_timestamps;

extern "C" JNIEXPORT jboolean JNICALL
Java_com_nativemapper_app_engine_NativeInputBridge_shouldFilterKeyEvent(
    JNIEnv* env,
    jobject /* this */,
    jint keyCode,
    jint action,
    jlong minIntervalMs
) {
    if (action != AKEY_EVENT_ACTION_DOWN) {
        return JNI_FALSE;
    }

    auto now = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::steady_clock::now().time_since_epoch()
    ).count();

    auto it = last_key_timestamps.find(keyCode);
    if (it != last_key_timestamps.end()) {
        if (now - it->second < minIntervalMs) {
            return JNI_TRUE;
        }
    }

    last_key_timestamps[keyCode] = now;
    return JNI_FALSE;
}
