﻿using UnityEngine;

public static class RenderSystem
{
    public static void Run(Mesh mesh, Material[] materials, MaterialPropertyBlock matProps)
    {
        int team1ActiveBees = Data.AliveCount[0] + Data.DeadCount[0];
        int numberOfBatches = team1ActiveBees / Data.beesPerBatch;
        int restNumber = team1ActiveBees % Data.beesPerBatch;
        var movements = Data.Team1BeeMovements;
        var sizes = Data.Team1Size;
        int teamIndex = 0;
        RenderTeam(numberOfBatches, restNumber, sizes, movements, matProps, teamIndex, mesh, materials);

        int team2ActiveBees = Data.AliveCount[1] + Data.DeadCount[1];
        numberOfBatches = team2ActiveBees / Data.beesPerBatch;
        restNumber = team2ActiveBees % Data.beesPerBatch;
        movements = Data.Team2BeeMovements;
        sizes = Data.Team2Size;
        teamIndex = 1;
        RenderTeam(numberOfBatches, restNumber, sizes, movements, matProps, teamIndex, mesh, materials);
    }

    static void RenderTeam(int numberOfBatches, int restNumber, float[] sizes, Movement[] movements, MaterialPropertyBlock matProps, int teamIndex, Mesh mesh, Material[] materials)
    {
        var fullBatch = Data.FullBatch;
        var restBatch = Data.RestBatch;
        var fullBatchColors = Data.FullBatchColors;
        var restBatchColors = Data.RestBatchColors;
        restBatch.Clear();
        restBatchColors.Clear();
        var directions = Data.BeeDirections[teamIndex];

        var material = materials[teamIndex];

        int beeIndex = 0;
        for (int i = 0; i < numberOfBatches; i++)
        {
            for (int j = 0; j < fullBatch.Length; j++)
            {
                var direction = directions[beeIndex];
                var rotation = Quaternion.LookRotation(direction);
                var size = sizes[beeIndex];
                var scale = Vector3.one * size;
                var movement = movements[beeIndex];
                fullBatch[j] = Matrix4x4.TRS(movement.Position, rotation, scale);
                beeIndex++;
            }
            Graphics.DrawMeshInstanced(mesh, 0, material, fullBatch, Data.beesPerBatch, matProps);
        }
        for (int i = 0; i < restNumber; i++)
        {
            var direction = directions[beeIndex];
            var rotation = Quaternion.LookRotation(direction);
            var size = sizes[beeIndex];
            var scale = Vector3.one * size;
            var movement = movements[beeIndex];
            restBatch.Add(Matrix4x4.TRS(movement.Position, rotation, scale));
            beeIndex++;
        }
        matProps.SetVectorArray("_Color", restBatchColors);
        Graphics.DrawMeshInstanced(mesh, 0, material, restBatch, matProps);

    }

}