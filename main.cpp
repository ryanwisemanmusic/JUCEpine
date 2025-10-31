#include <iostream>
#include <juce_core/juce_core.h>

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

int main() {
    std::cout << "=== JUCE Installation Test ===" << std::endl;
    std::cout << "✓ JUCE headers successfully included" << std::endl;
    std::cout << "✓ Package installation verified" << std::endl << std::endl;
    
    juce_core();
    
    return 0;
}