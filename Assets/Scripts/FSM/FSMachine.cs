using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FSMachine
{
    FSMState _currentState;

    public FSMachine(FSMState startingState)
    {
        _currentState = startingState;
    }

    public void Update()
    {
        FSMState nextState;

        if (_currentState.CheckTransitionToChildren(out nextState))
        {
            SetState(nextState);
        }
    }

    void SetState(FSMState state)
    {
        _currentState = state;

        _currentState.Execute();
    }

}
