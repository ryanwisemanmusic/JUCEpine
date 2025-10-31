Final Steps:
- Make sure that you can utilize functionality of all JUCE headers. Just test a variety of different elements
- Ensure that we have everything bound to the APKBUILD that is needed to. For example, we might need link_guard_stub.cpp, and all the other wrappers, are integrated with APKBUILD
- Ensure this works in genuine Alpine Linux environment
- Check on another machine (aka Evan)
- Submit to Alpine Edge by cloining Edge, creating a branch, and then create a pull request
- Be willing to answer any emails about the code in question
- Publicize repos 

Finalization TODO:
- Shell test calls in bash to JUCE, ensure we can parse through all the headers and it reflects everything added
- Create desktop environment via QEMU and attempt to run JUCE
