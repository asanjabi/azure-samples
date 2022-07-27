using Azure.Identity;
using Azure.Messaging.ServiceBus;

using Microsoft.Extensions.Configuration;

namespace MessageReceiver;

internal class Program
{
    static void Main(string[] args)
    {
        var builder = new ConfigurationBuilder();
        builder.AddJsonFile("appsettings.json", false);
        var config = builder.Build();

        Options options = new();
        config.Bind(options);

        ServiceBusClient? sbClient = new ServiceBusClient(options.ServiceBusNamespace, new DefaultAzureCredential());

        //Create a session processor
        var sessionProcessorOptions = new ServiceBusSessionProcessorOptions();

        //This needs to be 1 if the order of messages matters
        sessionProcessorOptions.PrefetchCount = 10;
        sessionProcessorOptions.MaxConcurrentSessions = options.MaxConcurrentSessions;
        sessionProcessorOptions.MaxAutoLockRenewalDuration = TimeSpan.FromSeconds(options.MaxAutoRenewalDurationSeconds);
        var processor = sbClient.CreateSessionProcessor(options.QueueName, sessionProcessorOptions);


        //subscribe for events
        processor.SessionInitializingAsync += Processor_SessionInitializingAsync;
        processor.ProcessMessageAsync += Processor_ProcessMessageAsync;

        processor.ProcessErrorAsync += Processor_ProcessErrorAsync;
        processor.SessionClosingAsync += Processor_SessionClosingAsync;

        var processorTask = processor.StartProcessingAsync();

        Console.WriteLine("Press enter to exit");
        Console.ReadLine();
    }

    private static Task Processor_SessionInitializingAsync(ProcessSessionEventArgs arg)
    {
        Console.WriteLine($"session initializing {arg.SessionId}");
        return Task.CompletedTask;
    }

    private static async Task Processor_ProcessMessageAsync(ProcessSessionMessageEventArgs arg)
    {
        var message = arg.Message;
        Console.WriteLine(DisplayMessage(message));

        if(message.SessionId == "session-2")
        {
            bool abandon = false;
            if(abandon)
            {
                //await arg.AbandonMessageAsync(message);
                await arg.CompleteMessageAsync(message);
                arg.ReleaseSession();
            }
        }
    }

    private static Task Processor_ProcessErrorAsync(ProcessErrorEventArgs arg)
    {
        Console.WriteLine($"ERROR: {arg.ErrorSource} -- {arg.EntityPath}");
        return Task.CompletedTask;
    }

    private static Task Processor_SessionClosingAsync(ProcessSessionEventArgs arg)
    {
        Console.WriteLine($"Session closing {arg.SessionId}");
        return Task.CompletedTask;
    }

    private static string DisplayMessage(ServiceBusReceivedMessage message)
    {
        return $"id:{message.MessageId} dc:{message.DeliveryCount} sid:{message.SessionId} body: {message.Body?.ToString()}";
    }
}
