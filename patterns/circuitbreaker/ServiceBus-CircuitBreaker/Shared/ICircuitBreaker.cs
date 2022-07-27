using System;
using System.Threading.Tasks;

namespace Shared
{
    public interface ICircuitBreaker
    {
        Task<bool> CanResume(string sessionId);
        Task<bool> ShouldAbort(Exception exception, string sessionId);
    }
}