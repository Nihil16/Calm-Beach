using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIbreathing : MonoBehaviour
{
    public Vector3 fullBreath = new Vector3(3f, 3f, 3f);
    private void Start()
    {
        LeanTween.scale(gameObject, fullBreath, 3f).setEaseInCubic().setLoopPingPong();
    }
}
