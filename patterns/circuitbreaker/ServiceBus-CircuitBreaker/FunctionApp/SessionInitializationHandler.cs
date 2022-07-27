using System;
using System.Threading.Tasks;

using Azure.Messaging.ServiceBus;

using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

using Shared;

namespace FunctionApp;
internal class SessionInitializationHandler
{
    public ICircuitBreaker _circuitBreaker;
    public ILogger _logger;

    public SessionInitializationHandler(ICircuitBreaker circuitBreaker, ILogger<SessionInitializationHandler> logger)
    {
        this._circuitBreaker = circuitBreaker ?? throw new ArgumentNullException(nameof(circuitBreaker));
        this._logger = logger;
    }

    public async Task SessionInitializing(ProcessSessionEventArgs args)
    {
        BinaryData sessionStateBinary = await args.GetSessionStateAsync();

        if (sessionStateBinary == null)
        {//No state, assume circuit is open and move on.
            return;
        }

        try
        {
            MySessionState sessionState = sessionStateBinary.ToObjectFromJson<MySessionState>();

            if (sessionState.IsCircuitOpen)
            {
                this._logger.LogInformation($"Circuit for session {args.SessionId} is open since {sessionState.DateTime} because of {sessionState.Message}, stopping processing");

                if (sessionState.NextRetryUTC < DateTime.UtcNow)
                {
                    //Check if we can resume it
                    if (await this._circuitBreaker.CanResume(args.SessionId))
                    {
                        this._logger.LogInformation($"Session {args.SessionId} was cleared for take off");

                        //Either clear the session state or mark it as closed
                        await args.SetSessionStateAsync(null);

                        //Allow processing of messages
                        return;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            this._logger.LogError(ex, "Error while parsing session state");
            //Depending on the situation decide weather to continue or abort.
            return; //Didn't understand the state, so continue processing
        }

        try
        {
            this._logger.LogInformation($"Session {args.SessionId} has an open circuit and can't continue");

            //Hold up this session for a bit so it doesn't come back right away if we don't have any other sessions to process
            await args.RenewSessionLockAsync();
            await Task.Delay(TimeSpan.FromSeconds(30));
        }
        finally
        {
            //Release the session to stop processing.
            args.ReleaseSession();
        }
    }
}
