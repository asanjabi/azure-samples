using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Azure.Messaging.ServiceBus;

namespace MessageSender;
internal class MessageBatch
{
    private readonly ServiceBusSender sender;
    private readonly string sessionId;
    private readonly int batchId;
    private readonly int messageCount;

    public MessageBatch(ServiceBusSender sender, string sessionId, int batchId, int messageCount)
    {
        this.sender = sender;
        this.sessionId = sessionId;
        this.batchId = batchId;
        this.messageCount = messageCount;
    }

    public async Task Run()
    {
        await Task.Delay(TimeSpan.FromSeconds(1));

        int messageId = 0;

        for (int i = 0; i < messageCount; i++)
        {
            messageId++;
            var message = new ServiceBusMessage($"{sessionId}-{batchId}-{messageId}");
            message.SessionId = sessionId;

            await sender.SendMessageAsync(message);
        }
    }

    private IEnumerable<ServiceBusMessage> GetMessages()
    {
        int messageId = 0;

        for (int i = 0; i < messageCount; i++)
        {
            messageId++;
            var message = new ServiceBusMessage($"{batchId} - {messageId}");
            message.SessionId = sessionId;

            yield return message;
        }
    }
}
