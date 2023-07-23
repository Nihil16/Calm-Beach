using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class UIbreathing : MonoBehaviour
{
    [SerializeField] private Vector3 fullBreath = new Vector3(3f, 3f, 3f);

    [SerializeField] private float timeTillTarget;

    [Header ("Inhale")]
    [SerializeField] private float StartInhaleTime = 1.8f;
    [SerializeField] private float TargetInhaleTime = 3f;
    [SerializeField] private float CurrentInhaleTime;

    [Header("Hold")]
    [SerializeField] private float StartHoldTime = 0.3f;
    [SerializeField] private float TargetHoldTime = 0.6f;
    [SerializeField] private float CurrentHoldTime;

    [Header("Exhale")]
    [SerializeField] private float StartExhaleTime = 4.2f;
    [SerializeField] private float TargetExhaleTime = 7f;
    [SerializeField] private float CurrentExhaleTime;
    
    private ParticleSystem particleSystem;
    private void Start()
    {
        particleSystem = GetComponent<ParticleSystem>();
        
        LeanTween.value(StartInhaleTime, TargetInhaleTime, timeTillTarget).setOnUpdate((float value) => CurrentInhaleTime = value );
        LeanTween.value(StartExhaleTime, TargetExhaleTime, timeTillTarget).setOnUpdate((float value) => CurrentExhaleTime = value );
        LeanTween.value(StartHoldTime, TargetHoldTime, timeTillTarget).setOnUpdate((float value) => CurrentHoldTime = value );
        StartInhale();
    }
    private void StartInhale()
    {
        LeanTween.scale(gameObject, fullBreath, CurrentInhaleTime)
            .setEaseInOutCubic()
            .setOnComplete(() => StartExhale());
        if (particleSystem!= null)
        {
            particleSystem.Stop();
        }
    }
    private void StartExhale()
    {
        LeanTween.scale(gameObject, Vector3.one, CurrentExhaleTime)
            .setEaseInOutCubic()
            .setOnComplete(() => StartInhale())
            .setDelay(CurrentHoldTime);
        if (particleSystem!= null)
        {
            particleSystem.Play();
        }

    }


}
