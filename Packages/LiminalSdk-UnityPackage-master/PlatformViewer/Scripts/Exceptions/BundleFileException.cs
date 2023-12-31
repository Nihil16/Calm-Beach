﻿using System;
using Liminal.Platform.Experimental.App.Experiences;

namespace Liminal.Platform.Experimental.Exceptions
{
    public class BundleFileException : Exception
    {
        private const string DefaultMessage = "An ExperienceApp component was not found";

        /// <summary>
        /// Gets the <see cref="Data.Models.Experience"/> the exception relates to.
        /// </summary>
        public Liminal.Platform.Experimental.App.Experiences.Experience Experience { get; private set; }

        public BundleFileException(Liminal.Platform.Experimental.App.Experiences.Experience experience) : this(experience, DefaultMessage)
        {
            Experience = experience;
        }

        public BundleFileException(Liminal.Platform.Experimental.App.Experiences.Experience experience, Exception innerException) : base(DefaultMessage, innerException)
        {
            Experience = experience;
        }

        public BundleFileException(Liminal.Platform.Experimental.App.Experiences.Experience experience, string message) : base(message)
        {
            Experience = experience;
        }
    }
}