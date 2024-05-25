using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireBehavior : MonoBehaviour
{
    // Start is called before the first frame update
    public float PeriodTime;

    private Animator animator;
    private float Timer = 0f;
    private bool fire = false;
    void Start()
    {
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        Timer += Time.deltaTime;
        if(Timer > PeriodTime)
        {
            fire = fire ? false : true;
            animator.SetBool("Fire", fire);
            Timer = 0f;
        }
    }
}
