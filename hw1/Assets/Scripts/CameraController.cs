using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public GameObject ball;
    public float sensitivity = 200f;

    private Vector3 offset;

    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        offset = transform.position - ball.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X");

        transform.position = ball.transform.position + offset;
        transform.RotateAround(ball.transform.position, Vector3.up, mouseX * sensitivity * Time.deltaTime);

        offset = transform.position - ball.transform.position;
    }
}
