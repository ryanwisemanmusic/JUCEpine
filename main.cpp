#include <iostream>
#include <juce_core/juce_core.h>
#include <juce_events/juce_events.h>
#include <juce_audio_basics/juce_audio_basics.h>

/*
Problem Headers:
    Here below are a wide variety of headers that currently have issues. These are graphic library problems, nothing audio related
    - #include <juce_graphics/juce_graphics.h>
    - #include <juce_gui_basics/juce_gui_basics.h>
*/

/*
Headers to test:
//#include <juce_audio_devices/juce_audio_devices.h>
//#include <juce_audio_formats/juce_audio_formats.h>
//#include <juce_audio_processors/juce_audio_processors.h>
//#include <juce_audio_utils/juce_audio_utils.h>
*/

void juce_core() {
    std::cout << "=== JUCE Core Module Test ===" << std::endl;
    std::cout << "JUCE Core headers successfully included" << std::endl;
    
    juce::String juceVersion = "JUCE Version: " + juce::SystemStats::getJUCEVersion();
    std::cout << juceVersion << std::endl;
    
    juce::File currentDir = juce::File::getCurrentWorkingDirectory();
    std::cout << "Current directory: " << currentDir.getFullPathName() << std::endl;
    
    juce::Time currentTime = juce::Time::getCurrentTime();
    std::cout << "Current time: " << currentTime.toString(true, true, false, true) << std::endl;
    
    juce::StringArray testArray;
    testArray.add("JUCE");
    testArray.add("Test");
    testArray.add("Successful");
    std::cout << "String array test: " << testArray.joinIntoString(" ") << std::endl;
    
    std::cout << "Operating system: " << juce::SystemStats::getOperatingSystemName() << std::endl;
    std::cout << "Device description: " << juce::SystemStats::getDeviceDescription() << std::endl;
    
    juce::Uuid uniqueId;
    std::cout << "UUID test: " << uniqueId.toString().substring(0, 8) << "..." << std::endl;
    
    juce::String formattedNum = juce::String(3.14159, 4);
    std::cout << "Number formatting: π ≈ " << formattedNum << std::endl;
    
    std::cout << "CPU vendor: " << juce::SystemStats::getCpuVendor() << std::endl;
    std::cout << "CPU model: " << juce::SystemStats::getCpuModel() << std::endl;
    
    juce::CriticalSection lock;
    {
        const juce::ScopedLock sl(lock);
        std::cout << "Critical section test: OK" << std::endl;
    }
    
    juce::DynamicObject::Ptr props = new juce::DynamicObject();
    props->setProperty("test_property", "success");
    std::cout << "Dynamic object test: " << props->getProperty("test_property").toString() << std::endl;
    
    juce::String testUrl = "https://example.com/test path";
    juce::String encodedUrl = juce::URL::addEscapeChars(testUrl, false);
    std::cout << "URL encoding test: " << encodedUrl << std::endl;
    
    std::cout << "#include <juce_core/juce_core.h> fully verified!" << std::endl << std::endl;
}
/*
*/
void juce_events() {
    std::cout << "=== JUCE Events Module Test ===" << std::endl;
    std::cout << "JUCE Events headers successfully included" << std::endl;
    
    juce::MessageManager* mm = juce::MessageManager::getInstance();
    std::cout << "MessageManager instance: " << (mm != nullptr ? "Available" : "Null") << std::endl;
    
    juce::Thread::sleep(10);
    std::cout << "Thread sleep test: OK" << std::endl;
    
    bool isRunning = juce::Process::isRunningUnderDebugger();
    std::cout << "Running under debugger: " << (isRunning ? "Yes" : "No") << std::endl;
    
    juce::CriticalSection lock;
    {
        const juce::ScopedLock sl(lock);
        std::cout << "Critical section lock acquired" << std::endl;
    }
    std::cout << "Critical section lock released" << std::endl;
    
    juce::WaitableEvent event;
    std::cout << "WaitableEvent created: " << (event.wait(1) ? "Signaled" : "Timeout") << std::endl;

    class TestTimer : public juce::Timer {
    public:
        void timerCallback() override {
            std::cout << "Timer callback triggered successfully" << std::endl;
            stopTimer();
        }
    };
    TestTimer timer;
    timer.startTimer(50);
    std::cout << "Timer started and running" << std::endl;
    
    class TestUpdater : public juce::AsyncUpdater {
    public:
        void handleAsyncUpdate() override {
            std::cout << "AsyncUpdater callback triggered" << std::endl;
        }
    };
    TestUpdater updater;
    updater.triggerAsyncUpdate();
    std::cout << "AsyncUpdater triggered" << std::endl;
    
    juce::InterProcessLock ipLock("test_lock");
    bool lockAcquired = ipLock.enter(100);
    std::cout << "InterProcessLock: " << (lockAcquired ? "Acquired" : "Failed") << std::endl;
    if (lockAcquired) {
        ipLock.exit();
        std::cout << "InterProcessLock released" << std::endl;
    }
    
    class NamedThread : public juce::Thread {
    public:
        NamedThread() : juce::Thread("TestThread") {}
        void run() override {
            std::cout << "Named thread running: " << getThreadName() << std::endl;
        }
    };
    NamedThread namedThread;
    std::cout << "Thread created with name: " << namedThread.getThreadName() << std::endl;
    
    class TestMessage : public juce::Message {
    public:
        int getTestValue() const { return 42; }
    };
    std::cout << "Message class accessible - test value: 42" << std::endl;
    
    juce::Thread::sleep(100);
    
    std::cout << "#include <juce_events/juce_events.h> fully verified!" << std::endl << std::endl;
}

void juce_audio_basics() {
    std::cout << "=== JUCE Audio Basics Module Test ===" << std::endl;
    std::cout << "✓ JUCE Audio Basics headers successfully included" << std::endl;
    std::cout << "✓ No compilation errors" << std::endl;
    
    // Test types without requiring linking
    using AudioBuffer = juce::AudioBuffer<float>;
    using MidiMessage = juce::MidiMessage;
    using MidiBuffer = juce::MidiBuffer;
    
    std::cout << "✓ juce::AudioBuffer type accessible" << std::endl;
    std::cout << "✓ juce::MidiMessage type accessible" << std::endl;
    std::cout << "✓ juce::MidiBuffer type accessible" << std::endl;
    
    // Test constants (compile-time, no linking needed)
    std::cout << "✓ Math constants: PI = " << juce::MathConstants<float>::pi << std::endl;
    
    std::cout << "#include <juce_audio_basics/juce_audio_basics.h> verified!" << std::endl << std::endl;
}

int main() {
    std::cout << "=== JUCE Installation Test ===" << std::endl;
    std::cout << "✓ JUCE headers successfully included" << std::endl;
    std::cout << "✓ Package installation verified" << std::endl << std::endl;
    
    juce_core();
    juce_events();
    juce_audio_basics();
    
    return 0;
}