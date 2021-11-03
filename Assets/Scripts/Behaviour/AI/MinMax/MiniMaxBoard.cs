using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MiniMaxBoard
{
    public Bot[] enemies { get; private set; }
    public PlayerUnit[] units { get; private set; }

    public Obstacle[] obstacles { get; private set; }

    public int value { get; private set; }

    public MiniMaxBoard()
    {
        enemies = GameObject.FindObjectsOfType<Bot>();
        units = GameObject.FindObjectsOfType<PlayerUnit>();
        obstacles = GameObject.FindObjectsOfType<Obstacle>();
    }

    public MiniMaxBoard(MiniMaxBoard parent)
    {

    }

    public MiniMaxBoard NextBoardAfterPlayerTurn()
    {
        TurnPreview[][] enemyPreview = new TurnPreview[enemies.Length][];

        for (int i = 0; i < enemies.Length; i++)
        {
            enemyPreview[i] = enemies[i].GetPossibleMoves();
        }

        TurnPreview[][] unitPreview = new TurnPreview[units.Length][];

        for (int i = 0; i < units.Length; i++)
        {
            unitPreview[i] = units[i].GetPossibleMoves();
        }



        return new MiniMaxBoard();
    }

    int GetPreviewValue(MinMaxWeights weights)
    {
        int value = 0;

        return value;
    }



}
