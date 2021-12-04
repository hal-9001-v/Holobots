using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectorNode : BehaviourNode
{
    public List<SelectableNode> selectableChildren { get; private set; }

    Action _executionAction;

    public SelectorNode(BehaviourNode parent, Action executionAction) : base(parent, NodeType.Selector)
    {
        _executionAction = executionAction;

        selectableChildren = new List<SelectableNode>();
    }

    public SelectorNode() : base(NodeType.Selector)
    {
        selectableChildren = new List<SelectableNode>();
    }


    public SelectorNode(Action executionAction) : base(NodeType.Selector)
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
