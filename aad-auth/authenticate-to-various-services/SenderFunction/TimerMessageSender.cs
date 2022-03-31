using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace SenderFunction
{
    public class TimerMessageSender
    {
        [FunctionName("TimerMessageSender")]
        [return: ServiceBus("queue1", Connection = "ServiceBusConnectionString")]
        public string Run([TimerTrigger("*/1 * * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
            return $"This message was sent at: {DateTime.Now}";
        }
    }
}
