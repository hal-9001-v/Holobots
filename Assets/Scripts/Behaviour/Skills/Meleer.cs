using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Meleer : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(2, 5)] int _meleeRange = 2;
    [SerializeField] [Range(1, 5)] int _defaultMeleerDamage = 1;
    [SerializeField] [Range(1, 5)] int _meleerCost = 1;

    [Header("Specific Damage")]
    [SerializeField] List<DamageForType> _specificDamages;

    VFXManager _vfxManager;

    public int meleeRange
    {
        get
        {
            return _meleeRange;
        }
    }

    MeleerExecuter _executer;
    TurnActor _actor;

    CharacterRotator _rotator;

    private void Awake()
    {
        _actor = GetComponent<TurnActor>();
        _rotator = GetComponentInChildren<CharacterRotator>();

        var vfxManager = FindObjectOfType<VFXManager>();
        var cameraMovement = FindObjectOfType<CameraMovement>();
        _executer = new MeleerExecuter(_actor, _meleerCost, vfxManager, cameraMovement);

        _vfxManager = FindObjectOfType<VFXManager>();
    }

    public void Hit(Target target)
    {
        int damage = _defaultMeleerDamage;

        foreach (var specificDamage in _specificDamages)
        {
            if (specificDamage.type == target.targetType)
            {
                damage = specificDamage.damage;
                break;
            }
        }

        if (_rotator)
        {
            var direction = target.transform.position - transform.position;
            direction.Normalize();

            _rotator.SetForward(direction, 0.6f);
        }

        _executer.Execute(target, damage);
    }

    [Serializable]
    class DamageForType
    {
        [SerializeField] TargetType _type;
        [SerializeField] [Range(0, 10)] int _damage;
        public TargetType type
        {
            get
            {
                return _type;
            }
        }

        public int damage
        {
            get { return _damage; }
        }
    }

}

class MeleerExecuter
{
    VFXManager _vfxManager;
    CameraMovement _cameraMovement;

    TurnActor _actor;
    Highlighter _highlighter;
    int _cost = 0;

    public MeleerExecuter(TurnActor actor, int cost, VFXManager vfxManager, CameraMovement cameraMovement)
    {
        _actor = actor;
        _cost = cost;

        _vfxManager = vfxManager;
        _cameraMovement = cameraMovement;

        _highlighter = new Highlighter();
    }

    public void Execute(Target target, int damage)
    {
        Debug.Log(_actor.name + " is attacking with melee " + target.name);
    
        _actor.StartCoroutine(MakeHit(target, damage));
    }



    IEnumerator MakeHit(Target target, int damage)
    {
        CountBarrier barrier = new CountBarrier(() =>
        {
            _actor.EndStep();
        });
        barrier.AddCounter();

        _actor.StartStep(_cost);
        _highlighter.AddDangerededHighlightable(target.highlightable);
        _highlighter.AddDangerededHighlightable(target.currentGroundTile.highlightable);
        Animator anim = _actor.gameObject.GetComponentInChildren<Animator>();
        anim.SetTrigger("Attack");
        _cameraMovement.FixLookAt(target.transform);
        yield return new WaitForSeconds(0.5f);
        anim.ResetTrigger("Attack");

        _vfxManager.Play("Hit", target.transform,Quaternion.EulerAngles(Vector3.zero));
        yield return new WaitForSeconds(_vfxManager.GetDuration() - 1.5f);

        _highlighter.Unhighlight();

        barrier.AddCounter();
        target.Hurt(_actor.target, damage, barrier);
        barrier.RemoveCounter();
    }
}