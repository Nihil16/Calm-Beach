using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LunarRotation : MonoBehaviour
{
    void Start()
    {
        LeanTween.rotate(gameObject, new Vector3(-16, 0, 0), 240);
    }
}
