using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeafNode : BehaviourNode
{
    Action _executionAction;


    public LeafNode(BehaviourNode parent, Action executionAction) : base(parent, NodeType.Leaf)
    {
        _executionAction = executionAction;
    }

    public LeafNode(Action executionAction) : base(NodeType.Leaf)
    {
        _executionAction = executionAction;
    }

    public override void Execute()
    {
        if (_executionAction != null)
        {
            _executionAction.Invoke();
        }
    }
}
