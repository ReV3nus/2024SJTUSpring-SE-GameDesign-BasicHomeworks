using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float BaseSpeed;
    public Camera mainCamera;

    private Vector2 BallPos = new Vector2(0.0f, 0.0f);
    private Vector2 BallVelocity = new Vector2(0.0f, 0.0f);

    private Rigidbody rb;
    private GameController gameController;
    // Start is called before the first frame update
    void Start()
    {
        BallPos.x = BallPos.y = 0.0f;
        BallVelocity.x = BallVelocity.y = 0.0f;

        rb = GetComponent<Rigidbody>();
        gameController = GameObject.Find("GameController").GetComponent<GameController>();
    }

    // Update is called once per frame
    void Update()
    {
    }

    private void FixedUpdate()
    {
        Quaternion cameraYRotation = Quaternion.Euler(0f, mainCamera.transform.rotation.eulerAngles.y, 0f);

        float moveHorizontal = Input.GetAxis("Horizontal"); 
        float moveVertical = Input.GetAxis("Vertical");


        Vector3 movement = new Vector3(moveHorizontal, 0.0f, moveVertical);
        movement = cameraYRotation * movement;
        rb.AddForce(movement * BaseSpeed * Time.deltaTime);

        Vector3 rotation = new Vector3(moveVertical, 0.0f, -moveHorizontal) * 2.0f;
        rotation = cameraYRotation * rotation;
        rb.AddTorque(rotation * BaseSpeed * Time.deltaTime);

    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag != "Snack") return;
        gameController.onSnackEaten(other.gameObject.transform.localScale.x);
        other.gameObject.GetComponent<SnackBehavior>().DestroySelf();

    }
}
