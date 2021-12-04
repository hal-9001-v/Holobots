using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceNode : BehaviourNode
{
    Action _executionAction;

    public SequenceNode(BehaviourNode parent, Action executionAction) : base(parent, NodeType.Sequence)
    {
        _executionAction = executionAction;
    }


    public SequenceNode(Action executionAction) : base(NodeType.Sequence)
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
