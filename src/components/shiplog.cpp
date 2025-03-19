#include "components/shiplog.h"
#include "gameGlobalInfo.h"


void ShipLog::add(const string& message, glm::u8vec4 color)
{
    add(gameGlobalInfo->getMissionTime() + string(": "), message, color);
}

void ShipLog::add(const string& prefix, const string& message, glm::u8vec4 color)
{
    // Cap the ship's log size to 10,000 entries. If it exceeds that limit,
    // start erasing entries from the beginning.
    if (entries.size() > 10000)
        entries.erase(entries.begin());

    // Timestamp a log entry, color it, and add it to the end of the log.
    entries.push_back({prefix, message, color});
    new_entry_count += 1;
}

void ShipLog::clear()
{
    cleared = true;
    new_entry_count = 0;
    entries.clear();
}