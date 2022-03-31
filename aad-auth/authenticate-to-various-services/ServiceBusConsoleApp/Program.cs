// See https://aka.ms/new-console-template for more information
using System.Runtime.InteropServices;

using Azure.Identity;
using Azure.Messaging.ServiceBus;

Console.WriteLine("Hello, World!");

string sbNamespace = "sb-4ogmj5slfs42a.servicebus.windows.net";
string sbQueueName = "queue1";

ServiceBusClient? sbClient = new ServiceBusClient(sbNamespace, new DefaultAzureCredential());

ServiceBusSender? sender = sbClient.CreateSender(sbQueueName);

while (true)
{
   

    string messageText = $"Hello from the console app, the time at the tone is: {DateTime.Now}";
    ServiceBusMessage? message = new ServiceBusMessage(messageText);

    await sender.SendMessageAsync(message);

    Console.WriteLine(messageText);

    await Task.Delay(TimeSpan.FromSeconds(1));
}