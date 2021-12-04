using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BehaviourTree
{
    public BehaviourNode root;

    Stack<BehaviourNode> _nodesForExecution;

    Action _endOfExecutionAction;

    public BehaviourTree()
    {
        _nodesForExecution = new Stack<BehaviourNode>();
    }

    public void ExecuteNode(BehaviourNode node)
    {
        node.Execute();


        //Execute next Nodes
        switch (node.nodeType)
        {
            case NodeType.Leaf:
                Tick();
                break;

            case NodeType.Sequence:
                AddNodesForExecution(node.children);

                Tick();
                break;

            case NodeType.WaitForTick:
                AddNodesForExecution(node.children);
                break;

            case NodeType.Selector:

                var selectorNode = (SelectorNode)node;

                foreach (var child in selectorNode.selectableChildren)
                {
                    if (child.CheckSuccess())
                    {
                        AddNodesForExecution(child.children);

                        Tick();
                        return;
                    }
                }

                break;

        }

    }

    public void Tick()
    {
        if (_nodesForExecution.Count > 0)
        {
            ExecuteNode(_nodesForExecution.Pop());
        }
        else
        {
            if (_endOfExecutionAction != null)
                _endOfExecutionAction.Invoke();
        }
    }

    public void StartTree(Action afterTreeExecutionAction)
    {
        _endOfExecutionAction = afterTreeExecutionAction;

        ExecuteNode(root);
    }

    public void StartTree()
    {
        ExecuteNode(root);
    }

    void AddNodesForExecution(List<BehaviourNode> nodes)
    {
        foreach (var node in nodes)
        {
            _nodesForExecution.Push(node);
        }
    }

}
