using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimation : MonoBehaviour
{
    private PlayerController player;
    private Animator anim;

    private float preX, preY;
    private bool preMovingAnim, curMovingAnim;
    private void Start()
    {
        anim = GetComponent<Animator>();
        player = GetComponent<PlayerController>();
    }

    private void Update()
    {
        AnimSetMovement();
    }
    void AnimSetMovement()
    {
        anim.SetInteger("SpeedX", (int)player.inputX);
        anim.SetInteger("SpeedY", (int)player.inputY);
        curMovingAnim = ((player.inputX != 0f || player.inputY != 0f) && player.onGround);
        anim.SetBool("Moving", (player.inputX != 0f || player.inputY != 0f));
        if (!curMovingAnim && preMovingAnim)
            anim.SetTrigger("StopMovingAnim");
        preMovingAnim = curMovingAnim;
        anim.SetBool("Ground", player.onGround);
    }

    public void StartJump()
    {
        anim.SetTrigger("Jump");
    }
}
