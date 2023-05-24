﻿using UnityEngine;

public class Bee {
	public Vector3 position;
	public Vector3 velocity;
	public Vector3 direction;
	public int team;
	public float size;
	public Bee enemyTarget;

	public bool dead = false;
	public float deathTimer = 1f;
	public bool isAttacking;
	public bool isHoldingResource;
	public int index;

	public void Init(Vector3 myPosition,int myTeam,float mySize) {
		position = myPosition;
		velocity = Vector3.zero;
		direction = Vector3.forward;
		velocity = Vector3.zero;
		team = myTeam;
		size = mySize;

		dead = false;
		deathTimer = 1f;
		isAttacking = false;
		isHoldingResource = false;
		index = -1;

		enemyTarget = null;
	}
}
