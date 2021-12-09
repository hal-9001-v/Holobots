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

    public int meleeRange
    {
        get
        {
            return _meleeRange;
        }
    }

    MeleerExecuter _executer;
    TurnActor _actor;

    private void Awake()
    {
        _actor = GetComponent<TurnActor>();

        _executer = new MeleerExecuter(_actor, _meleerCost);
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
    TurnActor _actor;
    Highlighter _highlighter;
    int _cost = 0;

    public MeleerExecuter(TurnActor actor, int cost)
    {
        _actor = actor;
        _cost = cost;

        _highlighter = new Highlighter();
    }

    public void Execute(Target target, int damage)
    {
        Debug.Log(_actor.name + " is attacking with melee " + target.name);

        _actor.StartCoroutine(MakeHit(target, damage));
    }

    IEnumerator MakeHit(Target target, int damage)
    {
        _actor.StartStep(_cost);
        _highlighter.AddDangerededHighlightable(target.highlightable);
        _highlighter.AddDangerededHighlightable(target.currentGroundTile.highlightable);

        
        CameraMovement c = GameObject.FindObjectOfType<CameraMovement>();
        c.FixLookAt(target.transform);
        yield return new WaitForSeconds(0.5f);
        VFXManager v = GameObject.FindObjectOfType<VFXManager>();
        v.Play("Hit", target.transform);
        yield return new WaitForSeconds(v.GetDuration()-1.5f);

        _highlighter.Unhighlight();
        if(target.currentHealth - damage <= 0){
        if(target!=null)   target.Hurt(damage);
            yield return new WaitForSeconds(2f);
        }  
      _actor.EndStep();

    }
}