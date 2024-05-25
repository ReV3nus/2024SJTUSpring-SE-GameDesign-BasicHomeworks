// 实验B：模拟抛物运动
// TODO:
// 1. 参考注释补全代码，用Explicit Euler方法模拟抛物运动
// 2. 设置不同的初速度，观察运动效果
// 3. 尝试不同大小的时间步长，通过修改step的值来控制步长
// 4. 不同时间步长之间进行对比，以及与解析式方式对比
class ExplicitEulerThrow : MonoBehaviour
{
    // current position
    private float height;
    private float x;
    private float z;
    // current velocity
    private Vector3 v = new Vector3(15,0,0); // try different initial values
    private float g = 9.79f; // gravity
    private int step = 2; // You can change this!
    private int count; // used to control the frequency of updates
    float deltaTime = 0;

    // TODO: complete the function
    void UpdatePosition()
    {
    	x = x + v.x * deltaTime;
        height = height + v.y * deltaTime;
        z = z + v.z * deltaTime;
        
		v.y = v.y - g * deltaTime;
        
        if (height <= transform.localScale.y/2)
        {
            height = transform.localScale.y/2;
            v = Vector3.zero;
        }
        deltaTime = 0f;
    }

    // Start is called before the first frame update
    void Start()
    {
        // set initial values
        height = transform.position.y;
        x = transform.position.x;
        z = transform.position.z;
        count = 0;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
    	deltaTime = deltaTime + Time.deltaTime;
        count++;
        if (count >= step)
        {
            // calculate new position
            UpdatePosition();
            // set new position
            transform.position = new Vector3(x, height, z);
            count = 0;
            
        }
    }
}
