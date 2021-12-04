using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectableNode : BehaviourNode
{
   
    Action _executionAction;
    Func<bool> _conditionFunc;


    public SelectableNode(Action executionAction, Func<bool> conditionFunc) : base(NodeType.Selectable)
    {
        _conditionFunc = conditionFunc;
        _executionAction = executionAction;
    }

    public SelectableNode(BehaviourNode parent, Action executionAction, Func<bool> conditionFunc) : base(parent, NodeType.Selectable)
    {
        _conditionFunc = conditionFunc;
        _executionAction = executionAction;
    }

    public SelectableNode(BehaviourNode parent, Func<bool> conditionFunc) : base(parent, NodeType.Selectable)
    {
        _conditionFunc = conditionFunc;
    }

    public SelectableNode(Func<bool> conditionFunc) : base(NodeType.Selectable)
    {
        _conditionFunc = conditionFunc;
    }

    public override void Execute()
    {
        if (_executionAction != null)
        {
            _executionAction.Invoke();
        }
    }

    public bool CheckSuccess()
    {
        return _conditionFunc.Invoke();
    }

}
