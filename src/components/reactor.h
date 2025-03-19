#pragma once

#include "shipsystem.h"

// The reactor component stores and generates energy, any shipsystem can use energy and drain this. While the reactor generates energy.
class Reactor : public ShipSystem {
public:
    Reactor() { can_be_hacked = false; }

    // Config
    float max_energy = 1000.0f;
    bool overload_explode = true;

    // Runtime
    float energy = 1000.0f;

    bool useEnergy(float amount) { if (amount > energy) return false; energy -= amount; return true; }
};