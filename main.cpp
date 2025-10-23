#include <iostream>

// Just test that we can include JUCE headers without linking
// Don't actually use any JUCE functionality that requires linking
#include <juce_core/juce_core.h>

int main()
{
    std::cout << "Hello, World!" << std::endl;
    std::cout << "JUCE headers compiled successfully!" << std::endl;

    // Don't create any JUCE objects that would require linking
    // Just use the version macros which are compile-time only
    //std::cout << "JUCE version: " << JUCE_MAJOR_VERSION << "." << JUCE_MINOR_VERSION << std::endl;

    return 0;
}