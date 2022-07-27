using System;
using System.Threading.Tasks;

using Azure.Messaging.ServiceBus;

using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;

using Shared;

namespace FunctionApp
{
    public class Function1
    {
        private ICircuitBreaker _circuitBreaker;

        public Function1(ICircuitBreaker circuitBreaker)
        {
            this._circuitBreaker = circuitBreaker;
        }

        [FunctionName("Function1")]
        public async Task RunAsync([ServiceBusTrigger("testqueue", Connection = "ServiceBusConnectionString", IsSessionsEnabled =true)]
            ServiceBusReceivedMessage message,
            ServiceBusSessionMessageActions sessionActions,
            ILogger log)
        {
            try
            {
                //something goes wrong during processing
                throw new Exception();
            }
            catch(Exception ex)
            {
                //check with circuit breaker if we should stop processing
                //this can be any logic that you application requires
                if(await this._circuitBreaker.ShouldAbort(ex, message.SessionId))
                {
                    log.LogInformation($"Stopping processing of session {message.SessionId}");
                    //Need to stop processing this session
                    try
                    {
                        MySessionState state = new()
                        {
                            DateTime = DateTime.UtcNow,
                            NextRetryUTC = DateTime.UtcNow.AddMinutes(1),
                            IsCircuitOpen = true,
                            Message = "There was an exception and we are stopping processing"
                        };
                        //Set a marker that we shouldn't keep processing this message
                        await sessionActions.SetSessionStateAsync(BinaryData.FromObjectAsJson(state));
                        
                        //Put the current message back in the queue (you can also 
                        await sessionActions.AbandonMessageAsync(message);
                        //Or complete the message before releasing the session.
                        //await sessionActions.CompleteMessageAsync(message);
                    }
                    finally
                    {
                        sessionActions.ReleaseSession();
                    }
                }
            }
        }
    }
}
