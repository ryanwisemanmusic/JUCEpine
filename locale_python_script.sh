#!/bin/sh

# locale_patch.sh - JUCE locale function patching for musl

patch_locale_functions() {
    local stats_file="$1"
    
    # Patch locale functions using Python
    cat > /tmp/fix_juce_locale.py << 'PYTHON_SCRIPT'
import sys

filename = sys.argv[1]
with open(filename, 'r') as f:
    content = f.read()

old_lang = '''String SystemStats::getUserLanguage()
{
   #if JUCE_BSD
    if (auto langEnv = getenv ("LANG"))
        return String::fromUTF8 (langEnv).upToLastOccurrenceOf (".UTF-8", false, true);

    return {};
   #else
    return getLocaleValue (_NL_ADDRESS_LANG_AB);
   #endif
}'''

new_lang = '''String SystemStats::getUserLanguage()
{
   #if JUCE_BSD || defined(__MUSL__)
    if (auto* lang = ::getenv("LANG"))
    {
        String langStr(lang);
        if (langStr.contains("_"))
            return langStr.upToFirstOccurrenceOf("_", false, false);
        if (langStr.contains("."))
            return langStr.upToFirstOccurrenceOf(".", false, false);
        return langStr;
    }
    return "en";
   #else
    return getLocaleValue (_NL_ADDRESS_LANG_AB);
   #endif
}'''

old_region = '''String SystemStats::getUserRegion()
{
   #if JUCE_BSD
    return {};
   #else
    return getLocaleValue (_NL_ADDRESS_COUNTRY_AB2);
   #endif
}'''

new_region = '''String SystemStats::getUserRegion()
{
   #if JUCE_BSD || defined(__MUSL__)
    if (auto* lang = ::getenv("LANG"))
    {
        String langStr(lang);
        if (langStr.contains("_"))
        {
            auto region = langStr.fromFirstOccurrenceOf("_", false, false);
            if (region.contains("."))
                return region.upToFirstOccurrenceOf(".", false, false);
            return region;
        }
    }
    return "US";
   #else
    return getLocaleValue (_NL_ADDRESS_COUNTRY_AB2);
   #endif
}'''

content = content.replace(old_lang, new_lang)
content = content.replace(old_region, new_region)

with open(filename, 'w') as f:
    f.write(content)

print("Successfully patched locale functions")
PYTHON_SCRIPT

    python3 /tmp/fix_juce_locale.py "$stats_file"
    rm -f /tmp/fix_juce_locale.py
}