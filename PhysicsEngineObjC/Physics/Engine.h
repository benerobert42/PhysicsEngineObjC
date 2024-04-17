#pragma once

#include "Eigen/Dense"

#include <vector>

using namespace Eigen;

class RigidBody;

class PhysicsEngine {
private:
    std::vector<RigidBody&> _bodies;
    uint32_t _subSteps;
    Vector3f _constraintCenter;
    float _constraintRadius;
    float _time;
    float _dt;
    
public:
    void checkCollisions(float dt);
    
    void applyConstraint();
    
    void updateObjects(float dt);
};
