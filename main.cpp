#include <iostream>
#include <cstdio>
#include <memory>
#include <array>

//#include <juce_core/juce_core.h>

int main()
{
    std::cout << "Hello, World!" << std::endl;
    std::cout << "JUCE headers compiled successfully!" << std::endl;

    /*
    We use this as a means of fetching our abuild, so we can see where things
    are failing. This helps since it lets us know if all the headers exist
    */
    const char* cmd = "abuild -r 2>&1";

    std::array<char, 128> buffer;
    std::unique_ptr<FILE, decltype(&pclose)> 
    pipe(popen(cmd, "r"), pclose);
    if (!pipe) 
    {
        std::cerr << "Failed to run abuild" << std::endl;
        return 1;
    }

    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) 
    {
        std::cout << buffer.data();
    }

    return 0;
}