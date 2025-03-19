#ifndef POWER_MANAGEMENT_H
#define POWER_MANAGEMENT_H

#include "gui/gui2_overlay.h"
#include "components/shipsystem.h"

class GuiPanel;
class GuiSlider;
class GuiProgressbar;
class GuiKeyValueDisplay;

class PowerManagementScreen : public GuiOverlay
{
private:
    GuiKeyValueDisplay* energy_display;
    GuiKeyValueDisplay* coolant_display;

    float previous_energy_measurement;
    float previous_energy_level;
    float average_energy_delta;
    ShipSystem::Type selected_system = ShipSystem::Type::None;

    class SystemRow
    {
    public:
        GuiPanel* box;
        GuiSlider* power_slider;
        GuiSlider* coolant_slider;
        GuiProgressbar* heat_bar;
        GuiProgressbar* power_bar;
        GuiProgressbar* coolant_bar;
    };
    SystemRow systems[ShipSystem::COUNT];
    bool set_power_active[ShipSystem::COUNT] = {false};
    bool set_coolant_active[ShipSystem::COUNT] = {false};
public:
    PowerManagementScreen(GuiContainer* owner);

    void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//POWER_MANAGEMENT_H
