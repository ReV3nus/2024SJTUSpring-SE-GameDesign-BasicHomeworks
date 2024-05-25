using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MimicBehavior : MonoBehaviour
{
    public float ActivatedSpeed;
    // Start is called before the first frame update

    private bool active = false;
    private float floatSpeed = 0f;
    void Start()
    {
        active = false;
    }

    // Update is called once per frame
    void Update()
    {
        if (active)
        {
            this.floatSpeed += ActivatedSpeed * Time.deltaTime;
            this.transform.Translate(0f, floatSpeed * Time.deltaTime, 0f, Space.World);
        }
    }
    public void Activate()
    {
        active = true;
    }
}
