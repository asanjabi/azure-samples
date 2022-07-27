using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Linq;

using Microsoft.Extensions.Configuration;

namespace Shared
{
    public class TestCircuitBreaker<T> : ICircuitBreaker
    {
        IConfiguration _config = null;
        public TestCircuitBreaker()
        {
            var builder = new ConfigurationBuilder();

            var assembly = Assembly.GetAssembly(typeof(T));

            string path = Path.GetDirectoryName(assembly.Location);
            if(path.EndsWith("bin", StringComparison.OrdinalIgnoreCase))
            {
                path = Path.GetDirectoryName(path);
            }

            builder.AddJsonFile(Path.Combine(path, "breaker.json"), false, true);
            this._config = builder.Build();
        }

        public async Task<bool> ShouldAbort(Exception exception, string sessionId)
        {
            if (this.DoesContain(sessionId))
            {
                return true;
            }

            return false;
        }

        public async Task<bool> CanResume(string sessionId)
        {
            if (this.DoesContain(sessionId))
            {
                return false;
            }

            return true;
        }

        private bool DoesContain(string sessionId)
        {
            var pausedSessionsSection = this._config.GetSection("PausedSessions");
            var pausedSessions = pausedSessionsSection.GetChildren().ToArray();

            bool conatins = pausedSessions.Any(section => string.Compare(section.Value, sessionId, true) == 0);

            return conatins;
        }
    }
}
