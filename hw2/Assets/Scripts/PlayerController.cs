using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float MoveSpeed;
    public float JumpSpeed;
    public float iceSlowRate;

    private Rigidbody2D rb;
    private Animator animator;

    private bool onAir = true;  
    private enum GT
    {
        Default, Sand, Ice
    };
    private GT groundType;
    // Start is called before the first frame update
    void Start()
    {
        rb = this.GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!onAir && Input.GetKeyDown(KeyCode.Space)) Jump();
        Move();

        animator.SetBool("Air", onAir);
        animator.SetFloat("vy", rb.velocity.y);
    }
    void Move()
    {
        float xInput = Input.GetAxisRaw("Horizontal");
        if(groundType == GT.Ice && xInput == 0f)
        {
            rb.velocity = new Vector2(rb.velocity.x * (1- iceSlowRate * Time.deltaTime), rb.velocity.y);
        }
        else rb.velocity = new Vector2(xInput * MoveSpeed / (1 + (groundType == GT.Sand ? 1 : 0)), rb.velocity.y);
        animator.SetBool("Move", xInput != 0);
        if (xInput != 0)
            transform.localScale = new Vector3(xInput, 1, 1);
    }
    void Jump()
    {
        rb.velocity = new Vector2(rb.velocity.x, JumpSpeed / (1 + (groundType == GT.Sand ? 1 : 0)));
    }
    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.tag == "Mimic")
            collision.gameObject.GetComponent<MimicBehavior>().Activate();
    }
    void OnCollisionStay2D(Collision2D collision)
    {
        if (collision.gameObject.layer == LayerMask.NameToLayer("Platform"))
            onAir = false;
        if (collision.collider.tag == "Spikes") Die();
        if (collision.collider.tag == "Ice")
            groundType = GT.Ice;
        if (collision.collider.tag == "Sand")
            groundType = GT.Sand;
    }
    private void OnCollisionExit2D(Collision2D collision)
    {
        if (collision.gameObject.layer == LayerMask.NameToLayer("Platform"))
            onAir = true;
        groundType = GT.Default;
    }
    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.tag == "Spikes") Die();
    }
    private void Die()
    {
        animator.SetBool("Hit", true);
        transform.position = new Vector3(transform.position.x, transform.position.y, 10f);
        rb.constraints = RigidbodyConstraints2D.None;
        GameManager.GameOver();
    }
}
