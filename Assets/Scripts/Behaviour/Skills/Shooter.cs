using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Mover))]
public class Shooter : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 5)] int _maxShoots;
    public int maxShoots
    {
        get
        {
            return _maxShoots;
        }
    }

    int _usedShoots;
    public int usedShoots
    {
        get
        {
            return _usedShoots;
        }
    }

    [SerializeField] [Range(1, 5)] int _damage;
    [SerializeField] [Range(1, 10)] float _speed;

    [SerializeField] Projectile _projectile;

    Mover _mover;
    TurnActor _turnActor;

    public GroundTile shootOriginTile
    {
        get
        {
            return _mover.lastPathTile;
        }
    }

    private void Awake()
    {
        _mover = GetComponent<Mover>();
        _turnActor = GetComponent<TurnActor>();
    }
    public void ResetSteps()
    {
        _usedShoots = 0;
    }

    public void AddShootStep(GroundTile target)
    {
        if (_usedShoots < _maxShoots)
        {
            _usedShoots++;
            _turnActor.AddStep(new ShooterTurnStep(target, _projectile, this, _turnActor, _damage, _speed));
        }

    }

    [Serializable]
    class Shoot
    {
        public GroundTile origin { get; private set; }
        public GroundTile destination { get; private set; }

        public Shoot(GroundTile origin, GroundTile destination)
        {
            this.origin = origin;
            this.destination = destination;
        }

    }
}

public class ShooterTurnStep : TurnStep
{
    GroundTile _destination;

    Projectile _projectile;

    TurnActor _turnActor;
    Shooter _owner;

    int _damage;
    float _speed;

    public ShooterTurnStep(GroundTile destination, Projectile projectile, Shooter owner, TurnActor turnActor, int damage, float speed)
    {
        _destination = destination;

        _projectile = projectile;
        _owner = owner;

        _turnActor = turnActor;

        _damage = damage;
        _speed = speed;
    }
    public override void Execute()
    {
        _projectile.Launch(_speed, _damage, _owner,_turnActor, _turnActor.transform.position, _destination.transform.position);
    }
}
