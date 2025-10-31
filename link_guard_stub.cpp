// Stub to satisfy JUCE mixed debug/release link guard when compiling only headers
namespace juce {
namespace this_will_fail_to_link_if_some_of_your_compile_units_are_built_in_release_mode {
// Some JUCE versions reference a function symbol
void this_will_fail_to_link_if_some_of_your_compile_units_are_built_in_release_mode() {}

// Others reference a type with a user-declared constructor
struct this_will_fail_to_link_if_some_of_your_compile_units_are_built_in_release_mode_struct {
    this_will_fail_to_link_if_some_of_your_compile_units_are_built_in_release_mode_struct() {}
};
}
}


