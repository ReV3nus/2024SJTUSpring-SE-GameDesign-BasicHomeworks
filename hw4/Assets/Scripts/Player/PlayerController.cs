using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Scripting.APIUpdating;

public class PlayerController : MonoBehaviour
{
    [Header("Components")]
    public CameraController Camera;
    private Rigidbody rb;
    private PlayerCharacter pc;
    private PlayerAnimation anim;

    [Header("Ground Checker")]
    public BoxCollider groundChecker;
    public LayerMask groundMask;
    public bool onGround;
    private float JumpCounter;

    [Header("Controller States")]
    public float inputX;
    public float inputY;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        pc = GetComponent<PlayerCharacter>();
        anim = GetComponent<PlayerAnimation>();
    }

    private void Update()
    {
        FaceWithCamera();
    }
    private void FixedUpdate()
    {
        if (JumpCounter > 0f) JumpCounter -= Time.deltaTime;
        Move();
        CheckGround();
    }

    void FaceWithCamera()
    {
        transform.rotation = Quaternion.Euler(0f, Camera.cameraFaceAngles.x, 0f);
    }
    void Move()
    {
        inputX = Input.GetAxisRaw("Horizontal");
        inputY = Input.GetAxisRaw("Vertical");
        Quaternion cameraRotation = Quaternion.Euler(0f, Camera.cameraFaceAngles.x, 0);
        Vector3 MoveDir = new Vector3(inputX, 0f, inputY) * pc.MoveSpeed * Time.deltaTime;
        MoveDir = cameraRotation * MoveDir;

        if(onGround && Input.GetKey(KeyCode.Space) && JumpCounter <= 0f)
        {
            Debug.Log("JUMP");
            MoveDir += new Vector3(0f, pc.JumpSpeed, 0f);
            onGround = false;
            anim.StartJump();
            JumpCounter = 0.5f;
        }
        rb.velocity = new Vector3(MoveDir.x, rb.velocity.y + MoveDir.y, MoveDir.z);
    }
    void CheckGround()
    {
        onGround = Physics.CheckBox(groundChecker.transform.position + groundChecker.center, 0.5f * groundChecker.size,Quaternion.identity, groundMask);
    }
}
