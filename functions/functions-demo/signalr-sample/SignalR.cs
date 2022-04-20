using System;
using System.IO;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.SignalRService;

namespace signalrSample;

public static class Function
{
    private const string HubName = "serverless";

    [FunctionName("index")]
    public static IActionResult GetHomePage([HttpTrigger(AuthorizationLevel.Anonymous)] HttpRequest req, ExecutionContext context)
    {
        var path = Path.Combine(context.FunctionAppDirectory, "content", "index.html");
        return new ContentResult
        {
            Content = File.ReadAllText(path),
            ContentType = "text/html",
        };
    }

    [FunctionName("negotiate")]
    public static SignalRConnectionInfo Negotiate(
        [HttpTrigger(AuthorizationLevel.Anonymous)] HttpRequest req,
        [SignalRConnectionInfo(HubName = HubName)] SignalRConnectionInfo connectionInfo)
    {
        return connectionInfo;
    }

    [FunctionName("broadcast")]
    public static async Task Broadcast([TimerTrigger("*/5 * * * * *")] TimerInfo myTimer,
    [SignalR(HubName = HubName)] IAsyncCollector<SignalRMessage> signalRMessages)
    {
        await signalRMessages.AddAsync(
            new SignalRMessage
            {
                Target = "Broadcast",
                Arguments = new[] { $"At the tone local time is: {DateTime.Now.ToLongTimeString()}" }
            });
    }

    [FunctionName("SendDirectMessage")]
    public static async Task SendDirectMessage(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "time")] HttpRequest req,
        [SignalR(HubName = HubName)] IAsyncCollector<SignalRMessage> signalRMessages)
    {
        string connectionId = String.Empty;
        using (StreamReader streamReader = new StreamReader(req.Body))
        {
            connectionId = await streamReader.ReadToEndAsync();
        }

        await signalRMessages.AddAsync(
            new SignalRMessage
            {
                ConnectionId = connectionId,
                Target = "Direct",
                Arguments = new[] { $"At the tone local time is: {DateTime.Now.ToLongTimeString()}" }
            });
    }
}
