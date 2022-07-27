
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

using Shared;

[assembly: FunctionsStartup(typeof(FunctionApp.Startup))]

namespace FunctionApp;
internal class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        builder.Services.AddSingleton<ICircuitBreaker, TestCircuitBreaker<FunctionApp.Startup>>();
        builder.Services.AddSingleton<SessionInitializationHandler>();

        builder.Services.AddOptions<ServiceBusOptions>()
         .Configure<SessionInitializationHandler>((options, sessionInitHandler) =>
         {
             options.SessionInitializingAsync = sessionInitHandler.SessionInitializing;
             options.MaxMessageBatchSize = 1;
             options.MaxConcurrentCalls = 1;
         });
    }
}
