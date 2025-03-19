#ifndef DAMCON_H
#define DAMCON_H

#include "gui/gui2_overlay.h"
#include "components/shipsystem.h"

class GuiKeyValueDisplay;

class DamageControlScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* hull_display;
    GuiKeyValueDisplay* system_health[ShipSystem::COUNT];
public:
    DamageControlScreen(GuiContainer* owner);

    void onDraw(sp::RenderTarget& target) override;
};

#endif//DAMCON_H
