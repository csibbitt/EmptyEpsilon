#include "components/ai.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/collision.h"
#include "systems/missilesystem.h"
#include "ai/missileVolleyAI.h"
#include "ai/aiFactory.h"

REGISTER_SHIP_AI(MissileVolleyAI, "missilevolley");

MissileVolleyAI::MissileVolleyAI(sp::ecs::Entity owner)
: ShipAI(owner)
{
    flank_position = Unknown;
}

bool MissileVolleyAI::canSwitchAI()
{
    return true;
}

void MissileVolleyAI::run(float delta)
{
    ShipAI::run(delta);
}

void MissileVolleyAI::runOrders()
{
    flank_position = Unknown;
    ShipAI::runOrders();
}

void MissileVolleyAI::runAttack(sp::ecs::Entity target)
{
    if (!has_missiles) {
        ShipAI::runAttack(target);
        return;
    }
    auto tubes = owner.getComponent<MissileTubes>();
    if (!tubes) {
        ShipAI::runAttack(target);
        return;
    }
    auto transform = owner.getComponent<sp::Transform>();
    if (!transform)
        return;
    auto target_transform = target.getComponent<sp::Transform>();
    if (!target_transform)
        return;

    auto position_diff = target_transform->getPosition() - transform->getPosition();
    float target_angle = vec2ToAngle(position_diff);
    float distance = glm::length(position_diff);

    if (flank_position == Unknown)
    {
        //No flanking position. Do we want to go left or right of the target?
        auto left_point = target_transform->getPosition() + vec2FromAngle(target_angle - 120) * 3500.0f;
        auto right_point = target_transform->getPosition() + vec2FromAngle(target_angle + 120) * 3500.0f;
        if (angleDifference(vec2ToAngle(left_point - transform->getPosition()), transform->getRotation()) < angleDifference(vec2ToAngle(right_point - transform->getPosition()), transform->getRotation()))
        {
            flank_position = Left;
        }else{
            flank_position = Right;
        }
    }

    if (distance < 4500)
    {
        bool all_possible_loaded = true;
        for(auto& tube : tubes->mounts)
        {
            //Base AI class already loads the tubes with available missiles.
            //If a tube is not loaded, but is currently being load with a new missile, then we still have missiles to load before we want to fire.
            if (tube.state == MissileTubes::MountPoint::State::Loading)
            {
                all_possible_loaded = false;
                break;
            }
        }

        if (all_possible_loaded)
        {
            int can_fire_count = 0;
            for(auto& tube : tubes->mounts)
            {
                float target_angle = calculateFiringSolution(target, tube);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    can_fire_count++;
                }
            }

            for(auto& tube : tubes->mounts)
            {
                float target_angle = calculateFiringSolution(target, tube);
                if (target_angle != std::numeric_limits<float>::infinity())
                {
                    can_fire_count--;
                    if (can_fire_count == 0)
                        MissileSystem::fire(owner, tube, target_angle, target);
                    else if ((can_fire_count % 2) == 0)
                        MissileSystem::fire(owner, tube, target_angle + 20.0f * (can_fire_count / 2), target);
                    else
                        MissileSystem::fire(owner, tube, target_angle - 20.0f * ((can_fire_count + 1) / 2), target);
                }
            }
        }
    }

    glm::vec2 target_position{};
    if (flank_position == Left)
    {
        target_position = target_transform->getPosition() + vec2FromAngle(target_angle - 120) * 3500.0f;
    }else{
        target_position = target_transform->getPosition() + vec2FromAngle(target_angle + 120) * 3500.0f;
    }

    auto ai = owner.getComponent<AIController>();
    if (ai && ai->orders == AIOrder::StandGround)
    {
        auto thrusters = owner.getComponent<ManeuveringThrusters>();
        if (thrusters) thrusters->target = vec2ToAngle(target_position - transform->getPosition());
    }else{
        flyTowards(target_position, 0.0f);
    }
}
