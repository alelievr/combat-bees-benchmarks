﻿using System.Collections.Generic;
using UnityEngine;

public static class BeeWallCollisionSystem
{
    public static void Run()
    {
		var alive = Data.Team1AliveBees;
		var dead = Data.Team1DeadBees;
		var movements = Data.Team1BeeMovements;
		CheckCollisions(alive, dead, movements);

		alive = Data.Team2AliveBees;
		dead = Data.Team2DeadBees;
		movements = Data.Team2BeeMovements;
		CheckCollisions(alive, dead, movements);
		
	}

	static void CheckCollisions(StateList alive, StateList dead, Movement[] movements)
    {
		int activeCount = alive.Count + dead.Count;

        for (int i = 0; i < activeCount; i++)
        {
			var movement = movements[i];
			if (Mathf.Abs(movement.Position.x) > Field.size.x * .5f)
			{
				movement.Position.x = (Field.size.x * .5f) * Mathf.Sign(movement.Position.x);
				movement.Velocity.x *= -.5f;
				movement.Velocity.y *= .8f;
				movement.Velocity.z *= .8f;
			}
			if (Mathf.Abs(movement.Position.z) > Field.size.z * .5f)
			{
				movement.Position.z = (Field.size.z * .5f) * Mathf.Sign(movement.Position.z);
				movement.Velocity.z *= -.5f;
				movement.Velocity.x *= .8f;
				movement.Velocity.y *= .8f;
			}
			
			if (Mathf.Abs(movement.Position.y) > Field.size.y * .5f)
			{
				movement.Position.y = (Field.size.y * .5f) * Mathf.Sign(movement.Position.y);
				movement.Velocity.y *= -.5f;
				movement.Velocity.z *= .8f;
				movement.Velocity.x *= .8f;
			}
			movements[i] = movement;
		}

		
	}
}