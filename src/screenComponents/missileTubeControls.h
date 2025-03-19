#ifndef MISSILE_TUBE_CONTROLS_H
#define MISSILE_TUBE_CONTROLS_H

#include "gui/gui2_element.h"
#include "missileWeaponData.h"

class GuiButton;
class GuiProgressbar;
class GuiLabel;
class GuiToggleButton;

class GuiMissileTubeControls : public GuiElement
{
public:
    GuiMissileTubeControls(GuiContainer* owner, string id);

    virtual void onUpdate() override;

    void setMissileTargetAngle(float angle);
    float getMissileTargetAngle();

    void setManualAim(bool manual);
    bool getManualAim();

private:
    struct TubeRow {
        GuiElement* layout;
        GuiButton* load_button;
        GuiButton* fire_button;
        GuiProgressbar* loading_bar;
        GuiLabel* loading_label;
    };
    GuiElement* tube_rows_layout;
    std::vector<TubeRow> rows;
    class TypeRow {
    public:
        GuiElement* layout;
        GuiToggleButton* button;
    };
    TypeRow load_type_rows[MW_Count];
    EMissileWeapons load_type;
    bool manual_aim;
    float missile_target_angle;

    void createTubeRow();
    void removeTubeRow();
    void selectMissileWeapon(EMissileWeapons type);
};

#endif//MISSILE_TUBE_CONTROLS_H
