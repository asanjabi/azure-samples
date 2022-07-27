using Azure.Identity;
using Azure.Messaging.ServiceBus;

using Microsoft.Extensions.Configuration;

namespace MessageSender;

internal class Program
{
    static void Main(string[] args)
    {
        var builder = new ConfigurationBuilder();
        builder.AddJsonFile("appsettings.json", false);
        var config = builder.Build();

        Options options = new();
        config.Bind(options);

        Task.Run(() => SendMessages(options));

        Console.WriteLine("Press enter to stop:");
        Console.ReadLine();
    }

    private static async Task SendMessages(Options options)
    {
        ServiceBusClient? sbClient = new ServiceBusClient(options.ServiceBusNamespace, new DefaultAzureCredential());
        ServiceBusSender? sender = sbClient.CreateSender(options.QueueName);
        int batchId = 0;

        while (true)
        {
            List<MessageBatch> batches = new List<MessageBatch>();
            batchId++;

            for (int i = 0; i < options.Sessions; i++)
            {
                var sessionId = $"session-{i}";
                batches.Add(new MessageBatch(sender, sessionId, batchId, options.BatchSize));
            }

            List<Task> tasks = new List<Task>();
            foreach (var batch in batches)
            {
                tasks.Add(batch.Run());
            }

            Task.WaitAll(tasks.ToArray());
            tasks.Clear();
            batches.Clear();
            Console.WriteLine($"{batchId} batches sent");
            await Task.Delay(TimeSpan.FromSeconds(options.Pause));
        }
    }
}

