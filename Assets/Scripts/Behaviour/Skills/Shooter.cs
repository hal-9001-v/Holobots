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
    [SerializeField] [Range(1, 5)] int _shootCost = 1;

    public int shootCost
    {
        get
        {
            return _shootCost;
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

    TurnActor _turnActor;
    Target _target;
    ShooterExecuter _executer;

    private void Awake()
    {
        _turnActor = GetComponent<TurnActor>();
        _target = GetComponent<Target>();

        _projectile.SetOwner(_target);

        var rotator = GetComponentInChildren<CharacterRotator>();
        var cameraMovement = FindObjectOfType<CameraMovement>();
        _executer = new ShooterExecuter(_projectile, rotator,cameraMovement, _damage, this, _turnActor, _speed);
    }

    public void AddShoot(Target target)
    {

        _executer.Execute(target);
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

public class ShooterExecuter
{
    Projectile _projectile;

    Highlighter _highligher;

    TurnActor _turnActor;
    Shooter _owner;

    float _speed;

    int _damage;

    CharacterRotator _rotator;

    CameraMovement _cameraMovement;

    public ShooterExecuter(Projectile projectile, CharacterRotator characterRotator, CameraMovement cameraMovement, int damage, Shooter owner, TurnActor turnActor, float speed)
    {
        _projectile = projectile;
        _owner = owner;

        _damage = damage;

        _turnActor = turnActor;

        _speed = speed;

        _rotator = characterRotator;

        _cameraMovement = cameraMovement;

        _highligher = new Highlighter();
    }

    public void Execute(Target target)
    {
        _owner.StartCoroutine(MoveProjectileToTarget(_speed, _turnActor.transform.position, target));
    }

    IEnumerator MoveProjectileToTarget(float speed, Vector3 origin, Target target)
    {
        CountBarrier barrier = new CountBarrier(() =>
        {
            _turnActor.EndStep();
        });
        barrier.AddCounter();

        _turnActor.StartStep(_owner.shootCost);

        _highligher.AddDangerededHighlightable(target.highlightable);
        _highligher.AddDangerededHighlightable(target.currentGroundTile.highlightable);

        if (_rotator)
        {
            var direction = target.transform.position - origin;
            direction.Normalize();

            _rotator.SetForward(direction, 0.3f);

        }

        yield return new WaitForSeconds(0.5f);

        float duration = Vector3.Distance(origin, target.transform.position) / speed;
        float elapsedTime = 0;
        _projectile.transform.position = origin;

        _projectile.EnableProjectile();
        _cameraMovement.FixLookAt(_projectile.transform);

        while (elapsedTime < duration)
        {
            elapsedTime += Time.deltaTime;

            _projectile.transform.position = Vector3.Lerp(origin, target.transform.position, elapsedTime / duration);

            yield return null;

        }

        _highligher.Unhighlight();

        _projectile.transform.position = target.transform.position;

        if (_projectile.damagedTarget)
        {
            barrier.AddCounter();
            _projectile.damagedTarget.Hurt(_damage, barrier);
        }

        _projectile.DisableProjectile();

        barrier.RemoveCounter();
    }

}
