using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BehaviourTreeAction : UtilityAction
{
    BehaviourTree _tree;

    SelectorNode _root;

    public BehaviourTreeAction(string name, Func<float> valueCalculation) : base(name, valueCalculation)
    {
        _tree = new BehaviourTree();

        _root = new SelectorNode();

        _tree.root = _root;
    }

    public void AddAction(Func<bool> execution)
    {
        new LeafNode(_root, execution);
    }

    public override void Execute()
    {
        _tree.StartTree();
    }
}
