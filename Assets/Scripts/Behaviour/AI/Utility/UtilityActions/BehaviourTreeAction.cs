using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BehaviourTreeAction : UtilityAction
{
    BehaviourTree _tree;

    SelectorNode _root;

    public BehaviourTreeAction(Func<float> valueCalculation) : base(valueCalculation)
    {
        _tree = new BehaviourTree();

        _root = new SelectorNode();

        _tree.root = _root;
    }

    public void AddAction(UtilityAction action, Func<bool> condition)
    {
        SelectableNode child = new SelectableNode(condition);
        _root.selectableChildren.Add(child);

        Action executionAction = action.Execute;
        executionAction += () =>
        {
            Debug.Log("Executing action " + action.ToString() + " from " + GetType().ToString());
        };

        var leaf = new LeafNode(executionAction);
        child.children.Add(new LeafNode(executionAction));

    }

    public override void Execute()
    {
        _tree.StartTree();
    }
}
