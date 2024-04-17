#pragma once

#include "Eigen/Dense"

using namespace Eigen;

struct RigidBody {
public:
    
    Vector3f _position;
    Vector3f _velocity;
    Vector3f _acceleration;
    float _radius;
    float _mass;
    float _drag;
    
    Affine3f _modelTransform;
    
    RigidBody(Vector3f position,
              Vector3f velocity,
              Vector3f acceleration,
              float radius = 1.0,
              float mass = 1.0,
              float drag = 0.5,
              Affine3f modelTransform = Affine3f::Identity()) {
        _position = position;
        _velocity = velocity;
        _acceleration = acceleration;
        _radius = radius;
        _mass = mass;
        _drag = drag;
        _modelTransform = modelTransform;
    }
    
    void update(double dt);

    Vector3f applyForces() const;
};
