#ifndef SELF_DESTRUCT_ENTRY_H
#define SELF_DESTRUCT_ENTRY_H

#include "gui/gui2_element.h"
#include "playerInfo.h"


class GuiPanel;
class GuiLabel;

class GuiSelfDestructEntry : public GuiElement
{
private:
    GuiPanel* box;
    GuiLabel* code_label;
    GuiElement* code_entry;
    GuiLabel* code_entry_code_label;
    GuiLabel* code_entry_label;
    int code_entry_position;

    CrewPositions has_position;
public:
    GuiSelfDestructEntry(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;

    void enablePosition(CrewPosition position) { has_position.add(position); }
};

#endif//SELF_DESTRUCT_ENTRY_H
