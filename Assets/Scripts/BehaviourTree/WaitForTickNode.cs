using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaitForTickNode : BehaviourNode
{
    Action _executionAction;

    public WaitForTickNode(BehaviourNode parent, Action executionAction) : base(parent, NodeType.WaitForTick)
    {
        _executionAction = executionAction;
    }

    public WaitForTickNode(Action executionAction) : base(NodeType.WaitForTick)
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
