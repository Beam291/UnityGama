using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GameObject cube = GameObject.Find("Cube");
        Color myColor = new Color(34f/255f, 128f/255f, 1f/255f);
        Renderer renderer = cube.GetComponent<Renderer>();
        renderer.material.color = myColor;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
