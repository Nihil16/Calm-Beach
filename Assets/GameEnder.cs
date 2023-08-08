using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameEnder : MonoBehaviour
{
    public AudioClip Narration;
    public float clipLength;
    // Start is called before the first frame update
    void Start()
    {
        clipLength = Narration.length;
    }
    void Update () 
    {
        clipLength -= Time.deltaTime;
        if (clipLength <= 0 )
        {
            Application.Quit();
        }
    }
    
}
