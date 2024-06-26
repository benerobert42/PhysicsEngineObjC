#pragma once

#include "RigidBody.h"

#include "Eigen/Dense"

#include "ViewController.h"

#include <vector>
#import <Foundation/Foundation.h>

using namespace Eigen;

class RigidBody;

class PhysicsEngine {
private:
    Vector3f _constraintCenter;
    float _constraintRadius;
    
    uint32_t _subSteps;
    float _time = 0;
    float _dt;
    
    NSTimeInterval _frameDuration;
    
public:
    std::vector<RigidBody*> _bodies;
    NSTimeInterval _lastDrawTime;
    
    PhysicsEngine(Vector3f constraintCenter = {0, 0, 0},
                      float constraintRadius = 1.0,
                      uint32_t subSteps = 1,
                      float dt = 60.0 / 1000.0) :
            _bodies(),
            _constraintCenter(constraintCenter),
            _constraintRadius(constraintRadius),
            _subSteps(subSteps),
            _dt(dt) {}
    
    void checkCollisions(float dt);
    
    void applyConstraint();
    
    void update();
    
    void updateObjects(float dt);
    
    void addBody(RigidBody* body);

    void bindModelMatrices();
};
